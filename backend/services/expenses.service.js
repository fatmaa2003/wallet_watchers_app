const ExpensesRepository = require("../repository/expenses.repository");
const axios = require("axios");

const postAllExpenses = async (userId) => {
  const expenses = await ExpensesRepository.postAllExpenses(userId);
  return expenses;
};

const postExpenses = async ({ userId, expenseAmount, categoryName }) => {
  console.log("in expenses service", expenseAmount, categoryName);

  if (!userId || !expenseAmount || !categoryName) {
    console.error("❌ Missing required fields in service");
    return null;
  }

  // Step 1: Save the expense to DB
  const expense = await ExpensesRepository.postExpenses({
    userId,
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
      console.log("✅ Expense deducted from AI budget successfully");
    } else {
      console.warn("⚠️ Deduct API call succeeded but returned:", response.data);
    }
  } catch (err) {
    console.error("❌ Failed to deduct from AI budget:", err.message);
  }

  return expense;
};

module.exports = {
  postAllExpenses,
  postExpenses,
};
