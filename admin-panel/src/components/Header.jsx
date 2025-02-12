import React from "react";
import { Layout, Button } from "antd";
import { useNavigate } from "react-router-dom";
import axios from "axios";

const { Header } = Layout;

const AppHeader = () => {
  const navigate = useNavigate();

  const handleLogout = async () => {
    await axios.get("http://127.0.0.1:8000/auth/logout", { withCredentials: true });
    navigate("/auth/admin_login");
  };

  return (
    <Header style={{ display: "flex", justifyContent: "space-between", padding: "0 20px" }}>
      <h2 style={{ color: "#fff" }}>Admin Dashboard</h2>
      <Button type="primary" danger onClick={handleLogout}>
        Logout
      </Button>
    </Header>
  );
};

export default AppHeader;
