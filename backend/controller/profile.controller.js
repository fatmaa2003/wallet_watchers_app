const ProfileService = require ('../services/profile.service');

const getProfile = async (req , res)=>{
    console.log("getting profile");
    const {userId }= req.body;
    if(!userId){
        return res.status(400).json({error:"missing userId"})
    }
    const profile = await ProfileService.getProfile({userId});
    res.status(200).json(profile);
}

module.exports={
    getProfile,
}