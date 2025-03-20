const User = require ('../model/user.model');
const bcrypt = require('bcrypt');

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

exports.signup = async (req, res) => {
    try {
        const { email, password, phoneNo } = req.body;

        const existingUser = await User.findOne({ email });
        if (existingUser) {
            return res.status(400).json({ message: "User already exists" });
        }

        const saltRounds = 10;
        const hashedPassword = await bcrypt.hash(password, saltRounds);

        const newUser = new User({
            email,
            password: hashedPassword,
            phoneNo
        });

        await newUser.save();
        res.status(201).json({ message: "User created successfully" });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};
