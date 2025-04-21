const Receipt = require('../model/receipt.model');

const saveReceipt = async ({ userId, text, timestamp }) => {
  try {
    const receipt = new Receipt({
      userId,
      text,
      timestamp: timestamp ? new Date(timestamp) : undefined,
    });
    const savedReceipt = await receipt.save();
    console.log('Receipt saved:', savedReceipt); // Debug log
    return savedReceipt;
  } catch (err) {
    console.error('Error saving receipt:', err);
    throw err;
  }
};

module.exports = {
  saveReceipt,
};