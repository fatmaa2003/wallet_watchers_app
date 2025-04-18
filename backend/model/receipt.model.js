const mongoose = require('mongoose');
const { Schema } = mongoose;

const receiptSchema = new Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    text: {
      type: String,
      required: true,
    },
    timestamp: {
      type: Date,
      default: Date.now,
    },
  },
  { timestamps: true }
);

const Receipt = mongoose.model('Receipt', receiptSchema);
module.exports = Receipt;