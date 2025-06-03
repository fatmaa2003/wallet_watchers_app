const CollaborativeGoal = require("../model/collaborativeGoal.model");
const User = require("../model/user.model");


exports.createGoal = async (data) => CollaborativeGoal.create(data);

exports.getGoalsByUserId = async (userId) =>
  CollaborativeGoal.find({
    participants: { $elemMatch: { userId, status: "accepted" } },
  }).populate("participants.userId", "firstName lastName email");

exports.updateParticipantAmount = async (goalId, userId, amount) =>
  CollaborativeGoal.updateOne(
    { _id: goalId, "participants.userId": userId },
    { $set: { "participants.$.savedAmount": amount } }
  );


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


exports.deleteGoalById = async (goalId) =>
  CollaborativeGoal.findByIdAndDelete(goalId);

exports.removeParticipant = async (goalId, userId) =>
  CollaborativeGoal.updateOne(
    { _id: goalId },
    { $pull: { participants: { userId } } }
  );

exports.updateParticipantStatus = async (goalId, userId, status) =>
  CollaborativeGoal.updateOne(
    { _id: goalId, "participants.userId": userId },
    { $set: { "participants.$.status": status } }
  );


exports.getPendingInvites = async (userId) =>
  CollaborativeGoal.find({
    participants: { $elemMatch: { userId, status: "pending" } },
  }).populate("participants.userId", "firstName lastName");
