const express = require("express");
const router = express.Router();
const axios = require("axios");
const Budget = require("../model/budget.model");

// ✅ Generate AI Budget for the next month (prevent duplicates in same month)
router.post("/generateBudget", async (req, res) => {
  const { userId } = req.body;
  const now = new Date();
  const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);

  try {
    // Check for existing budget for this month
    const existing = await Budget.findOne({
      userId,
      createdAt: { $gte: startOfMonth },
    });

    if (existing) {
      return res.status(200).json({
        message: "✅ Budget already generated for this month. Please wait for next month.",
        budget: existing,
      });
    }

    // Call AI model to predict new budget
    const response = await axios.post("http://localhost:8000/predict_budget", { userId });
    const budget = response.data;

    // Normalize categories before saving
    const normalizedByCategory = budget.byCategory.map(c => ({
      category: c.category.toLowerCase().trim(),
      amount: c.amount
    }));

    // Save to DB
    const saved = await Budget.create({ userId, total: budget.total, byCategory: normalizedByCategory, createdAt: new Date() });

    res.status(200).json({
      message: "🎉 New budget generated successfully.",
      budget: saved,
    });
  } catch (err) {
    console.error("❌ Error generating budget:", err.message);
    res.status(500).json({ error: "AI budget prediction failed" });
  }
});

// ✅ Deduct an expense from the most recent AI-predicted budget (with fuzzy + case-insensitive matching)
router.post("/deductExpense", async (req, res) => {
  const { userId, categoryName, expenseAmount } = req.body;

  try {
    const latestBudget = await Budget.findOne({ userId }).sort({ createdAt: -1 });
    if (!latestBudget) return res.status(404).json({ error: "No budget found" });

    const normalizedCategoryName = categoryName.toLowerCase().trim();

    console.log("🧾 Looking for category:", normalizedCategoryName);
    console.log("🧾 Budget categories:", latestBudget.byCategory.map(c => c.category));

    const category = latestBudget.byCategory.find(
      cat => cat.category.toLowerCase().trim().includes(normalizedCategoryName)
    );

    if (!category) {
      return res.status(404).json({
        error: `Category '${categoryName}' not found in budget.`,
        availableCategories: latestBudget.byCategory.map(c => c.category),
      });
    }

    category.amount = Math.max(0, category.amount - expenseAmount); // Avoid negative values
    await latestBudget.save();

    res.status(200).json({
      message: "✅ Expense deducted from AI budget",
      updatedBudget: latestBudget,
    });
  } catch (err) {
    console.error("❌ Error deducting expense:", err.message);
    res.status(500).json({ error: "Failed to deduct expense" });
  }
});

// ✅ Get all saved budgets for a user
router.get("/budgets/:userId", async (req, res) => {
  try {
    const { userId } = req.params;
    const budgets = await Budget.find({ userId }).sort({ createdAt: -1 });
    res.status(200).json(budgets);
  } catch (err) {
    console.error("❌ Error fetching budgets:", err.message);
    res.status(500).json({ error: "Failed to fetch budgets" });
  }
});

module.exports = router;
