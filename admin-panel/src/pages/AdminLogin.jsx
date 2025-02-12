import React, { useState, useEffect } from "react";
import { Form, Input, Button, message, Card, Typography, Space, Spin } from "antd";
import { useNavigate } from "react-router-dom";
import { motion, AnimatePresence } from "framer-motion";
import {
  UserOutlined,
  LockOutlined,
  LoginOutlined,
  EyeInvisibleOutlined,
  EyeTwoTone,
} from "@ant-design/icons";
import styled, { keyframes } from "styled-components";
import API from "../api/api";

const { Title, Text } = Typography;

// Animations
const gradient = keyframes`
  0% { background-position: 0% 50%; }
  50% { background-position: 100% 50%; }
  100% { background-position: 0% 50%; }
`;

const float = keyframes`
  0% { transform: translateY(0px); }
  50% { transform: translateY(-10px); }
  100% { transform: translateY(0px); }
`;

// Styled Components
const PageContainer = styled.div`
  min-height: 100vh;
  display: flex;
  justify-content: center;
  align-items: center;
  background: linear-gradient(-45deg, #ee7752, #e73c7e, #23a6d5, #23d5ab);
  background-size: 400% 400%;
  animation: ${gradient} 15s ease infinite;
  padding: 20px;
  position: relative;
  overflow: hidden;
`;

const BackgroundBubble = styled.div`
  position: absolute;
  background: rgba(255, 255, 255, 0.1);
  border-radius: 50%;
  pointer-events: none;
  animation: ${float} 4s ease-in-out infinite;

  &:nth-child(1) {
    width: 80px;
    height: 80px;
    top: 10%;
    left: 10%;
    animation-delay: 0s;
  }

  &:nth-child(2) {
    width: 60px;
    height: 60px;
    top: 20%;
    right: 15%;
    animation-delay: 1s;
  }

  &:nth-child(3) {
    width: 100px;
    height: 100px;
    bottom: 15%;
    right: 20%;
    animation-delay: 2s;
  }
`;

const StyledCard = styled(Card)`
  width: 100%;
  max-width: 420px;
  border-radius: 20px;
  box-shadow: 0 8px 32px 0 rgba(31, 38, 135, 0.37);
  backdrop-filter: blur(12px);
  border: 1px solid rgba(255, 255, 255, 0.18);
  background: rgba(255, 255, 255, 0.95);
  overflow: hidden;

  .ant-card-body {
    padding: 40px;
  }

  &:hover {
    transform: translateY(-5px);
    box-shadow: 0 12px 40px 0 rgba(31, 38, 135, 0.45);
    transition: all 0.3s ease;
  }
`;

const StyledForm = styled(Form)`
  .ant-form-item-label > label {
    color: #434343;
    font-weight: 500;
    font-size: 15px;
  }

  .ant-input-affix-wrapper {
    border-radius: 12px;
    padding: 12px;
    border: 2px solid #f0f0f0;
    transition: all 0.3s ease;
    background: rgba(255, 255, 255, 0.9);

    &:hover, &:focus {
      border-color: #1890ff;
      box-shadow: 0 0 0 3px rgba(24, 144, 255, 0.2);
    }

    .ant-input {
      background: transparent;
    }
  }

  .ant-btn {
    height: 48px;
    border-radius: 12px;
    font-weight: 600;
    font-size: 16px;
    transition: all 0.3s ease;
    background: linear-gradient(45deg, #1890ff, #722ed1);
    border: none;

    &:hover {
      transform: translateY(-2px);
      box-shadow: 0 8px 15px rgba(24, 144, 255, 0.4);
      background: linear-gradient(45deg, #40a9ff, #85a5ff);
    }

    &:active {
      transform: translateY(0);
    }
  }
`;

const LogoContainer = styled.div`
  text-align: center;
  margin-bottom: 40px;
`;

const StyledTitle = styled(Title)`
  &.ant-typography {
    background: linear-gradient(45deg, #1890ff, #722ed1);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    margin-bottom: 10px;
  }
`;

const StyledSubtitle = styled(Text)`
  &.ant-typography {
    color: #8c8c8c;
    font-size: 16px;
    display: block;
    margin-bottom: 30px;
  }
`;

const LoadingOverlay = styled(motion.div)`
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.7);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1000;
`;

const AdminLogin = () => {
  const [loading, setLoading] = useState(false);
  const [form] = Form.useForm();
  const navigate = useNavigate();
  const [showSuccess, setShowSuccess] = useState(false);

  useEffect(() => {
    // Add entrance animation for form fields
    const timeout = setTimeout(() => {
      form.setFields([
        { name: "username", touched: false },
        { name: "password", touched: false },
      ]);
    }, 500);

    return () => clearTimeout(timeout);
  }, [form]);

  const handleLogin = async (values) => {
    setLoading(true);
    try {
      const response = await API.post("/auth/admin_login", values);

      if (response.status === 200) {
        setShowSuccess(true);
        message.success({
          content: "Login successful! Redirecting...",
          icon: <LoginOutlined style={{ color: "#52c41a" }} />,
          duration: 2,
        });
        
        // Add success animation before navigation
        setTimeout(() => {
          navigate("/app");
        }, 1500);
      }
    } catch (error) {
      message.error({
        content: "Invalid credentials",
        icon: <LockOutlined style={{ color: "#ff4d4f" }} />,
      });
      
      // Add shake animation on error
      form.setFields([
        {
          name: "password",
          errors: [""],
        },
      ]);
    } finally {
      setLoading(false);
    }
  };

  // Framer Motion variants
  const containerVariants = {
    hidden: { opacity: 0, y: 20 },
    visible: {
      opacity: 1,
      y: 0,
      transition: {
        duration: 0.6,
        ease: "easeOut",
        staggerChildren: 0.1,
      },
    },
  };

  const formItemVariants = {
    hidden: { opacity: 0, x: -20 },
    visible: { 
      opacity: 1, 
      x: 0,
      transition: {
        type: "spring",
        stiffness: 260,
        damping: 20,
      }
    },
  };

  return (
    <PageContainer>
      {/* Background Bubbles */}
      <BackgroundBubble />
      <BackgroundBubble />
      <BackgroundBubble />

      <motion.div
        initial="hidden"
        animate="visible"
        variants={containerVariants}
      >
        <StyledCard>
          <LogoContainer>
            <motion.div
              initial={{ scale: 0 }}
              animate={{ scale: 1 }}
              transition={{
                type: "spring",
                stiffness: 260,
                damping: 20,
              }}
            >
              <StyledTitle level={2}>Welcome Back</StyledTitle>
              <StyledSubtitle>Sign in to your admin account</StyledSubtitle>
            </motion.div>
          </LogoContainer>

          <StyledForm
            form={form}
            layout="vertical"
            onFinish={handleLogin}
            requiredMark={false}
          >
            <Space direction="vertical" size={24} style={{ width: "100%" }}>
              <motion.div
                variants={formItemVariants}
                transition={{ delay: 0.2 }}
              >
                <Form.Item
                  label="Username"
                  name="username"
                  rules={[
                    { required: true, message: "Please enter your username" },
                    { min: 3, message: "Username must be at least 3 characters" },
                  ]}
                  hasFeedback
                >
                  <Input
                    prefix={<UserOutlined style={{ color: "#1890ff" }} />}
                    placeholder="Enter your username"
                    size="large"
                    autoComplete="username"
                  />
                </Form.Item>
              </motion.div>

              <motion.div
                variants={formItemVariants}
                transition={{ delay: 0.3 }}
              >
                <Form.Item
                  label="Password"
                  name="password"
                  rules={[
                    { required: true, message: "Please enter your password" },
                    { min: 6, message: "Password must be at least 6 characters" },
                  ]}
                  hasFeedback
                >
                  <Input.Password
                    prefix={<LockOutlined style={{ color: "#1890ff" }} />}
                    placeholder="Enter your password"
                    size="large"
                    iconRender={(visible) =>
                      visible ? <EyeTwoTone /> : <EyeInvisibleOutlined />
                    }
                  />
                </Form.Item>
              </motion.div>

              <motion.div
                variants={formItemVariants}
                transition={{ delay: 0.4 }}
                whileHover={{ scale: 1.02 }}
                whileTap={{ scale: 0.98 }}
              >
                <Form.Item>
                  <Button
                    type="primary"
                    htmlType="submit"
                    loading={loading}
                    block
                    icon={<LoginOutlined />}
                  >
                    Sign In
                  </Button>
                </Form.Item>
              </motion.div>
            </Space>
          </StyledForm>
        </StyledCard>
      </motion.div>

      <AnimatePresence>
        {loading && (
          <LoadingOverlay
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
          >
            <Spin size="large" />
          </LoadingOverlay>
        )}
      </AnimatePresence>
    </PageContainer>
  );
};

export default AdminLogin;