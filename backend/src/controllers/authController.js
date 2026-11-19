const authService = require('../services/authService');
const { successResponse, errorResponse } = require('../utils/responseHelper');

/**
 * POST /api/v1/auth/register
 */
async function register(req, res, next) {
  try {
    const result = await authService.registerStoreAndOwner(req.body);
    return successResponse(res, result, 'Pendaftaran toko dan pemilik berhasil.', 201);
  } catch (error) {
    next(error);
  }
}

/**
 * POST /api/v1/auth/register-customer
 */
async function registerCustomer(req, res, next) {
  try {
    const result = await authService.registerCustomer(req.body);
    return successResponse(res, result, 'Pendaftaran akun pembeli berhasil.', 201);
  } catch (error) {
    next(error);
  }
}

/**
 * POST /api/v1/auth/login
 */
async function login(req, res, next) {
  try {
    const result = await authService.loginUser(req.body);
    return successResponse(res, result, 'Login berhasil.');
  } catch (error) {
    next(error);
  }
}

/**
 * GET /api/v1/auth/me
 */
async function getMe(req, res, next) {
  try {
    const result = await authService.getMe(req.user.userId, req.user.storeId);
    return successResponse(res, result, 'Profil pengguna berhasil diambil.');
  } catch (error) {
    next(error);
  }
}

/**
 * PUT /api/v1/auth/profile
 */
async function updateProfile(req, res, next) {
  try {
    const result = await authService.updateProfile(
      req.user.userId,
      req.user.storeId,
      req.user.role,
      req.body
    );
    return successResponse(res, result, 'Profil berhasil diperbarui.');
  } catch (error) {
    next(error);
  }
}

/**
 * POST /api/v1/auth/forgot-password
 */
async function forgotPassword(req, res, next) {
  try {
    const result = await authService.requestForgotPassword(req.body.email);
    return successResponse(res, result, result.message);
  } catch (error) {
    next(error);
  }
}

/**
 * POST /api/v1/auth/reset-password
 */
async function resetPassword(req, res, next) {
  try {
    const result = await authService.executeResetPassword(req.body.token, req.body.new_password);
    return successResponse(res, result, result.message);
  } catch (error) {
    next(error);
  }
}

module.exports = {
  register,
  registerCustomer,
  login,
  getMe,
  updateProfile,
  forgotPassword,
  resetPassword,
};
