const mongoose = require ('mongoose');
//const userModel = require ('./user.model');

const { Schema } = mongoose;

const categoriesSchema = new Schema({

    // userId:{
    //         type: mongoose.Schema.Types.ObjectId,
    //         ref: 'userModel',
    //     },
    categoryName:{
        type: String,
        default: 0
    }

    //add category id and category name instead of user id and remove ell category names and add them as enteries from db.
   
}, { timestamps: true });

const categoriesModel = mongoose.model('categories',categoriesSchema);

module.exports = categoriesModel;