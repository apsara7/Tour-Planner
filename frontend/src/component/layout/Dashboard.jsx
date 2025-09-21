import React, { useState, useContext } from "react";
import Sidebar from "./Sidebar";
import Header from "./Header";
import DashboardCard from "./DashboardBody";
import { UserContext } from "../../context/userContext";
import {
  Users,
  Building2,
  Car,
  MapPin,
  UserCheck,
  CloudRain,
  Shield,
  DollarSign,
  Activity,
  Calendar,
  AlertTriangle,
} from "lucide-react";

const Dashboard = () => {
  const [activeMenu, setActiveMenu] = useState("dashboard");
  const [sidebarOpen, setSidebarOpen] = useState(true);
  const { userData, clearUserData } = useContext(UserContext);

  const handleLogout = () => {
    if (window.confirm("Are you sure you want to logout?")) {
      clearUserData();
      // Add your logout logic here (redirect to login page)
      window.location.href = "/login";
    }
  };

  const toggleSidebar = () => {
    setSidebarOpen(!sidebarOpen);
  };

  const stats = [
    {
      title: "Total Users",
      value: "8,421",
      change: "+12.5%",
      icon: <Users className="h-6 w-6" />,
      color: "bg-blue-500",
    },
    {
      title: "Total Hotels",
      value: "324",
      change: "+5.2%",
      icon: <Building2 className="h-6 w-6" />,
      color: "bg-purple-500",
    },
    {
      title: "Vehicles Rented",
      value: "1,247",
      change: "+8.7%",
      icon: <Car className="h-6 w-6" />,
      color: "bg-green-500",
    },
    {
      title: "Places Listed",
      value: "892",
      change: "+3.1%",
      icon: <MapPin className="h-6 w-6" />,
      color: "bg-orange-500",
    },
    {
      title: "Active Guides",
      value: "156",
      change: "+7.3%",
      icon: <UserCheck className="h-6 w-6" />,
      color: "bg-indigo-500",
    },
    {
      title: "Weather Alerts",
      value: "12",
      change: "-2.1%",
      icon: <CloudRain className="h-6 w-6" />,
      color: "bg-yellow-500",
    },
  ];

  const recentActivities = [
    {
      id: 1,
      action: "New hotel registration",
      details: "Grand Plaza Hotel added to the system",
      time: "2 minutes ago",
      type: "hotel",
    },
    {
      id: 2,
      action: "Weather alert issued",
      details: "Heavy rain warning for Mountain Region",
      time: "5 minutes ago",
      type: "weather",
    },
    {
      id: 3,
      action: "Guide verification completed",
      details: "Sarah Johnson's profile verified",
      time: "10 minutes ago",
      type: "guide",
    },
    {
      id: 4,
      action: "Vehicle booking",
      details: "Toyota Camry booked for 3 days",
      time: "15 minutes ago",
      type: "vehicle",
    },
  ];

  return (
    <div className="flex min-h-screen bg-slate-50">
      {/* Sidebar */}
      <div className={`${sidebarOpen ? 'translate-x-0' : '-translate-x-full'} fixed lg:relative lg:translate-x-0 transition-transform duration-300 ease-in-out z-30 lg:z-auto`}>
        <Sidebar 
          activeMenu={activeMenu} 
          setActiveMenu={setActiveMenu} 
          handleLogout={handleLogout} 
        />
      </div>

      {/* Sidebar Overlay for Mobile */}
      {sidebarOpen && (
        <div 
          className="fixed inset-0 bg-black bg-opacity-50 z-20 lg:hidden"
          onClick={() => setSidebarOpen(false)}
        />
      )}

      {/* Main Content */}
      <div className="flex-1 flex flex-col overflow-hidden lg:ml-0">
        <Header 
          title="Dashboard" 
          username={userData?.name || "Admin"} 
          onMenuToggle={toggleSidebar}
        />

        <main className="flex-1 overflow-auto p-6">
          {/* Welcome Section */}
          <div className="mb-8">
            <h1 className="text-3xl font-bold text-slate-900 mb-2">
              Welcome back, {userData?.name || "Admin"}!
            </h1>
            <p className="text-slate-600">
              Here's what's happening with your travel management system today.
            </p>
          </div>

          {/* Stats Grid */}
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6 mb-8">
            {stats.map((stat, index) => (
              <DashboardCard
                key={index}
                title={stat.title}
                value={stat.value}
                change={stat.change}
                icon={stat.icon}
                color={stat.color}
              />
            ))}
          </div>

          <div className="grid grid-cols-1 xl:grid-cols-3 gap-6">
            {/* Recent Activities */}
            <div className="xl:col-span-2">
              <div className="bg-white rounded-xl border border-slate-200 shadow-lg">
                <div className="p-6 border-b border-slate-200">
                  <div className="flex items-center justify-between">
                    <h2 className="text-lg font-semibold text-slate-900">
                      Recent Activities
                    </h2>
                    <button className="text-blue-600 hover:text-blue-700 text-sm font-medium">
                      View all
                    </button>
                  </div>
                </div>
                <div className="p-6">
                  <div className="space-y-4">
                    {recentActivities.map((activity) => (
                      <div
                        key={activity.id}
                        className="flex items-start space-x-4 p-4 rounded-lg border border-slate-100 hover:bg-slate-50 transition-colors"
                      >
                        <div className="flex-shrink-0">
                          <Activity className="h-5 w-5 text-blue-500 mt-0.5" />
                        </div>
                        <div className="flex-1">
                          <p className="text-sm font-medium text-slate-900">
                            {activity.action}
                          </p>
                          <p className="text-sm text-slate-600 mt-1">
                            {activity.details}
                          </p>
                          <p className="text-xs text-slate-500 mt-2">{activity.time}</p>
                        </div>
                      </div>
                    ))}
                  </div>
                </div>
              </div>
            </div>

            {/* Quick Actions & Alerts */}
            <div className="space-y-6">
              {/* Quick Actions */}
              <div className="bg-white rounded-xl border border-slate-200 shadow-lg p-6">
                <h2 className="text-lg font-semibold text-slate-900 mb-4">
                  Quick Actions
                </h2>
                <div className="space-y-3">
                  <button 
                    onClick={() => setActiveMenu('add-hotel')}
                    className="w-full bg-blue-600 hover:bg-blue-700 text-white rounded-lg px-4 py-2 text-sm font-medium transition-colors"
                  >
                    Add New Hotel
                  </button>
                  <button 
                    onClick={() => setActiveMenu('create-alert')}
                    className="w-full bg-purple-600 hover:bg-purple-700 text-white rounded-lg px-4 py-2 text-sm font-medium transition-colors"
                  >
                    Create Weather Alert
                  </button>
                  <button 
                    onClick={() => setActiveMenu('add-guide')}
                    className="w-full bg-green-600 hover:bg-green-700 text-white rounded-lg px-4 py-2 text-sm font-medium transition-colors"
                  >
                    Add Tour Guide
                  </button>
                  <button 
                    onClick={() => setActiveMenu('analytics')}
                    className="w-full border border-slate-300 text-slate-700 hover:bg-slate-50 rounded-lg px-4 py-2 text-sm font-medium transition-colors"
                  >
                    View Reports
                  </button>
                </div>
              </div>

              {/* System Alerts */}
              <div className="bg-white rounded-xl border border-slate-200 shadow-lg p-6">
                <h2 className="text-lg font-semibold text-slate-900 mb-4">
                  System Alerts
                </h2>
                <div className="space-y-3">
                  <div className="flex items-center space-x-3 p-3 bg-yellow-50 rounded-lg border border-yellow-200">
                    <AlertTriangle className="h-4 w-4 text-yellow-600" />
                    <div>
                      <p className="text-sm font-medium text-yellow-800">
                        Server Maintenance
                      </p>
                      <p className="text-xs text-yellow-600">
                        Scheduled for tonight
                      </p>
                    </div>
                  </div>
                  <div className="flex items-center space-x-3 p-3 bg-red-50 rounded-lg border border-red-200">
                    <AlertTriangle className="h-4 w-4 text-red-600" />
                    <div>
                      <p className="text-sm font-medium text-red-800">
                        High Traffic Alert
                      </p>
                      <p className="text-xs text-red-600">
                        Booking system under load
                      </p>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </main>
      </div>
    </div>
  );
};

export default Dashboard;