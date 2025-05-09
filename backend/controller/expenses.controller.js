const ExpensesService = require("../services/expenses.service");

const postAllExpenses = async (req, res) => {
  console.log("fetching expenses for user");
  const userId = req.body.userId;

  if (!userId) {
    return res.status(400).json({ error: "userId is required" });
  }

  const expenses = await ExpensesService.postAllExpenses(userId);
  res.status(200).json(expenses);
};

const postExpenses = async (req, res) => {
  const { userId, expenseAmount, categoryName } = req.body;

  console.log(
    "in controller post expenses",
    userId,
    expenseAmount,
    categoryName
  );

  if (!userId || !expenseAmount || !categoryName) {
    return res.status(400).json({ error: "Missing required fields" });
  }

  const expense = await ExpensesService.postExpenses({
    userId,
    expenseAmount,
    categoryName,
  });

  res.status(201).json(expense);
};

module.exports = { postAllExpenses, postExpenses };
