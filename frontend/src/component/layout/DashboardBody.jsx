import React from "react";

const DashboardCard = ({ title, value, icon }) => {
  return (
    <div className="bg-white rounded-xl shadow-md p-6 flex items-center space-x-4 hover:shadow-lg transition">
      <div className="p-3 bg-indigo-100 rounded-lg flex items-center justify-center w-12 h-12">
        {icon}
      </div>
      <div>
        <h3 className="text-lg font-semibold text-gray-700">{title}</h3>
        <p className="text-2xl font-bold text-indigo-700">{value}</p>
      </div>
    </div>
  );
};

export default DashboardCard;
