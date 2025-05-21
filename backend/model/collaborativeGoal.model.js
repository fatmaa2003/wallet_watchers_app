const mongoose = require("mongoose");
const { Schema } = mongoose;

const participantSchema = new Schema({
  userId: { type: Schema.Types.ObjectId, ref: "User", required: true },
  savedAmount: { type: Number, default: 0 },
  status: { type: String, enum: ["pending", "accepted", "rejected"], default: "pending" },
});

const collaborativeGoalSchema = new Schema({
  title: { type: String, required: true },
  totalTargetPerUser: { type: Number, required: true },
  createdBy: { type: Schema.Types.ObjectId, ref: "User", required: true },
  participants: [participantSchema],
}, { timestamps: true });

module.exports = mongoose.model("CollaborativeGoal", collaborativeGoalSchema);