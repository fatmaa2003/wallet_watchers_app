const Receipt = require('../model/receipt.model');

const saveReceipt = async ({ userId, text, timestamp }) => {
  try {
    const receipt = new Receipt({
      userId,
      text,
      timestamp,
    });
    return await receipt.save();
  } catch (err) {
    console.error('Error saving receipt:', err);
    throw err;
  }
};

module.exports = {
  saveReceipt,
};