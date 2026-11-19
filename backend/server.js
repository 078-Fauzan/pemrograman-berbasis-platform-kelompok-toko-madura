
const app = require('./src/app');
const config = require('./src/config/env');
const { testConnection, pool } = require('./src/config/database');

async function startServer() {
  let server;

  try {
    // 1. Periksa koneksi database
    await testConnection();

    // 2. Jalankan Express
    server = app.listen(config.port, '0.0.0.0', () => {
      console.log('========================================');
      console.log('UMKMate Backend Server Berjalan!');
      console.log(`URL Lokal    : http://localhost:${config.port}`);
      console.log(`Base API URL : http://localhost:${config.port}/api/v1`);
      console.log(`Environment  : ${config.env}`);
      console.log('========================================');
    });

    // 3. Tangani error server
    server.on('error', (error) => {
      console.error('[Server Error]', error.message);
    });

    // 4. Graceful shutdown
    const shutdown = () => {
      console.log('\n[Server] Menutup server...');

      server.close(async () => {
        try {
          await pool.end();
          console.log('[Server] Koneksi database ditutup.');
          process.exit(0);
        } catch (error) {
          console.error('[Shutdown Error]', error.message);
          process.exit(1);
        }
      });
    };

    process.on('SIGTERM', shutdown);
    process.on('SIGINT', shutdown);

  } catch (error) {
    console.error('[Startup Error]', error.message);

    await pool.end().catch(() => {});
    process.exit(1);
  }
}

startServer();
