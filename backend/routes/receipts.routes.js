const express = require('express');
const router = express.Router();
const receiptController = require('../controller/receipts.controller');

router.post('/', receiptController.saveReceipt);

module.exports = router;