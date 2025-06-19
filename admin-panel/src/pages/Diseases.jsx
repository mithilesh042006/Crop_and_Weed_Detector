import React, { useEffect, useState } from "react";
import { Table, Button, message, Modal, Form, Select, Spin, Input } from "antd";
import { motion, AnimatePresence } from "framer-motion";
import styled, { keyframes } from "styled-components";
import { PlusCircle, Trash2, Leaf, Send } from "lucide-react";
import axios from "axios";

// Crop names array
const cropNames = [
  // "almond",
    "banana",
    // "cardamom",
    "cherry",
    "chilli",
    // "clove",
    // "coconut",
    // "coffee-plant",
    // "cotton",
    // "cucumber",
    // "fox_nut(makhana)",
    // "gram",
    // "jowar",
    // "jute",
    // "lemon",
    "maize",
    // "mustard-oil",
    // "olive-tree",
    // "papaya",
    "pearl_millet(bajra)",
    // "pineapple",
    // "rice",
    // "soyabean",
    // "sugarcane",
    // "sunflower",
    // "tea",
    "tobacco-plant",
    "tomato",
    // "vigna-radiati(mung)",
    "wheat"
].sort();

// Animation keyframes (same glow as in tips)
const glowAnimation = keyframes`
  0% { box-shadow: 0 0 5px #4CAF50, 0 0 10px #4CAF50; }
  50% { box-shadow: 0 0 20px #4CAF50, 0 0 25px #4CAF50; }
  100% { box-shadow: 0 0 5px #4CAF50, 0 0 10px #4CAF50; }
`;

// Styled Components
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

const Diseases = () => {
  const [diseases, setDiseases] = useState([]);
  const [loading, setLoading] = useState(false);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [form] = Form.useForm();

  useEffect(() => {
    fetchDiseases();
  }, []);

  // Fetch diseases from API
  const fetchDiseases = async () => {
    setLoading(true);
    try {
      const response = await axios.get("http://127.0.0.1:8000/api/diseases", {
        withCredentials: true,
      });
      setDiseases(response.data.diseases);
    } catch (error) {
      message.error({
        content: "Failed to fetch diseases",
        style: { marginTop: '20vh' },
      });
    } finally {
      setLoading(false);
    }
  };

  // Add disease to the database
  const handleAddDisease = async (values) => {
    setLoading(true);
    try {
      await axios.post("http://127.0.0.1:8000/admin_dashboard/add_disease", values, {
        withCredentials: true,
      });
      message.success({
        content: "Disease added successfully",
        icon: <Leaf size={20} color="#4CAF50" />,
      });
      setIsModalOpen(false);
      form.resetFields();
      fetchDiseases();
    } catch (error) {
      message.error("Failed to add disease");
    } finally {
      setLoading(false);
    }
  };

  // Delete disease by name
  const handleDelete = async (diseaseName) => {
    setLoading(true);
    try {
      await axios.delete("http://127.0.0.1:8000/admin_dashboard/delete_disease", {
        data: { disease_name: diseaseName },
        withCredentials: true,
      });
      message.success({
        content: "Disease deleted successfully",
        icon: <Trash2 size={20} color="#ff4d4f" />,
      });
      fetchDiseases();
    } catch (error) {
      message.error("Failed to delete disease");
    } finally {
      setLoading(false);
    }
  };

  // Table columns
  const columns = [
    {
      title: "Disease Name",
      dataIndex: "disease_name",
      key: "disease_name",
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
      title: "Crop Name",
      dataIndex: "crop_name",
      key: "crop_name",
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
      title: "Cure",
      dataIndex: "cure",
      key: "cure",
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
      title: "Commonness",
      dataIndex: "commonness",
      key: "commonness",
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
      title: "Action",
      key: "action",
      render: (_, record) => (
        <DeleteButton
          danger
          type="primary"
          onClick={() => handleDelete(record.disease_name)}
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
      {/* Add New Disease Button */}
      <AddButton
        type="primary"
        onClick={() => setIsModalOpen(true)}
        icon={<PlusCircle size={20} />}
      >
        Add New Disease
      </AddButton>

      {/* Table and Spinner with framer-motion transitions */}
      <AnimatePresence>
        {loading ? (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            style={{ textAlign: 'center', marginTop: '50px' }}
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
              dataSource={diseases}
              rowKey="disease_name"
              style={{ marginTop: 20 }}
            />
          </motion.div>
        )}
      </AnimatePresence>

      {/* Modal for Adding Disease */}
      <StyledModal
        title="Add New Disease"
        open={isModalOpen}
        onCancel={() => setIsModalOpen(false)}
        footer={null}
      >
        <Form form={form} layout="vertical" onFinish={handleAddDisease}>
          <Form.Item
            label="Disease Name"
            name="disease_name"
            rules={[{ required: true, message: "Please enter a disease name" }]}
          >
            <Input />
          </Form.Item>
          <Form.Item
            label="Crop Name"
            name="crop_name"
            rules={[{ required: true, message: "Please select a crop" }]}
          >
            <Select
              showSearch
              placeholder="Select a crop"
              optionFilterProp="children"
              filterOption={(input, option) =>
                option.children.toLowerCase().indexOf(input.toLowerCase()) >= 0
              }
            >
              {cropNames.map((crop) => (
                <Select.Option key={crop} value={crop}>
                  {crop}
                </Select.Option>
              ))}
            </Select>
          </Form.Item>
          <Form.Item
            label="Cure"
            name="cure"
            rules={[{ required: true, message: "Please enter a cure" }]}
          >
            <Input.TextArea rows={4} />
          </Form.Item>
          <Form.Item
            label="Commonness"
            name="commonness"
            rules={[{ required: true, message: "Please enter how common it is" }]}
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
              Add Disease
            </Button>
          </Form.Item>
        </Form>
      </StyledModal>
    </PageContainer>
  );
};

export default Diseases;
