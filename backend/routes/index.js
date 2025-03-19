const userRoute = require ("./users.routes")
const categoriesRoute = require ("./categories.routes")


module.exports = (app) =>
{
    app.use('/api/users', userRoute),
    app.use('/api/categories', categoriesRoute)
}