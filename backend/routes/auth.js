const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { PrismaClient } = require('../generated/prisma');
const Joi = require('joi');
const crypto = require('crypto');
const rateLimit = require('express-rate-limit');

const { sendVerificationEmail, sendPasswordResetEmail } = require('../services/emailService');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();
const prisma = new PrismaClient();

// 邮件发送限制（每小时最多5次）
const emailLimiter = rateLimit({
  windowMs: 60 * 60 * 1000, // 1小时
  max: 5,
  message: {
    success: false,
    message: '邮件发送过于频繁，请1小时后再试'
  }
});

// 登录限制（每15分钟最多10次）
const loginLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 10,
  message: {
    success: false,
    message: '登录尝试过于频繁，请15分钟后再试'
  }
});

// 验证模式
const registerSchema = Joi.object({
  email: Joi.string().email().required().messages({
    'string.email': '请输入有效的邮箱地址',
    'any.required': '邮箱地址是必需的'
  }),
  password: Joi.string().min(6).required().messages({
    'string.min': '密码至少需要6个字符',
    'any.required': '密码是必需的'
  }),
  username: Joi.string().min(2).max(20).optional().messages({
    'string.min': '用户名至少需要2个字符',
    'string.max': '用户名不能超过20个字符'
  })
});

const loginSchema = Joi.object({
  email: Joi.string().email().required().messages({
    'string.email': '请输入有效的邮箱地址',
    'any.required': '邮箱地址是必需的'
  }),
  password: Joi.string().required().messages({
    'any.required': '密码是必需的'
  })
});

// 生成JWT令牌
const generateToken = (userId) => {
  return jwt.sign({ userId }, process.env.JWT_SECRET, {
    expiresIn: process.env.JWT_EXPIRES_IN
  });
};

// 生成验证令牌
const generateVerificationToken = () => {
  return crypto.randomBytes(32).toString('hex');
};

// 1. 注册接口
router.post('/register', emailLimiter, async (req, res, next) => {
  try {
    // 验证输入
    const { error, value } = registerSchema.validate(req.body);
    if (error) {
      return res.status(400).json({
        success: false,
        message: error.details[0].message
      });
    }

    const { email, password, username } = value;

    // 检查邮箱是否已存在
    const existingUser = await prisma.user.findUnique({
      where: { email }
    });

    if (existingUser) {
      return res.status(400).json({
        success: false,
        message: '该邮箱已被注册'
      });
    }

    // 加密密码
    const hashedPassword = await bcrypt.hash(password, 12);

    // 创建用户
    const user = await prisma.user.create({
      data: {
        email,
        password: hashedPassword,
        username: username || email.split('@')[0]
      }
    });

    // 生成验证令牌
    const verificationToken = generateVerificationToken();
    const expiresAt = new Date();
    expiresAt.setHours(expiresAt.getHours() + 24); // 24小时后过期

    // 保存验证记录
    await prisma.emailVerification.create({
      data: {
        email,
        token: verificationToken,
        expiresAt,
        userId: user.id
      }
    });

    // 发送验证邮件
    await sendVerificationEmail(email, verificationToken);

    res.status(201).json({
      success: true,
      message: '注册成功！验证邮件已发送到您的邮箱，请查收',
      data: {
        user: {
          id: user.id,
          email: user.email,
          username: user.username,
          isEmailVerified: user.isEmailVerified
        }
      }
    });
  } catch (error) {
    next(error);
  }
});

// 2. 登录接口
router.post('/login', loginLimiter, async (req, res, next) => {
  try {
    // 验证输入
    const { error, value } = loginSchema.validate(req.body);
    if (error) {
      return res.status(400).json({
        success: false,
        message: error.details[0].message
      });
    }

    const { email, password } = value;

    // 查找用户
    const user = await prisma.user.findUnique({
      where: { email }
    });

    if (!user) {
      return res.status(401).json({
        success: false,
        message: '邮箱或密码错误'
      });
    }

    // 验证密码
    const isPasswordValid = await bcrypt.compare(password, user.password);
    if (!isPasswordValid) {
      return res.status(401).json({
        success: false,
        message: '邮箱或密码错误'
      });
    }

    // 生成访问令牌
    const token = generateToken(user.id);

    res.json({
      success: true,
      message: '登录成功',
      data: {
        token,
        user: {
          id: user.id,
          email: user.email,
          username: user.username,
          avatar: user.avatar,
          isEmailVerified: user.isEmailVerified,
          createdAt: user.createdAt.toISOString(),
          updatedAt: user.updatedAt.toISOString()
        }
      }
    });
  } catch (error) {
    next(error);
  }
});

// 3. 验证邮箱接口
router.post('/verify-email', async (req, res, next) => {
  try {
    const { token } = req.body;

    if (!token) {
      return res.status(400).json({
        success: false,
        message: '验证令牌是必需的'
      });
    }

    // 查找验证记录
    const verification = await prisma.emailVerification.findUnique({
      where: { token },
      include: { user: true }
    });

    if (!verification) {
      return res.status(400).json({
        success: false,
        message: '无效的验证令牌'
      });
    }

    // 检查是否已使用
    if (verification.isUsed) {
      return res.status(400).json({
        success: false,
        message: '验证令牌已使用'
      });
    }

    // 检查是否过期
    if (new Date() > verification.expiresAt) {
      return res.status(400).json({
        success: false,
        message: '验证令牌已过期，请重新申请'
      });
    }

    // 更新用户验证状态
    await prisma.user.update({
      where: { id: verification.userId },
      data: { isEmailVerified: true }
    });

    // 标记验证令牌为已使用
    await prisma.emailVerification.update({
      where: { id: verification.id },
      data: { isUsed: true }
    });

    res.json({
      success: true,
      message: '邮箱验证成功！'
    });
  } catch (error) {
    next(error);
  }
});

// 4. 重新发送验证邮件
router.post('/resend-verification', emailLimiter, async (req, res, next) => {
  try {
    const { email } = req.body;

    if (!email) {
      return res.status(400).json({
        success: false,
        message: '邮箱地址是必需的'
      });
    }

    // 查找用户
    const user = await prisma.user.findUnique({
      where: { email }
    });

    if (!user) {
      return res.status(404).json({
        success: false,
        message: '用户不存在'
      });
    }

    if (user.isEmailVerified) {
      return res.status(400).json({
        success: false,
        message: '邮箱已验证，无需重复验证'
      });
    }

    // 生成新的验证令牌
    const verificationToken = generateVerificationToken();
    const expiresAt = new Date();
    expiresAt.setHours(expiresAt.getHours() + 24);

    // 创建新的验证记录
    await prisma.emailVerification.create({
      data: {
        email,
        token: verificationToken,
        expiresAt,
        userId: user.id
      }
    });

    // 发送验证邮件
    await sendVerificationEmail(email, verificationToken);

    res.json({
      success: true,
      message: '验证邮件已重新发送'
    });
  } catch (error) {
    next(error);
  }
});

// 5. 获取当前用户信息
router.get('/me', authenticateToken, async (req, res) => {
  res.json({
    success: true,
    data: {
      user: req.user
    }
  });
});

// 6. 更新用户信息
router.put('/profile', authenticateToken, async (req, res, next) => {
  try {
    const { username, avatar } = req.body;
    
    const updateData = {};
    if (username) updateData.username = username;
    if (avatar) updateData.avatar = avatar;

    const updatedUser = await prisma.user.update({
      where: { id: req.user.id },
      data: updateData,
      select: {
        id: true,
        email: true,
        username: true,
        avatar: true,
        isEmailVerified: true
      }
    });

    res.json({
      success: true,
      message: '用户信息更新成功',
      data: {
        user: updatedUser
      }
    });
  } catch (error) {
    next(error);
  }
});

// 7. 退出登录
router.post('/logout', authenticateToken, async (req, res) => {
  // 在实际应用中，可以在这里将token加入黑名单
  res.json({
    success: true,
    message: '退出登录成功'
  });
});

module.exports = router; 