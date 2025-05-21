const repo = require("../repository/collaborativeGoal.repository");

exports.createGoal = async (data) => repo.createGoal(data);
exports.getUserGoals = async (userId) => repo.getGoalsByUserId(userId);
exports.updateContribution = async (goalId, userId, amount) => repo.updateParticipantAmount(goalId, userId, amount);
exports.inviteFriendByEmail = async (goalId, email) => repo.addParticipantByEmail(goalId, email);
exports.deleteGoal = async (goalId) => repo.deleteGoalById(goalId);
exports.removeParticipant = async (goalId, userId) => repo.removeParticipant(goalId, userId);
exports.updateInviteStatus = async (goalId, userId, status) => repo.updateParticipantStatus(goalId, userId, status);
exports.leaveGoal = async (goalId, userId) => repo.removeParticipant(goalId, userId);
exports.getPendingInvites = async (userId) => repo.getPendingInvites(userId);