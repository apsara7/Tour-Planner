const User = require('../models/userModel');
const Permissions = require('../models/rolesPermission');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcrypt');
const CryptoJS = require('crypto-js');
require('dotenv').config();

// Login and JWT token generation
const loginUser = async (req, res) => {
  const { encryptedUsername, encryptedPassword } = req.body;

  try {
    // Decrypt credentials
    const username = CryptoJS.AES.decrypt(
      encryptedUsername,
      process.env.DECRYPTION_SECRET_USERKEY
    ).toString(CryptoJS.enc.Utf8);

    const password = CryptoJS.AES.decrypt(
      encryptedPassword,
      process.env.DECRYPTION_SECRET_PASSKEY
    ).toString(CryptoJS.enc.Utf8);

    if (!username || !password) {
      return res.status(400).json({ success: false, message: 'Username and password are required' });
    }

    // Find user
    const user = await User.findOne({ username });
    if (!user) {
      return res.status(401).json({ success: false, message: 'Invalid username or password' });
    }

    // Compare password
    const passwordMatch = await bcrypt.compare(password, user.password);
    if (!passwordMatch) {
      return res.status(401).json({ success: false, message: 'Invalid username or password' });
    }

    // Create JWT
    const payload = { userId: user._id, username: user.username, role: user.role };
    const token = jwt.sign(payload, process.env.JWT_SECRET, { expiresIn: '24h' });

    // Encrypt the token (optional)
    const secretKey = process.env.SECRET_KEY || 'default_secret';
    const encryptedToken = CryptoJS.AES.encrypt(token, secretKey).toString();

    return res.status(200).json({
      success: true,
      token,
      encryptedToken,
      user: { username: user.username, role: user.role, firstName: user.firstName }
    });
  } catch (err) {
    console.error('Error in loginUser:', err);
    return res.status(500).json({ success: false, message: 'Server error' });
  }
};

// Fetch dashboard data
const getDashboardData = async (req, res) => {
  try {
    const userId = req.user.userId;
    const user = await User.findById(userId).select('-password');
    if (!user) return res.status(404).json({ message: 'User not found' });

    // Get permissions
    let permissions = {};
    const rolePermissions = await Permissions.findOne({ roleName: user.role });
    if (rolePermissions && rolePermissions.permissions instanceof Map) {
      permissions = Object.fromEntries(rolePermissions.permissions.entries());
    }

    res.json({
      username: user.username,
      firstName: user.firstName,
      lastName: user.lastName,
      mobile: user.mobile,
      role: user.role,
      permissions
    });
  } catch (error) {
    console.error('Error fetching dashboard data:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

module.exports = { loginUser, getDashboardData };
