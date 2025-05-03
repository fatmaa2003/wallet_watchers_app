const express = require('express');
const router = express.Router();
const goalController = require('../controller/goal.controller');

router.post('/create', goalController.createGoal);
router.get('/:userId', goalController.getGoals);
router.put('/:id', goalController.updateGoal);
router.delete('/:id', goalController.deleteGoal);

module.exports = router;