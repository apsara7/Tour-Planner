const Guide = require("../models/guides");
const path = require("path");
const fs = require("fs");

// ✅ Create Guide
const createGuide = async (req, res) => {
  try {
    const {
      guideName,
      description,
      contactDetails,
      address,
      experience,
      license,
      availability,
      pricing,
      bio,
      achievements,
      socialMedia,
    } = req.body;

    if (!guideName)
      return res.status(400).json({ message: "Guide name required" });

    // Handle images
    const imagePaths = req.files
      ? req.files.map((file) => `uploads/${file.filename}`)
      : [];

    // Parse JSON fields if they come as strings
    const parsedContactDetails =
      typeof contactDetails === "string"
        ? JSON.parse(contactDetails)
        : contactDetails;

    const parsedAddress =
      typeof address === "string" ? JSON.parse(address) : address;

    const parsedExperience =
      typeof experience === "string" ? JSON.parse(experience) : experience;

    const parsedLicense =
      typeof license === "string" ? JSON.parse(license) : license;

    const parsedAvailability =
      typeof availability === "string"
        ? JSON.parse(availability)
        : availability;

    const parsedPricing =
      typeof pricing === "string" ? JSON.parse(pricing) : pricing;

    const parsedAchievements =
      typeof achievements === "string"
        ? JSON.parse(achievements)
        : achievements;

    const parsedSocialMedia =
      typeof socialMedia === "string" ? JSON.parse(socialMedia) : socialMedia;

    // Handle license image
    let licenseImagePath = "";
    if (req.files) {
      const licenseImageFile = req.files.find(
        (file) => file.fieldname === "licenseImage"
      );
      if (licenseImageFile) {
        licenseImagePath = `uploads/${licenseImageFile.filename}`;
      }
    }

    const newGuide = new Guide({
      guideName,
      description,
      contactDetails: parsedContactDetails,
      address: parsedAddress,
      experience: parsedExperience,
      license: {
        ...parsedLicense,
        licenseImage: licenseImagePath,
      },
      availability: parsedAvailability,
      pricing: parsedPricing,
      bio,
      achievements: parsedAchievements,
      socialMedia: parsedSocialMedia,
      images: imagePaths,
    });

    await newGuide.save();
    res.status(201).json({ status: "Success", guide: newGuide });
  } catch (err) {
    res.status(500).json({ status: "Error", message: err.message });
  }
};

// ✅ Get All Guides
const getAllGuides = async (req, res) => {
  try {
    const { search, status, minRating, maxRating, province, city } = req.query;

    // Build filter object
    let filter = {};

    if (search) {
      filter.$or = [
        { guideName: { $regex: search, $options: "i" } },
        { description: { $regex: search, $options: "i" } },
        { "address.city": { $regex: search, $options: "i" } },
        { "address.province": { $regex: search, $options: "i" } },
        { "experience.specializations": { $in: [new RegExp(search, "i")] } },
        { "experience.languages": { $in: [new RegExp(search, "i")] } },
      ];
    }

    if (status) {
      filter.status = status;
    }

    if (minRating || maxRating) {
      filter["ratings.averageRating"] = {};
      if (minRating)
        filter["ratings.averageRating"].$gte = parseFloat(minRating);
      if (maxRating)
        filter["ratings.averageRating"].$lte = parseFloat(maxRating);
    }

    if (province) {
      filter["address.province"] = { $regex: province, $options: "i" };
    }

    if (city) {
      filter["address.city"] = { $regex: city, $options: "i" };
    }

    const guides = await Guide.find(filter).sort({
      "ratings.averageRating": -1,
      createdAt: -1,
    });

    const response = guides.map((guide) => {
      const obj = guide.toObject();

      // Format images with full URLs
      obj.images = obj.images.map(
        (img) => `${req.protocol}://${req.get("host")}/${img}`
      );

      // Format license image with full URL
      if (obj.license.licenseImage) {
        obj.license.licenseImage = `${req.protocol}://${req.get("host")}/${
          obj.license.licenseImage
        }`;
      }

      return obj;
    });

    res.json(response);
  } catch (err) {
    res.status(500).json({ status: "Error", message: err.message });
  }
};

// ✅ Get Guide by ID
const getGuideById = async (req, res) => {
  try {
    const guide = await Guide.findById(req.params.id);
    if (!guide) return res.status(404).json({ message: "Guide not found" });

    const obj = guide.toObject();

    // Format images with full URLs
    obj.images = obj.images.map(
      (img) => `${req.protocol}://${req.get("host")}/${img}`
    );

    // Format license image with full URL
    if (obj.license.licenseImage) {
      obj.license.licenseImage = `${req.protocol}://${req.get("host")}/${
        obj.license.licenseImage
      }`;
    }

    res.json({ status: "Success", guide: obj });
  } catch (err) {
    res.status(500).json({ status: "Error", message: err.message });
  }
};

// ✅ Update Guide
const updateGuide = async (req, res) => {
  try {
    const {
      guideName,
      description,
      contactDetails,
      address,
      experience,
      license,
      availability,
      pricing,
      bio,
      achievements,
      socialMedia,
    } = req.body;

    const guide = await Guide.findById(req.params.id);
    if (!guide) return res.status(404).json({ message: "Guide not found" });

    // Handle images - preserve existing and add new ones
    const newImageFiles = req.files
      ? req.files.filter((file) => file.fieldname === "images")
      : [];
    const newImages = newImageFiles.map((file) => `uploads/${file.filename}`);

    // frontend sends the list of images user kept
    const keptImages = req.body.existingImages
      ? JSON.parse(req.body.existingImages)
      : guide.images || [];

    // Clean existing images URLs - remove duplicated URLs and extract just the filename
    const cleanedKeptImages = keptImages
      .map((img) => {
        if (typeof img === "string") {
          const match = img.match(/uploads\/[^\/]+\.(jpg|jpeg|png|gif|webp)$/i);
          return match ? match[0] : img;
        }
        return img;
      })
      .filter((img) => img && img.length > 0);

    guide.images = [...cleanedKeptImages, ...newImages];

    // Handle license image update
    if (req.files) {
      const licenseImageFile = req.files.find(
        (file) => file.fieldname === "licenseImage"
      );
      if (licenseImageFile) {
        guide.license.licenseImage = `uploads/${licenseImageFile.filename}`;
      }
    }

    // Parse JSON fields if they come as strings
    const parsedContactDetails =
      typeof contactDetails === "string"
        ? JSON.parse(contactDetails)
        : contactDetails;

    const parsedAddress =
      typeof address === "string" ? JSON.parse(address) : address;

    const parsedExperience =
      typeof experience === "string" ? JSON.parse(experience) : experience;

    const parsedLicense =
      typeof license === "string" ? JSON.parse(license) : license;

    const parsedAvailability =
      typeof availability === "string"
        ? JSON.parse(availability)
        : availability;

    const parsedPricing =
      typeof pricing === "string" ? JSON.parse(pricing) : pricing;

    const parsedAchievements =
      typeof achievements === "string"
        ? JSON.parse(achievements)
        : achievements;

    const parsedSocialMedia =
      typeof socialMedia === "string" ? JSON.parse(socialMedia) : socialMedia;

    // Update fields
    if (guideName) guide.guideName = guideName;
    if (description !== undefined) guide.description = description;
    if (parsedContactDetails) guide.contactDetails = parsedContactDetails;
    if (parsedAddress) guide.address = parsedAddress;
    if (parsedExperience) guide.experience = parsedExperience;
    if (parsedLicense) {
      guide.license = { ...guide.license, ...parsedLicense };
    }
    if (parsedAvailability) guide.availability = parsedAvailability;
    if (parsedPricing) guide.pricing = parsedPricing;
    if (bio !== undefined) guide.bio = bio;
    if (parsedAchievements) guide.achievements = parsedAchievements;
    if (parsedSocialMedia) guide.socialMedia = parsedSocialMedia;

    await guide.save();
    res.json({ status: "Success", guide });
  } catch (err) {
    res.status(500).json({ status: "Error", message: err.message });
  }
};

// ✅ Delete Guide
const deleteGuide = async (req, res) => {
  try {
    const guide = await Guide.findById(req.params.id);
    if (!guide) return res.status(404).json({ message: "Guide not found" });

    // Delete associated images
    guide.images.forEach((img) => {
      const filePath = path.resolve(img);
      if (fs.existsSync(filePath)) fs.unlinkSync(filePath);
    });

    // Delete license image
    if (guide.license.licenseImage) {
      const licenseImagePath = path.resolve(guide.license.licenseImage);
      if (fs.existsSync(licenseImagePath)) fs.unlinkSync(licenseImagePath);
    }

    await Guide.findByIdAndDelete(req.params.id);
    res.json({ status: "Success", message: "Guide deleted" });
  } catch (err) {
    res.status(500).json({ status: "Error", message: err.message });
  }
};

// ✅ Add Tourist Rating
const addTouristRating = async (req, res) => {
  try {
    const { guideId, touristId, touristName, rating, review } = req.body;

    if (!guideId || !touristId || !rating) {
      return res
        .status(400)
        .json({ message: "Guide ID, Tourist ID, and rating are required" });
    }

    if (rating < 1 || rating > 5) {
      return res
        .status(400)
        .json({ message: "Rating must be between 1 and 5" });
    }

    const guide = await Guide.findById(guideId);
    if (!guide) return res.status(404).json({ message: "Guide not found" });

    // Check if tourist has already rated this guide
    const existingRating = guide.ratings.touristRatings.find(
      (r) => r.touristId === touristId
    );

    if (existingRating) {
      return res
        .status(400)
        .json({ message: "Tourist has already rated this guide" });
    }

    // Add new rating
    const newRating = {
      touristId,
      touristName: touristName || "Anonymous",
      rating,
      review: review || "",
      date: new Date(),
    };

    guide.ratings.touristRatings.push(newRating);

    // Update rating statistics
    guide.ratings.totalRatings += 1;
    guide.ratings.ratingBreakdown[`${rating}Star`] += 1;

    // Calculate new average rating
    const totalRatingSum = guide.ratings.touristRatings.reduce(
      (sum, r) => sum + r.rating,
      0
    );
    guide.ratings.averageRating = totalRatingSum / guide.ratings.totalRatings;

    await guide.save();
    res.json({ status: "Success", guide });
  } catch (err) {
    res.status(500).json({ status: "Error", message: err.message });
  }
};

// ✅ Update Guide Status
const updateGuideStatus = async (req, res) => {
  try {
    const { guideId, status } = req.body;

    if (!guideId || !status) {
      return res
        .status(400)
        .json({ message: "Guide ID and status are required" });
    }

    const validStatuses = [
      "active",
      "inactive",
      "suspended",
      "pending_verification",
    ];
    if (!validStatuses.includes(status)) {
      return res.status(400).json({ message: "Invalid status" });
    }

    const guide = await Guide.findById(guideId);
    if (!guide) return res.status(404).json({ message: "Guide not found" });

    guide.status = status;
    await guide.save();

    res.json({ status: "Success", guide });
  } catch (err) {
    res.status(500).json({ status: "Error", message: err.message });
  }
};

// ✅ Get Guide Statistics
const getGuideStatistics = async (req, res) => {
  try {
    const totalGuides = await Guide.countDocuments();
    const activeGuides = await Guide.countDocuments({ status: "active" });
    const pendingGuides = await Guide.countDocuments({
      status: "pending_verification",
    });
    const suspendedGuides = await Guide.countDocuments({ status: "suspended" });

    // Get top rated guides
    const topRatedGuides = await Guide.find({
      "ratings.averageRating": { $gte: 4 },
    })
      .sort({ "ratings.averageRating": -1 })
      .limit(5)
      .select("guideName ratings.averageRating ratings.totalRatings");

    res.json({
      status: "Success",
      statistics: {
        totalGuides,
        activeGuides,
        pendingGuides,
        suspendedGuides,
        topRatedGuides,
      },
    });
  } catch (err) {
    res.status(500).json({ status: "Error", message: err.message });
  }
};

module.exports = {
  createGuide,
  getAllGuides,
  getGuideById,
  updateGuide,
  deleteGuide,
  addTouristRating,
  updateGuideStatus,
  getGuideStatistics,
};
