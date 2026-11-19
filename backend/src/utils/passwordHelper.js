const bcrypt = require('bcryptjs');

const SALT_ROUNDS = 10;

/**
 * Hash plain text password menggunakan bcrypt
 */
async function hashPassword(plainPassword) {
  return bcrypt.hash(plainPassword, SALT_ROUNDS);
}

/**
 * Membandingkan plain text password dengan hash bcrypt
 */
async function comparePassword(plainPassword, hashedPassword) {
  return bcrypt.compare(plainPassword, hashedPassword);
}

module.exports = {
  hashPassword,
  comparePassword,
};
