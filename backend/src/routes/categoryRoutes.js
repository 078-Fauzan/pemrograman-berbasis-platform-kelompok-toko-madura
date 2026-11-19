const express = require('express');
const router = express.Router();
const categoryController = require('../controllers/categoryController');
const { authenticate } = require('../middleware/authMiddleware');
const { requireRole } = require('../middleware/roleMiddleware');

router.use(authenticate);

// Baik Owner maupun Kasir dapat melihat daftar kategori produk
router.get('/', categoryController.getCategories);

// Tambah, ubah, dan hapus hanya untuk OWNER
router.post('/', requireRole('owner'), categoryController.createCategory);
router.put('/:id', requireRole('owner'), categoryController.updateCategory);
router.delete('/:id', requireRole('owner'), categoryController.deleteCategory);

module.exports = router;
