const ExpensesRepository = require("../repository/expenses.repository");

const postAllExpenses = async (userId) => {
  const expenses = await ExpensesRepository.postAllExpenses(userId);
  return expenses;
};

const postExpenses = async ({ userId, expenseAmount, categoryName }) => {


  console.log("in expenses service",expenseAmount, categoryName);

 if (!userId || !expenseAmount || !categoryName) {
    console.error(" Missing required fields in service");
    return null;
  }

  const expenses = await ExpensesRepository.postExpenses({
    userId,
    expenseAmount,
    categoryName,
  });

  return expenses;
};

module.exports = {
  postAllExpenses,
  postExpenses,
};
