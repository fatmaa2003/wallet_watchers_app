const { model } = require("mongoose");

const Expenses = require("../model/expenses.model").default || require("../model/expenses.model");
const Categories = require("../model/categories.model");

const getAllExpenses = async () => {
  try {
    const expenses = await Expenses.find();
    return expenses;
  } catch (err) {
    console.log("error", err);
  }
};

const postExpenses = async ({expenseAmount , categoryName}) => {
  try {
    // const { expenseAmount, categoryName } = req.body;

    console.log("in repo post expense", expenseAmount , categoryName);
    console.log(Categories)
    const category = await Categories.find();
    console.log(category)
    if (!category) {
     
      return console.log("category not found")
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
  getAllExpenses,
  postExpenses,
};
