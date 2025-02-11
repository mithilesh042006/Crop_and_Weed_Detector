import React, { useEffect, useState } from "react";
import { Row, Col, message } from "antd";
import axios from "axios";
import styled, { keyframes } from "styled-components";
import { motion, AnimatePresence } from "framer-motion";
import { Coffee, AlertTriangle, Zap } from "lucide-react";
import CountUp from "react-countup";

// Animations
const glowAnimation = keyframes`
  0% { box-shadow: 0 0 5px #00ff00, 0 0 10px #00ff00, 0 0 15px #00ff00; }
  50% { box-shadow: 0 0 10px #00ff00, 0 0 20px #00ff00, 0 0 30px #00ff00; }
  100% { box-shadow: 0 0 5px #00ff00, 0 0 10px #00ff00, 0 0 15px #00ff00; }
`;

const scanlineAnimation = keyframes`
  0% { transform: translateY(-100%); }
  100% { transform: translateY(100%); }
`;

const pulseAnimation = keyframes`
  0% { transform: scale(1); }
  50% { transform: scale(1.05); }
  100% { transform: scale(1); }
`;

// Styled Components
const DashboardContainer = styled.div`
  background: #0a0a0a;
  padding: 24px;
  min-height: 100vh;
  position: relative;
  overflow: hidden;

  &::before {
    content: "";
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background: linear-gradient(
      rgba(32, 32, 32, 0.1) 50%,
      rgba(32, 32, 32, 0.2) 50%
    );
    background-size: 100% 4px;
    pointer-events: none;
    z-index: 1;
  }
`;

const StatsCard = styled(motion.div)`
  background: rgba(16, 16, 16, 0.95);
  border: 1px solid #00ff00;
  border-radius: 8px;
  padding: 20px;
  color: #00ff00;
  position: relative;
  overflow: hidden;
  backdrop-filter: blur(10px);
  cursor: pointer;
  
  &::after {
    content: '';
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    height: 2px;
    background: rgba(0, 255, 0, 0.5);
    animation: ${scanlineAnimation} 2s linear infinite;
  }

  &:hover {
    animation: ${glowAnimation} 1.5s ease-in-out infinite;
    transform: translateY(-5px);
    transition: transform 0.3s ease;
  }
`;

const StatTitle = styled.h3`
  color: #00ff00;
  font-family: 'Orbitron', sans-serif;
  font-size: 1.2em;
  margin-bottom: 15px;
  display: flex;
  align-items: center;
  gap: 10px;

  svg {
    stroke-width: 1.5;
    animation: ${pulseAnimation} 2s infinite ease-in-out;
  }
`;

const StatValue = styled.div`
  font-size: 2.5em;
  font-weight: bold;
  font-family: 'Orbitron', sans-serif;
  text-shadow: 0 0 10px #00ff00;
  letter-spacing: 2px;
`;

const StatusBar = styled.div`
  height: 4px;
  background: #1a1a1a;
  border-radius: 2px;
  margin-top: 15px;
  overflow: hidden;
  position: relative;

  &::after {
    content: '';
    display: block;
    height: 100%;
    width: ${props => props.value}%;
    background: #00ff00;
    transition: width 1s ease-in-out;
    box-shadow: 0 0 10px #00ff00;
  }
`;

const Dashboard = () => {
  const [stats, setStats] = useState({
    totalTips: 0,
    totalDiseases: 0,
    totalNews: 0,
  });
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchStats();
  }, []);

  const fetchStats = async () => {
    try {
      setLoading(true);
      const [tipsResponse, diseasesResponse, newsResponse] = await Promise.all([
        axios.get("http://127.0.0.1:8000/api/tips", { withCredentials: true }),
        axios.get("http://127.0.0.1:8000/api/diseases", { withCredentials: true }),
        axios.get("http://127.0.0.1:8000/api/news", { withCredentials: true }),
      ]);

      setStats({
        totalTips: tipsResponse.data.tips.length,
        totalDiseases: diseasesResponse.data.diseases.length,
        totalNews: newsResponse.data.news.length,
      });
    } catch (error) {
      message.error({
        content: "SYSTEM MALFUNCTION: Failed to fetch dashboard statistics",
        style: {
          background: "#1a1a1a",
          border: "1px solid #00ff00",
          color: "#00ff00",
        },
      });
    } finally {
      setLoading(false);
    }
  };

  const cardVariants = {
    hidden: { opacity: 0, y: 20 },
    visible: {
      opacity: 1,
      y: 0,
      transition: {
        type: "spring",
        stiffness: 100,
        damping: 15,
      },
    },
  };

  const statCards = [
    { icon: Coffee, title: "CROP TIPS", value: stats.totalTips },
    { icon: AlertTriangle, title: "DISEASES", value: stats.totalDiseases },
    { icon: Zap, title: "NEWS FEED", value: stats.totalNews },
  ];

  return (
    <DashboardContainer>
      <Row gutter={[24, 24]}>
        {statCards.map((card, index) => (
          <Col xs={24} sm={8} key={card.title}>
            <AnimatePresence>
              <StatsCard
                variants={cardVariants}
                initial="hidden"
                animate="visible"
                transition={{ delay: 0.2 * (index + 1) }}
                whileHover={{ scale: 1.02 }}
                whileTap={{ scale: 0.98 }}
              >
                <StatTitle>
                  <card.icon /> {card.title}
                </StatTitle>
                <StatValue>
                  <CountUp
                    end={card.value}
                    duration={2.5}
                    separator=","
                  />
                </StatValue>
                <StatusBar value={(card.value / 100) * 100} />
              </StatsCard>
            </AnimatePresence>
          </Col>
        ))}
      </Row>
    </DashboardContainer>
  );
};

export default Dashboard;