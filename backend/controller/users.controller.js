const User = require('../model/user.model');
const authService = require('../services/auth.service');
const bcrypt = require('bcrypt');

//api.post('/addexpense) , haygely feha object user id number wel expense number category id number,
// bel user id da hadwr fel users table 3la el user, 
// then fel list of expenses, ha add el expense de
// el list gowaha el category id wel amount wel category name.

const signup = async (req, res) => {
    try {
        const { firstName, lastName, email, password, phoneNo } = req.body;
        const user = await authService.signup(firstName, lastName, email, password, phoneNo);
        res.status(201).json({ message: 'User created successfully', user });
    } catch (error) {
        res.status(400).json({ message: error.message });
    }
};

const login = async (req, res) => {
    try {
        const { email, password } = req.body;

        console.log("logging in", email, password);
        const user = await User.findOne({ email });
        if (!user) {
            return res.status(400).json({ message: 'Invalid email or password' });
        }

        
        const isPasswordValid = await bcrypt.compare(password, user.password);
        if (!isPasswordValid) {
            return res.status(400).json({ message: 'Invalid email or password' });
        }

        res.status(200).json({
            message: 'Login successful',
            user: {
                id: user._id,
                firstName: user.firstName,
                lastName: user.lastName,
                email: user.email,
                phoneNo: user.phoneNo,
            }
        });
    } catch (error) {
        console.error('Login error:', error);
        res.status(500).json({ message: 'Error during login', error: error.message });
    }
};

const forgotPassword = async (req, res) => {
    const { email, newPassword } = req.body;

    try {
        await authService.forgotPassword(email, newPassword);

        res.status(200).json({ message: 'Password updated successfully' });

    } catch (error) {
        console.error('Error in forgotPassword:', error);
        res.status(400).json({ message: error.message }); 
    }
};

const addExpense = async (req, res) => {
    try {
        const { userId, amount, categoryId, categoryName } = req.body;

        const user = await User.findById(userId);

        if (!user) return res.status(404).json({ message: "User not found" });

        const expense = { categoryId, categoryName, amount };
        user.expenses.push(expense);

        await user.save();
        res.status(200).json(user);
    } catch (err) {
        res.status(500).json({ message: err.message })
    }
};

module.exports = {
    signup,
    login,
    forgotPassword,
    addExpense,
};