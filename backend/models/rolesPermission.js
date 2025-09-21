const mongoose = require('mongoose');

const PermissionsSchema = new mongoose.Schema({
  roleName: { type: String, required: true, unique: true },
  permissions: { type: Map, of: mongoose.Schema.Types.Mixed, default: {} }
});

module.exports = mongoose.model('RolePermissions', PermissionsSchema);
