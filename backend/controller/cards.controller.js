const CardsService = require("../services/cards.service");

const postCard = async (req, res) => {
  const { userId, cardData } = req.body;
  console.log("In controller POST card:", userId, cardData);
  if (!userId || !cardData) {
    return res.status(400).json({ error: "userId and cardData are required" });
  }
  const card = await CardsService.postCard(userId, cardData);
  if (!card) {
    return res.status(500).json({ error: "Failed to add card" });
  }
  res.status(201).json(card);
};

const getCardsByUserId = async (req, res) => {
  const { userId } = req.query;
  console.log("In controller GET cards by userId:", userId);
  if (!userId) {
    return res.status(400).json({ error: "userId is required" });
  }
  const Cards = await CardsService.getCardsByUserId(userId);
  if (!Cards) {
    return res.status(404).json({ error: "No cards found for this user" });
  }
  res.status(200).json(Cards);
};

const deleteCard = async (req, res) => {
  const { userId, cardName } = req.query;
  console.log("In controller DELETE card:", userId, cardName);
  if (!userId || !cardName) {
    return res.status(400).json({ error: "userId and cardName are required" });
  }
  const deletedCard = await CardsService.deleteCard(userId, cardName);
  if (!deletedCard) {
    return res.status(404).json({ error: "Card not found" });
  }
  res.status(200).json(deletedCard);
};

module.exports = {
  postCard,
  getCardsByUserId,
  deleteCard,
};
