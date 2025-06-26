const ExpensesRepository = require("../repository/expenses.repository");

const postAllExpenses = async (userId) => {
  return await ExpensesRepository.postAllExpenses(userId);
};

const postExpenses = async ({ userId, expenseName, expenseAmount, categoryName,  isBank ,bankName, cardNumber, accountNumber  }) => {
  console.log("in expenses service", expenseName, expenseAmount, categoryName);

  if (!userId || !expenseName || !expenseAmount || !categoryName) {
    console.error("Missing required fields in service");
    return null;
  }

  if (isBank && (!bankName || !cardNumber || !accountNumber)) {
    console.error("Missing bank details in service");
    return null;
  }


  return await ExpensesRepository.postExpenses({
    userId,
    expenseName,
    expenseAmount,
    categoryName,
    isBank,
    bankName,
    cardNumber,
    accountNumber
  });
};

const updateExpense = async (userId, expenseName, expenseAmount) => {
  if (!userId || !expenseName || !expenseAmount) {
    console.error("Missing required fields in service");
    return null;
  }

  return await ExpensesRepository.updateExpense(userId, expenseName, expenseAmount);
};

const getExpensesByDate = async (userId, date) => {
  if (!userId || !date) {
    console.error("Missing required fields in service");
    return null;
  }

  return await ExpensesRepository.getExpensesByDate(userId, date);
};

const deleteExpense = async (userId, expenseName) => {
  if (!userId || !expenseName) {
    console.error("Missing required fields in service");
    return null;
  }

  return await ExpensesRepository.deleteExpense(userId, expenseName);
};

const getCardExpenses = async (userId, cardNumber) => {
  return await ExpensesRepository.getCardExpenses(userId, cardNumber);
};

module.exports = {
  getCardExpenses,
  postAllExpenses,
  postExpenses,
  getExpensesByDate,
  deleteExpense,
  updateExpense,
};
