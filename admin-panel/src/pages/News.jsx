import React, { useEffect, useState } from "react";
import { Table, Button, message, Modal, Form, Input, Spin } from "antd";
import axios from "axios";
import styled, { keyframes } from "styled-components";
import { motion, AnimatePresence } from "framer-motion";
import { PlusCircle, Trash2, Leaf, Send } from "lucide-react";

// ============= STYLED COMPONENTS & ANIMATIONS =============

// Keyframe for the green glow animation
const glowAnimation = keyframes`
  0% { box-shadow: 0 0 5px #4CAF50, 0 0 10px #4CAF50; }
  50% { box-shadow: 0 0 20px #4CAF50, 0 0 25px #4CAF50; }
  100% { box-shadow: 0 0 5px #4CAF50, 0 0 10px #4CAF50; }
`;

// Container with a gentle background and padding
const PageContainer = styled(motion.div)`
  padding: 24px;
  background: #f0f8f1;
  min-height: 100vh;
`;

// Styled AntD Table with a translucent background
const StyledTable = styled(Table)`
  .ant-table {
    background: rgba(255, 255, 255, 0.9);
    backdrop-filter: blur(10px);
  }

  .ant-table-row {
    transition: all 0.3s ease;

    &:hover {
      background: #f0f8f1 !important;
      transform: scale(1.01);
    }
  }
`;

// Green "Add News" button with glow on hover
const AddButton = styled(Button)`
  background: #4caf50;
  border: none;
  height: 45px;
  padding: 0 25px;
  display: flex;
  align-items: center;
  gap: 8px;

  &:hover {
    animation: ${glowAnimation} 1.5s infinite;
    background: #45a049 !important;
  }
`;

// Styled Modal for consistency
const StyledModal = styled(Modal)`
  .ant-modal-content {
    background: rgba(255, 255, 255, 0.95);
    backdrop-filter: blur(10px);
    border-radius: 15px;
    box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
  }

  .ant-modal-header {
    border-radius: 15px 15px 0 0;
    background: transparent;
  }
`;

const DeleteButton = styled(Button)`
  display: flex;
  align-items: center;
  gap: 5px;

  &:hover {
    transform: scale(1.05);
  }
`;

// ============= MAIN COMPONENT =============
const News = () => {
  const [news, setNews] = useState([]);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [loading, setLoading] = useState(false);
  const [form] = Form.useForm();

  useEffect(() => {
    fetchNews();
  }, []);

  // Fetch news from API
  const fetchNews = async () => {
    setLoading(true);
    try {
      const response = await axios.get("http://127.0.0.1:8000/api/news", {
        withCredentials: true,
      });
      setNews(response.data.news);
    } catch (error) {
      message.error({
        content: "Failed to fetch news",
        style: { marginTop: "20vh" },
      });
    } finally {
      setLoading(false);
    }
  };

  // Delete news article
  const handleDelete = async (title) => {
    setLoading(true);
    try {
      await axios.delete("http://127.0.0.1:8000/admin_dashboard/delete_news", {
        data: { title },
        withCredentials: true,
      });
      message.success({
        content: "News deleted successfully",
        icon: <Trash2 size={20} color="#ff4d4f" />,
      });
      fetchNews();
    } catch (error) {
      message.error("Failed to delete news");
    } finally {
      setLoading(false);
    }
  };

  // Add news article
  const handleAddNews = async (values) => {
    setLoading(true);
    try {
      await axios.post("http://127.0.0.1:8000/admin_dashboard/add_news", values, {
        withCredentials: true,
      });
      message.success({
        content: "News added successfully",
        icon: <Leaf size={20} color="#4CAF50" />,
      });
      setIsModalOpen(false);
      form.resetFields();
      fetchNews();
    } catch (error) {
      message.error("Failed to add news");
    } finally {
      setLoading(false);
    }
  };

  // Helper function to format ISO date strings into a more readable format
  const formatTimestamp = (isoString) => {
    if (!isoString) return "";
    // Create a JavaScript Date object from the string
    const dateObj = new Date(isoString);
    // Use toLocaleString() or a library like dayjs/moment for custom formatting
    return dateObj.toLocaleString(); 
  };

  // Table columns with subtle motion animations on content
  const columns = [
    {
      title: "Title",
      dataIndex: "title",
      key: "title",
      render: (text) => (
        <motion.span
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ duration: 0.5 }}
        >
          {text}
        </motion.span>
      ),
    },
    {
      title: "Subtitle",
      dataIndex: "subtitle",
      key: "subtitle",
      render: (text) => (
        <motion.span
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ duration: 0.5 }}
        >
          {text}
        </motion.span>
      ),
    },
    {
      title: "Author",
      dataIndex: "author_name",
      key: "author_name",
      render: (text) => (
        <motion.span
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ duration: 0.5 }}
        >
          {text}
        </motion.span>
      ),
    },
    {
      title: "Published",
      dataIndex: "timestamp",
      key: "timestamp",
      render: (timestamp) => {
        // Convert the ISO date string to a local, readable format
        const readableDate = formatTimestamp(timestamp);
        return (
          <motion.span
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ duration: 0.5 }}
          >
            {readableDate}
          </motion.span>
        );
      },
    },
    {
      title: "Action",
      key: "action",
      render: (_, record) => (
        <DeleteButton
          danger
          type="primary"
          onClick={() => handleDelete(record.title)}
          icon={<Trash2 size={16} />}
        >
          Delete
        </DeleteButton>
      ),
    },
  ];

  return (
    <PageContainer
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      transition={{ duration: 0.5 }}
    >
      {/* Add News Article Button */}
      <AddButton
        type="primary"
        onClick={() => setIsModalOpen(true)}
        icon={<PlusCircle size={20} />}
      >
        Add News Article
      </AddButton>

      {/* Table and Spinner with framer-motion transitions */}
      <AnimatePresence>
        {loading ? (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            style={{ textAlign: "center", marginTop: "50px" }}
          >
            <Spin size="large" />
          </motion.div>
        ) : (
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5 }}
          >
            <StyledTable
              columns={columns}
              dataSource={news}
              rowKey="title"
              style={{ marginTop: 20 }}
            />
          </motion.div>
        )}
      </AnimatePresence>

      {/* Modal for Adding News */}
      <StyledModal
        title="Add News Article"
        open={isModalOpen}
        onCancel={() => setIsModalOpen(false)}
        footer={null}
      >
        <Form form={form} layout="vertical" onFinish={handleAddNews}>
          <Form.Item
            label="Title"
            name="title"
            rules={[{ required: true, message: "Please enter the news title" }]}
          >
            <Input />
          </Form.Item>
          <Form.Item label="Subtitle" name="subtitle">
            <Input />
          </Form.Item>
          <Form.Item
            label="Content"
            name="content"
            rules={[{ required: true, message: "Please enter the news content" }]}
          >
            <Input.TextArea rows={4} />
          </Form.Item>
          <Form.Item
            label="Author Name"
            name="author_name"
            rules={[{ required: true, message: "Please enter the author name" }]}
          >
            <Input />
          </Form.Item>
          <Form.Item>
            <Button
              type="primary"
              htmlType="submit"
              loading={loading}
              icon={<Send size={16} />}
              style={{
                background: "#4CAF50",
                borderColor: "#4CAF50",
                width: "100%",
              }}
            >
              Add News
            </Button>
          </Form.Item>
        </Form>
      </StyledModal>
    </PageContainer>
  );
};

export default News;
