import React, { useEffect, useState } from "react";
import axios from "axios";
import { useNavigate, useParams } from "react-router-dom";

export default function EditVehicle() {
  const { id } = useParams();
  const navigate = useNavigate();

  const [form, setForm] = useState({
    type: "",
    passengerAmount: "",
    owner: { name: "", contact: "", email: "" }, // Add email field
    rentPrice: "",
    driverCost: "",
    status: "available",
  });
  const [images, setImages] = useState([]);
  const [existingImages, setExistingImages] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchVehicle = async () => {
      try {
        const response = await axios.get(
          `${process.env.REACT_APP_BASE_URL}/api/vehicles/${id}`
        );

        if (response.data.status === "Success") {
          const vehicle = response.data.vehicle;

          setForm({
            type: vehicle.type || "",
            passengerAmount: vehicle.passengerAmount || "",
            owner: {
              name: vehicle.owner?.name || "",
              contact: vehicle.owner?.phone || "", // Fix: use phone field
              email: vehicle.owner?.email || "", // Add email field
            },
            rentPrice: vehicle.rentPrice || "",
            driverCost: vehicle.driverCost || "",
            status: vehicle.status || "available",
          });

          setExistingImages(vehicle.images || []);
        }
      } catch (err) {
        console.error("Error fetching vehicle:", err);
        alert("Failed to load vehicle data");
        navigate("/vehicles");
      } finally {
        setLoading(false);
      }
    };

    if (id) {
      fetchVehicle();
    }
  }, [id, navigate]);

  const handleChange = (e) => {
    if (e.target.name.startsWith("owner.")) {
      const ownerField = e.target.name.split(".")[1];
      setForm({
        ...form,
        owner: {
          ...form.owner,
          [ownerField]: e.target.value,
        },
      });
    } else {
      setForm({ ...form, [e.target.name]: e.target.value });
    }
  };

  const handleFileChange = (e) => {
    const filesArray = Array.from(e.target.files);
    setImages((prev) => [...prev, ...filesArray]);
  };

  const handleRemoveNewImage = (index) => {
    setImages((prev) => prev.filter((_, i) => i !== index));
  };

  const handleRemoveExistingImage = (index) => {
    setExistingImages((prev) => prev.filter((_, i) => i !== index));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();

    const formData = new FormData();

    // Add text fields
    Object.keys(form).forEach((key) => {
      if (key === "owner") {
        // Fix: map contact to phone and include email
        const ownerData = {
          name: form.owner.name,
          phone: form.owner.contact,
          email: form.owner.email,
        };
        formData.append(key, JSON.stringify(ownerData));
      } else {
        formData.append(key, form[key]);
      }
    });

    // Add existing images to keep
    formData.append("existingImages", JSON.stringify(existingImages));

    // Add new images
    for (let i = 0; i < images.length; i++) {
      formData.append("images", images[i]);
    }

    try {
      await axios.put(
        `${process.env.REACT_APP_BASE_URL}/api/vehicles/${id}`,
        formData,
        { headers: { "Content-Type": "multipart/form-data" } }
      );
      alert("Vehicle updated successfully");
      navigate("/vehicles");
    } catch (err) {
      console.error(err);
      alert("Failed to update vehicle");
    }
  };

  if (loading) {
    return (
      <div className="max-w-4xl mx-auto p-8 bg-white shadow-lg rounded">
        <div className="text-center">Loading vehicle details...</div>
      </div>
    );
  }

  return (
    <form
      onSubmit={handleSubmit}
      className="max-w-4xl mx-auto p-8 bg-white shadow-lg rounded space-y-6"
    >
      <h2 className="text-2xl font-bold text-blue-700 border-b pb-2">
        Edit Vehicle
      </h2>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        <div>
          <label className="block text-sm font-medium mb-1">Vehicle Type</label>
          <input
            type="text"
            name="type"
            value={form.type}
            onChange={handleChange}
            className="w-full border rounded p-3"
            required
          />
        </div>

        <div>
          <label className="block text-sm font-medium mb-1">
            Passenger Capacity
          </label>
          <input
            type="number"
            name="passengerAmount"
            value={form.passengerAmount}
            onChange={handleChange}
            className="w-full border rounded p-3"
            required
          />
        </div>

        <div>
          <label className="block text-sm font-medium mb-1">Owner Name</label>
          <input
            type="text"
            name="owner.name"
            value={form.owner.name}
            onChange={handleChange}
            className="w-full border rounded p-3"
            required
          />
        </div>

        <div>
          <label className="block text-sm font-medium mb-1">
            Owner Contact (Phone)
          </label>
          <input
            type="text"
            name="owner.contact"
            value={form.owner.contact}
            onChange={handleChange}
            className="w-full border rounded p-3"
            required
          />
        </div>

        {/* Add Owner Email Field */}
        <div>
          <label className="block text-sm font-medium mb-1">Owner Email</label>
          <input
            type="email"
            name="owner.email"
            value={form.owner.email}
            onChange={handleChange}
            className="w-full border rounded p-3"
          />
        </div>

        <div>
          <label className="block text-sm font-medium mb-1">
            Rent Price (LKR) per Day
          </label>
          <input
            type="number"
            name="rentPrice"
            value={form.rentPrice}
            onChange={handleChange}
            className="w-full border rounded p-3"
            required
          />
        </div>

        {/* Driver Cost Field */}
        <div>
          <label className="block text-sm font-medium mb-1">
            Driver Cost (LKR) per Day
          </label>
          <input
            type="number"
            name="driverCost"
            value={form.driverCost}
            onChange={handleChange}
            className="w-full border rounded p-3"
          />
        </div>

        <div>
          <label className="block text-sm font-medium mb-1">Status</label>
          <select
            name="status"
            value={form.status}
            onChange={handleChange}
            className="w-full border rounded p-3"
          >
            <option value="available">Available</option>
            <option value="rented">Rented</option>
            <option value="maintenance">Maintenance</option>
          </select>
        </div>
      </div>

      {/* Existing Images */}
      {existingImages.length > 0 && (
        <div>
          <h3 className="text-lg font-semibold mb-3">Current Images:</h3>
          <div className="flex flex-wrap gap-4 mb-4">
            {existingImages.map((imageUrl, index) => (
              <div key={index} className="relative w-24 h-24">
                <img
                  src={imageUrl}
                  alt={`existing ${index}`}
                  className="w-full h-full object-cover rounded border"
                />
                <button
                  type="button"
                  onClick={() => handleRemoveExistingImage(index)}
                  className="absolute top-0 right-0 bg-red-600 text-white text-xs px-1 rounded-full hover:bg-red-700"
                >
                  X
                </button>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* Add New Images */}
      <div>
        <h3 className="text-lg font-semibold mb-2">Add New Images:</h3>
        <input
          type="file"
          multiple
          accept="image/*"
          onChange={handleFileChange}
          className="w-full border p-3 rounded"
        />

        <div className="flex flex-wrap gap-4 mt-3">
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
                onClick={() => handleRemoveNewImage(index)}
                className="absolute top-0 right-0 bg-red-600 text-white text-xs px-1 rounded-full hover:bg-red-700"
              >
                X
              </button>
            </div>
          ))}
        </div>
      </div>

      <div className="flex gap-4">
        <button
          type="button"
          onClick={() => navigate("/vehicles")}
          className="flex-1 bg-gray-500 hover:bg-gray-600 text-white px-6 py-3 rounded-lg shadow transition"
        >
          Cancel
        </button>
        <button
          type="submit"
          className="flex-1 bg-blue-600 hover:bg-blue-700 text-white px-6 py-3 rounded-lg shadow transition"
        >
          Update Vehicle
        </button>
      </div>
    </form>
  );
}
