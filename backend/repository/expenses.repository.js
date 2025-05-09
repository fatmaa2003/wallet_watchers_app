const Expenses = require("../model/expenses.model");
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

const postExpenses = async ({ userId, expenseAmount, categoryName }) => {
  try {
    const user = await User.findById(userId);
    if (!user) {
      console.error("User not found");
      return null;
    }

    const category = await Categories.findOne({
      categoryName: new RegExp(`^${categoryName.trim()}$`, "i"),
    });

    if (!category) {
      console.error("Category not found");
      return null;
    }

    const newExpense = new Expenses({
      userId,
      expenseAmount,
      categoryName,
    });

    await newExpense.save();
    return newExpense;
  } catch (err) {
    console.error("Error in postExpenses (repository):", err);
    return null;
  }
};

// const postExpenses = async ({ userId, expenseAmount, categoryName }) => {
//   try {
//     // const { expenseAmount, categoryName } = req.body;
//     if (!userId) {
//       console.log("userId not provided");
//       return null;
//     }

//     const profile = await User.findById(userId);
//     if (!profile) {
//       console.log("User not found");
//       return null;
//     }
//     if (!expenseAmount || !categoryName) {
//       console.log("Missing required fields");
//       return null;
//     }
//     console.log("in repo post expense", expenseAmount, categoryName);
//     console.log(Categories);

//     const category = await Categories.findOne({ name: categoryName });
//     console.log(category);
//     if (!category) {
//       return console.log("category not found");
//     }

//     const newExpense = new Expenses({
//       userId,
//       categoryName,
//       expenseAmount,
//     });

//     await newExpense.save();
//     return newExpense;
//   } catch (err) {
//     console.log("err", err);
//   }
// };

module.exports = {
  postAllExpenses,
  postExpenses,
};