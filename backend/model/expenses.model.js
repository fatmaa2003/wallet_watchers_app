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
    isBank: {
      type: Boolean,
      default: false,
    },
    bankName: {
      type: String,
      default: null,
    },
    cardNumber: {
      type: String,
      default: null,
      validate: {
        validator: function (v) {
          return /^\d{4}-\d{4}-\d{4}-\d{4}$/.test(v); // Regex to match 1234-5678-9876-5432
        },
        message: props => `${props.value} is not a valid card number format!`,
      },
      unique: true,
    },
    accontNumber: {
      type: Number,
      default: null,
    },
  },
  { timestamps: true }
);

const expensesModel = mongoose.model("expenses", expensesSchema);

module.exports = expensesModel;
