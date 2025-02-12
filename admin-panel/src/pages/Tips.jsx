import React, { useEffect, useState } from "react";
import { Table, Button, message, Modal, Form, Select, Spin, Input } from "antd";
import { motion, AnimatePresence } from "framer-motion";
import styled, { keyframes } from "styled-components";
import { PlusCircle, Trash2, Leaf, Send } from "lucide-react";
import { fetchTipsAPI, addTipAPI, deleteTipAPI } from "../api/api";

// Crop names array
const cropNames = [
  "almond",
  "banana",
  "cardamom",
  "cherry",
  "chilli",
  "clove",
  "coconut",
  "coffee-plant",
  "cotton",
  "cucumber",
  "fox_nut(makhana)",
  "gram",
  "jowar",
  "jute",
  "lemon",
  "maize",
  "mustard-oil",
  "olive-tree",
  "papaya",
  "pearl_millet(bajra)",
  "pineapple",
  "rice",
  "soyabean",
  "sugarcane",
  "sunflower",
  "tea",
  "tobacco-plant",
  "tomato",
  "vigna-radiati(mung)",
  "wheat"
].sort();

// Animation keyframes
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
  background: #4CAF50;
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

const Tips = () => {
  const [tips, setTips] = useState([]);
  const [loading, setLoading] = useState(false);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [form] = Form.useForm();

  useEffect(() => {
    fetchTips();
  }, []);

  const fetchTips = async () => {
    setLoading(true);
    try {
      const response = await fetchTipsAPI();
      setTips(response.data.tips);
    } catch (error) {
      message.error({
        content: "Failed to fetch tips",
        style: { marginTop: '20vh' },
      });
    } finally {
      setLoading(false);
    }
  };

  const handleAddTip = async (values) => {
    setLoading(true);
    try {
      await addTipAPI(values);
      message.success({
        content: "Tip added successfully",
        icon: <Leaf size={20} color="#4CAF50" />,
      });
      setIsModalOpen(false);
      form.resetFields();
      fetchTips();
    } catch (error) {
      message.error("Failed to add tip");
    } finally {
      setLoading(false);
    }
  };

  const handleDelete = async (cropName) => {
    setLoading(true);
    try {
      await deleteTipAPI(cropName);
      message.success({
        content: "Tip deleted successfully",
        icon: <Trash2 size={20} color="#ff4d4f" />,
      });
      fetchTips();
    } catch (error) {
      message.error("Failed to delete tip");
    } finally {
      setLoading(false);
    }
  };

  const columns = [
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
      title: "Tips",
      dataIndex: "crop_tips",
      key: "crop_tips",
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
          onClick={() => handleDelete(record.crop_name)}
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
      <AddButton
        type="primary"
        onClick={() => setIsModalOpen(true)}
        icon={<PlusCircle size={20} />}
      >
        Add New Tip
      </AddButton>

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
              dataSource={tips}
              rowKey="crop_name"
              style={{ marginTop: 20 }}
            />
          </motion.div>
        )}
      </AnimatePresence>

      <StyledModal
        title="Add New Crop Tip"
        open={isModalOpen}
        onCancel={() => setIsModalOpen(false)}
        footer={null}
      >
        <Form form={form} layout="vertical" onFinish={handleAddTip}>
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
              {cropNames.map(crop => (
                <Select.Option key={crop} value={crop}>
                  {crop}
                </Select.Option>
              ))}
            </Select>
          </Form.Item>
          <Form.Item
            label="Crop Tips"
            name="crop_tips"
            rules={[{ required: true, message: "Please enter crop tips" }]}
          >
            <Input.TextArea rows={4} />
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
              Add Tip
            </Button>
          </Form.Item>
        </Form>
      </StyledModal>
    </PageContainer>
  );
};

export default Tips;