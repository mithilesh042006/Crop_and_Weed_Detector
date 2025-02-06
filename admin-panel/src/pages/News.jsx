import React, { useEffect, useState } from "react";
import { Table, Button, message, Modal, Form, Input } from "antd";
import axios from "axios";

const News = () => {
  const [news, setNews] = useState([]);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [form] = Form.useForm();

  useEffect(() => {
    fetchNews();
  }, []);

  const fetchNews = async () => {
    try {
      const response = await axios.get("http://127.0.0.1:8000/api/news", { withCredentials: true });
      setNews(response.data.news);
    } catch (error) {
      message.error("Failed to fetch news");
    }
  };

  const handleDelete = async (title) => {
    try {
      await axios.delete("http://127.0.0.1:8000/admin_dashboard/delete_news", {
        data: { title },
        withCredentials: true
      });
      message.success("News deleted successfully");
      fetchNews();
    } catch (error) {
      message.error("Failed to delete news");
    }
  };

  const handleAddNews = async (values) => {
    try {
      await axios.post("http://127.0.0.1:8000/admin_dashboard/add_news", values, { withCredentials: true });
      message.success("News added successfully");
      setIsModalOpen(false);
      fetchNews();
    } catch (error) {
      message.error("Failed to add news");
    }
  };

  const columns = [
    { title: "Title", dataIndex: "title", key: "title" },
    { title: "Subtitle", dataIndex: "subtitle", key: "subtitle" },
    { title: "Author", dataIndex: "author_name", key: "author_name" },
    { title: "Published", dataIndex: "timestamp", key: "timestamp" },
    {
      title: "Action",
      key: "action",
      render: (_, record) => (
        <Button type="primary" danger onClick={() => handleDelete(record.title)}>
          Delete
        </Button>
      ),
    },
  ];

  return (
    <div>
      <Button type="primary" onClick={() => setIsModalOpen(true)} style={{ marginBottom: "20px" }}>
        Add News Article
      </Button>

      <Table columns={columns} dataSource={news} rowKey="title" />

      {/* Modal for Adding News */}
      <Modal
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
          <Form.Item
            label="Subtitle"
            name="subtitle"
          >
            <Input />
          </Form.Item>
          <Form.Item
            label="Content"
            name="content"
            rules={[{ required: true, message: "Please enter the news content" }]}
          >
            <Input.TextArea />
          </Form.Item>
          <Form.Item
            label="Author Name"
            name="author_name"
            rules={[{ required: true, message: "Please enter the author name" }]}
          >
            <Input />
          </Form.Item>
          <Form.Item>
            <Button type="primary" htmlType="submit">
              Add News
            </Button>
          </Form.Item>
        </Form>
      </Modal>
    </div>
  );
};

export default News;
