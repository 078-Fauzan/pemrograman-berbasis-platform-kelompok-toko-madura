const jwt = require('jsonwebtoken');
const config = require('../config/env');

/**
 * Menghasilkan JWT token berisi klaim: userId, storeId, role, email
 */
function generateToken(payload, expiresIn = config.jwt.expiresIn) {
  return jwt.sign(
    {
      userId: payload.userId,
      storeId: payload.storeId,
      role: payload.role,
      email: payload.email,
    },
    config.jwt.secret,
    { expiresIn }
  );
}

/**
 * Verifikasi token JWT
 */
function verifyToken(token) {
  try {
    return jwt.verify(token, config.jwt.secret);
  } catch (err) {
    return null;
  }
}

module.exports = {
  generateToken,
  verifyToken,
};
