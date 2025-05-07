const Income = require("../model/income.model");
const User = require("../model/user.model");

const postIncome = async ({ userId, incomeAmount, incomeName }) => {
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

module.exports = {
  postIncome,
  getIncome,
};
