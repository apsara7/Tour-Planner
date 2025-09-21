import React, { useState } from "react";
import axios from "axios";
import { useNavigate } from "react-router-dom";

export default function AddGuide() {
  const navigate = useNavigate();

  const [form, setForm] = useState({
    guideName: "",
    description: "",
    bio: "",
  });

  const [contactDetails, setContactDetails] = useState({
    phone: "",
    email: "",
    website: "",
    emergencyContact: "",
  });

  const [address, setAddress] = useState({
    street: "",
    city: "",
    province: "",
    postalCode: "",
    country: "Sri Lanka",
  });

  const [experience, setExperience] = useState({
    yearsOfExperience: "",
    specializations: "",
    languages: "",
    certifications: "",
  });

  const [license, setLicense] = useState({
    licenseNumber: "",
    licenseType: "",
    issuedDate: "",
    expiryDate: "",
    issuingAuthority: "",
  });

  const [availability, setAvailability] = useState({
    isAvailable: true,
    workingDays: "",
    workingHours: {
      start: "09:00",
      end: "18:00",
    },
  });

  const [pricing, setPricing] = useState({
    hourlyRate: "",
    dailyRate: "",
    currency: "LKR",
  });

  const [achievements, setAchievements] = useState("");
  const [socialMedia, setSocialMedia] = useState({
    facebook: "",
    instagram: "",
    linkedin: "",
    twitter: "",
  });

  const [images, setImages] = useState([]);

  const handleChange = (e) =>
    setForm({ ...form, [e.target.name]: e.target.value });

  const handleContactChange = (e) =>
    setContactDetails({ ...contactDetails, [e.target.name]: e.target.value });

  const handleAddressChange = (e) =>
    setAddress({ ...address, [e.target.name]: e.target.value });

  const handleExperienceChange = (e) =>
    setExperience({ ...experience, [e.target.name]: e.target.value });

  const handleLicenseChange = (e) =>
    setLicense({ ...license, [e.target.name]: e.target.value });

  const handleAvailabilityChange = (e) => {
    if (e.target.name === "isAvailable") {
      setAvailability({ ...availability, [e.target.name]: e.target.checked });
    } else if (e.target.name === "start" || e.target.name === "end") {
      setAvailability({
        ...availability,
        workingHours: {
          ...availability.workingHours,
          [e.target.name]: e.target.value,
        },
      });
    } else {
      setAvailability({ ...availability, [e.target.name]: e.target.value });
    }
  };

  const handlePricingChange = (e) =>
    setPricing({ ...pricing, [e.target.name]: e.target.value });

  const handleSocialMediaChange = (e) =>
    setSocialMedia({ ...socialMedia, [e.target.name]: e.target.value });

  // Convert FileList to array when selecting new images
  const handleFileChange = (e) => {
    const filesArray = Array.from(e.target.files);
    setImages((prev) => [...prev, ...filesArray]);
  };

  // Remove image by index
  const handleRemoveImage = (index) => {
    setImages((prev) => prev.filter((_, i) => i !== index));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();

    if (!form.guideName) {
      alert("Guide name is required");
      return;
    }

    if (!contactDetails.phone || !contactDetails.email) {
      alert("Phone and email are required");
      return;
    }

    if (!address.street || !address.city || !address.province) {
      alert("Street, city, and province are required");
      return;
    }

    if (
      !license.licenseNumber ||
      !license.licenseType ||
      !license.issuedDate ||
      !license.expiryDate ||
      !license.issuingAuthority
    ) {
      alert("All license fields are required");
      return;
    }

    if (!experience.yearsOfExperience) {
      alert("Years of experience is required");
      return;
    }

    if (!pricing.hourlyRate || !pricing.dailyRate) {
      alert("Hourly and daily rates are required");
      return;
    }

    const formData = new FormData();

    // Add main form fields
    Object.keys(form).forEach((key) => formData.append(key, form[key]));

    // Add nested objects as JSON strings
    formData.append("contactDetails", JSON.stringify(contactDetails));
    formData.append("address", JSON.stringify(address));
    formData.append(
      "experience",
      JSON.stringify({
        ...experience,
        specializations: experience.specializations
          ? experience.specializations.split(",").map((s) => s.trim())
          : [],
        languages: experience.languages
          ? experience.languages.split(",").map((l) => l.trim())
          : [],
        certifications: experience.certifications
          ? experience.certifications.split(",").map((c) => c.trim())
          : [],
      })
    );
    formData.append("license", JSON.stringify(license));
    formData.append(
      "availability",
      JSON.stringify({
        ...availability,
        workingDays: availability.workingDays
          ? availability.workingDays.split(",").map((d) => d.trim())
          : [],
      })
    );
    formData.append("pricing", JSON.stringify(pricing));
    formData.append(
      "achievements",
      JSON.stringify(
        achievements ? achievements.split(",").map((a) => a.trim()) : []
      )
    );
    formData.append("socialMedia", JSON.stringify(socialMedia));

    // Add images
    for (let i = 0; i < images.length; i++) {
      formData.append("images", images[i]);
    }

    try {
      await axios.post(
        `${process.env.REACT_APP_BASE_URL}/api/createGuides`,
        formData,
        { headers: { "Content-Type": "multipart/form-data" } }
      );
      alert("Guide created successfully");
      navigate("/guides");
    } catch (err) {
      console.error(err);
      alert("Failed to create guide");
    }
  };

  return (
    <form
      onSubmit={handleSubmit}
      className="max-w mx-auto p-16 bg-white shadow-lg rounded space-y-6"
    >
      <h2 className="text-2xl font-bold text-blue-700 border-b pb-2">
        Add New Guide
      </h2>

      {/* Basic Information */}
      <div className="space-y-4">
        <h3 className="text-lg font-semibold">Basic Information</h3>
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <input
            type="text"
            name="guideName"
            placeholder="Guide Name"
            value={form.guideName}
            onChange={handleChange}
            className="w-full border rounded p-2"
            required
          />
        </div>
        <textarea
          name="description"
          placeholder="Guide Description"
          value={form.description}
          onChange={handleChange}
          className="w-full border rounded p-2"
          rows="4"
        />
        <textarea
          name="bio"
          placeholder="Personal Bio"
          value={form.bio}
          onChange={handleChange}
          className="w-full border rounded p-2"
          rows="3"
        />
      </div>

      {/* Contact Details */}
      <div className="space-y-4">
        <h3 className="text-lg font-semibold">Contact Details</h3>
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <input
            type="tel"
            name="phone"
            placeholder="Phone Number"
            value={contactDetails.phone}
            onChange={handleContactChange}
            className="w-full border rounded p-2"
            required
          />
          <input
            type="email"
            name="email"
            placeholder="Email"
            value={contactDetails.email}
            onChange={handleContactChange}
            className="w-full border rounded p-2"
            required
          />
          <input
            type="url"
            name="website"
            placeholder="Website"
            value={contactDetails.website}
            onChange={handleContactChange}
            className="w-full border rounded p-2"
          />
          <input
            type="tel"
            name="emergencyContact"
            placeholder="Emergency Contact"
            value={contactDetails.emergencyContact}
            onChange={handleContactChange}
            className="w-full border rounded p-2"
          />
        </div>
      </div>

      {/* Address */}
      <div className="space-y-4">
        <h3 className="text-lg font-semibold">Address</h3>
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <input
            type="text"
            name="street"
            placeholder="Street Address"
            value={address.street}
            onChange={handleAddressChange}
            className="w-full border rounded p-2"
            required
          />
          <input
            type="text"
            name="city"
            placeholder="City"
            value={address.city}
            onChange={handleAddressChange}
            className="w-full border rounded p-2"
            required
          />
          <input
            type="text"
            name="province"
            placeholder="Province"
            value={address.province}
            onChange={handleAddressChange}
            className="w-full border rounded p-2"
            required
          />
          <input
            type="text"
            name="postalCode"
            placeholder="Postal Code"
            value={address.postalCode}
            onChange={handleAddressChange}
            className="w-full border rounded p-2"
          />
          <input
            type="text"
            name="country"
            placeholder="Country"
            value={address.country}
            onChange={handleAddressChange}
            className="w-full border rounded p-2"
          />
        </div>
      </div>

      {/* Experience */}
      <div className="space-y-4">
        <h3 className="text-lg font-semibold">Experience & Qualifications</h3>
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <input
            type="number"
            name="yearsOfExperience"
            placeholder="Years of Experience"
            value={experience.yearsOfExperience}
            onChange={handleExperienceChange}
            className="w-full border rounded p-2"
            required
            min="0"
          />
          <input
            type="text"
            name="specializations"
            placeholder="Specializations (comma separated)"
            value={experience.specializations}
            onChange={handleExperienceChange}
            className="w-full border rounded p-2"
          />
          <input
            type="text"
            name="languages"
            placeholder="Languages (comma separated)"
            value={experience.languages}
            onChange={handleExperienceChange}
            className="w-full border rounded p-2"
          />
          <input
            type="text"
            name="certifications"
            placeholder="Certifications (comma separated)"
            value={experience.certifications}
            onChange={handleExperienceChange}
            className="w-full border rounded p-2"
          />
        </div>
      </div>

      {/* License Information */}
      <div className="space-y-4">
        <h3 className="text-lg font-semibold">License Information</h3>
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <input
            type="text"
            name="licenseNumber"
            placeholder="License Number"
            value={license.licenseNumber}
            onChange={handleLicenseChange}
            className="w-full border rounded p-2"
            required
          />
          <input
            type="text"
            name="licenseType"
            placeholder="License Type"
            value={license.licenseType}
            onChange={handleLicenseChange}
            className="w-full border rounded p-2"
            required
          />
          <input
            type="date"
            name="issuedDate"
            placeholder="Issued Date"
            value={license.issuedDate}
            onChange={handleLicenseChange}
            className="w-full border rounded p-2"
            required
          />
          <input
            type="date"
            name="expiryDate"
            placeholder="Expiry Date"
            value={license.expiryDate}
            onChange={handleLicenseChange}
            className="w-full border rounded p-2"
            required
          />
          <input
            type="text"
            name="issuingAuthority"
            placeholder="Issuing Authority"
            value={license.issuingAuthority}
            onChange={handleLicenseChange}
            className="w-full border rounded p-2 sm:col-span-2"
            required
          />
        </div>
        <input
          type="file"
          name="licenseImage"
          accept="image/*"
          className="w-full border p-2"
        />
      </div>

      {/* Availability */}
      <div className="space-y-4">
        <h3 className="text-lg font-semibold">Availability</h3>
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <div className="flex items-center space-x-2">
            <input
              type="checkbox"
              name="isAvailable"
              checked={availability.isAvailable}
              onChange={handleAvailabilityChange}
              className="border rounded"
            />
            <label>Currently Available</label>
          </div>
          <input
            type="text"
            name="workingDays"
            placeholder="Working Days (comma separated)"
            value={availability.workingDays}
            onChange={handleAvailabilityChange}
            className="w-full border rounded p-2"
          />
          <input
            type="time"
            name="start"
            placeholder="Start Time"
            value={availability.workingHours.start}
            onChange={handleAvailabilityChange}
            className="w-full border rounded p-2"
          />
          <input
            type="time"
            name="end"
            placeholder="End Time"
            value={availability.workingHours.end}
            onChange={handleAvailabilityChange}
            className="w-full border rounded p-2"
          />
        </div>
      </div>

      {/* Pricing */}
      <div className="space-y-4">
        <h3 className="text-lg font-semibold">Pricing</h3>
        <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
          <input
            type="number"
            name="hourlyRate"
            placeholder="Hourly Rate"
            value={pricing.hourlyRate}
            onChange={handlePricingChange}
            className="w-full border rounded p-2"
            required
            min="0"
          />
          <input
            type="number"
            name="dailyRate"
            placeholder="Daily Rate"
            value={pricing.dailyRate}
            onChange={handlePricingChange}
            className="w-full border rounded p-2"
            required
            min="0"
          />
          <select
            name="currency"
            value={pricing.currency}
            onChange={handlePricingChange}
            className="w-full border rounded p-2"
          >
            <option value="LKR">LKR</option>
            <option value="USD">USD</option>
            <option value="EUR">EUR</option>
          </select>
        </div>
      </div>

      {/* Achievements */}
      <div className="space-y-4">
        <h3 className="text-lg font-semibold">Achievements</h3>
        <textarea
          placeholder="Achievements (comma separated)"
          value={achievements}
          onChange={(e) => setAchievements(e.target.value)}
          className="w-full border rounded p-2"
          rows="3"
        />
      </div>

      {/* Social Media */}
      <div className="space-y-4">
        <h3 className="text-lg font-semibold">Social Media</h3>
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <input
            type="url"
            name="facebook"
            placeholder="Facebook URL"
            value={socialMedia.facebook}
            onChange={handleSocialMediaChange}
            className="w-full border rounded p-2"
          />
          <input
            type="url"
            name="instagram"
            placeholder="Instagram URL"
            value={socialMedia.instagram}
            onChange={handleSocialMediaChange}
            className="w-full border rounded p-2"
          />
          <input
            type="url"
            name="linkedin"
            placeholder="LinkedIn URL"
            value={socialMedia.linkedin}
            onChange={handleSocialMediaChange}
            className="w-full border rounded p-2"
          />
          <input
            type="url"
            name="twitter"
            placeholder="Twitter URL"
            value={socialMedia.twitter}
            onChange={handleSocialMediaChange}
            className="w-full border rounded p-2"
          />
        </div>
      </div>

      {/* Images */}
      <div className="space-y-4">
        <h3 className="text-lg font-semibold">Images</h3>
        <input
          type="file"
          multiple
          accept="image/*"
          onChange={handleFileChange}
          className="w-full border p-2"
        />

        <div className="flex flex-wrap gap-4 mt-2">
          {images.map((file, index) => (
            <div key={index} className="relative w-24 h-24">
              <img
                src={URL.createObjectURL(file)}
                alt={`preview ${index}`}
                onLoad={(e) => URL.revokeObjectURL(e.target.src)}
                className="w-full h-full object-cover rounded border"
              />
              <button
                type="button"
                onClick={() => handleRemoveImage(index)}
                className="absolute top-0 right-0 bg-red-600 text-white text-xs px-1 rounded-full hover:bg-red-700"
              >
                X
              </button>
            </div>
          ))}
        </div>
      </div>

      <p className="text-sm text-gray-500">
        Upload high-quality images of the guide
      </p>

      <button
        type="submit"
        className="w-full bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg shadow transition"
      >
        Create Guide
      </button>
    </form>
  );
}
