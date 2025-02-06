import React, { useState } from "react";
import { Form, Input, Button, message } from "antd";
import { useNavigate } from "react-router-dom";
import API from "../api/api"; // ✅ Removed setManualCookies

const AdminLogin = () => {
  const [loading, setLoading] = useState(false);
  const navigate = useNavigate();

  const handleLogin = async (values) => {
    setLoading(true);
    try {
      // POST request to login API
      const response = await API.post("/auth/admin_login", values);

      if (response.status === 200) {
        message.success("Admin login successful");
        navigate("/app"); // 🔥 Redirect to Dashboard
      }
    } catch (error) {
      message.error("Invalid admin credentials");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div style={{ maxWidth: 400, margin: "100px auto", textAlign: "center" }}>
      <h2>Admin Login</h2>
      <Form layout="vertical" onFinish={handleLogin}>
        <Form.Item
          label="Username"
          name="username"
          rules={[{ required: true, message: "Please enter your username" }]}
        >
          <Input />
        </Form.Item>
        <Form.Item
          label="Password"
          name="password"
          rules={[{ required: true, message: "Please enter your password" }]}
        >
          <Input.Password />
        </Form.Item>
        <Form.Item>
          <Button type="primary" htmlType="submit" loading={loading}>
            Login
          </Button>
        </Form.Item>
      </Form>
    </div>
  );
};

export default AdminLogin;
