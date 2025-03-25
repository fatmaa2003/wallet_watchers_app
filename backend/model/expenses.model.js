const mongoose = require ("mongoose");

const {Schema} = mongoose ;
 
const expensesSchema = new Schema ({

    expenseAmount :{
        type: Number,
        default:0,
        required: true
    },
    categoryName:{
        type: String,
        ref: 'categories'
    
    }
}, {timestamps: true});

const expensesModel = mongoose.model('expenses' , expensesSchema);

module.exports = expensesModel;
