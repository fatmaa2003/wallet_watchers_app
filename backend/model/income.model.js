const mongoose = require("mongoose");
const Schema = mongoose.Schema;

const userModel = require("./user.model");

const incomeSchema = new Schema(
  {
    incomeAmount: {
      type: Number,
      default: 0,
      required: true,
    },
    incomeName: {
      type: String,
      required: true,
    },
    userId: {
      type: Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },
    date: {
      type: Date,
      default: Date.now,
    },
  },
  { timestamps: true }
);
const incomeModel = mongoose.model("income", incomeSchema);

module.exports = incomeModel;
