// src/pages/Tips.jsx

import React, { useEffect, useState } from "react";
import { Table, Button, message, Modal, Form, Input, Spin } from "antd";
import { fetchTipsAPI, addTipAPI, deleteTipAPI } from "../api/api";

const Tips = () => {
  const [tips, setTips] = useState([]);
  const [loading, setLoading] = useState(false);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [form] = Form.useForm();

  // Fetch tips on first render
  useEffect(() => {
    fetchTips();
  }, []);

  const fetchTips = async () => {
    setLoading(true);
    try {
      const response = await fetchTipsAPI();
      setTips(response.data.tips);
    } catch (error) {
      message.error("Failed to fetch tips");
    } finally {
      setLoading(false);
    }
  };

  // Add Tip
  const handleAddTip = async (values) => {
    setLoading(true);
    try {
      // Make POST request w/ session + csrf in the Cookie
      await addTipAPI(values);
      message.success("Tip added successfully");
      setIsModalOpen(false);
      form.resetFields();
      fetchTips();
    } catch (error) {
      message.error("Failed to add tip");
    } finally {
      setLoading(false);
    }
  };

  // Delete Tip
  const handleDelete = async (cropName) => {
    setLoading(true);
    try {
      // Make DELETE request w/ session + csrf in the Cookie
      await deleteTipAPI(cropName);
      message.success("Tip deleted successfully");
      fetchTips();
    } catch (error) {
      message.error("Failed to delete tip");
    } finally {
      setLoading(false);
    }
  };

  const columns = [
    { title: "Crop Name", dataIndex: "crop_name", key: "crop_name" },
    { title: "Tips", dataIndex: "crop_tips", key: "crop_tips" },
    {
      title: "Action",
      key: "action",
      render: (_, record) => (
        <Button
          danger
          type="primary"
          onClick={() => handleDelete(record.crop_name)}
        >
          Delete
        </Button>
      ),
    },
  ];

  return (
    <div>
      <Button
        type="primary"
        onClick={() => setIsModalOpen(true)}
        style={{ marginBottom: 20 }}
      >
        Add New Tip
      </Button>

      {loading ? (
        <Spin size="large" />
      ) : (
        <Table columns={columns} dataSource={tips} rowKey="crop_name" />
      )}

      <Modal
        title="Add New Crop Tip"
        open={isModalOpen}
        onCancel={() => setIsModalOpen(false)}
        footer={null}
      >
        <Form form={form} layout="vertical" onFinish={handleAddTip}>
          <Form.Item
            label="Crop Name"
            name="crop_name"
            rules={[{ required: true, message: "Please enter the crop name" }]}
          >
            <Input />
          </Form.Item>
          <Form.Item
            label="Crop Tips"
            name="crop_tips"
            rules={[{ required: true, message: "Please enter crop tips" }]}
          >
            <Input.TextArea />
          </Form.Item>
          <Form.Item>
            <Button type="primary" htmlType="submit" loading={loading}>
              Add Tip
            </Button>
          </Form.Item>
        </Form>
      </Modal>
    </div>
  );
};

export default Tips;
