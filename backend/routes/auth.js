const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { PrismaClient } = require('../generated/prisma');
const Joi = require('joi');
const crypto = require('crypto');
const rateLimit = require('express-rate-limit');

const { sendVerificationEmail, sendPasswordResetEmail, sendRegistrationCode } = require('../services/emailService');
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

// 验证码限制（每分钟最多3次）
const verificationCodeLimiter = rateLimit({
  windowMs: 60 * 1000, // 1分钟
  max: 3,
  message: {
    success: false,
    message: '验证码请求过于频繁，请1分钟后再试'
  }
});

// 验证模式
const sendCodeSchema = Joi.object({
  email: Joi.string().email().required().messages({
    'string.email': '请输入有效的邮箱地址',
    'any.required': '邮箱地址是必需的'
  })
});

const registerSchema = Joi.object({
  email: Joi.string().email().required().messages({
    'string.email': '请输入有效的邮箱地址',
    'any.required': '邮箱地址是必需的'
  }),
  code: Joi.string().length(6).pattern(/^\d+$/).required().messages({
    'string.length': '验证码必须是6位数字',
    'string.pattern.base': '验证码必须是6位数字',
    'any.required': '验证码是必需的'
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

// 生成6位数字验证码
const generateVerificationCode = () => {
  return Math.floor(100000 + Math.random() * 900000).toString();
};

// 1. 发送注册验证码
router.post('/send-verification-code', verificationCodeLimiter, async (req, res, next) => {
  try {
    // 验证输入
    const { error, value } = sendCodeSchema.validate(req.body);
    if (error) {
      return res.status(400).json({
        success: false,
        message: error.details[0].message
      });
    }

    const { email } = value;

    // 检查邮箱是否已被注册
    const existingUser = await prisma.user.findUnique({
      where: { email }
    });

    if (existingUser) {
      return res.status(400).json({
        success: false,
        message: '该邮箱已被注册，请直接登录'
      });
    }

    // 生成验证码
    const code = generateVerificationCode();
    const expiresAt = new Date();
    expiresAt.setMinutes(expiresAt.getMinutes() + 5); // 5分钟后过期

    // 删除该邮箱之前的验证码
    await prisma.emailVerificationCode.deleteMany({
      where: { email }
    });

    // 保存验证码
    await prisma.emailVerificationCode.create({
      data: {
        email,
        code,
        expiresAt
      }
    });

    // 发送验证码邮件
    if (process.env.NODE_ENV === 'production') {
      await sendRegistrationCode(email, code);
    } else {
      console.log(`🧪 测试环境验证码: ${code}`);
    }

    res.json({
      success: true,
      message: process.env.NODE_ENV === 'production' 
        ? '验证码已发送到您的邮箱，请查收' 
        : `测试环境验证码: ${code}`,
      testCode: process.env.NODE_ENV !== 'production' ? code : undefined
    });

  } catch (error) {
    next(error);
  }
});

// 2. 注册接口（需要验证码）
router.post('/register', async (req, res, next) => {
  try {
    // 验证输入
    const { error, value } = registerSchema.validate(req.body);
    if (error) {
      return res.status(400).json({
        success: false,
        message: error.details[0].message
      });
    }

    const { email, code, password, username } = value;

    // 验证验证码
    const verificationRecord = await prisma.emailVerificationCode.findFirst({
      where: {
        email,
        code,
        isUsed: false
      },
      orderBy: {
        createdAt: 'desc'
      }
    });

    if (!verificationRecord) {
      return res.status(400).json({
        success: false,
        message: '验证码错误或已过期'
      });
    }

    // 检查验证码是否过期
    if (new Date() > verificationRecord.expiresAt) {
      return res.status(400).json({
        success: false,
        message: '验证码已过期，请重新获取'
      });
    }

    // 检查尝试次数
    if (verificationRecord.attempts >= 3) {
      return res.status(400).json({
        success: false,
        message: '验证码尝试次数过多，请重新获取'
      });
    }

    // 再次检查邮箱是否已被注册（防止并发）
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

    // 创建用户（邮箱已通过验证码验证）
    const user = await prisma.user.create({
      data: {
        email,
        password: hashedPassword,
        username: username || email.split('@')[0],
        isEmailVerified: true // 验证码验证通过，设置为已验证
      }
    });

    // 标记验证码为已使用
    await prisma.emailVerificationCode.update({
      where: { id: verificationRecord.id },
      data: { isUsed: true }
    });

    // 生成访问令牌
    const token = generateToken(user.id);

    res.status(201).json({
      success: true,
      message: '注册成功！欢迎加入跑步追踪器 🎉',
      data: {
        token,
        user: {
          id: user.id,
          email: user.email,
          username: user.username,
          avatar: user.avatar,
          bio: user.bio,
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

// 3. 登录接口
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
          bio: user.bio,
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

// 4. 验证邮箱接口
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

// 5. 重新发送验证邮件
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

// 6. 获取当前用户信息
router.get('/me', authenticateToken, async (req, res) => {
  res.json({
    success: true,
    data: {
      user: req.user
    }
  });
});

// 7. 更新用户信息
router.put('/profile', authenticateToken, async (req, res, next) => {
  try {
    const { username, avatar, bio } = req.body;
    
    // 验证输入
    const updateData = {};
    
    if (username !== undefined) {
      if (username.trim().length < 2 || username.trim().length > 20) {
        return res.status(400).json({
          success: false,
          message: '用户名长度必须在2-20个字符之间'
        });
      }
      updateData.username = username.trim();
    }
    
    if (avatar !== undefined) {
      if (avatar && typeof avatar !== 'string') {
        return res.status(400).json({
          success: false,
          message: '头像必须是有效的字符串'
        });
      }
      updateData.avatar = avatar;
    }
    
    if (bio !== undefined) {
      if (bio && bio.length > 200) {
        return res.status(400).json({
          success: false,
          message: '个人简介不能超过200个字符'
        });
      }
      updateData.bio = bio || null;
    }

    // 如果没有更新内容
    if (Object.keys(updateData).length === 0) {
      return res.status(400).json({
        success: false,
        message: '没有提供任何更新内容'
      });
    }

    const updatedUser = await prisma.user.update({
      where: { id: req.user.id },
      data: updateData,
      select: {
        id: true,
        email: true,
        username: true,
        avatar: true,
        bio: true,
        isEmailVerified: true,
        createdAt: true,
        updatedAt: true
      }
    });

    res.json({
      success: true,
      message: '个人资料更新成功',
      data: {
        user: updatedUser
      }
    });
  } catch (error) {
    next(error);
  }
});

// 8. 退出登录
router.post('/logout', authenticateToken, async (req, res) => {
  // 在实际应用中，可以在这里将token加入黑名单
  res.json({
    success: true,
    message: '退出登录成功'
  });
});

module.exports = router; 