const express = require("express");
const router = express.Router();
const cardsController = require("../controller/cards.controller");

router.post("/postCard", cardsController.postCard);
router.get("/getCardsByUserId", cardsController.getCardsByUserId);
router.delete("/deleteCard", cardsController.deleteCard);

module.exports = router;
