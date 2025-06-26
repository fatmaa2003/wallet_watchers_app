const IncomeRepoistory = require("../repository/income.repository");

const getIncome = async (userId) => {
  console.log(" in service get income", userId);
  const incomeInfo = await IncomeRepoistory.getIncome(userId);
  return incomeInfo;
};

const postIncome = async ({ userId, incomeName, incomeAmount, date }) => {
  console.log("in service post income", userId, incomeName, incomeAmount, date);
  const incomeInfo = await IncomeRepoistory.postIncome({
    userId,
    incomeName,
    incomeAmount,
    date,
  });
  return incomeInfo;
};

const updateIncome = async (userId, incomeName, incomeAmount) => {
  console.log("in service update income", userId, incomeName, incomeAmount);
  const updatedIncome = await IncomeRepoistory.updateIncome(userId, incomeName, incomeAmount);
  return updatedIncome;
};

const deleteIncome = async (userId, incomeName) => {
  console.log("in service delete income", userId, incomeName);
  const deletedIncome = await IncomeRepoistory.deleteIncome(userId, incomeName);
  return deletedIncome;
};

module.exports = {
  getIncome,
  postIncome,
  updateIncome,
  deleteIncome,
};
