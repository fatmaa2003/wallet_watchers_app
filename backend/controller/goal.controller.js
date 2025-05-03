const goalService = require('../services/goal.service');

const createGoal = async (req, res) => {
  try {
    const goal = await goalService.createGoal(req.body);
    res.status(201).json(goal);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

const getGoals = async (req, res) => {
  try {
    const goals = await goalService.getGoalsByUser(req.params.userId);
    res.status(200).json(goals);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

const updateGoal = async (req, res) => {
  try {
    const updated = await goalService.updateGoal(req.params.id, req.body);
    res.status(200).json(updated);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

const deleteGoal = async (req, res) => {
  try {
    await goalService.deleteGoal(req.params.id);
    res.status(200).json({ message: 'Goal deleted' });
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

module.exports = {
  createGoal,
  getGoals,
  updateGoal,
  deleteGoal
};