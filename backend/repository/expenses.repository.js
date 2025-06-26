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
const updateExpense = async (userId, expenseName, expenseAmount) => {
  try {
    const normalizedName = expenseName.trim().replace(/\s+/g, " ");
    const regex = new RegExp(`^${normalizedName}$`, "i");

    const updated = await Expenses.findOneAndUpdate(
      { userId, expenseName: regex },
      { expenseAmount },
      { new: true }
    );

    if (!updated) {
      console.log("No matching expense found");
      return null;
    }

    return updated;
  } catch (err) {
    console.error("Error in updateExpense (repo):", err);
    return null;
  }
};

const getExpensesByDate = async (userId, date) => {
  try {
    if (!userId || !date) {
      console.log("missing query params");
      return [];
    }

    const start = new Date(date + "T00:00:00.000Z");
    const end = new Date(date + "T23:59:59.999Z");

    const expenses = await Expenses.find({
      userId,
      createdAt: { $gte: start, $lte: end },
    });

    if (!expenses) {
      console.log("no expenses found by that date");
      return [];
    }
    return expenses;
  } catch (err) {
    console.log("found an erro in getExpensesByDateRepo", err);
  }
};
const deleteExpense = async (userId, expenseName) => {
  if (!userId || !expenseName) {
    console.log("missing query params");
    return [];
  }

  const normalizedExpenseName = expenseName.trim().replace(/\s+/g, " ");
  const regex = new RegExp(`^${normalizedExpenseName}$`, "i");

  const deletedExpense = await Expenses.findOneAndDelete({
    userId,
    expenseName: regex,
  });
  if (!deletedExpense) {
    console.log("no expenses found by that name");
    return [];
  }
  return deletedExpense;
};

const postExpenses = async ({
  userId,
  expenseName,
  expenseAmount,
  categoryName,
  isBank = false,
  bankName,
  cardNumber,
  accountNumber,
}) => {
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

    const expenseData = {
      userId,
      expenseName,
      expenseAmount,
      categoryName,
      isBank,
    };

    if (isBank) {
      expenseData.bankName = bankName;
      expenseData.cardNumber = cardNumber;
      expenseData.accountNumber = accountNumber;
    }

    const newExpense = new Expenses(expenseData);
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


const getCardExpenses = async (userId, cardNumber) => {
  try {
    if (!userId) {
      console.log("userId not provided");
      return [];
    }
    if (!cardNumber) {
      console.log("card number not provided");
      return [];
    }

    const expenses = await Expenses.find({
      userId: userId,
      cardNumber: cardNumber,
      isBank: true // filter only card/bank related
    }).select('expenseName categoryName expenseAmount bankName');

    return expenses;
  } catch (err) {
    console.error("Error in repository getCardExpenses:", err);
    return [];
  }
};

module.exports = {
  getCardExpenses,
  postAllExpenses,
  postExpenses,
  getExpensesByDate,
  deleteExpense,
  updateExpense,
};
