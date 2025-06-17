const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
require('dotenv').config();

const authRoutes = require('./routes/auth');
const { errorHandler } = require('./middleware/errorHandler');

const app = express();
const PORT = process.env.PORT || 3000;

// 安全中间件
app.use(helmet());

// CORS配置
app.use(cors({
  origin: process.env.FRONTEND_URL || 'http://localhost:8080',
  credentials: true
}));

// 请求速率限制
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15分钟
  max: 100, // 每个IP最多100个请求
  message: {
    error: '请求过于频繁，请稍后再试'
  }
});
app.use(limiter);

// 解析JSON
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// 健康检查
app.get('/health', (req, res) => {
  res.json({ 
    status: 'OK', 
    timestamp: new Date().toISOString(),
    service: '跑步追踪器后端服务'
  });
});

// API路由
app.use('/api/auth', authRoutes);

// 404处理 - 修复路由语法
app.all('*', (req, res) => {
  res.status(404).json({
    success: false,
    message: '接口不存在'
  });
});

// 错误处理中间件
app.use(errorHandler);

// 启动服务器
const HOST = '0.0.0.0';
app.listen(PORT, HOST, () => {
  console.log(`🚀 跑步追踪器后端服务启动成功!`);
  console.log(`📡 服务正在监听: http://${HOST}:${PORT}`);
  console.log(`💻 本地访问: http://localhost:${PORT}`);
  console.log(` LAN 访问: http://192.168.8.119:${PORT}`);
  console.log(`🌍 环境: ${process.env.NODE_ENV || 'development'}`);
  console.log(`📧 邮件服务: ${process.env.EMAIL_HOST}`);
});

module.exports = app; 