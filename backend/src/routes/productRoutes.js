const express = require('express');
const router = express.Router();
const productController = require('../controllers/productController');
const { authenticate } = require('../middleware/authMiddleware');
const { requireRole } = require('../middleware/roleMiddleware');

router.use(authenticate);

// Endpoint pencarian barcode harus diletakkan sebelum /:id agar tidak tertimpa
router.get('/barcode/:code', productController.getProductByBarcode);

router.get('/', productController.getProducts);
router.get('/:id', productController.getProductById);

// Operasi manajemen hanya untuk OWNER
router.post('/', requireRole('owner'), productController.createProduct);
router.put('/:id', requireRole('owner'), productController.updateProduct);
router.delete('/:id', requireRole('owner'), productController.deleteProduct);

module.exports = router;
