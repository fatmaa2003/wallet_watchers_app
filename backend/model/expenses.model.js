const mongoose = require("mongoose");
const User = require("../model/user.model");


const { Schema } = mongoose;

const expensesSchema = new Schema(
  {
    expenseName: {
      type: String,
      required: true,
      Uint16Array,
    },
    expenseAmount: {
      type: Number,
      default: 0,
      required: true,
    },
    categoryName: {
      type: String,
      ref: "categories",
    },
    userId: {
      type: Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },
  },
  { timestamps: true }
);

const expensesModel = mongoose.model("expenses", expensesSchema);

module.exports = expensesModel;
