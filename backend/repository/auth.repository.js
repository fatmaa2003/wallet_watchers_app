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

const updatePassword = async (email, newPassword) => {
    const user = await findUserByEmail(email);

    if (!user) {
        throw new Error('User not found');
    }

    const isSame = await bcrypt.compare(newPassword, user.password);
    if (isSame) {
        throw new Error('New password must be different from the old password');
    }

    const hashedPassword = await bcrypt.hash(newPassword, 10);
    user.password = hashedPassword;

    await user.save();
    return user;
};


module.exports = {
    findUserByEmail,
    createUser,
    updatePassword,
};
