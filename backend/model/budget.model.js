const mongoose = require("mongoose");

const budgetSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, required: true },
  total: Number,
  byCategory: [{ category: String, amount: Number }],
  createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model("Budgets", budgetSchema);
