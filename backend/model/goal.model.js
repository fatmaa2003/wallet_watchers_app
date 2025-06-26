const mongoose = require('mongoose');

const goalSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  title: { type: String, required: true },
  icon: { type: String, default: 'target' },
  targetAmount: { type: Number, required: true },
  savedAmount: { type: Number, default: 0 },
  isAchieved: { type: Boolean, default: false },
  targetDate: { type: Date },
}, { timestamps: true });

module.exports = mongoose.model('Goal', goalSchema);