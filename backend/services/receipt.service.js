const ReceiptRepository = require('../repository/receipt.repository');

const saveReceipt = async (userId, text, timestamp) => {
  if (!userId || !text) {
    throw new Error('Missing required fields');
  }
  return await ReceiptRepository.saveReceipt({ userId, text, timestamp });
};

module.exports = {
  saveReceipt,
};