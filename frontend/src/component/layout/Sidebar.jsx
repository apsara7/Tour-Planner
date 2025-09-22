import React, { useState, useEffect, useContext } from "react";
import { useNavigate, useLocation } from "react-router-dom";
import { toast } from "react-toastify";
import {
  Home,
  Building2,
  MapPin,
  Users,
  UserCheck,
  Car,
  CloudRain,
  Shield,
  BarChart3,
  Settings,
  ChevronDown,
  ChevronRight,
  Search,
  Plus,
  Edit,
  Eye,
} from "lucide-react";
import { UserContext } from "../../context/userContext";

export default function Sidebar() {
  const { clearUserData } = useContext(UserContext);
  const navigate = useNavigate();
  const location = useLocation();

  const handleLogout = () => {
    clearUserData();
    sessionStorage.clear();
    toast.info("Logged out successfully!");
    navigate("/");
  };

  const [activeMenu, setActiveMenu] = useState(() => {
    return sessionStorage.getItem("activeMenu") || "dashboard";
  });
  const [openDropdown, setOpenDropdown] = useState(() => {
    return JSON.parse(sessionStorage.getItem("openDropdown")) || {};
  });
  const [searchTerm, setSearchTerm] = useState("");

  useEffect(() => {
    sessionStorage.setItem("activeMenu", activeMenu);
  }, [activeMenu]);

  useEffect(() => {
    sessionStorage.setItem("openDropdown", JSON.stringify(openDropdown));
  }, [openDropdown]);

  const toggleDropdown = (key) => {
    setOpenDropdown((prev) => ({ ...prev, [key]: !prev[key] }));
  };

  const menuItems = [
    {
      key: "dashboard",
      label: "Dashboard",
      icon: Home,
      onClick: () => navigate("/dashboard"),
      paths: ["/dashboard"],
    },
    {
      key: "hotels",
      label: "Manage Hotels",
      icon: Building2,
      paths: ["/hotels", "/hotels/create", "/hotels/edit"],
      onClick: () => navigate("/hotels"),
    },
    {
      key: "places",
      label: "Manage Places",
      icon: MapPin,
      paths: ["/places", "/places/create", "/places/edit"],
      onClick: () => navigate("/places"),
    },
    {
      key: "users",
      label: "Manage Users",
      icon: Users,
      paths: ["/users"],
      onClick: () => navigate("/users"),
    },
    {
      key: "guides",
      label: "Manage Guides",
      icon: UserCheck,
      paths: ["/guides", "/guides/create", "/guides/edit"],
      onClick: () => navigate("/guides"),
    },
    {
      key: "vehicles",
      label: "Rental Vehicles",
      icon: Car,
      paths: ["/vehicles", "/vehicles/create", "/vehicles/edit"],
      onClick: () => navigate("/vehicles"),
    },
    {
      key: "weather-alerts",
      label: "Weather Alerts",
      icon: CloudRain,
      paths: [
        "/weather-alerts",
        "/weather-alerts/create",
        "/weather-alerts/edit",
      ],
      onClick: () => navigate("/weather-alerts"),
    },
    {
      key: "security-options",
      label: "Security Contacts",
      icon: Shield,
      paths: [
        "/security-options",
        "/security-options/create",
        "/security-options/edit/:id",
      ],
      onClick: () => navigate("/security-options"),
    },
    // {
    //   key: "reports",
    //   label: "Reports",
    //   icon: BarChart3,
    //   paths: ["/reports"],
    //   onClick: () => navigate("/reports"),
    // },
    // {
    //   key: "settings",
    //   label: "Settings",
    //   icon: Settings,
    //   paths: ["/settings"],
    //   onClick: () => navigate("/settings"),
    // },
  ];

  const filteredItems = menuItems.filter(
    (item) =>
      item.label.toLowerCase().includes(searchTerm.toLowerCase()) ||
      item.children?.some((child) =>
        child.label.toLowerCase().includes(searchTerm.toLowerCase())
      )
  );

  // Helper function to check if a path is active
  const isPathActive = (paths) => {
    if (!paths) return false;
    return paths.some((path) => {
      // Handle dynamic routes like /places/edit/:id
      if (path.includes(":")) {
        const basePath = path.replace(/\/:.*$/, "");
        return location.pathname.startsWith(basePath);
      }
      return (
        location.pathname === path || location.pathname.startsWith(path + "/")
      );
    });
  };

  // Auto-open dropdowns when their children are active
  useEffect(() => {
    const newOpenDropdown = { ...openDropdown };
    menuItems.forEach((item) => {
      if (item.children) {
        const hasActiveChild = item.children.some((child) =>
          isPathActive(child.paths)
        );
        if (hasActiveChild) {
          newOpenDropdown[item.key] = true;
        }
      }
    });
    setOpenDropdown(newOpenDropdown);
  }, [location.pathname]);

  return (
    <div className="h-screen w-72 bg-gradient-to-b from-slate-900 to-slate-800 text-white shadow-2xl flex flex-col border-r border-slate-700">
      {/* Logo */}
      <div className="px-6 py-5 border-b border-slate-700 flex items-center justify-center bg-gradient-to-r from-blue-600 to-purple-600">
        <div className="flex items-center space-x-3">
          <div className="w-8 h-8 bg-white rounded-lg flex items-center justify-center">
            <Building2 className="h-5 w-5 text-blue-600" />
          </div>
          <h1 className="text-xl font-bold tracking-wide">Tour Planner</h1>
        </div>
      </div>
      {/* Search */}
      <div className="px-4 py-4">
        <div className="relative">
          <Search className="absolute left-3 top-3 h-4 w-4 text-slate-400" />
          <input
            type="text"
            placeholder="Search menu..."
            className="w-full pl-10 pr-4 py-2.5 rounded-lg bg-slate-800 text-white placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:bg-slate-700 transition-all duration-200 border border-slate-700"
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
          />
        </div>
      </div>
      {/* Menu */}
      <nav className="flex-1 overflow-y-auto px-3 pb-4 space-y-1 scrollbar-thin scrollbar-thumb-slate-600 scrollbar-track-transparent">
        {filteredItems.map((item) => {
          const Icon = item.icon;
          const isActive = isPathActive(item.paths);
          const isDropdownOpen = openDropdown[item.key];

          return (
            <div key={item.key}>
              <button
                onClick={() =>
                  item.children
                    ? toggleDropdown(item.key)
                    : item.onClick
                    ? item.onClick()
                    : setActiveMenu(item.key)
                }
                className={`w-full flex items-center px-4 py-3 rounded-xl transition-all duration-200 font-medium group ${
                  isActive
                    ? "bg-gradient-to-r from-blue-600 to-purple-600 text-white shadow-lg transform scale-[1.02]"
                    : "text-slate-300 hover:bg-slate-700 hover:text-white hover:transform hover:scale-[1.01]"
                }`}
              >
                <Icon className="h-5 w-5 mr-3 shrink-0 group-hover:scale-110 transition-transform duration-200" />
                <span className="flex-1 text-left text-sm">{item.label}</span>
                {item.children && (
                  <span className="transition-transform duration-200">
                    {isDropdownOpen ? (
                      <ChevronDown className="h-4 w-4" />
                    ) : (
                      <ChevronRight className="h-4 w-4" />
                    )}
                  </span>
                )}
              </button>

              {/* Submenu */}
              {item.children && isDropdownOpen && (
                <div className="ml-4 mt-1 space-y-1">
                  {item.children.map((child) => {
                    const ChildIcon = child.icon;
                    const isChildActive = isPathActive(child.paths);

                    return (
                      <button
                        key={child.key}
                        onClick={() => child.onClick && child.onClick()}
                        className={`w-full flex items-center px-4 py-2 rounded-lg transition-all duration-200 text-sm group ${
                          isChildActive
                            ? "bg-blue-500/20 text-blue-300 border-l-2 border-blue-400"
                            : "text-slate-400 hover:bg-slate-700 hover:text-white"
                        }`}
                      >
                        <ChildIcon className="h-4 w-4 mr-3 shrink-0" />
                        <span className="flex-1 text-left">{child.label}</span>
                      </button>
                    );
                  })}
                </div>
              )}
            </div>
          );
        })}
      </nav>
      {/* Footer */}
      <div className="px-6 py-4 border-t border-slate-700 bg-slate-800/50">
        {/* ✅ Logout button only once, at bottom */}
        <button
          onClick={handleLogout}
          className="w-full flex items-center justify-center px-4 py-2 bg-red-600 hover:bg-red-500 rounded-lg font-medium text-sm transition-all duration-200"
        >
          Logout
        </button>
      </div>{" "}
    </div>
  );
}
