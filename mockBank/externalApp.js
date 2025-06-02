const axios = require("axios");

const expenseData = {
  userId: "67e4b4e117e6a83e0b8bb145",
  expenseName: "ATM Withdrawal - Electricity",
  expenseAmount: -4000,
  categoryName: "Bank",
  isBank: true,
  bankName: "Bank Misr",
  cardNumber: "1234-5678-9876-5432",
  accountNumber: "012345678901",
};

async function sendExpense() {
  try {
    const response = await axios.post(
      "http://localhost:3000/api/expenses/postExpenses",
      expenseData
    );
    console.log(" Expense sent successfully:", response.data);
  } catch (error) {
    console.error(
      "Failed to send expense:",
      error.response?.data || error.message
    );
  }
}

sendExpense();
