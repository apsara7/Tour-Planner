const User = require("../models/userModel");
const bcrypt = require("bcrypt");
require("dotenv").config();
const jwt = require("jsonwebtoken");
const sendEmail = require("../utill/mails");

const loginAppUser = async (req, res) => {
  try {
    const { username, password } = req.body;
    const user = await User.findOne({ username });

    if (!user) {
      return res
        .status(400)
        .json({ success: false, message: "User not found" });
    }

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res
        .status(400)
        .json({ success: false, message: "Invalid password" });
    }

    const token = jwt.sign(
      { id: user._id, username: user.username },
      process.env.JWT_SECRET,
      { expiresIn: "1d" }
    );

    res.json({
      success: true,
      message: "Login successful",
      data: {
        user: {
          id: user._id,
          username: user.username,
          email: user.email,
          firstName: user.firstName,
          lastName: user.lastName,
          mobile: user.mobile,
        },
        token,
      },
    });
  } catch (error) {
    console.error("Login error:", error);
    res.status(500).json({ success: false, message: "Server error" });
  }
};

// User Registration Function
const registerUser = async (req, res) => {
  try {
    const { username, email, password, firstName, lastName, phone } = req.body;

    // Validation
    if (!username || !password || !firstName || !email) {
      return res.status(400).json({
        message: "Username, password, first name, and email are required",
      });
    }

    // Check password length
    if (password.length < 6) {
      return res.status(400).json({
        message: "Password must be at least 6 characters long",
      });
    }

    // Email validation
    const emailRegex = /^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$/;
    if (!emailRegex.test(email)) {
      return res.status(400).json({
        message: "Please enter a valid email address",
      });
    }

    // Check if user already exists (by username)
    const existingUserByUsername = await User.findOne({ username });
    if (existingUserByUsername) {
      return res.status(400).json({
        message: "Username already exists. Please choose a different username.",
      });
    }

    // Check if user already exists (by email)
    if (email) {
      const existingUserByEmail = await User.findOne({ email });
      if (existingUserByEmail) {
        return res.status(400).json({
          message:
            "Email already registered. Please use a different email address.",
        });
      }
    }

    // Check if user already exists (by mobile/phone)
    if (phone) {
      const existingUserByPhone = await User.findOne({ mobile: phone });
      if (existingUserByPhone) {
        return res.status(400).json({
          message:
            "Phone number already registered. Please use a different phone number.",
        });
      }
    }

    // Hash the password
    const saltRounds = 10;
    const hashedPassword = await bcrypt.hash(password, saltRounds);

    // Create new user with default role
    const newUser = new User({
      username,
      email,
      firstName,
      lastName: lastName || "", // lastName is optional
      password: hashedPassword,
      mobile: phone || "", // phone is optional but recommended
      role: "user", // Default role for regular users
      profileImage: "", // Default empty profile image
    });

    // Save user to database
    await newUser.save();

    await sendEmail(
      email,
      "Welcome to Tour Planner!",
      `
  <div style="font-family: Arial, sans-serif; max-width: 600px; margin: auto; padding: 20px; border: 1px solid #ddd; border-radius: 10px; background-color: #f9f9f9;">
    <h2 style="color: #2c3e50;">Welcome to Tour Planner, ${firstName}!</h2>
    <p style="font-size: 16px; color: #333;">
      Your account has been successfully created. Now you can log in to the mobile app and start exploring amazing tours and experiences.
    </p>
    <a href="http://localhost:8080/#/login" style="display: inline-block; padding: 10px 20px; margin-top: 15px; background-color: #4CAF50; color: white; text-decoration: none; border-radius: 5px;">
      Login Now
    </a>
    <p style="margin-top: 20px; font-size: 14px; color: #777;">
      Thank you for joining Tour Planner!
    </p>
  </div>
  `
    );

    // Return success response (exclude password from response)
    const userResponse = {
      id: newUser._id,
      username: newUser.username,
      email: newUser.email,
      firstName: newUser.firstName,
      lastName: newUser.lastName,
      mobile: newUser.mobile,
      role: newUser.role,
    };

    res.status(201).json({
      success: true,
      message: "User registered successfully! You can now log in.",
      data: userResponse,
    });
  } catch (error) {
    console.error("Error in user registration:", error);

    // Handle duplicate key errors
    if (error.code === 11000) {
      if (error.keyPattern.username) {
        return res.status(400).json({
          message:
            "Username already exists. Please choose a different username.",
        });
      }
      if (error.keyPattern.mobile) {
        return res.status(400).json({
          message:
            "Phone number already registered. Please use a different phone number.",
        });
      }
      if (error.keyPattern.email) {
        return res.status(400).json({
          message:
            "Email already registered. Please use a different email address.",
        });
      }
    }

    res.status(500).json({
      success: false,
      message: "Server error during registration. Please try again later.",
    });
  }
};

// Check username availability
const checkUsernameAvailability = async (req, res) => {
  try {
    const { username } = req.params;

    if (!username) {
      return res.status(400).json({
        message: "Username is required",
      });
    }

    const existingUser = await User.findOne({ username });

    res.json({
      available: !existingUser,
      message: existingUser
        ? "Username already taken"
        : "Username is available",
    });
  } catch (error) {
    console.error("Error checking username availability:", error);
    res.status(500).json({
      message: "Server error while checking username availability",
    });
  }
};

// Check phone availability
const checkPhoneAvailability = async (req, res) => {
  try {
    const { phone } = req.params;

    if (!phone) {
      return res.status(400).json({
        message: "Phone number is required",
      });
    }

    const existingUser = await User.findOne({ mobile: phone });

    res.json({
      available: !existingUser,
      message: existingUser
        ? "Phone number already registered"
        : "Phone number is available",
    });
  } catch (error) {
    console.error("Error checking phone availability:", error);
    res.status(500).json({
      message: "Server error while checking phone availability",
    });
  }
};

// Check email availability
const checkEmailAvailability = async (req, res) => {
  try {
    const { email } = req.params;

    if (!email) {
      return res.status(400).json({
        message: "Email is required",
      });
    }

    const existingUser = await User.findOne({ email });

    res.json({
      available: !existingUser,
      message: existingUser ? "Email already registered" : "Email is available",
    });
  } catch (error) {
    console.error("Error checking email availability:", error);
    res.status(500).json({
      message: "Server error while checking email availability",
    });
  }
};

// Get User Profile
const getUserProfile = async (req, res) => {
  try {
    const userId = req.user.id; // From JWT token
    const user = await User.findById(userId).select("-password");

    if (!user) {
      return res.status(404).json({
        success: false,
        message: "User not found",
      });
    }

    res.json({
      success: true,
      data: {
        id: user._id,
        username: user.username,
        email: user.email,
        firstName: user.firstName,
        lastName: user.lastName,
        mobile: user.mobile,
        role: user.role,
        profileImage: user.profileImage,
      },
    });
  } catch (error) {
    console.error("Error fetching user profile:", error);
    res.status(500).json({
      success: false,
      message: "Server error while fetching profile",
    });
  }
};

// Update User Profile
const updateUserProfile = async (req, res) => {
  try {
    const userId = req.user.id; // From JWT token
    const { firstName, lastName, email, mobile } = req.body;

    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({
        success: false,
        message: "User not found",
      });
    }

    // Check if email is being changed and if it's unique
    if (email && email !== user.email) {
      const existingUser = await User.findOne({ email, _id: { $ne: userId } });
      if (existingUser) {
        return res.status(400).json({
          success: false,
          message: "Email already exists",
        });
      }
    }

    // Check if mobile is being changed and if it's unique
    if (mobile && mobile !== user.mobile) {
      const existingUser = await User.findOne({ mobile, _id: { $ne: userId } });
      if (existingUser) {
        return res.status(400).json({
          success: false,
          message: "Mobile number already exists",
        });
      }
    }

    // Update user fields
    if (firstName) user.firstName = firstName;
    if (lastName) user.lastName = lastName;
    if (email) user.email = email;
    if (mobile) user.mobile = mobile;

    await user.save();

    res.json({
      success: true,
      message: "Profile updated successfully",
      data: {
        id: user._id,
        username: user.username,
        email: user.email,
        firstName: user.firstName,
        lastName: user.lastName,
        mobile: user.mobile,
        role: user.role,
        profileImage: user.profileImage,
      },
    });
  } catch (error) {
    console.error("Error updating user profile:", error);
    res.status(500).json({
      success: false,
      message: "Server error while updating profile",
    });
  }
};

module.exports = {
  registerUser,
  checkUsernameAvailability,
  checkPhoneAvailability,
  checkEmailAvailability,
  loginAppUser,
  getUserProfile,
  updateUserProfile,
};
