// server/models/securityOption.js
const mongoose = require("mongoose");

const securityOptionSchema = new mongoose.Schema({
  type: String,
  name: String,
  mobiles: {
    type: [String],
    validate: {
      validator: function (v) {
        // For emergency contacts, require exactly 2 mobile numbers
        return this.type !== "emergency" || v.length === 2;
      },
      message: "Emergency contacts must have exactly 2 mobile numbers",
    },
  },
  emails: {
    type: [String],
    validate: {
      validator: function (v) {
        // For emergency contacts, require exactly 2 email addresses
        return this.type !== "emergency" || v.length === 2;
      },
      message: "Emergency contacts must have exactly 2 email addresses",
    },
  },
  address: String,
  otherContacts: [String],
  region: String,
  description: String,
});

module.exports = mongoose.model("SecurityOption", securityOptionSchema);
