const mongoose = require ('mongoose');

const { Schema } = mongoose;

const categoriesSchema = new Schema({

    categoryId:{
        type: Number,
        default: 0,
    },
    categoryName:{
        type: String,
        default: 0
    }

    //add category id and category name instead of user id and remove ell category names and add them as enteries from db.
   
}, { timestamps: true });

const categoriesModel = mongoose.model('categories',categoriesSchema);

module.exports = categoriesModel;