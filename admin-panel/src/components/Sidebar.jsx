import React from "react";
import { Layout, Menu } from "antd";
import { Link } from "react-router-dom";
import {
  DashboardOutlined,
  BookOutlined,
  BugOutlined,
  ReadOutlined,
} from "@ant-design/icons";

const { Sider } = Layout;

const Sidebar = () => {
  return (
    <Sider theme="dark">
      <Menu mode="inline" theme="dark" defaultSelectedKeys={["1"]}>
        <Menu.Item key="1" icon={<DashboardOutlined />}>
          <Link to="/app">Dashboard</Link>
        </Menu.Item>
        <Menu.Item key="2" icon={<BookOutlined />}>
          <Link to="/app/tips">Crop Tips</Link>
        </Menu.Item>
        <Menu.Item key="3" icon={<BugOutlined />}>
          <Link to="/app/diseases">Diseases</Link>
        </Menu.Item>
        <Menu.Item key="4" icon={<ReadOutlined />}>
          <Link to="/app/news">News</Link>
        </Menu.Item>
      </Menu>
    </Sider>
  );
};

export default Sidebar;
