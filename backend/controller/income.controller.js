const IncomeService = require("../services/income.service");

const getIncome = async (req, res) => {
  console.log("getting income");
  const { userId } = req.query;
  const income = await IncomeService.getIncome(userId);
  res.status(200).json(income);
};

const postIncome = async (req, res) => {
  console.log("in post income controller ");
  const { userId, incomeName, incomeAmount } = req.body;
  console.log("post income", userId, incomeName, incomeAmount);
  if (!userId || !incomeName || !incomeAmount) {
    return res.status(400).json({ error: "Missing required fields" });
  }
  const income = await IncomeService.postIncome({
    userId,
    incomeName,
    incomeAmount,
  });
  res.status(201).json(income);
};

module.exports = {
  getIncome,
  postIncome,
};
