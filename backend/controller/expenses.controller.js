const ExpensesService = require("../services/expenses.service");

const postAllExpenses = async (req, res) => {
  console.log("fetching expenses for user");
  const userId = req.body.userId;

  if (!userId) {
    return res.status(400).json({ error: "userId is required" });
  }

  const expenses = await ExpensesService.postAllExpenses(userId);
  res.status(200).json(expenses);
};

const postExpenses = async (req, res) => {
  const { userId, expenseAmount, categoryName } = req.body;

  console.log(
    "in controller post expenses",
    userId,
    expenseAmount,
    categoryName
  );

  if (!userId || !expenseAmount || !categoryName) {
    return res.status(400).json({ error: "Missing required fields" });
  }

  const expense = await ExpensesService.postExpenses({
    userId,
    expenseAmount,
    categoryName,
  });

  res.status(201).json(expense);
};

const getExpensesByDate = async ( req, res)=>{
  const {userId , date }= req.query;
  console.log("in controller get expenses by date", userId, date);
  if (!userId || !date) {
    return res.status(400).json({ error: "Missing required fields in expenses controller" });
  }
  const expenses = await ExpensesService.getExpensesByDate(userId, date);
  return res.status(200).json(expenses);
}


module.exports = { postAllExpenses, postExpenses, getExpensesByDate };

