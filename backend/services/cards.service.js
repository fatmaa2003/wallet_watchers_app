const CardsRepo = require("../repository/cards.repository");

const postCard = async (userId, cardData) => {
  if (!userId || !cardData) {
    console.error("Missing userId or cardData in service");
    return null;
  }

  return await CardsRepo.postCard(userId, cardData);
};

const getCardsByUserId = async (userId) => {
  if (!userId) {
    console.error("Missing userId in service");
    return [];
  }

  return await CardsRepo.getCardsByUserId(userId);
};

const getCardExpenses = async (userId, cardNumber) =>{

}

const deleteCard = async (userId, cardName) => {
  if (!userId || !cardName) {
    console.error("Missing userId or cardName in service");
    return null;
  }

  return await CardsRepo.deleteCard(userId, cardName);
};

module.exports = {
  postCard,
  getCardsByUserId,
  deleteCard,
};