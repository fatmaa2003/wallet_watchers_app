const User = require('../model/user.model');
const bcrypt = require('bcrypt');

const findUserByEmail = async (email) => {
    return await User.findOne({ email });
};

const createUser = async ({ firstName, lastName, email, password, phoneNo }) => {
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    const user = new User({
        firstName,
        lastName,
        email,
        password: hashedPassword,
        phoneNo: parseInt(phoneNo),
    });

    return await user.save();
};

module.exports = {
    findUserByEmail,
    createUser,
};
