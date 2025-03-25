const CategoriesService = require("../services/categoreies.service");

const getAllCategories = async (req, res) => {
  console.log("getting all categories");
  const categories = await CategoriesService.getAllCategories();
  res.status(200).json(categories);
};

module.exports = {
  getAllCategories,
};
