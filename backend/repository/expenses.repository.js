const Expenses =
  require("../model/expenses.model").default ||
  require("../model/expenses.model");
const Categories = require("../model/categories.model");
const User = require("../model/user.model");

const postAllExpenses = async (userId) => {
  try {
    if (!userId) {
      console.log("userId not provided");
      return [];
    }

    const expenses = await Expenses.find({ userId }); 
    return expenses;
  } catch (err) {
    console.log("error in postAllExpenses:", err);
    return [];
  }
};

const postExpenses = async ({ expenseAmount, categoryName }) => {
  try {
    // const { expenseAmount, categoryName } = req.body;

    console.log("in repo post expense", expenseAmount, categoryName);
    console.log(Categories);
    const category = await Categories.find();
    console.log(category);
    if (!category) {
      return console.log("category not found");
    }

    const newExpense = new Expenses({
      categoryName,
      expenseAmount,
    });

    await newExpense.save();
    return newExpense;
  } catch (err) {
    console.log("err", err);
  }
};

module.exports = {
  postAllExpenses,
  postExpenses,
};
