const userModel = require("../model/user.model");
const Cards = require("../model/cards.model");

const postCard = async (userId, cardData) => {
  try {
    if (!userId || !cardData) {
      console.log("userId or cardData not provided");
      return null;
    }
    const user = await userModel.findById( userId );

    if (!user) {
      console.log("user not found");
      return null;
    }
    const card = new Cards({
      userId,
      cardName: cardData.cardName,
      cardNumber: cardData.cardNumber,
      cardHolder: cardData.cardHolder,
      expiryDate: cardData.expiryDate,
      cvv: cardData.cvv,
    });
    await card.save();
    return card;
  } catch (err) {
    console.log("error in repo postCard: ", err);
    return null;
  }
};

const getCardsByUserId = async (userId) => {
  try {
    if (!userId) {
      console.log("user id not provided");
      return [];
    }
    const cards = await Cards.find( {userId} );
    return cards;
  } catch (err) {
    console.log("error in repo getcardsByUserId: ", err);
  }
};

const deleteCard = async (userId, cardName) => {
  try {
    if (!userId || !cardName) {
      console.log("userId or cardName not provided");
      return null;
    }
    const deletedCard = await Cards.findOneAndDelete({ userId, cardName });
    if (!deletedCard) {
      console.log("Card not found");
      return null;
    }
    return deletedCard;
  } catch (err) {
    console.log("error in repo deleteCard: ", err);
    return null;
  }
};

module.exports = {
  getCardsByUserId,
  postCard,
  deleteCard,
};
