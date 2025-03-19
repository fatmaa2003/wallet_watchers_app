const User = require ('../model/user.model');

//api.post('/addexpense) , haygely feha object user id number wel expense number category id number,
// bel user id da hadwr fel users table 3la el user, 
// then fel list of expenses, ha add el expense de
// el list gowaha el category id wel amount wel category name.


exports.addExpense = async (req , res) => {

    try{

        const {userId, amount,categoryId, categoryName} = req.body;

        const user = await User.findById(userId);

        if (!user) return res.status(404).json({message: "User not found"});

        const expense = { categoryId, categoryName , amount};
        user.expenses.push(expense);

        await user.save();
        res.status(200).json(user);

    } catch (err){
        res.status(500).json({message : err.message})
    }

}