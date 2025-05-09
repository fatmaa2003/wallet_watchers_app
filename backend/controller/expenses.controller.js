const ExpensesService = require("../services/expenses.service");

const postAllExpenses = async (req, res) => {
    console.log("fetching expenses for user");
    const userId = req.body.userId ;
  
    if (!userId) {
      return res.status(400).json({ error: "userId is required" });
    }
  
    const expenses = await ExpensesService.postAllExpenses(userId);
    res.status(200).json(expenses);
  };

const postExpenses = async (req, res) => {
  const { expenseAmount, categoryName } = req.body;
  console.log("post expenses", expenseAmount, categoryName);
  if (!expenseAmount || !categoryName) {
    return res.status(400).json({ error: "Missing required fields" });
  }

  const expense = await ExpensesService.postExpenses({
    expenseAmount,
    categoryName,
  });
  res.status(201).json(expense);
};

module.exports = { postAllExpenses, postExpenses };
