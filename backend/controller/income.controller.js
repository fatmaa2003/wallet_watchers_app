const IncomeService = require("../services/income.service");

const getIncome = async (req, res) => {
  console.log("getting income");
  const { userId } = req.query;
  const income = await IncomeService.getIncome(userId);
  res.status(200).json(income);
};

const postIncome = async (req, res) => {
  console.log("in post income controller ");
  const { userId, incomeName, incomeAmount, date } = req.body;
  console.log("post income", userId, incomeName, incomeAmount, date);
  if (!userId || !incomeName || !incomeAmount) {
    return res.status(400).json({ error: "Missing required fields" });
  }
  const income = await IncomeService.postIncome({
    userId,
    incomeName,
    incomeAmount,
    date: date ? new Date(date) : new Date(),
  });
  res.status(201).json(income);
};

const updateIncome = async (req, res) => {
  console.log("in update income controller");
  const { userId, incomeName, incomeAmount } = req.body;
  console.log("update income", userId, incomeName, incomeAmount);
  
  if (!userId || !incomeName || !incomeAmount) {
    return res.status(400).json({ error: "Missing required fields" });
  }
  
  const updated = await IncomeService.updateIncome(userId, incomeName, incomeAmount);
  if (!updated) {
    return res.status(404).json({ error: "Income not found" });
  }
  
  res.status(200).json(updated);
};

const deleteIncome = async (req, res) => {
  console.log("in delete income controller");
  const { userId, incomeName } = req.query;
  console.log("delete income", userId, incomeName);
  
  if (!userId || !incomeName) {
    return res.status(400).json({ error: "userId and incomeName are required" });
  }
  
  const deleted = await IncomeService.deleteIncome(userId, incomeName);
  if (!deleted) {
    return res.status(404).json({ error: "Income not found" });
  }
  
  res.status(200).json({ message: "Income deleted successfully" });
};

module.exports = {
  getIncome,
  postIncome,
  updateIncome,
  deleteIncome,
};
