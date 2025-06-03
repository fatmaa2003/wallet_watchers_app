const express = require("express");
const router = express.Router();
const controller = require("../controller/collaborativeGoal.controller");


router.post("/create", controller.createGoal);
router.get("/:userId", controller.getGoals);
router.put("/update-contribution", controller.updateContribution);
router.put("/add-friend", controller.addFriend);
router.delete("/:goalId", controller.deleteGoal);
router.put("/remove-friend", controller.removeFriend);
router.put("/respond-invite", controller.respondInvite);
router.put("/leave", controller.leaveGoal);
router.get("/notifications/:userId", controller.getInvitations);

module.exports = router;