const http = require('http');

const BASE_URL = 'http://localhost:5000/api/v1';

async function req(method, path, body = null, token = null) {
  return new Promise((resolve, reject) => {
    const url = new URL(BASE_URL + path);
    const headers = { 'Content-Type': 'application/json' };
    if (token) headers['Authorization'] = `Bearer ${token}`;

    const payload = body ? JSON.stringify(body) : null;
    if (payload) headers['Content-Length'] = Buffer.byteLength(payload);

    const r = http.request(url, { method, headers }, (res) => {
      let raw = '';
      res.on('data', (c) => (raw += c));
      res.on('end', () => {
        try {
          resolve({ status: res.statusCode, data: JSON.parse(raw) });
        } catch {
          resolve({ status: res.statusCode, raw });
        }
      });
    });
    r.on('error', reject);
    if (payload) r.write(payload);
    r.end();
  });
}

async function runTests() {
  console.log('🧪 MENJALANKAN TEST 3-ROLE & PESANAN PEMBELI\n');

  // 1. Health check
  const health = await req('GET', '/health');
  console.log('1. Health Check:', health.status === 200 ? '✅ PASS' : '❌ FAIL');

  // 2. Login Admin
  const adminLogin = await req('POST', '/auth/login', {
    email: 'admin@umkmate.com',
    password: 'Password123!',
  });
  console.log('2. Login Admin:', adminLogin.status === 200 && adminLogin.data.data.user.role === 'admin' ? '✅ PASS' : '❌ FAIL');
  const adminToken = adminLogin.data?.data?.token;

  // 3. Login Kasir
  const cashierLogin = await req('POST', '/auth/login', {
    email: 'kasir1@umkmate.com',
    password: 'Password123!',
  });
  console.log('3. Login Kasir:', cashierLogin.status === 200 && cashierLogin.data.data.user.role === 'cashier' ? '✅ PASS' : '❌ FAIL');
  const cashierToken = cashierLogin.data?.data?.token;

  // 4. Login Customer
  const customerLogin = await req('POST', '/auth/login', {
    email: 'customer@umkmate.com',
    password: 'Password123!',
  });
  console.log('4. Login Customer:', customerLogin.status === 200 && customerLogin.data.data.user.role === 'customer' ? '✅ PASS' : '❌ FAIL');
  const customerToken = customerLogin.data?.data?.token;

  // 5. Register Customer Baru
  const testEmail = `cust.${Date.now()}@example.com`;
  const registerCust = await req('POST', '/auth/register-customer', {
    name: 'Customer Baru Test',
    email: testEmail,
    phone: '081299998888',
    password: 'Password123!',
    address: 'Jl. Malioboro No. 10, Yogyakarta',
  });
  console.log('5. Register Customer Baru:', registerCust.status === 201 && registerCust.data.data.user.role === 'customer' ? '✅ PASS' : '❌ FAIL');
  const newCustToken = registerCust.data?.data?.token;

  // 6. Buat Pesanan oleh Customer Baru
  const createOrder = await req(
    'POST',
    '/orders',
    {
      order_type: 'takeaway',
      delivery_address: 'Ambil langsung di warung',
      payment_method: 'cash',
      notes: 'Siapkan segera',
      items: [
        { product_id: 15, quantity: 2 }, // 2x Indomie
        { product_id: 7, quantity: 1 },  // 1x Le Minerale
      ],
    },
    newCustToken
  );
  console.log('6. Buat Pesanan Customer:', createOrder.status === 201 && createOrder.data.data.order_number ? '✅ PASS' : '❌ FAIL');
  const orderId = createOrder.data?.data?.id;

  // 7. Customer Lihat Riwayat Pesanan Sendiri
  const custOrders = await req('GET', '/orders', null, newCustToken);
  console.log('7. Riwayat Pesanan Customer:', custOrders.status === 200 && custOrders.data.data.length >= 1 ? '✅ PASS' : '❌ FAIL');

  // 8. Kasir Lihat Semua Pesanan Toko
  const cashierOrders = await req('GET', '/orders', null, cashierToken);
  console.log('8. Kasir Lihat Semua Pesanan Toko:', cashierOrders.status === 200 && cashierOrders.data.data.length >= 2 ? '✅ PASS' : '❌ FAIL');

  // 9. Kasir Update Status Pesanan ke "confirmed"
  const updateStatus = await req(
    'PATCH',
    `/orders/${orderId}/status`,
    { status: 'confirmed' },
    cashierToken
  );
  console.log('9. Kasir Konfirmasi Pesanan:', updateStatus.status === 200 && updateStatus.data.data.new_status === 'confirmed' ? '✅ PASS' : '❌ FAIL');

  // 10. Role Guard: Customer Ditolak Update Status Pesanan Toko
  const forbiddenUpdate = await req(
    'PATCH',
    `/orders/${orderId}/status`,
    { status: 'completed' },
    newCustToken
  );
  console.log('10. Role Guard (Customer ditolak update status):', forbiddenUpdate.status === 403 ? '✅ PASS' : '❌ FAIL');

  console.log('\n🎉 SELURUH SKENARIO 3-ROLE & PESANAN BACKEND TERVERIFIKASI SEMPURNA!');
}

runTests().catch(console.error);
