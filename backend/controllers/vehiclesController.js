const Vehicle = require("../models/vehicle");
const path = require("path");
const fs = require("fs");

const createVehicle = async (req, res) => {
  try {
    const { type, passengerAmount, owner, rentPrice, driverCost, status } =
      req.body;
    const images = req.files
      ? req.files.map((f) => `uploads/${f.filename}`)
      : [];
    const newVehicle = new Vehicle({
      type,
      passengerAmount,
      owner: typeof owner === "string" ? JSON.parse(owner) : owner,
      rentPrice,
      driverCost: driverCost || 0, // Add driverCost field
      status,
      images,
    });
    await newVehicle.save();
    res.status(201).json({ status: "Success", vehicle: newVehicle });
  } catch (err) {
    res.status(500).json({ status: "Error", message: err.message });
  }
};

const getAllVehicles = async (req, res) => {
  try {
    // Filtering
    const { type, status, ownerName } = req.query;
    let filter = {};
    if (type) filter.type = type;
    if (status) filter.status = status;
    if (ownerName) filter["owner.name"] = ownerName;

    const vehicles = await Vehicle.find(filter);
    const response = vehicles.map((v) => ({
      ...v.toObject(),
      images: v.images.map(
        (img) => `${req.protocol}://${req.get("host")}/${img}`
      ),
    }));
    res.json(response);
  } catch (err) {
    res.status(500).json({ status: "Error", message: err.message });
  }
};

const getVehicleById = async (req, res) => {
  try {
    const vehicle = await Vehicle.findById(req.params.id);
    if (!vehicle) return res.status(404).json({ message: "Vehicle not found" });
    const obj = vehicle.toObject();
    obj.images = obj.images.map(
      (img) => `${req.protocol}://${req.get("host")}/${img}`
    );
    res.json({ status: "Success", vehicle: obj });
  } catch (err) {
    res.status(500).json({ status: "Error", message: err.message });
  }
};

const updateVehicle = async (req, res) => {
  try {
    const vehicle = await Vehicle.findById(req.params.id);
    if (!vehicle) return res.status(404).json({ message: "Vehicle not found" });

    // Handle images
    const newImages = req.files
      ? req.files.map((f) => `uploads/${f.filename}`)
      : [];
    const keptImages = req.body.existingImages
      ? JSON.parse(req.body.existingImages)
      : vehicle.images || [];
    vehicle.images = [...keptImages, ...newImages];

    // Update fields
    if (req.body.type) vehicle.type = req.body.type;
    if (req.body.passengerAmount)
      vehicle.passengerAmount = req.body.passengerAmount;
    if (req.body.owner)
      vehicle.owner =
        typeof req.body.owner === "string"
          ? JSON.parse(req.body.owner)
          : req.body.owner;
    if (req.body.rentPrice) vehicle.rentPrice = req.body.rentPrice;
    if (req.body.driverCost) vehicle.driverCost = req.body.driverCost; // Add driverCost field
    if (req.body.status) vehicle.status = req.body.status;

    await vehicle.save();
    res.json({ status: "Success", vehicle });
  } catch (err) {
    res.status(500).json({ status: "Error", message: err.message });
  }
};

const deleteVehicle = async (req, res) => {
  try {
    const vehicle = await Vehicle.findById(req.params.id);
    if (!vehicle) return res.status(404).json({ message: "Vehicle not found" });
    vehicle.images.forEach((img) => {
      const filePath = path.resolve(img);
      if (fs.existsSync(filePath)) fs.unlinkSync(filePath);
    });
    await Vehicle.findByIdAndDelete(req.params.id);
    res.json({ status: "Success", message: "Vehicle deleted" });
  } catch (err) {
    res.status(500).json({ status: "Error", message: err.message });
  }
};

module.exports = {
  createVehicle,
  getAllVehicles,
  deleteVehicle,
  getVehicleById,
  updateVehicle,
};
