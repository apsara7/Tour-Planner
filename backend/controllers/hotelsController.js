const Hotel = require("../models/hotels");
const path = require("path");
const fs = require("fs");
const asyncHandler = require("express-async-handler");

// ✅ Create Hotel
const createHotel = async (req, res) => {
  try {
    const {
      hotelName,
      contactDetails,
      address,
      otherContacts,
      roomPackages,
      facilities,
      description,
      rating,
      checkInTime,
      checkOutTime,
      policies,
    } = req.body;

    if (!hotelName)
      return res.status(400).json({ message: "Hotel name required" });

    // Handle hotel images
    const imagePaths = req.files
      ? req.files
          .filter((file) => file.fieldname === "images")
          .map((file) => `uploads/${file.filename}`)
      : [];

    // Parse JSON fields if they come as strings
    const parsedContactDetails =
      typeof contactDetails === "string"
        ? JSON.parse(contactDetails)
        : contactDetails;

    const parsedAddress =
      typeof address === "string" ? JSON.parse(address) : address;

    const parsedOtherContacts =
      typeof otherContacts === "string"
        ? JSON.parse(otherContacts)
        : otherContacts;

    let parsedRoomPackages = req.body.roomPackages;
    if (typeof parsedRoomPackages === "string") {
      parsedRoomPackages = JSON.parse(parsedRoomPackages);
    }
    parsedRoomPackages = parsedRoomPackages || [];

    // Process room package images
    const processedRoomPackages = parsedRoomPackages.map((pkg, index) => {
      const packageImages = [];

      // Look for package-specific images in req.files
      if (req.files) {
        req.files.forEach((file) => {
          // Check if this file belongs to this package based on fieldname
          if (file.fieldname.includes(`package_${index}_images`)) {
            packageImages.push(`uploads/${file.filename}`);
          }
        });
      }

      return {
        ...pkg,
        images: packageImages,
      };
    });

    const parsedFacilities =
      typeof facilities === "string"
        ? facilities.split(",").map((f) => f.trim())
        : facilities;

    const parsedPolicies =
      typeof policies === "string" ? JSON.parse(policies) : policies;

    const newHotel = new Hotel({
      hotelName,
      contactDetails: parsedContactDetails,
      address: parsedAddress,
      otherContacts: parsedOtherContacts,
      roomPackages: processedRoomPackages,
      facilities: parsedFacilities,
      description,
      rating: rating || 3,
      checkInTime: checkInTime || "14:00",
      checkOutTime: checkOutTime || "11:00",
      policies: parsedPolicies,
      images: imagePaths,
    });

    await newHotel.save();
    res.status(201).json({ status: "Success", hotel: newHotel });
  } catch (err) {
    res.status(500).json({ status: "Error", message: err.message });
  }
};

// ✅ Get All Hotels
const getAllHotels = async (req, res) => {
  try {
    const hotels = await Hotel.find({});
    const response = hotels.map((hotel) => {
      const obj = hotel.toObject();

      // Format hotel images with full URLs
      obj.images = obj.images.map(
        (img) => `${req.protocol}://${req.get("host")}/${img}`
      );

      // Format room package images with full URLs
      obj.roomPackages = obj.roomPackages.map((pkg) => ({
        ...pkg,
        images: pkg.images.map(
          (img) => `${req.protocol}://${req.get("host")}/${img}`
        ),
      }));

      return obj;
    });
    res.json(response);
  } catch (err) {
    res.status(500).json({ status: "Error", message: err.message });
  }
};

// ✅ Get Hotel by ID
const getHotelById = async (req, res) => {
  try {
    const hotel = await Hotel.findById(req.params.id);
    if (!hotel) return res.status(404).json({ message: "Hotel not found" });

    const obj = hotel.toObject();

    // Format hotel images with full URLs
    obj.images = obj.images.map(
      (img) => `${req.protocol}://${req.get("host")}/${img}`
    );

    // Format room package images with full URLs
    obj.roomPackages = obj.roomPackages.map((pkg) => ({
      ...pkg,
      images: pkg.images.map(
        (img) => `${req.protocol}://${req.get("host")}/${img}`
      ),
    }));

    res.json({ status: "Success", hotel: obj });
  } catch (err) {
    res.status(500).json({ status: "Error", message: err.message });
  }
};

// @desc Update hotel details
// @route PUT /api/hotels/:id
// @access Private
const updateHotel = async (req, res) => {
  try {
    const {
      hotelName,
      contactDetails,
      address,
      otherContacts,
      roomPackages,
      facilities,
      description,
      rating,
      checkInTime,
      checkOutTime,
      policies,
    } = req.body;

    const hotel = await Hotel.findById(req.params.id);
    if (!hotel) return res.status(404).json({ message: "Hotel not found" });

    // Handle hotel images - preserve existing and add new ones
    const newImageFiles = req.files
      ? req.files.filter((file) => file.fieldname === "images")
      : [];
    const newImages = newImageFiles.map((file) => `uploads/${file.filename}`);

    // frontend sends the list of images user kept
    const keptImages = req.body.existingImages
      ? JSON.parse(req.body.existingImages)
      : hotel.images || [];

    // Clean existing images URLs - remove duplicated URLs and extract just the filename
    const cleanedKeptImages = keptImages
      .map((img) => {
        if (typeof img === "string") {
          // Extract just the filename from URLs like "http://localhost:4066/http://localhost:4066/uploads/filename.jpg"
          const match = img.match(/uploads\/[^\/]+\.(jpg|jpeg|png|gif|webp)$/i);
          return match ? match[0] : img;
        }
        return img;
      })
      .filter((img) => img && img.length > 0);

    hotel.images = [...cleanedKeptImages, ...newImages];

    // Parse JSON fields if they come as strings
    const parsedContactDetails =
      typeof contactDetails === "string"
        ? JSON.parse(contactDetails)
        : contactDetails;

    const parsedAddress =
      typeof address === "string" ? JSON.parse(address) : address;

    const parsedOtherContacts =
      typeof otherContacts === "string"
        ? JSON.parse(otherContacts)
        : otherContacts;

    let parsedRoomPackages = roomPackages;
    if (typeof parsedRoomPackages === "string") {
      parsedRoomPackages = JSON.parse(parsedRoomPackages);
    }
    parsedRoomPackages = parsedRoomPackages || [];

    // Get existing package images from frontend
    const existingPackageImagesData = req.body.existingPackageImages
      ? JSON.parse(req.body.existingPackageImages)
      : {};

    // Process room package images - merge existing and new images
    const processedRoomPackages = parsedRoomPackages.map((pkg, index) => {
      // Get existing images for this package from frontend (user kept images)
      const keptPackageImages = existingPackageImagesData[index] || [];

      // Clean existing images URLs
      const cleanedKeptImages = keptPackageImages
        .map((img) => {
          if (typeof img === "string") {
            const match = img.match(
              /uploads\/[^\/]+\.(jpg|jpeg|png|gif|webp)$/i
            );
            return match ? match[0] : img;
          }
          return img;
        })
        .filter((img) => img && img.length > 0);

      // Get new images for this package
      const newPackageImages = [];
      if (req.files) {
        req.files.forEach((file) => {
          // Check if this file belongs to this package based on fieldname
          if (file.fieldname.includes(`packageImages_${index}`)) {
            newPackageImages.push(`uploads/${file.filename}`);
          }
        });
      }

      return {
        ...pkg,
        images: [...cleanedKeptImages, ...newPackageImages],
      };
    });

    const parsedFacilities =
      typeof facilities === "string"
        ? facilities.split(",").map((f) => f.trim())
        : facilities;

    const parsedPolicies =
      typeof policies === "string" ? JSON.parse(policies) : policies;

    // Update fields with same validation as create
    if (hotelName) hotel.hotelName = hotelName;
    if (description !== undefined) hotel.description = description;
    if (rating !== undefined) hotel.rating = rating;
    if (checkInTime !== undefined) hotel.checkInTime = checkInTime;
    if (checkOutTime !== undefined) hotel.checkOutTime = checkOutTime;
    if (parsedContactDetails) hotel.contactDetails = parsedContactDetails;
    if (parsedAddress) hotel.address = parsedAddress;
    if (parsedOtherContacts) hotel.otherContacts = parsedOtherContacts;
    if (parsedPolicies) hotel.policies = parsedPolicies;
    if (parsedFacilities) hotel.facilities = parsedFacilities;
    if (processedRoomPackages) hotel.roomPackages = processedRoomPackages;

    await hotel.save();
    res.json({ status: "Success", hotel });
  } catch (err) {
    res.status(500).json({ status: "Error", message: err.message });
  }
};

// Delete Hotel
const deleteHotel = async (req, res) => {
  try {
    const hotel = await Hotel.findById(req.params.id);
    if (!hotel) return res.status(404).json({ message: "Hotel not found" });

    hotel.images.forEach((img) => {
      const filePath = path.resolve(img);
      if (fs.existsSync(filePath)) fs.unlinkSync(filePath);
    });

    await Hotel.findByIdAndDelete(req.params.id);
    res.json({ status: "Success", message: "Hotel deleted" });
  } catch (err) {
    res.status(500).json({ status: "Error", message: err.message });
  }
};

// ✅ Update Room Package Status
const updateRoomPackageStatus = async (req, res) => {
  try {
    const { hotelId, packageId, status } = req.body;

    const hotel = await Hotel.findById(hotelId);
    if (!hotel) return res.status(404).json({ message: "Hotel not found" });

    const packageIndex = hotel.roomPackages.findIndex(
      (pkg) => pkg._id.toString() === packageId
    );

    if (packageIndex === -1) {
      return res.status(404).json({ message: "Room package not found" });
    }

    hotel.roomPackages[packageIndex].status = status;
    await hotel.save();

    res.json({ status: "Success", hotel });
  } catch (err) {
    res.status(500).json({ status: "Error", message: err.message });
  }
};

module.exports = {
  createHotel,
  getAllHotels,
  getHotelById,
  updateHotel,
  deleteHotel,
  updateRoomPackageStatus,
};
