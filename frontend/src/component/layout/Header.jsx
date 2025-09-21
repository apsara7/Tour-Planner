import React from "react";

const Header = ({ title, username }) => {
  return (
    <header className="w-full bg-white shadow-md flex justify-between items-center px-6 py-4">
      <h1 className="text-xl font-semibold text-gray-700">{title}</h1>
      <div className="flex items-center space-x-3">
        <span className="text-gray-600">{username}</span>
        <img
          src="https://ui-avatars.com/api/?name=Admin"
          alt="avatar"
          className="w-10 h-10 rounded-full border"
        />
      </div>
    </header>
  );
};

export default Header;
