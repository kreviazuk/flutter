const nodemailer = require('nodemailer');

// 创建邮件传输器
const createTransporter = () => {
  return nodemailer.createTransport({
    host: process.env.EMAIL_HOST,
    port: parseInt(process.env.EMAIL_PORT),
    secure: process.env.EMAIL_SECURE === 'true',
    auth: {
      user: process.env.EMAIL_USER,
      pass: process.env.EMAIL_PASS
    },
  });
};

// 发送邮箱验证邮件
const sendVerificationEmail = async (email, token) => {
  try {
    const transporter = createTransporter();
    
    const verificationUrl = `${process.env.FRONTEND_URL}/verify-email?token=${token}`;
    
    const mailOptions = {
      from: {
        name: '跑步追踪器',
        address: process.env.EMAIL_FROM
      },
      to: email,
      subject: '🏃‍♂️ 欢迎使用跑步追踪器 - 验证您的邮箱',
      html: `
        <div style="max-width: 600px; margin: 0 auto; padding: 20px; font-family: Arial, sans-serif;">
          <div style="text-align: center; margin-bottom: 30px;">
            <h1 style="color: #2563eb; margin: 0;">🏃‍♂️ 跑步追踪器</h1>
            <p style="color: #6b7280; margin: 10px 0;">记录你的每一步精彩！</p>
          </div>
          
          <div style="background: #f9fafb; padding: 30px; border-radius: 10px; margin: 20px 0;">
            <h2 style="color: #1f2937; margin-top: 0;">邮箱验证</h2>
            <p style="color: #4b5563; line-height: 1.6;">
              感谢您注册跑步追踪器！为了保护您的账户安全，请点击下方按钮验证您的邮箱地址。
            </p>
            
            <div style="text-align: center; margin: 30px 0;">
              <a href="${verificationUrl}" 
                 style="background: #2563eb; color: white; padding: 12px 30px; 
                        text-decoration: none; border-radius: 6px; font-weight: bold;
                        display: inline-block;">
                验证邮箱 ✅
              </a>
            </div>
            
            <p style="color: #6b7280; font-size: 14px; margin-bottom: 0;">
              如果按钮无法点击，请复制以下链接到浏览器：<br>
              <a href="${verificationUrl}" style="color: #2563eb; word-break: break-all;">
                ${verificationUrl}
              </a>
            </p>
          </div>
          
          <div style="border-top: 1px solid #e5e7eb; padding-top: 20px; color: #6b7280; font-size: 14px;">
            <p><strong>温馨提示：</strong></p>
            <ul style="margin: 10px 0; padding-left: 20px;">
              <li>验证链接将在24小时后失效</li>
              <li>如果您没有注册此账户，请忽略此邮件</li>
              <li>请不要回复此邮件</li>
            </ul>
            
            <div style="text-align: center; margin-top: 30px; color: #9ca3af;">
              <p>© 2024 跑步追踪器 | 让运动更有趣</p>
            </div>
          </div>
        </div>
      `
    };

    const result = await transporter.sendMail(mailOptions);
    console.log('✅ 验证邮件发送成功:', result.messageId);
    return { success: true, messageId: result.messageId };
  } catch (error) {
    console.error('❌ 验证邮件发送失败:', error);
    throw new Error(`邮件发送失败: ${error.message}`);
  }
};

// 发送密码重置邮件
const sendPasswordResetEmail = async (email, token) => {
  try {
    const transporter = createTransporter();
    
    const resetUrl = `${process.env.FRONTEND_URL}/reset-password?token=${token}`;
    
    const mailOptions = {
      from: {
        name: '跑步追踪器',
        address: process.env.EMAIL_FROM
      },
      to: email,
      subject: '🔒 重置您的密码 - 跑步追踪器',
      html: `
        <div style="max-width: 600px; margin: 0 auto; padding: 20px; font-family: Arial, sans-serif;">
          <div style="text-align: center; margin-bottom: 30px;">
            <h1 style="color: #dc2626; margin: 0;">🔒 密码重置</h1>
            <p style="color: #6b7280; margin: 10px 0;">跑步追踪器</p>
          </div>
          
          <div style="background: #fef2f2; padding: 30px; border-radius: 10px; margin: 20px 0; border-left: 4px solid #dc2626;">
            <h2 style="color: #1f2937; margin-top: 0;">重置密码请求</h2>
            <p style="color: #4b5563; line-height: 1.6;">
              我们收到了您的密码重置请求。如果这是您本人操作，请点击下方按钮重置密码。
            </p>
            
            <div style="text-align: center; margin: 30px 0;">
              <a href="${resetUrl}" 
                 style="background: #dc2626; color: white; padding: 12px 30px; 
                        text-decoration: none; border-radius: 6px; font-weight: bold;
                        display: inline-block;">
                重置密码 🔑
              </a>
            </div>
            
            <p style="color: #6b7280; font-size: 14px; margin-bottom: 0;">
              如果按钮无法点击，请复制以下链接到浏览器：<br>
              <a href="${resetUrl}" style="color: #dc2626; word-break: break-all;">
                ${resetUrl}
              </a>
            </p>
          </div>
          
          <div style="border-top: 1px solid #e5e7eb; padding-top: 20px; color: #6b7280; font-size: 14px;">
            <p><strong>安全提示：</strong></p>
            <ul style="margin: 10px 0; padding-left: 20px;">
              <li>重置链接将在1小时后失效</li>
              <li>如果不是您本人操作，请忽略此邮件</li>
              <li>建议您定期更换密码以保护账户安全</li>
            </ul>
            
            <div style="text-align: center; margin-top: 30px; color: #9ca3af;">
              <p>© 2024 跑步追踪器 | 让运动更有趣</p>
            </div>
          </div>
        </div>
      `
    };

    const result = await transporter.sendMail(mailOptions);
    console.log('✅ 密码重置邮件发送成功:', result.messageId);
    return { success: true, messageId: result.messageId };
  } catch (error) {
    console.error('❌ 密码重置邮件发送失败:', error);
    throw new Error(`邮件发送失败: ${error.message}`);
  }
};

module.exports = {
  sendVerificationEmail,
  sendPasswordResetEmail
}; 