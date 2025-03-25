const { model } = require("mongoose");
const Categories = require("../model/categories.model");

const getAllCategories = async () => {
  try {
    const categories = await Categories.find();
    return categories;
  } catch (err) {}
};

module.exports = {
  getAllCategories,
};
