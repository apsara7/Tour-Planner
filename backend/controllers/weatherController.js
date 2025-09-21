const WeatherAlert = require("../models/weatherAlert");

const createAlert = async (req, res) => {
  try {
    const alert = new WeatherAlert(req.body);
    await alert.save();
    res.status(201).json({ status: "Success", alert });
  } catch (err) {
    res.status(500).json({ status: "Error", message: err.message });
  }
};

const getAllAlerts = async (req, res) => {
  try {
    const { region, severity } = req.query;
    let filter = {};
    if (region) filter.region = region;
    if (severity) filter.severity = severity;
    const alerts = await WeatherAlert.find(filter).sort({ issuedAt: -1 });
    res.json(alerts);
  } catch (err) {
    res.status(500).json({ status: "Error", message: err.message });
  }
};

const getAlertById = async (req, res) => {
  try {
    const alert = await WeatherAlert.findById(req.params.id);
    if (!alert) return res.status(404).json({ message: "Alert not found" });
    res.json(alert);
  } catch (err) {
    res.status(500).json({ status: "Error", message: err.message });
  }
};

const updateAlert = async (req, res) => {
  try {
    const alert = await WeatherAlert.findByIdAndUpdate(
      req.params.id,
      req.body,
      { new: true }
    );
    if (!alert) return res.status(404).json({ message: "Alert not found" });
    res.json(alert);
  } catch (err) {
    res.status(500).json({ status: "Error", message: err.message });
  }
};

const deleteAlert = async (req, res) => {
  try {
    await WeatherAlert.findByIdAndDelete(req.params.id);
    res.json({ status: "Success", message: "Alert deleted" });
  } catch (err) {
    res.status(500).json({ status: "Error", message: err.message });
  }
};

module.exports = {
  createAlert,
  getAllAlerts,
  deleteAlert,
  getAlertById,
  updateAlert,
};
