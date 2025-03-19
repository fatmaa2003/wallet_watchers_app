
const Category = require('../model/categories.model');

//app.get bta3t drop down bta3t el categories, yecall api betget el categories kolaha.


exports.getAllCategories = async (req, res) => {
    try {
        const categories = await Category.find();
        res.status(200).json(categories);
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
};