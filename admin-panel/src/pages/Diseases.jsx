import React, { useEffect, useState } from "react";
import { Table, Button, message, Modal, Form, Input } from "antd";
import axios from "axios";

const Diseases = () => {
  const [diseases, setDiseases] = useState([]);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [form] = Form.useForm();

  useEffect(() => {
    fetchDiseases();
  }, []);

  const fetchDiseases = async () => {
    try {
      const response = await axios.get("http://127.0.0.1:8000/api/diseases", {
        withCredentials: true,
      });
      setDiseases(response.data.diseases);
    } catch (error) {
      message.error("Failed to fetch diseases");
    }
  };

  const handleDelete = async (diseaseName) => {
    try {
      await axios.delete(
        "http://127.0.0.1:8000/admin_dashboard/delete_disease",
        {
          data: { disease_name: diseaseName },
          withCredentials: true,
        }
      );
      message.success("Disease deleted successfully");
      fetchDiseases();
    } catch (error) {
      message.error("Failed to delete disease");
    }
  };

  const handleAddDisease = async (values) => {
    try {
      // Note: "values" will include crop_name, disease_name, cure, commonness
      await axios.post(
        "http://127.0.0.1:8000/admin_dashboard/add_disease",
        values,
        {
          withCredentials: true,
        }
      );
      message.success("Disease added/updated successfully");
      setIsModalOpen(false);
      form.resetFields();
      fetchDiseases();
    } catch (error) {
      message.error("Failed to add disease");
    }
  };

  const columns = [
    { title: "Disease Name", dataIndex: "disease_name", key: "disease_name" },
    { title: "Crop Name", dataIndex: "crop_name", key: "crop_name" },
    { title: "Cure", dataIndex: "cure", key: "cure" },
    { title: "Commonness", dataIndex: "commonness", key: "commonness" },
    {
      title: "Action",
      key: "action",
      render: (_, record) => (
        <Button
          type="primary"
          danger
          onClick={() => handleDelete(record.disease_name)}
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
        style={{ marginBottom: "20px" }}
      >
        Add New Disease
      </Button>

      <Table columns={columns} dataSource={diseases} rowKey="disease_name" />

      {/* Modal for Adding/Updating Disease */}
      <Modal
        title="Add/Update Disease"
        open={isModalOpen}
        onCancel={() => setIsModalOpen(false)}
        footer={null}
      >
        <Form form={form} layout="vertical" onFinish={handleAddDisease}>
          <Form.Item
            label="Disease Name"
            name="disease_name"
            rules={[
              { required: true, message: "Please enter the disease name" },
            ]}
          >
            <Input />
          </Form.Item>
          <Form.Item label="Crop Name" name="crop_name">
            <Input />
          </Form.Item>
          <Form.Item
            label="Cure"
            name="cure"
            rules={[{ required: true, message: "Please enter the cure" }]}
          >
            <Input />
          </Form.Item>
          <Form.Item label="Commonness" name="commonness">
            <Input />
          </Form.Item>
          <Form.Item>
            <Button type="primary" htmlType="submit">
              Save Disease
            </Button>
          </Form.Item>
        </Form>
      </Modal>
    </div>
  );
};

export default Diseases;
