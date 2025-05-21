const ExpensesRepository = require("../repository/expenses.repository");
const axios = require("axios");

// Post all expenses for user (bulk insert or fetch)
const postAllExpenses = async (userId) => {
  const expenses = await ExpensesRepository.postAllExpenses(userId);
  return expenses;
};

// Post single expense and deduct from AI-predicted budget
const postExpenses = async ({ userId, expenseName, expenseAmount, categoryName }) => {
  console.log("In expenses service:", { expenseName, expenseAmount, categoryName });

  if (!userId || !expenseName || !expenseAmount || !categoryName) {
    console.error("Missing required fields in service");
    return null;
  }

  // Step 1: Save the expense to DB
  const expense = await ExpensesRepository.postExpenses({
    userId,
    expenseName,
    expenseAmount,
    categoryName,
  });

  // Step 2: Deduct it from AI-predicted budget
  try {
    const response = await axios.post("http://localhost:3000/api/ai/deductExpense", {
      userId,
      categoryName,
      expenseAmount,
    });

    if (response.status === 200) {
      console.log("Expense deducted from AI budget successfully");
    } else {
      console.warn("Deduct API call succeeded but returned:", response.data);
    }
  } catch (err) {
    console.error("Failed to deduct from AI budget:", err.message);
  }

  return expense;
};

// Get expenses by date
const getExpensesByDate = async (userId, date) => {
  if (!userId || !date) {
    console.error("Missing required fields in getExpensesByDate");
    return null;
  }

  const expenses = await ExpensesRepository.getExpensesByDate(userId, date);
  return expenses;
};

// Delete expense
const deleteExpense = async (userId, expenseName) => {
  if (!userId || !expenseName) {
    console.error("Missing required fields in deleteExpense service");
    return null;
  }

  const deletedExpense = await ExpensesRepository.deleteExpense(userId, expenseName);
  return deletedExpense;
};

module.exports = {
  postAllExpenses,
  postExpenses,
  getExpensesByDate,
  deleteExpense,
};
