const mongoose = require('mongoose');
const { Schema } = mongoose;

const cardsSchema = new Schema(
  {
    userId: {
      type: Schema.Types.ObjectId,
      ref: 'User',
      required: true
    },
    cardName: {
      type: String,
      required: true
    },
    cardNumber: {
      type: String,
      required: true,
      validate: {
        validator: function (v) {
          return /^\d{4}-\d{4}-\d{4}-\d{4}$/.test(v);
        },
        message: props => `${props.value} is not a valid card number format!`
      }
    },
    expiryDate: {
      type: Date,
      required: true,
      validate: {
        validator: function (v) {
          return v > new Date(); 
        },
        message: props => `Card is expired (${props.value.toDateString()})`
      }
    },
    cvv: {
      type: String,
      required: true,
      validate: {
        validator: function (v) {
          return /^\d{3}$/.test(v);
        },
        message: props => `${props.value} is not a valid CVV format!`
      }
    }
  },
  {
    timestamps: true 
  }
);

cardsSchema.index({ userId: 1, cardName: 1 }, { unique: true });

module.exports = mongoose.model('Cards', cardsSchema);