import React, { useEffect, useState } from "react";
import axios from "axios";
import { useNavigate, useParams } from "react-router-dom";

export default function EditHotel() {
  const { id } = useParams();
  const navigate = useNavigate();

  const [form, setForm] = useState({
    hotelName: "",
    description: "",
    rating: 3,
    checkInTime: "14:00",
    checkOutTime: "11:00",
  });

  const [contactDetails, setContactDetails] = useState({
    phone: "",
    email: "",
    website: "",
    fax: "",
  });

  const [address, setAddress] = useState({
    street: "",
    city: "",
    province: "",
    postalCode: "",
    country: "Sri Lanka",
  });

  const [otherContacts, setOtherContacts] = useState({
    managerName: "",
    managerPhone: "",
    managerEmail: "",
    emergencyContact: "",
  });

  const [policies, setPolicies] = useState({
    cancellation: "",
    petPolicy: "",
    smokingPolicy: "",
    otherPolicies: "",
  });

  const [roomPackages, setRoomPackages] = useState([]);
  const [facilities, setFacilities] = useState("");
  const [images, setImages] = useState([]);
  const [existingImages, setExistingImages] = useState([]);
  const [packageImages, setPackageImages] = useState({}); // Store new images for each package
  const [existingPackageImages, setExistingPackageImages] = useState({}); // Store existing images for each package
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchHotel = async () => {
      try {
        const response = await axios.get(
          `${process.env.REACT_APP_BASE_URL}/api/viewHotelByID/${id}`
        );

        if (response.data.status === "Success") {
          const hotel = response.data.hotel;

          // Set form data
          setForm({
            hotelName: hotel.hotelName || "",
            description: hotel.description || "",
            rating: hotel.rating || 3,
            checkInTime: hotel.checkInTime || "14:00",
            checkOutTime: hotel.checkOutTime || "11:00",
          });

          // Set nested objects
          setContactDetails(
            hotel.contactDetails || {
              phone: "",
              email: "",
              website: "",
              fax: "",
            }
          );

          setAddress(
            hotel.address || {
              street: "",
              city: "",
              province: "",
              postalCode: "",
              country: "Sri Lanka",
            }
          );

          setOtherContacts(
            hotel.otherContacts || {
              managerName: "",
              managerPhone: "",
              managerEmail: "",
              emergencyContact: "",
            }
          );

          setPolicies(
            hotel.policies || {
              cancellation: "",
              petPolicy: "",
              smokingPolicy: "",
              otherPolicies: "",
            }
          );

          setRoomPackages(hotel.roomPackages || []);
          setFacilities(hotel.facilities ? hotel.facilities.join(", ") : "");

          // Clean existing hotel images URLs
          const cleanedHotelImages = (hotel.images || []).map((img) => {
            if (typeof img === "string") {
              // Extract just the filename from URLs like "http://localhost:4066/http://localhost:4066/uploads/filename.jpg"
              const match = img.match(
                /uploads\/[^\/]+\.(jpg|jpeg|png|gif|webp)$/i
              );
              return match ? match[0] : img;
            }
            return img;
          });
          setExistingImages(cleanedHotelImages);

          // Set existing package images and clean URLs
          const packageImagesData = {};
          if (hotel.roomPackages) {
            hotel.roomPackages.forEach((pkg, index) => {
              const cleanedImages = (pkg.images || []).map((img) => {
                if (typeof img === "string") {
                  // Extract just the filename from URLs like "http://localhost:4066/http://localhost:4066/uploads/filename.jpg"
                  const match = img.match(
                    /uploads\/[^\/]+\.(jpg|jpeg|png|gif|webp)$/i
                  );
                  return match ? match[0] : img;
                }
                return img;
              });
              packageImagesData[index] = cleanedImages;
            });
          }
          setExistingPackageImages(packageImagesData);

          // Debug: Log the package images to see what we're getting
          console.log("Package images data:", packageImagesData);
        }
      } catch (err) {
        console.error("Error fetching hotel:", err);
        alert("Failed to load hotel data");
        navigate("/hotels");
      } finally {
        setLoading(false);
      }
    };

    if (id) {
      fetchHotel();
    }
  }, [id, navigate]);

  const handleChange = (e) =>
    setForm({ ...form, [e.target.name]: e.target.value });

  const handleContactChange = (e) =>
    setContactDetails({ ...contactDetails, [e.target.name]: e.target.value });

  const handleAddressChange = (e) =>
    setAddress({ ...address, [e.target.name]: e.target.value });

  const handleOtherContactsChange = (e) =>
    setOtherContacts({ ...otherContacts, [e.target.name]: e.target.value });

  const handlePoliciesChange = (e) =>
    setPolicies({ ...policies, [e.target.name]: e.target.value });

  const handleRoomPackageChange = (index, field, value) => {
    const updatedPackages = [...roomPackages];
    updatedPackages[index][field] = value;

    // Preserve existing images when updating other fields
    if (field !== "images" && existingPackageImages[index]) {
      updatedPackages[index].images = existingPackageImages[index];
    }

    setRoomPackages(updatedPackages);
  };

  const addRoomPackage = () => {
    setRoomPackages([
      ...roomPackages,
      {
        packageName: "",
        roomType: "",
        price: "",
        capacity: "",
        amenities: "",
        description: "",
        status: "active",
        availableRooms: "",
        totalRooms: "",
        images: [],
      },
    ]);
  };

  const removeRoomPackage = (index) => {
    if (roomPackages.length > 1) {
      setRoomPackages(roomPackages.filter((_, i) => i !== index));
    }
  };

  // Convert FileList to array when selecting new images
  const handleFileChange = (e) => {
    const filesArray = Array.from(e.target.files);
    setImages((prev) => [...prev, ...filesArray]);
  };

  // Remove new image by index
  const handleRemoveNewImage = (index) => {
    setImages((prev) => prev.filter((_, i) => i !== index));
  };

  // Remove existing image by index
  const handleRemoveExistingImage = (index) => {
    setExistingImages((prev) => prev.filter((_, i) => i !== index));
  };

  // Handle package image uploads
  const handlePackageFileChange = (packageIndex, e) => {
    const filesArray = Array.from(e.target.files);
    setPackageImages((prev) => ({
      ...prev,
      [packageIndex]: [...(prev[packageIndex] || []), ...filesArray],
    }));
  };

  // Remove new package image by index
  const handleRemoveNewPackageImage = (packageIndex, imageIndex) => {
    setPackageImages((prev) => ({
      ...prev,
      [packageIndex]:
        prev[packageIndex]?.filter((_, i) => i !== imageIndex) || [],
    }));
  };

  // Remove existing package image by index
  const handleRemoveExistingPackageImage = (packageIndex, imageIndex) => {
    setExistingPackageImages((prev) => ({
      ...prev,
      [packageIndex]:
        prev[packageIndex]?.filter((_, i) => i !== imageIndex) || [],
    }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();

    if (!form.hotelName) {
      alert("Hotel name is required");
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

    const formData = new FormData();

    // Add main form fields
    Object.keys(form).forEach((key) => formData.append(key, form[key]));

    // Add nested objects as JSON strings
    formData.append("contactDetails", JSON.stringify(contactDetails));
    formData.append("address", JSON.stringify(address));
    formData.append("otherContacts", JSON.stringify(otherContacts));
    formData.append("policies", JSON.stringify(policies));

    // Prepare room packages - don't include images here as they're handled separately
    const roomPackagesWithoutImages = roomPackages.map((pkg) => {
      const { images, ...pkgWithoutImages } = pkg;
      return pkgWithoutImages;
    });

    formData.append("roomPackages", JSON.stringify(roomPackagesWithoutImages));
    formData.append("facilities", facilities);

    // Add existing images to prevent deletion
    formData.append("existingImages", JSON.stringify(existingImages));

    // Add existing package images to prevent deletion
    formData.append(
      "existingPackageImages",
      JSON.stringify(existingPackageImages)
    );

    // Add new images
    for (let i = 0; i < images.length; i++) {
      formData.append("images", images[i]);
    }

    // Add package images
    Object.keys(packageImages).forEach((packageIndex) => {
      const images = packageImages[packageIndex];
      images.forEach((file) => {
        formData.append(`packageImages_${packageIndex}`, file);
      });
    });

    try {
      await axios.put(
        `${process.env.REACT_APP_BASE_URL}/api/editHotel/${id}`,
        formData,
        { headers: { "Content-Type": "multipart/form-data" } }
      );
      alert("Hotel updated successfully");
      navigate("/hotels");
    } catch (err) {
      console.error(err);
      alert("Failed to update hotel");
    }
  };

  if (loading) {
    return (
      <div className="max-w mx-auto p-16 bg-white shadow-lg rounded">
        <div className="text-center">Loading...</div>
      </div>
    );
  }

  return (
    <form
      onSubmit={handleSubmit}
      className="max-w mx-auto p-16 bg-white shadow-lg rounded space-y-6"
    >
      <h2 className="text-2xl font-bold text-blue-700 border-b pb-2">
        Edit Hotel
      </h2>

      {/* Basic Information */}
      <div className="space-y-4">
        <h3 className="text-lg font-semibold">Basic Information</h3>
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <input
            type="text"
            name="hotelName"
            placeholder="Hotel Name"
            value={form.hotelName}
            onChange={handleChange}
            className="w-full border rounded p-2"
            required
          />
          <input
            type="number"
            min="1"
            max="5"
            step="0.1"
            name="rating"
            placeholder="Rating (1-5)"
            value={form.rating}
            onChange={handleChange}
            className="w-full border rounded p-2"
          />
        </div>
        <textarea
          name="description"
          placeholder="Hotel Description"
          value={form.description}
          onChange={handleChange}
          className="w-full border rounded p-2"
          rows="4"
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
            name="fax"
            placeholder="Fax"
            value={contactDetails.fax}
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

      {/* Other Contacts */}
      <div className="space-y-4">
        <h3 className="text-lg font-semibold">Other Contacts</h3>
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <input
            type="text"
            name="managerName"
            placeholder="Manager Name"
            value={otherContacts.managerName}
            onChange={handleOtherContactsChange}
            className="w-full border rounded p-2"
          />
          <input
            type="tel"
            name="managerPhone"
            placeholder="Manager Phone"
            value={otherContacts.managerPhone}
            onChange={handleOtherContactsChange}
            className="w-full border rounded p-2"
          />
          <input
            type="email"
            name="managerEmail"
            placeholder="Manager Email"
            value={otherContacts.managerEmail}
            onChange={handleOtherContactsChange}
            className="w-full border rounded p-2"
          />
          <input
            type="tel"
            name="emergencyContact"
            placeholder="Emergency Contact"
            value={otherContacts.emergencyContact}
            onChange={handleOtherContactsChange}
            className="w-full border rounded p-2"
          />
        </div>
      </div>

      {/* Room Packages */}
      <div className="space-y-4">
        <div className="flex justify-between items-center">
          <h3 className="text-lg font-semibold">Room Packages</h3>
          <button
            type="button"
            onClick={addRoomPackage}
            className="bg-green-600 text-white px-3 py-1 rounded text-sm hover:bg-green-700"
          >
            + Add Package
          </button>
        </div>

        {roomPackages.map((pkg, index) => (
          <div key={index} className="border rounded p-4 space-y-4">
            <div className="flex justify-between items-center">
              <h4 className="font-medium">Package {index + 1}</h4>
              {roomPackages.length > 1 && (
                <button
                  type="button"
                  onClick={() => removeRoomPackage(index)}
                  className="bg-red-600 text-white px-2 py-1 rounded text-sm hover:bg-red-700"
                >
                  Remove
                </button>
              )}
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <input
                type="text"
                placeholder="Package Name"
                value={pkg.packageName}
                onChange={(e) =>
                  handleRoomPackageChange(index, "packageName", e.target.value)
                }
                className="w-full border rounded p-2"
              />
              <input
                type="text"
                placeholder="Room Type"
                value={pkg.roomType}
                onChange={(e) =>
                  handleRoomPackageChange(index, "roomType", e.target.value)
                }
                className="w-full border rounded p-2"
              />
              <input
                type="number"
                placeholder="Price"
                value={pkg.price}
                onChange={(e) =>
                  handleRoomPackageChange(index, "price", e.target.value)
                }
                className="w-full border rounded p-2"
              />
              <input
                type="number"
                placeholder="Capacity"
                value={pkg.capacity}
                onChange={(e) =>
                  handleRoomPackageChange(index, "capacity", e.target.value)
                }
                className="w-full border rounded p-2"
              />
              <input
                type="number"
                placeholder="Available Rooms"
                value={pkg.availableRooms}
                onChange={(e) =>
                  handleRoomPackageChange(
                    index,
                    "availableRooms",
                    e.target.value
                  )
                }
                className="w-full border rounded p-2"
              />
              <input
                type="number"
                placeholder="Total Rooms"
                value={pkg.totalRooms}
                onChange={(e) =>
                  handleRoomPackageChange(index, "totalRooms", e.target.value)
                }
                className="w-full border rounded p-2"
              />
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <input
                type="text"
                placeholder="Amenities (comma separated)"
                value={pkg.amenities}
                onChange={(e) =>
                  handleRoomPackageChange(index, "amenities", e.target.value)
                }
                className="w-full border rounded p-2"
              />
              <select
                value={pkg.status}
                onChange={(e) =>
                  handleRoomPackageChange(index, "status", e.target.value)
                }
                className="w-full border rounded p-2"
              >
                <option value="active">Active</option>
                <option value="booked">Booked</option>
                <option value="maintenance">Maintenance</option>
                <option value="inactive">Inactive</option>
              </select>
            </div>

            <textarea
              placeholder="Package Description"
              value={pkg.description}
              onChange={(e) =>
                handleRoomPackageChange(index, "description", e.target.value)
              }
              className="w-full border rounded p-2"
              rows="2"
            />

            {/* Package Images */}
            <div className="space-y-2">
              <h5 className="font-medium text-sm text-gray-700">
                Package Images
              </h5>

              {/* Existing Package Images */}
              {existingPackageImages[index]?.length > 0 && (
                <div>
                  <h6 className="text-xs text-gray-600 mb-2">
                    Current Images:
                  </h6>
                  <div className="flex flex-wrap gap-2 mb-2">
                    {existingPackageImages[index].map(
                      (imageUrl, imageIndex) => (
                        <div key={imageIndex} className="relative w-20 h-20">
                          <img
                            src={`${process.env.REACT_APP_BASE_URL}/${imageUrl}`}
                            alt={`existing package ${index} ${imageIndex}`}
                            className="w-full h-full object-cover rounded border"
                          />
                          <button
                            type="button"
                            onClick={() =>
                              handleRemoveExistingPackageImage(
                                index,
                                imageIndex
                              )
                            }
                            className="absolute top-0 right-0 bg-red-600 text-white text-xs px-1 rounded-full hover:bg-red-700"
                          >
                            X
                          </button>
                        </div>
                      )
                    )}
                  </div>
                </div>
              )}

              {/* Add New Package Images */}
              <div>
                <h6 className="text-xs text-gray-600 mb-2">Add New Images:</h6>
                <input
                  type="file"
                  multiple
                  accept="image/*"
                  onChange={(e) => handlePackageFileChange(index, e)}
                  className="w-full border p-2 text-sm"
                />

                <div className="flex flex-wrap gap-2 mt-2">
                  {packageImages[index]?.map((file, imageIndex) => (
                    <div key={imageIndex} className="relative w-20 h-20">
                      <img
                        src={URL.createObjectURL(file)}
                        alt={`package ${index} preview ${imageIndex}`}
                        onLoad={(e) => URL.revokeObjectURL(e.target.src)}
                        className="w-full h-full object-cover rounded border"
                      />
                      <button
                        type="button"
                        onClick={() =>
                          handleRemoveNewPackageImage(index, imageIndex)
                        }
                        className="absolute top-0 right-0 bg-red-600 text-white text-xs px-1 rounded-full hover:bg-red-700"
                      >
                        X
                      </button>
                    </div>
                  ))}
                </div>
              </div>
            </div>
          </div>
        ))}
      </div>

      {/* Facilities */}
      <div className="space-y-4">
        <h3 className="text-lg font-semibold">Facilities</h3>
        <textarea
          placeholder="Facilities (comma separated)"
          value={facilities}
          onChange={(e) => setFacilities(e.target.value)}
          className="w-full border rounded p-2"
          rows="3"
        />
      </div>

      {/* Policies */}
      <div className="space-y-4">
        <h3 className="text-lg font-semibold">Policies</h3>
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <textarea
            name="cancellation"
            placeholder="Cancellation Policy"
            value={policies.cancellation}
            onChange={handlePoliciesChange}
            className="w-full border rounded p-2"
            rows="3"
          />
          <textarea
            name="petPolicy"
            placeholder="Pet Policy"
            value={policies.petPolicy}
            onChange={handlePoliciesChange}
            className="w-full border rounded p-2"
            rows="3"
          />
          <textarea
            name="smokingPolicy"
            placeholder="Smoking Policy"
            value={policies.smokingPolicy}
            onChange={handlePoliciesChange}
            className="w-full border rounded p-2"
            rows="3"
          />
          <textarea
            name="otherPolicies"
            placeholder="Other Policies"
            value={policies.otherPolicies}
            onChange={handlePoliciesChange}
            className="w-full border rounded p-2"
            rows="3"
          />
        </div>
      </div>

      {/* Check-in/Check-out Times */}
      <div className="space-y-4">
        <h3 className="text-lg font-semibold">Check-in/Check-out Times</h3>
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <input
            type="time"
            name="checkInTime"
            value={form.checkInTime}
            onChange={handleChange}
            className="w-full border rounded p-2"
          />
          <input
            type="time"
            name="checkOutTime"
            value={form.checkOutTime}
            onChange={handleChange}
            className="w-full border rounded p-2"
          />
        </div>
      </div>

      {/* Existing Images */}
      {existingImages.length > 0 && (
        <div>
          <h3 className="text-lg font-semibold mb-2">Current Images:</h3>
          <div className="flex flex-wrap gap-4 mb-4">
            {existingImages.map((imageUrl, index) => (
              <div key={index} className="relative w-24 h-24">
                <img
                  src={`${process.env.REACT_APP_BASE_URL}/${imageUrl}`}
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
                onClick={() => handleRemoveNewImage(index)}
                className="absolute top-0 right-0 bg-red-600 text-white text-xs px-1 rounded-full hover:bg-red-700"
              >
                X
              </button>
            </div>
          ))}
        </div>
      </div>

      <p className="text-sm text-gray-500">
        Upload high-quality images to replace or add to existing ones
      </p>

      <button
        type="submit"
        className="w-full bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg shadow transition"
      >
        Update Hotel
      </button>
    </form>
  );
}
