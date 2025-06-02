const CategoriesRepository = require("../repository/categories.repository");

const getAllCategories = async () => {
  const categories = await CategoriesRepository.getAllCategories();
  return categories;
};

const postCategory = async (categoryName) => {
  if (!categoryName || categoryName.trim() === "") {
    console.error("Invalid category name");
    return null;
  }

  return await CategoriesRepository.postCategory(categoryName.trim());
};

module.exports = {
  getAllCategories,
  postCategory
};
