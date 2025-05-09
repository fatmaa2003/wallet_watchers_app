const IncomeRepoistory = require("../repository/income.repository");

const getIncome = async (userId) => {
  console.log(" in service get income", userId);
  const incomeInfo = await IncomeRepoistory.getIncome(userId);
  return incomeInfo;
};

const postIncome = async ({ userId, incomeName, incomeAmount }) => {
  console.log("in service post income", userId, incomeName, incomeAmount);
  const incomeInfo = await IncomeRepoistory.postIncome({
    userId,
    incomeName,
    incomeAmount,
  });
  return incomeInfo;
};

module.exports = {
  getIncome,
  postIncome,
};
