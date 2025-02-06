import React, { useEffect, useState } from "react";
import { Card, Row, Col, message } from "antd";
import axios from "axios";

const Dashboard = () => {
  const [stats, setStats] = useState({
    totalTips: 0,
    totalDiseases: 0,
    totalNews: 0,
  });

  useEffect(() => {
    fetchStats();
  }, []);

  const fetchStats = async () => {
    try {
      const tipsResponse = await axios.get("http://127.0.0.1:8000/api/tips", { withCredentials: true });
      const diseasesResponse = await axios.get("http://127.0.0.1:8000/api/diseases", { withCredentials: true });
      const newsResponse = await axios.get("http://127.0.0.1:8000/api/news", { withCredentials: true });

      setStats({
        totalTips: tipsResponse.data.tips.length,
        totalDiseases: diseasesResponse.data.diseases.length,
        totalNews: newsResponse.data.news.length,
      });
    } catch (error) {
      message.error("Failed to fetch dashboard stats");
    }
  };

  return (
    <Row gutter={16}>
      <Col span={8}>
        <Card title="Total Crop Tips" bordered={false} style={{ textAlign: "center" }}>
          <h2>{stats.totalTips}</h2>
        </Card>
      </Col>
      <Col span={8}>
        <Card title="Total Diseases" bordered={false} style={{ textAlign: "center" }}>
          <h2>{stats.totalDiseases}</h2>
        </Card>
      </Col>
      <Col span={8}>
        <Card title="Total News Articles" bordered={false} style={{ textAlign: "center" }}>
          <h2>{stats.totalNews}</h2>
        </Card>
      </Col>
    </Row>
  );
};

export default Dashboard;
