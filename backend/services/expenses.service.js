const ExpensesRepository = require ('../repository/expenses.repository');


const getAllExpenses = async () => {
    const expenses = await ExpensesRepository.getAllExpenses();
    return expenses;
    
}

const postExpenses = async(expenseAmount, categoryName)=>{
    console.log(expenseAmount, categoryName);
    const expenses = await ExpensesRepository.postExpenses(expenseAmount , categoryName);
    return expenses;
}

module.exports ={
    getAllExpenses,
    postExpenses,
}