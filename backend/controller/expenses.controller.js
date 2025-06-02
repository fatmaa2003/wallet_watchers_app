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

const updateExpense = async (req, res) => {
  const { userId, expenseName, expenseAmount } = req.body;
  console.log(
    "In controller PATCH update:",
    userId,
    expenseName,
    expenseAmount
  );

  if (!userId || !expenseName || !expenseAmount) {
    return res
      .status(400)
      .json({ error: "userId, expenseName, and expenseAmount are required" });
  }

  const updated = await ExpensesService.updateExpense(
    userId,
    expenseName,
    expenseAmount
  );
  if (!updated) {
    return res.status(404).json({ error: "Expense not found" });
  }

  res.status(200).json(updated);
};

const deleteExpense = async (req, res) => {
  const { userId, expenseName } = req.query;
  console.log(" in expense controller delte expense ", expenseName);
  if (!expenseName) {
    return res.status(400).json({ error: "expenseName is required" });
  }
  const deletedExpense = await ExpensesService.deleteExpense(
    userId,
    expenseName
  );
  res.status(200).json(deletedExpense);
};

const postExpenses = async (req, res) => {
  const {
    userId,
    expenseName,
    expenseAmount,
    categoryName,
    isBank,
    bankName,
    cardNumber,
    accountNumber,
  } = req.body;

  console.log("in controller post expenses", userId, expenseName);

  if (!userId || !expenseName || !expenseAmount || !categoryName) {
    return res.status(400).json({ error: "Missing required fields" });
  }

  if (isBank === true && (!bankName || !cardNumber || !accountNumber)) {
    return res
      .status(400)
      .json({ error: "Missing bank details for bank transaction" });
  }
  const expense = await ExpensesService.postExpenses({
    userId,
    expenseName,
    expenseAmount,
    categoryName,
    isBank,
    bankName,
    cardNumber,
    accountNumber,
  });

  res.status(201).json(expense);
};

const getExpensesByDate = async (req, res) => {
  const { userId, date } = req.query;
  console.log("in controller get expenses by date", userId, date);
  if (!userId || !date) {
    return res
      .status(400)
      .json({ error: "Missing required fields in expenses controller" });
  }
  const expenses = await ExpensesService.getExpensesByDate(userId, date);
  return res.status(200).json(expenses);
};

module.exports = {
  postAllExpenses,
  postExpenses,
  getExpensesByDate,
  deleteExpense,
  updateExpense,
};
