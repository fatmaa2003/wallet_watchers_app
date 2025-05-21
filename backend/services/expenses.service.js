const ExpensesRepository = require("../repository/expenses.repository");

const postAllExpenses = async (userId) => {
  const expenses = await ExpensesRepository.postAllExpenses(userId);
  return expenses;
};

const postExpenses = async ({ userId, expenseName, expenseAmount, categoryName }) => {


  console.log("in expenses service",expenseName, expenseAmount, categoryName);

 if (!userId ||!expenseName || !expenseAmount || !categoryName) {
    console.error(" Missing required fields in service");
    return null;
  }

  const expenses = await ExpensesRepository.postExpenses({
    userId,
    expenseName,
    expenseAmount,
    categoryName,
  });

  return expenses;
};

const getExpensesByDate = async (userId , date)=>{
  if (!userId || !date) {
    console.error(" Missing required fields in service");
    return null;
  }

  const expenses = await ExpensesRepository.getExpensesByDate(userId, date);
  return expenses;
}

module.exports = {
  postAllExpenses,
  postExpenses,
  getExpensesByDate,

};

