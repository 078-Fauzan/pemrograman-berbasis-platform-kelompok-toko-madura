const mysql = require('mysql2/promise');
const config = require('./env');

const pool = mysql.createPool({
  host: config.db.host,
  port: config.db.port,
  user: config.db.user,
  password: config.db.password,
  database: config.db.name,
  waitForConnections: true,
  connectionLimit: 15,
  queueLimit: 0,
  enableKeepAlive: true,
  keepAliveInitialDelay: 10000,
  decimalNumbers: true, // Kembalikan DECIMAL sebagai number bukan string jika memungkinkan
  timezone: '+07:00', // Asia/Jakarta (WIB)
});

// Fungsi untuk menguji konektivitas pool
async function testConnection() {
  try {
    const connection = await pool.getConnection();
    console.log(`[Database] Terhubung ke MySQL ${config.db.name} pada ${config.db.host}:${config.db.port}`);
    connection.release();
    return true;
  } catch (error) {
    console.error(`[Database Error] Gagal terhubung ke MySQL:`, error.message);
    throw error;
  }
}

module.exports = {
  pool,
  testConnection,
};
