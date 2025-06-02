const CategoriesService = require("../services/categories.service");

const getAllCategories = async (req, res) => {
  console.log("getting all categories");
  const categories = await CategoriesService.getAllCategories();
  res.status(200).json(categories);
};

const postCategory = async (req, res) => {
  const { categoryName } = req.body;
  console.log("in post category controller", categoryName);
  if (!categoryName) {
    return res.status(400).json({ error: "categoryName is required" });
  }
  const newCategory = await CategoriesService.postCategory(
    categoryName
  );
  if (!newCategory) {
    return res.status(400).json({ error: "Failed to create category" });
  }
  res.status(201).json(newCategory);
};

module.exports = {
  getAllCategories,
  postCategory,
};
