const axios = require("axios");
const Budget = require("../model/budget.model");

const generateAIBudget = async (userId) => {
  const now = new Date();
  const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);

  // Check if budget already exists for this month
  const existing = await Budget.findOne({
    userId,
    createdAt: { $gte: startOfMonth },
  });

  if (existing) {
    return {
      message: "✅ Budget already generated for this month. Please wait for next month.",
      budget: existing,
    };
  }

  // Get budget prediction from AI model
  const response = await axios.post("http://localhost:8000/predict_budget", { userId });
  const budget = response.data;

  const normalizedByCategory = budget.byCategory.map(c => ({
    category: c.category.toLowerCase().trim(),
    amount: c.amount,
  }));

  const saved = await Budget.create({
    userId,
    total: budget.total,
    byCategory: normalizedByCategory,
    createdAt: new Date(),
  });

  return {
    message: "🎉 New budget generated successfully.",
    budget: saved,
  };
};

const deductExpenseFromAIBudget = async ({ userId, categoryName, expenseAmount }) => {
  const latestBudget = await Budget.findOne({ userId }).sort({ createdAt: -1 });
  if (!latestBudget) throw new Error("No budget found");

  const normalizedCategoryName = categoryName.toLowerCase().trim();

  const category = latestBudget.byCategory.find(
    cat => cat.category.toLowerCase().trim().includes(normalizedCategoryName)
  );

  if (!category) {
    throw new Error(`Category '${categoryName}' not found in budget.`);
  }

  category.amount = Math.max(0, category.amount - expenseAmount);
  await latestBudget.save();

  return latestBudget;
};

const getAllBudgetsForUser = async (userId) => {
  const budgets = await Budget.find({ userId }).sort({ createdAt: -1 });
  return budgets;
};

module.exports = {
  generateAIBudget,
  deductExpenseFromAIBudget,
  getAllBudgetsForUser,
};
