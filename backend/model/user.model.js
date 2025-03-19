const mongoose = require('mongoose');
const categoriesModel = require('./categories.model');

const { Schema } = mongoose;

const userSchema = new Schema({
    // userId: {
    //     type: Number,
    //     required: true,
    //     unique: true,
    // },
    email: {
        type: String,
        required: true,
        unique: true
    },
    password: {
        type: String,
        required: true,
    },
    phoneNo:{
        type:Number,
        required:true,
    },
    categoryId:{
        type: mongoose.Schema.Types.ObjectId,
        ref: 'categories'
    },
    expenses: [
        {
            categoryId: { type: Number, required: true, ref: categoriesModel },
            categoryName: { type: String , unique: true},
            amount: { type: Number, required: true },
            date: { type: Date, default: Date.now }      
        }
    ]
    

    //list of objects catrgory id (taken men el category table) and expenese

});

// Use mongoose.model, not db.model
const User = mongoose.model('User', userSchema);

module.exports = User;
