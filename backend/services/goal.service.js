const Goal = require('../model/goal.model');

const createGoal = async (goalData) => await Goal.create(goalData);
const getGoalsByUser = async (userId) => await Goal.find({ userId });
const updateGoal = async (id, data) => await Goal.findByIdAndUpdate(id, data, { new: true });
const deleteGoal = async (id) => await Goal.findByIdAndDelete(id);

module.exports = {
  createGoal,
  getGoalsByUser,
  updateGoal,
  deleteGoal
};