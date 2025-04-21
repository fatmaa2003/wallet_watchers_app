const mongoose = require('mongoose');
const ReceiptService = require('../services/receipt.service');

const saveReceipt = async (req, res) => {
  try {
    const { userId, text, timestamp } = req.body;

    // Validate required fields
    if (!userId || !text) {
      return res.status(400).json({
        message: 'Missing required fields',
        errors: {
          userId: userId ? undefined : 'userId is required',
          text: text ? undefined : 'text is required',
        },
      });
    }

    // Validate userId format
    if (!mongoose.Types.ObjectId.isValid(userId)) {
      return res.status(400).json({ message: 'Invalid userId format' });
    }

    // Log incoming data for debugging
    console.log('Received receipt data:', { userId, text, timestamp });

    const receipt = await ReceiptService.saveReceipt({ userId, text, timestamp });
    res.status(201).json({ message: 'Receipt saved successfully', receipt });
  } catch (err) {
    console.error('Error in saveReceipt:', err);
    res.status(500).json({ message: 'Error saving receipt', error: err.message });
  }
};

module.exports = {
  saveReceipt,
};