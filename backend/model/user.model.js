const mongoose = require('mongoose');
const { Schema } = mongoose;

const userSchema = new Schema({
  firstName: {
    type: String,
    required: true,
  },
  lastName: {
    type: String,
    required: true,
  },
  email: {
    type: String,
    required: true,
    unique: true,
  },
  password: {
    type: String,
    required: true,
  },
  phoneNo: {
    type: Number,
    required: true,
  },


  // Optional: if user has a default category
  categoryId: {
    type: Schema.Types.ObjectId,
    ref: 'categories',
  },

  // Optional embedded expenses (use only if you don't use a separate Expenses collection)
  expenses: [
    {
      categoryId: { type: Schema.Types.ObjectId, ref: 'categories', required: true },
      categoryName: { type: String },
      amount: { type: Number, required: true },
      date: { type: Date, default: Date.now },
    },
  ],

  // Optional embedded categories (if you want a personal list per user)
//   categories: [
//     {
//       categoryId: { type: Schema.Types.ObjectId, ref: 'categories', required: true },
//       categoryName: { type: String },
//       amount: { type: Number, required: true },
//       date: { type: Date, default: Date.now },
//     },
//   ],
});

const User = mongoose.model('User', userSchema);
module.exports = User;


    //list of objects catrgory id (taken men el category table) and expenese


