const authrepository = require('../repository/auth.repository');
const bcrypt = require('bcrypt');

const signup = async (firstName, lastName, email, password, phoneNo) => {
    const existingUser = await authrepository.findUserByEmail(email);
    console.log("existingUser", existingUser);
    if (existingUser) {
        throw new Error('User already exists');
    }
    const user = await authrepository.createUser({ firstName, lastName, email, password, phoneNo });
    console.log("usersignup", user);
    return user;
};

const login = async (email, password) => {
    const user = await authrepository.findUserByEmail(email);
    if (!user) {
        throw new Error('Invalid email or password');
    }

    const isPasswordValid = await bcrypt.compare(password, user.password);
    if (!isPasswordValid) {
        throw new Error('Invalid email or password');
    }

    return {
        id: user._id,
        firstName: user.firstName,
        lastName: user.lastName,
        email: user.email,
        phoneNo: user.phoneNo,
    };
};

const forgotPassword = async (email, newPassword) => {
    const user = await authrepository.findUserByEmail(email);
    if (!user) {
        throw new Error('User not found');
    }

    const isSame = await bcrypt.compare(newPassword, user.password);
    if (isSame) {
        throw new Error('New password must be different from the old password');
    }

    const hashedPassword = await bcrypt.hash(newPassword, 10);
    user.password = hashedPassword;

    return await user.save();
};


module.exports = {
    signup,
    login,
    forgotPassword
};
