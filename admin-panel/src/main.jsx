import React from "react";
import ReactDOM from "react-dom/client";
import { BrowserRouter, Routes, Route, Navigate } from "react-router-dom";
import App from "./App"; // Layout or main component
import AdminLogin from "./pages/AdminLogin";
import Dashboard from "./pages/Dashboard";
import Tips from "./pages/Tips";
import Diseases from "./pages/Diseases";
import News from "./pages/News";
import "antd/dist/reset.css"; // Ant Design CSS reset

ReactDOM.createRoot(document.getElementById("root")).render(
  <BrowserRouter>
    <Routes>
      {/* Default route ("/") now redirects to admin login */}
      <Route path="/" element={<Navigate replace to="/auth/admin_login" />} />

      {/* Admin login route */}
      <Route path="/auth/admin_login" element={<AdminLogin />} />

      {/* Wrap other routes inside App layout */}
      <Route path="/app" element={<App />}>
        <Route index element={<Dashboard />} />
        <Route path="tips" element={<Tips />} />
        <Route path="diseases" element={<Diseases />} />
        <Route path="news" element={<News />} />
      </Route>
    </Routes>
  </BrowserRouter>
);
