const ProfileRepository = require("../repository/profile.repository");

const getProfile = async ({ userId }) => {
  console.log("in service get profile ", userId);
  const profileInfo = await ProfileRepository.getProfile({ userId });

  return profileInfo;
};

module.exports = {
  getProfile,
};
