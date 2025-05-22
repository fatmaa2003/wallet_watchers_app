const CollaborativeGoal = require("../model/collaborativeGoal.model");
const User = require("../model/user.model");

// Create a new collaborative goal
exports.createGoal = async (data) => CollaborativeGoal.create(data);

// Get only accepted goals for a user
exports.getGoalsByUserId = async (userId) =>
  CollaborativeGoal.find({
    "participants.userId": userId,
    "participants.status": "accepted",
  }).populate("participants.userId", "firstName lastName email");

// Update a participant's contribution amount
exports.updateParticipantAmount = async (goalId, userId, amount) =>
  CollaborativeGoal.updateOne(
    { _id: goalId, "participants.userId": userId },
    { $set: { "participants.$.savedAmount": amount } }
  );

// Add a friend to a goal by email (invite only if not already invited or joined)
exports.addParticipantByEmail = async (goalId, email) => {
  const user = await User.findOne({ email });
  if (!user) throw new Error("User not found");

  const existingGoal = await CollaborativeGoal.findOne({
    _id: goalId,
    participants: { $elemMatch: { userId: user._id } },
  });
  if (existingGoal) throw new Error("User already invited or joined");

  return CollaborativeGoal.updateOne(
    { _id: goalId },
    {
      $addToSet: {
        participants: {
          userId: user._id,
          savedAmount: 0,
          status: "pending",
        },
      },
    }
  );
};

// Delete a goal by ID
exports.deleteGoalById = async (goalId) =>
  CollaborativeGoal.findByIdAndDelete(goalId);

// Remove a participant (used for both remove friend and leave goal)
exports.removeParticipant = async (goalId, userId) =>
  CollaborativeGoal.updateOne(
    { _id: goalId },
    { $pull: { participants: { userId } } }
  );

// Update a user's invite status (accept/reject)
exports.updateParticipantStatus = async (goalId, userId, status) =>
  CollaborativeGoal.updateOne(
    { _id: goalId, "participants.userId": userId },
    { $set: { "participants.$.status": status } }
  );

// Get all pending invitations for a user
exports.getPendingInvites = async (userId) =>
  CollaborativeGoal.find({
    participants: { $elemMatch: { userId, status: "pending" } },
  }).populate("participants.userId", "firstName lastName");
