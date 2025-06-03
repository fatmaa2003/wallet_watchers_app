const service = require("../services/collaborativeGoal.service");

exports.createGoal = async (req, res) => {
  try {
    const goal = await service.createGoal(req.body);
    res.status(201).json(goal);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
};

exports.getGoals = async (req, res) => {
  try {
    const goals = await service.getUserGoals(req.params.userId);
    res.status(200).json(goals);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
};

exports.updateContribution = async (req, res) => {
  try {
    const { goalId, userId, amount } = req.body;
    await service.updateContribution(goalId, userId, amount);
    res.status(200).json({ message: "Updated" });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
};

exports.addFriend = async (req, res) => {
  try {
    const { goalId, email } = req.body;
    await service.inviteFriendByEmail(goalId, email);
    res.status(200).json({ message: "Friend invited" });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
};

exports.deleteGoal = async (req, res) => {
  try {
    await service.deleteGoal(req.params.goalId);
    res.status(200).json({ message: "Goal deleted" });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
};

exports.removeFriend = async (req, res) => {
  try {
    const { goalId, userId } = req.body;
    await service.removeParticipant(goalId, userId);
    res.status(200).json({ message: "Friend removed" });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
};

exports.respondInvite = async (req, res) => {
  try {
    const { goalId, userId, status } = req.body;
    await service.updateInviteStatus(goalId, userId, status);
    res.status(200).json({ message: `Invite ${status}` });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
};

exports.leaveGoal = async (req, res) => {
  try {
    const { goalId, userId } = req.body;
    await service.leaveGoal(goalId, userId);
    res.status(200).json({ message: "Left goal" });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
};

exports.getInvitations = async (req, res) => {
  try {
    const invites = await service.getPendingInvites(req.params.userId);
    res.status(200).json(invites);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
};
