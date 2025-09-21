const Permissions = require('../models/rolesPermission');

const verifyPermission = async (user) => {
  try {
    const rolePermissions = await Permissions.findOne({ roleName: user.role });
    if (!rolePermissions) throw new Error('No permissions found for this role');
    return rolePermissions.permissions;
  } catch (error) {
    console.error('Error in verifying permissions:', error.message || error);
    throw error;
  }
};

module.exports = { verifyPermission };
