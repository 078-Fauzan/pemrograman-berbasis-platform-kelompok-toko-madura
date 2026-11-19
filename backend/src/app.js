const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const config = require('./config/env');
const routes = require('./routes');
const { errorHandler } = require('./middleware/errorHandler');
const { errorResponse } = require('./utils/responseHelper');

const app = express();

// 1. Security & Protection Middleware
app.use(helmet());

// 2. CORS (Cross-Origin Resource Sharing)
app.use(
  cors({
    origin: config.corsOrigin === '*' ? true : config.corsOrigin,
    credentials: true,
    methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization'],
  })
);

// 3. HTTP Request Logger (Hanya aktifkan verbose logging di development)
if (config.env === 'development') {
  app.use(morgan('dev'));
} else {
  app.use(morgan('combined'));
}

// 4. Request Body Parsers
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// 5. Root Welcome Route
app.get('/', (req, res) => {
  res.status(200).json({
    success: true,
    name: 'UMKMate Backend REST API',
    version: '1.0.0',
    description: 'Sistem Informasi Manajemen Warung Madura dan Toko Kelontong',
    api_prefix: '/api/v1',
    docs: '/api/v1/health',
  });
});

// 6. Mount REST API Version 1
app.use('/api/v1', routes);

// 7. Route 404 Not Found Handler
app.use((req, res) => {
  return errorResponse(res, `Endpoint '${req.method} ${req.originalUrl}' tidak ditemukan.`, 404);
});

// 8. Global Centralized Error Handler
app.use(errorHandler);

module.exports = app;
