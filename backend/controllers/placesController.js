const Place = require("../models/places");
const path = require("path");
const fs = require("fs");

// ✅ Create Place
const createPlace = async (req, res) => {
  try {
    const {
      name,
      description,
      province,
      district,
      location,
      mapUrl,
      latitude,
      longitude,
      visitingHours,
      entryFee,
      bestTimeToVisit,
      transportation,
      highlights,
    } = req.body;

    if (!name) return res.status(400).json({ message: "Place name required" });

    // Handle images
    const imagePaths = req.files
      ? req.files.map((file) => `uploads/${file.filename}`)
      : [];

    if (imagePaths.length < 1) {
      return res
        .status(400)
        .json({ message: "Please upload at least 1 images" });
    }

    const newPlace = new Place({
      name,
      description,
      province,
      district,
      location,
      mapUrl,
      latitude,
      longitude,
      visitingHours,
      entryFee,
      bestTimeToVisit,
      transportation,
      highlights: highlights ? highlights.split(",").map((h) => h.trim()) : [],
      images: imagePaths,
    });

    await newPlace.save();
    res.status(201).json({ status: "Success", place: newPlace });
  } catch (err) {
    res.status(500).json({ status: "Error", message: err.message });
  }
};

// ✅ Get All Places
const getAllPlaces = async (req, res) => {
  try {
    const places = await Place.find({});
    const response = places.map((place) => {
      const obj = place.toObject();
      obj.images = obj.images.map(
        (img) => `${req.protocol}://${req.get("host")}/${img}`
      );
      return obj;
    });
    res.json(response);
  } catch (err) {
    res.status(500).json({ status: "Error", message: err.message });
  }
};

// ✅ Get Place by ID
const getPlaceById = async (req, res) => {
  try {
    const place = await Place.findById(req.params.id);
    if (!place) return res.status(404).json({ message: "Place not found" });

    const obj = place.toObject();

    // Format images with full URLs
    obj.images = obj.images.map(
      (img) => `${req.protocol}://${req.get("host")}/${img}`
    );

    // Format highlights as comma-separated string for editing (reverse of create)
    obj.highlights = obj.highlights ? obj.highlights.join(", ") : "";

    res.json({ status: "Success", place: obj });
  } catch (err) {
    res.status(500).json({ status: "Error", message: err.message });
  }
};

// ✅ Update Place
const updatePlace = async (req, res) => {
  try {
    const {
      name,
      description,
      province,
      district,
      location,
      mapUrl,
      latitude,
      longitude,
      visitingHours,
      entryFee,
      bestTimeToVisit,
      transportation,
      highlights,
    } = req.body;

    const place = await Place.findById(req.params.id);
    if (!place) return res.status(404).json({ message: "Place not found" });

    // Handle images - preserve existing and add new ones
    const newImageFiles = req.files || [];
    const newImages = newImageFiles.map((file) => `uploads/${file.filename}`);

    // frontend sends the list of images user kept
    const keptImages = req.body.existingImages
      ? JSON.parse(req.body.existingImages)
      : place.images || [];

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

    place.images = [...cleanedKeptImages, ...newImages];

    // Update fields with same validation as create
    if (name) place.name = name;
    if (description !== undefined) place.description = description;
    if (province !== undefined) place.province = province;
    if (district !== undefined) place.district = district;
    if (location !== undefined) place.location = location;
    if (mapUrl !== undefined) place.mapUrl = mapUrl;
    if (latitude !== undefined) place.latitude = latitude;
    if (longitude !== undefined) place.longitude = longitude;
    if (visitingHours !== undefined) place.visitingHours = visitingHours;
    if (entryFee !== undefined) place.entryFee = entryFee;
    if (bestTimeToVisit !== undefined) place.bestTimeToVisit = bestTimeToVisit;
    if (transportation !== undefined) place.transportation = transportation;

    // Handle highlights same as create function
    if (highlights !== undefined) {
      place.highlights = highlights
        ? highlights.split(",").map((h) => h.trim())
        : [];
    }

    await place.save();
    res.json({ status: "Success", place });
  } catch (err) {
    res.status(500).json({ status: "Error", message: err.message });
  }
};

// ✅ Delete Place
const deletePlace = async (req, res) => {
  try {
    const place = await Place.findById(req.params.id);
    if (!place) return res.status(404).json({ message: "Place not found" });

    place.images.forEach((img) => {
      const filePath = path.resolve(img);
      if (fs.existsSync(filePath)) fs.unlinkSync(filePath);
    });

    await Place.findByIdAndDelete(req.params.id);
    res.json({ status: "Success", message: "Place deleted" });
  } catch (err) {
    res.status(500).json({ status: "Error", message: err.message });
  }
};

module.exports = {
  createPlace,
  getAllPlaces,
  getPlaceById,
  updatePlace,
  deletePlace,
};
