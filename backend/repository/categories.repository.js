const { model } = require("mongoose");
const Categories = require("../model/categories.model");

const getAllCategories = async () => {
  try {
    const categories = await Categories.find();
    return categories;
  } catch (err) {}
};

const postCategory = async (categoryName) => {
  try {
    if (!categoryName) {
      console.log("categoryName not provided");
      return null;
    }

    // Check if category already exists (case-insensitive)
    const existing = await Categories.findOne({
      categoryName: new RegExp(`^${categoryName.trim()}$`, "i"),
    });

    if (existing) {
      console.log("Category already exists");
      return existing;
    }

    const newCategory = new Categories({ categoryName: categoryName.trim() });
    await newCategory.save();
    return newCategory;

  } catch (err) {
    console.error("Error in postCategory:", err);
    return null;
  }
};


module.exports = {
  getAllCategories,
  postCategory,
};
