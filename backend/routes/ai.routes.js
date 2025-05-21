const express = require("express");
const router = express.Router();
const aiService = require("../services/ai.service");

// Generate Budget
router.post("/generateBudget", async (req, res) => {
  const { userId } = req.body;

  try {
    const result = await aiService.generateAIBudget(userId);
    res.status(200).json(result);
  } catch (err) {
    console.error("❌ Error generating budget:", err.message);
    res.status(500).json({ error: "AI budget prediction failed" });
  }
});

// Deduct Expense
router.post("/deductExpense", async (req, res) => {
  const { userId, categoryName, expenseAmount } = req.body;

  try {
    const updatedBudget = await aiService.deductExpenseFromAIBudget({ userId, categoryName, expenseAmount });
    res.status(200).json({
      message: "✅ Expense deducted from AI budget",
      updatedBudget,
    });
  } catch (err) {
    console.error("❌ Error deducting expense:", err.message);
    res.status(500).json({ error: err.message });
  }
});

// Get all budgets for a user
router.get("/budgets/:userId", async (req, res) => {
  try {
    const { userId } = req.params;
    const budgets = await aiService.getAllBudgetsForUser(userId);
    res.status(200).json(budgets);
  } catch (err) {
    console.error("❌ Error fetching budgets:", err.message);
    res.status(500).json({ error: "Failed to fetch budgets" });
  }
});

module.exports = router;
