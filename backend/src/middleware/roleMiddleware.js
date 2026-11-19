const { errorResponse } = require('../utils/responseHelper');

/**
 * Middleware untuk membatasi akses endpoint berdasarkan role pengguna
 * Contoh pemakaian: requireRole('owner') atau requireRole('owner', 'cashier')
 */
function requireRole(...allowedRoles) {
  return (req, res, next) => {
    if (!req.user) {
      return errorResponse(res, 'Autentikasi diperlukan sebelum memeriksa peran.', 401);
    }

    const userRole = req.user.role;
    const hasAdminAccess =
      (allowedRoles.includes('owner') || allowedRoles.includes('admin')) &&
      (userRole === 'admin' || userRole === 'owner');

    if (!allowedRoles.includes(userRole) && !hasAdminAccess) {
      return errorResponse(
        res,
        `Akses ditolak. Fitur ini hanya diperuntukkan bagi pengguna dengan peran: [${allowedRoles.join(', ')}].`,
        403
      );
    }

    next();
  };
}

module.exports = {
  requireRole,
};
