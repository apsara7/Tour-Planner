const User = require('../models/userModel');
const Permissions = require('../models/rolesPermission');
const { verifyPermission } = require('../middleware/roleAuthMiddleware');
const bcrypt = require('bcrypt');
require('dotenv').config();

// Initial running (Create Admin User & Assign Role Permissions)
const initialRunning = async (req, res) => {
  const username = process.env.ADMIN_USERNAME;
  const password = process.env.ADMIN_PASSWORD;
  const role = process.env.ADMIN_ROLE;
  const firstName = process.env.ADMIN_FNAME;
  const mobile = process.env.ADMIN_MOBILE;

  try {
    if (!username || !password) {
      return res.status(400).json({ message: 'Username and password required' });
    }

    const existingUser = await User.findOne({ username });
    if (existingUser) {
      return res.status(400).json({ message: 'User already exists' });
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    const newUser = new User({
      username,
      firstName,
      password: hashedPassword,
      role,
      mobile
    });
    await newUser.save();

    const existingRole = await Permissions.findOne({ roleName: role });
    if (existingRole) {
      return res.status(400).json({ message: 'Role already exists' });
    }

    const roleData = JSON.parse(process.env.ROLE_DATA);
    const formattedPermissions = {};

    for (const [key, value] of Object.entries(roleData)) {
      if (Array.isArray(value)) {
        formattedPermissions[key] = value.reduce((acc, feature) => {
          acc[feature] = true;
          return acc;
        }, {});
      } else {
        formattedPermissions[key] = true;
      }
    }

    const newPermissions = new Permissions({
      roleName: role,
      permissions: formattedPermissions
    });
    await newPermissions.save();

    res.status(201).json({
      message: 'Admin created successfully, permissions added',
      data: newUser
    });
  } catch (err) {
    console.error('Error in initial setup:', err);
    res.status(500).json({ message: 'Server error during user creation' });
  }
};

// Fetch dashboard data
const getInitialData = async (req, res) => {
  try {
    const userId = req.user.userId;
    const user = await User.findById(userId).select('-password');
    if (!user) return res.status(404).json({ message: 'User not found' });

    const permissions = await verifyPermission(user);

    res.json({
      permissions,
      username: user.username,
      role: user.role
    });
  } catch (error) {
    console.error('Error fetching profile data:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

module.exports = { initialRunning, getInitialData };