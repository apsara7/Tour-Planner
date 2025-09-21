// server/controllers/securityOptionController.js
const SecurityOption = require("../models/securityOption");

const createOption = async (req, res) => {
  try {
    const option = new SecurityOption(req.body);
    await option.save();
    res.status(201).json({ status: "Success", option });
  } catch (err) {
    res.status(500).json({ status: "Error", message: err.message });
  }
};

const getAllOptions = async (req, res) => {
  try {
    const { type, region } = req.query;
    let filter = {};
    if (type) filter.type = type;
    if (region) filter.region = region;
    const options = await SecurityOption.find(filter);
    res.json(options);
  } catch (err) {
    res.status(500).json({ status: "Error", message: err.message });
  }
};

const getOptionById = async (req, res) => {
  try {
    const option = await SecurityOption.findById(req.params.id);
    if (!option) return res.status(404).json({ message: "Option not found" });
    res.json(option);
  } catch (err) {
    res.status(500).json({ status: "Error", message: err.message });
  }
};

const updateOption = async (req, res) => {
  try {
    const option = await SecurityOption.findByIdAndUpdate(
      req.params.id,
      req.body,
      { new: true }
    );
    if (!option) return res.status(404).json({ message: "Option not found" });
    res.json(option);
  } catch (err) {
    res.status(500).json({ status: "Error", message: err.message });
  }
};

const deleteOption = async (req, res) => {
  try {
    await SecurityOption.findByIdAndDelete(req.params.id);
    res.json({ status: "Success", message: "Option deleted" });
  } catch (err) {
    res.status(500).json({ status: "Error", message: err.message });
  }
};

module.exports = {
  createOption,
  getAllOptions,
  getOptionById,
  updateOption,
  deleteOption,
};