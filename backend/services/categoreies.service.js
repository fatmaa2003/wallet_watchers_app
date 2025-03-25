const CategoriesRepository = require("../repository/categories.repository");

const getAllCategories = async () => {
  const categories = await CategoriesRepository.getAllCategories();
  return categories;
};

module.exports = {
  getAllCategories,
};
