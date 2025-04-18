const ReceiptService = require('../services/receipt.service');

const saveReceipt = async (req, res) => {
  try {
    const { userId, text, timestamp } = req.body;
    const receipt = await ReceiptService.saveReceipt(userId, text, timestamp);
    res.status(201).json({ message: 'Receipt saved successfully', receipt });
  } catch (err) {
    console.error('Error in saveReceipt:', err);
    res.status(500).json({ message: 'Error saving receipt', error: err.message });
  }
};

module.exports = {
  saveReceipt,
};