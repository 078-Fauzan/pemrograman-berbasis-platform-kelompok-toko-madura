/**
 * Generator nomor faktur / invoice unik berdasarkan tanggal dan sekuens acak
 * Format: INV-YYYYMMDD-XXXX (contoh: INV-20261031-4829)
 */
function generateInvoiceNumber(prefix = 'INV') {
  const now = new Date();
  const year = now.getFullYear();
  const month = String(now.getMonth() + 1).padStart(2, '0');
  const day = String(now.getDate()).padStart(2, '0');
  const dateStr = `${year}${month}${day}`;

  const randomStr = Math.floor(1000 + Math.random() * 9000); // 4 digit angka unik
  return `${prefix}-${dateStr}-${randomStr}`;
}

module.exports = {
  generateInvoiceNumber,
};
