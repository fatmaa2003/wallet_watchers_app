const {model}= require("mongoose");

const Profile = require ('../model/user.model')

const getProfile = async ({userId}) =>{
    try{

        if(!userId){
             console.log("userId not found", err)
             return null;
        }

        const profile = await Profile.findById(userId);

        if(!profile){
             console.log('profile not found' , err);
             return null;
        }
    
        return {
            fullName: `${profile.firstName} ${profile.lastName}`,
            email: profile.email,
            phoneNo: profile.phoneNo,
            //city :profile.city,
        }
         
        
    }catch(err){
        console.log("error", err);
    }
}

module.exports = {
    getProfile,
}

