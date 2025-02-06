import React from "react";
import { Layout } from "antd";
import { Outlet } from "react-router-dom";
import Sidebar from "./components/Sidebar";
import AppHeader from "./components/Header";

const { Content } = Layout;

const App = () => {
  return (
    <Layout style={{ minHeight: "100vh" }}>
      <Sidebar />
      <Layout>
        <AppHeader />
        <Content style={{ margin: "20px", background: "#fff", padding: "20px" }}>
          <Outlet />
        </Content>
      </Layout>
    </Layout>
  );
};

export default App;
