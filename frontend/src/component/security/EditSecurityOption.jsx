// src/pages/admin/EditSecurityOption.jsx
import React, { useState, useEffect } from "react";
import axios from "axios";
import { useNavigate, useParams } from "react-router-dom";
import { Plus, Trash2 } from "lucide-react";

export default function EditSecurityOption() {
  const { id } = useParams();
  const navigate = useNavigate();
  const [form, setForm] = useState({
    type: "",
    name: "",
    mobiles: [""],
    emails: [""],
    address: "",
    otherContacts: [""],
    region: "",
    description: "",
  });

  // load data
  useEffect(() => {
    axios
      .get(`${process.env.REACT_APP_BASE_URL}/api/security-options/${id}`)
      .then((res) => {
        const data = res.data;
        setForm({
          type: data.type || "",
          name: data.name || "",
          mobiles: data.mobiles?.length ? data.mobiles : [""],
          emails: data.emails?.length ? data.emails : [""],
          address: data.address || "",
          otherContacts: data.otherContacts?.length ? data.otherContacts : [""],
          region: data.region || "",
          description: data.description || "",
        });
      })
      .catch((err) => {
        console.error(err);
        alert("Failed to load security option");
      });
  }, [id]);

  // handlers
  const handleMobileChange = (i, v) => {
    const arr = [...form.mobiles];
    arr[i] = v;
    setForm({ ...form, mobiles: arr });
  };
  const addMobile = () => setForm({ ...form, mobiles: [...form.mobiles, ""] });
  const removeMobile = (i) =>
    setForm({ ...form, mobiles: form.mobiles.filter((_, idx) => idx !== i) });

  const handleEmailChange = (i, v) => {
    const arr = [...form.emails];
    arr[i] = v;
    setForm({ ...form, emails: arr });
  };
  const addEmail = () => setForm({ ...form, emails: [...form.emails, ""] });
  const removeEmail = (i) =>
    setForm({ ...form, emails: form.emails.filter((_, idx) => idx !== i) });

  const handleOtherChange = (i, v) => {
    const arr = [...form.otherContacts];
    arr[i] = v;
    setForm({ ...form, otherContacts: arr });
  };
  const addOther = () =>
    setForm({ ...form, otherContacts: [...form.otherContacts, ""] });
  const removeOther = (i) =>
    setForm({
      ...form,
      otherContacts: form.otherContacts.filter((_, idx) => idx !== i),
    });

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      await axios.put(
        `${process.env.REACT_APP_BASE_URL}/api/security-options/${id}`,
        form
      );
      alert("Security Option updated successfully");
      navigate("/security-options");
    } catch (err) {
      console.error(err);
      alert("Failed to update security option");
    }
  };

  const Section = ({ title, children }) => (
    <div className="bg-white shadow rounded-xl p-4 mb-6">
      <h3 className="text-lg font-semibold mb-3">{title}</h3>
      {children}
    </div>
  );

  return (
    <div className="max-w-6xl mx-auto p-6 bg-gray-50 min-h-screen">
      <h2 className="text-2xl font-bold mb-6 text-center">
        Edit Security Option
      </h2>
      <form onSubmit={handleSubmit} className="bg-white p-6 rounded-xl shadow">
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          {/* Left Column */}
          <div className="space-y-6">
            <div className="bg-gray-50 p-4 rounded-lg">
              <h3 className="text-lg font-semibold mb-3">General Info</h3>
              <label className="block mb-2 font-medium">Type</label>
              <input
                className="w-full border rounded p-2 mb-4 bg-white"
                value={form.type}
                onChange={(e) => setForm({ ...form, type: e.target.value })}
              />
              <label className="block mb-2 font-medium">Name</label>
              <input
                className="w-full border rounded p-2 bg-white"
                value={form.name}
                onChange={(e) => setForm({ ...form, name: e.target.value })}
              />
            </div>

            <div className="bg-gray-50 p-4 rounded-lg">
              <h3 className="text-lg font-semibold mb-3">Mobile Numbers</h3>
              {form.mobiles.map((mobile, index) => (
                <div
                  key={index}
                  className="flex gap-2 items-center bg-white rounded-lg p-2 mb-2 border"
                >
                  <input
                    type="tel"
                    placeholder={`Mobile ${index + 1}`}
                    className="flex-1 border rounded p-2"
                    value={mobile}
                    onChange={(e) => handleMobileChange(index, e.target.value)}
                  />
                  <button
                    type="button"
                    onClick={() => removeMobile(index)}
                    className="text-red-600 hover:text-red-800"
                  >
                    <Trash2 size={20} />
                  </button>
                </div>
              ))}
              <button
                type="button"
                onClick={addMobile}
                className="flex items-center gap-2 text-blue-600 hover:text-blue-800"
              >
                <Plus size={20} /> Add Mobile
              </button>
            </div>

            <div className="bg-gray-50 p-4 rounded-lg">
              <h3 className="text-lg font-semibold mb-3">Emails</h3>
              {form.emails.map((email, index) => (
                <div
                  key={index}
                  className="flex gap-2 items-center bg-white rounded-lg p-2 mb-2 border"
                >
                  <input
                    type="email"
                    placeholder={`Email ${index + 1}`}
                    className="flex-1 border rounded p-2"
                    value={email}
                    onChange={(e) => handleEmailChange(index, e.target.value)}
                  />
                  <button
                    type="button"
                    onClick={() => removeEmail(index)}
                    className="text-red-600 hover:text-red-800"
                  >
                    <Trash2 size={20} />
                  </button>
                </div>
              ))}
              <button
                type="button"
                onClick={addEmail}
                className="flex items-center gap-2 text-blue-600 hover:text-blue-800"
              >
                <Plus size={20} /> Add Email
              </button>
            </div>
          </div>

          {/* Right Column */}
          <div className="space-y-6">
            <div className="bg-gray-50 p-4 rounded-lg">
              <h3 className="text-lg font-semibold mb-3">Address</h3>
              <label className="block mb-2 font-medium">Address</label>
              <textarea
                className="w-full border rounded p-2 bg-white"
                rows={4}
                value={form.address}
                onChange={(e) => setForm({ ...form, address: e.target.value })}
              />
            </div>

            <div className="bg-gray-50 p-4 rounded-lg">
              <h3 className="text-lg font-semibold mb-3">Other Contacts</h3>
              {form.otherContacts.map((contact, index) => (
                <div
                  key={index}
                  className="flex gap-2 items-center bg-white rounded-lg p-2 mb-2 border"
                >
                  <input
                    type="text"
                    placeholder={`Other Contact ${index + 1}`}
                    className="flex-1 border rounded p-2"
                    value={contact}
                    onChange={(e) => handleOtherChange(index, e.target.value)}
                  />
                  <button
                    type="button"
                    onClick={() => removeOther(index)}
                    className="text-red-600 hover:text-red-800"
                  >
                    <Trash2 size={20} />
                  </button>
                </div>
              ))}
              <button
                type="button"
                onClick={addOther}
                className="flex items-center gap-2 text-blue-600 hover:text-blue-800"
              >
                <Plus size={20} /> Add Other Contact
              </button>
            </div>

            <div className="bg-gray-50 p-4 rounded-lg">
              <h3 className="text-lg font-semibold mb-3">
                Region & Description
              </h3>
              <label className="block mb-2 font-medium">Region</label>
              <input
                className="w-full border rounded p-2 mb-4 bg-white"
                value={form.region}
                onChange={(e) => setForm({ ...form, region: e.target.value })}
              />
              <label className="block mb-2 font-medium">Description</label>
              <textarea
                className="w-full border rounded p-2 bg-white"
                rows={4}
                value={form.description}
                onChange={(e) =>
                  setForm({ ...form, description: e.target.value })
                }
              />
            </div>
          </div>
        </div>

        <div className="text-center mt-6">
          <button
            type="submit"
            className="bg-green-600 hover:bg-green-700 text-white px-6 py-2 rounded-xl shadow"
          >
            Update Security Option
          </button>
        </div>
      </form>
    </div>
  );
}
