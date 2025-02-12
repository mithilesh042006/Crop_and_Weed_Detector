// src/pages/UserHistory.jsx

import React, { useEffect, useState } from "react";
import { Table, message, Spin } from "antd";
import styled, { keyframes } from "styled-components";
import { motion, AnimatePresence } from "framer-motion";
import { fetchHistoryAPI } from "../api/api";

// ============= STYLED COMPONENTS & ANIMATIONS =============
const glowAnimation = keyframes`
  0% { box-shadow: 0 0 5px #4CAF50, 0 0 10px #4CAF50; }
  50% { box-shadow: 0 0 20px #4CAF50, 0 0 25px #4CAF50; }
  100% { box-shadow: 0 0 5px #4CAF50, 0 0 10px #4CAF50; }
`;

const PageContainer = styled(motion.div)`
  padding: 24px;
  background: #f0f8f1;
  min-height: 100vh;
`;

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

const UserHistory = () => {
  const [history, setHistory] = useState([]);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    fetchHistory();
  }, []);

  const fetchHistory = async () => {
    setLoading(true);
    try {
      const response = await fetchHistoryAPI(); // from api.js
      // The data is presumably an array of records, per your Django view
      setHistory(response.data);
    } catch (error) {
      message.error({
        content: "Failed to fetch user history",
        style: { marginTop: "20vh" },
      });
    } finally {
      setLoading(false);
    }
  };

  // Use a helper function to format timestamps
  const formatTimestamp = (isoString) => {
    if (!isoString) return "";
    const dateObj = new Date(isoString);
    return dateObj.toLocaleString(); // or customize with dayjs/moment
  };

  // Define columns for the table
  const columns = [
    {
      title: "ID",
      dataIndex: "image_id",
      key: "image_id",
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
      title: "Username",
      dataIndex: "username",
      key: "username",
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
      title: "Summary",
      dataIndex: "summary",
      key: "summary",
      render: (text) => (
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ duration: 0.5 }}
        >
          {text}
        </motion.div>
      ),
    },
    {
      title: "Model Chosen",
      dataIndex: "model_chosen",
      key: "model_chosen",
      render: (text) => (
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ duration: 0.5 }}
        >
          {text}
        </motion.div>
      ),
    },
    {
      title: "Crop Name",
      dataIndex: "crop_name",
      key: "crop_name",
      render: (text) => (
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ duration: 0.5 }}
        >
          {text}
        </motion.div>
      ),
    },
    {
      title: "Image",
      dataIndex: "processed_image_url",
      key: "processed_image_url",
      render: (url) => (
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ duration: 0.5 }}
        >
          {url ? (
            <img
              src={url}
              alt="Processed"
              style={{ maxWidth: "100px", borderRadius: "5px" }}
            />
          ) : (
            "No image"
          )}
        </motion.div>
      ),
    },
    {
      title: "Created At",
      dataIndex: "created_at",
      key: "created_at",
      render: (timestamp) => {
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
  ];

  return (
    <PageContainer
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      transition={{ duration: 0.5 }}
    >
      <h2 style={{ marginBottom: 20 }}>User History</h2>

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
              dataSource={history}
              rowKey="image_id"
              style={{ marginTop: 20 }}
            />
          </motion.div>
        )}
      </AnimatePresence>
    </PageContainer>
  );
};

export default UserHistory;
