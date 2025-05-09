const ExpensesRepository = require("../repository/expenses.repository");

const postAllExpenses = async (userId) => {
    const expenses = await ExpensesRepository.postAllExpenses(userId);
    return expenses;
  }

const postExpenses = async (expenseAmount, categoryName) => {
  console.log(expenseAmount, categoryName);
  const expenses = await ExpensesRepository.postExpenses(
    expenseAmount,
    categoryName
  );
  return expenses;
};

module.exports = {
  postAllExpenses,
  postExpenses,
};
