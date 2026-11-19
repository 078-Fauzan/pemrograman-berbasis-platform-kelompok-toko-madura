/**
 * Script Pengujian Otomatis REST API UMKMate (Tahap 2)
 */
const http = require('http');

const BASE_URL = 'http://localhost:5000/api/v1';

async function request(method, path, body = null, token = null) {
  return new Promise((resolve, reject) => {
    const url = new URL(BASE_URL + path);
    const headers = {
      'Content-Type': 'application/json',
    };

    if (token) {
      headers['Authorization'] = `Bearer ${token}`;
    }

    const payload = body ? JSON.stringify(body) : null;
    if (payload) {
      headers['Content-Length'] = Buffer.byteLength(payload);
    }

    const req = http.request(
      url,
      {
        method,
        headers,
      },
      (res) => {
        let rawData = '';
        res.on('data', (chunk) => (rawData += chunk));
        res.on('end', () => {
          try {
            const parsed = rawData ? JSON.parse(rawData) : {};
            resolve({ status: res.statusCode, body: parsed });
          } catch (e) {
            resolve({ status: res.statusCode, raw: rawData });
          }
        });
      }
    );

    req.on('error', reject);
    if (payload) {
      req.write(payload);
    }
    req.end();
  });
}

async function runTests() {
  console.log('====================================================');
  console.log('🧪 MEMULAI PENGUJIAN OTOMATIS BACKEND UMKMATE (TAHAP 2)');
  console.log('====================================================\n');

  let passed = 0;
  let failed = 0;

  function assert(condition, message, detail = '') {
    if (condition) {
      console.log(`✅ [PASS] ${message}`);
      passed++;
    } else {
      console.error(`❌ [FAIL] ${message} - Detail: ${detail}`);
      failed++;
    }
  }

  try {
    // 1. Health Check
    const health = await request('GET', '/health');
    assert(health.status === 200 && health.body.success, '1. Health Check API (/health)');

    // 2. Login Owner (Seed Data)
    const ownerLogin = await request('POST', '/auth/login', {
      email: 'owner@umkmate.com',
      password: 'Password123!',
    });
    assert(
      ownerLogin.status === 200 && ownerLogin.body.data.token,
      '2. Login Owner Berhasil (Dapat JWT Token)',
      JSON.stringify(ownerLogin.body)
    );
    const ownerToken = ownerLogin.body.data?.token;

    // 3. Login Kasir 1 (Seed Data)
    const cashierLogin = await request('POST', '/auth/login', {
      email: 'kasir1@umkmate.com',
      password: 'Password123!',
    });
    assert(
      cashierLogin.status === 200 && cashierLogin.body.data.user.role === 'cashier',
      '3. Login Kasir Berhasil (Role cashier terverifikasi)',
      JSON.stringify(cashierLogin.body)
    );
    const cashierToken = cashierLogin.body.data?.token;

    // 4. Login Password Salah
    const wrongLogin = await request('POST', '/auth/login', {
      email: 'owner@umkmate.com',
      password: 'WrongPassword!',
    });
    assert(wrongLogin.status === 401, '4. Login Password Salah Ditolak (401 Unauthorized)');

    // 5. Akses Endpoint Terproteksi Tanpa Token
    const noToken = await request('GET', '/auth/me');
    assert(noToken.status === 401, '5. Akses Tanpa Token Ditolak (401 Unauthorized)');

    // 6. Profil Pengguna Terautentikasi (/auth/me)
    const me = await request('GET', '/auth/me', null, ownerToken);
    assert(
      me.status === 200 && me.body.data.user.email === 'owner@umkmate.com',
      '6. Profil Owner Terverifikasi (/auth/me)'
    );

    // 7. Update Profil Owner (/auth/profile)
    const updateProf = await request(
      'PUT',
      '/auth/profile',
      { phone: '081234567899', store_name: 'Warung Madura Berkah 24 Jam' },
      ownerToken
    );
    assert(
      updateProf.status === 200 && updateProf.body.data.store.store_name === 'Warung Madura Berkah 24 Jam',
      '7. Update Profil Toko & Owner Berhasil'
    );

    // 8. Otorisasi Role: Kasir Mengakses Endpoint Manajemen User (/users) -> Ditolak 403
    const cashierAccessUsers = await request('GET', '/users', null, cashierToken);
    assert(
      cashierAccessUsers.status === 403,
      '8. Role Guard: Kasir Ditolak Mengakses /users (403 Forbidden)'
    );

    // 9. Owner Mengakses Endpoint Manajemen User (/users)
    const ownerGetUsers = await request('GET', '/users', null, ownerToken);
    assert(
      ownerGetUsers.status === 200 && Array.isArray(ownerGetUsers.body.data),
      '9. Owner Mengakses Daftar Kasir Toko (/users)'
    );

    // 10. Owner Membuat Kasir Baru (POST /users)
    const uniqueEmail = `kasir.baru.${Date.now()}@umkmate.com`;
    const createCashier = await request(
      'POST',
      '/users',
      {
        name: 'Bambang Kasir Baru',
        email: uniqueEmail,
        password: 'Password123!',
        phone: '081344556677',
      },
      ownerToken
    );
    assert(
      createCashier.status === 201 && createCashier.body.data.id,
      '10. Owner Membuat Akun Kasir Baru Berhasil',
      JSON.stringify(createCashier.body)
    );
    const newCashierId = createCashier.body.data?.id;

    // 11. Owner Menonaktifkan Akun Kasir Baru (PATCH /users/:id/status)
    const deactivateCashier = await request(
      'PATCH',
      `/users/${newCashierId}/status`,
      { is_active: false },
      ownerToken
    );
    assert(
      deactivateCashier.status === 200 && deactivateCashier.body.data.is_active === 0,
      '11. Owner Menonaktifkan Akun Kasir Berhasil'
    );

    // 12. Kasir Nonaktif Mencoba Login -> Ditolak 403
    const deactivatedLogin = await request('POST', '/auth/login', {
      email: uniqueEmail,
      password: 'Password123!',
    });
    assert(
      deactivatedLogin.status === 403,
      '12. Akun Kasir Nonaktif Ditolak Login (403 Forbidden)'
    );

    // 13. Owner Mengaktifkan Kembali Akun Kasir
    const activateCashier = await request(
      'PATCH',
      `/users/${newCashierId}/status`,
      { is_active: true },
      ownerToken
    );
    assert(
      activateCashier.status === 200 && activateCashier.body.data.is_active === 1,
      '13. Owner Mengaktifkan Kembali Akun Kasir'
    );

    // 14. Registrasi Toko Baru (POST /auth/register)
    const storeEmail = `toko.baru.${Date.now()}@umkmate.com`;
    const registerNewStore = await request('POST', '/auth/register', {
      store_name: 'Warung Barokah Madura',
      owner_name: 'Haji Makmur',
      email: storeEmail,
      phone: '081299887766',
      password: 'Password123!',
      address: 'Jl. Gejayan No. 88, Sleman',
    });
    assert(
      registerNewStore.status === 201 && registerNewStore.body.data.store.id > 1,
      '14. Registrasi Toko Baru & Owner Baru via ACID Transaction',
      JSON.stringify(registerNewStore.body)
    );
    const store2Token = registerNewStore.body.data?.token;
    const store2Id = registerNewStore.body.data?.store.id;

    // 15. Isolasi Multi-Tenant Toko: Toko 2 Tidak Melihat Produk Toko 1
    const store2Products = await request('GET', '/products', null, store2Token);
    assert(
      store2Products.status === 200 && store2Products.body.data.length === 0,
      '15. Isolasi Data Multi-Tenant: Toko Baru Tidak Dapat Mengakses Produk Toko Lain'
    );

    // 16. Kasir Mengakses Katalog Produk (Tanpa Harga Modal / cost_price)
    const cashierProducts = await request('GET', '/products', null, cashierToken);
    const firstProduct = cashierProducts.body.data[0];
    assert(
      cashierProducts.status === 200 &&
        cashierProducts.body.data.length > 0 &&
        firstProduct.cost_price === undefined,
      '16. Kasir Mengakses Katalog Produk (Proteksi: cost_price Disembunyikan)'
    );

    // 17. Pemindaian Barcode Produk (/products/barcode/:code)
    const scanBarcode = await request('GET', '/products/barcode/8996001414018', null, cashierToken);
    assert(
      scanBarcode.status === 200 && scanBarcode.body.data.product_name.includes('Le Minerale'),
      '17. Scan Barcode Kamera HP: Produk Le Minerale Ditemukan Cepat'
    );

    // 18. Dashboard & Analitik Owner
    const dashboard = await request('GET', '/dashboard', null, ownerToken);
    assert(
      dashboard.status === 200 && dashboard.body.data.total_products > 0,
      '18. Owner Mengambil Ringkasan Metrik Dashboard'
    );

    // 19. Kasir Ditolak Mengakses Dashboard Analitik (403 Forbidden)
    const cashierDashboard = await request('GET', '/dashboard', null, cashierToken);
    assert(
      cashierDashboard.status === 403,
      '19. Role Guard: Kasir Ditolak Mengakses Dashboard Analitik (/dashboard)'
    );

    // 20. Permintaan Lupa Password & Reset Password
    const forgotPwd = await request('POST', '/auth/forgot-password', {
      email: uniqueEmail,
    });
    assert(
      forgotPwd.status === 200 && forgotPwd.body.data.reset_token,
      '20. Permintaan Reset Password Menghasilkan Token Aman'
    );

    const resetToken = forgotPwd.body.data.reset_token;
    const resetPwd = await request('POST', '/auth/reset-password', {
      token: resetToken,
      new_password: 'NewPassword123!',
    });
    assert(resetPwd.status === 200, '21. Reset Password dengan Token Valid Berhasil');

    // Login dengan password baru
    const loginWithNewPwd = await request('POST', '/auth/login', {
      email: uniqueEmail,
      password: 'NewPassword123!',
    });
    assert(
      loginWithNewPwd.status === 200,
      '22. Login dengan Password Baru yang Telah Direset Berhasil'
    );
  } catch (err) {
    console.error('Kesalahan pengujian tidak terduga:', err);
    failed++;
  }

  console.log('\n====================================================');
  console.log(`📊 RINGKASAN HASIL PENGUJIAN:`);
  console.log(`   Total Pengujian : ${passed + failed}`);
  console.log(`   Berhasil (PASS) : ${passed}`);
  console.log(`   Gagal (FAIL)    : ${failed}`);
  console.log('====================================================');

  process.exit(failed > 0 ? 1 : 0);
}

runTests();
