const Income = require("../model/income.model");
const User = require("../model/user.model");

const postIncome = async ({ userId, incomeAmount, incomeName, date }) => {
  try {
    if (!userId) {
      console.log("userId not provided");
      return null;
    }

    const profile = await User.findById(userId);
    if (!profile) {
      console.log("User not found");
      return null;
    }

    const newIncome = new Income({
      userId,
      incomeName,
      incomeAmount,
      date: date || new Date(),
    });

    await newIncome.save();
    return newIncome;
  } catch (err) {
    console.log("Error in postIncome:", err);
    return null;
  }
};

const getIncome = async (userId) => {
  try {
    if (!userId) {
      console.log("userId not provided");
      return [];
    }

    const income = await Income.find({ userId });
    return income;
  } catch (err) {
    console.log("Error in getIncome:", err);
    return [];
  }
};

const updateIncome = async (userId, incomeName, incomeAmount) => {
  try {
    if (!userId || !incomeName) {
      console.log("userId or incomeName not provided");
      return null;
    }

    const updatedIncome = await Income.findOneAndUpdate(
      { userId: userId, incomeName: incomeName },
      { incomeAmount: incomeAmount },
      { new: true }
    );

    return updatedIncome;
  } catch (err) {
    console.log("Error in updateIncome:", err);
    return null;
  }
};

const deleteIncome = async (userId, incomeName) => {
  try {
    if (!userId || !incomeName) {
      console.log("userId or incomeName not provided");
      return null;
    }

    const deletedIncome = await Income.findOneAndDelete({
      userId: userId,
      incomeName: incomeName,
    });

    return deletedIncome;
  } catch (err) {
    console.log("Error in deleteIncome:", err);
    return null;
  }
};

module.exports = {
  postIncome,
  getIncome,
  updateIncome,
  deleteIncome,
};
