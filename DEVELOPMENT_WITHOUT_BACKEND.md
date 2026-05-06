# Panduan Development Mobile Tanpa Backend (Mock Backend)

Untuk mengembangkan aplikasi mobile UI (Flutter) secara independen tanpa perlu menjalankan Backend (Node.js/Database) aslinya, kita akan menggunakan **Mock Server** sederhana berbasis Express.js.

Cara ini sangat direkomendasikan karena:
1. **Tidak Perlu Mengubah Kode Flutter:** Anda tidak perlu menyentuh logic API karena kita membuat server palsu di port yang sama, sehingga format request & response (`data`) persis sama.
2. **Ringan & Cepat:** Berjalan secara lokal dan instan, data disimpan di memori sementara.
3. **Mendukung Fitur Penuh:** Sudah termasuk simulasi delay, auth palsu, dan operasi CRUD pada Tasks.

---

## Prasyarat

Pastikan Anda memiliki [Node.js](https://nodejs.org/) terinstal di perangkat Anda (karena Mock Server berjalan di atas environment Node).

## 1. Setup Mock Server

Mock Server sudah disiapkan pada direktori `dofirst/mock-server`. Ikuti langkah berikut untuk pertama kali saja:

1. Buka terminal baru dan masuk ke folder `mock-server`:
   ```bash
   cd dofirst/mock-server
   ```
2. Instal dependencies (`express` & `cors`):
   ```bash
   npm install
   ```

## 2. Menjalankan Mock Server

Setiap kali Anda ingin melakukan *development* Flutter tanpa backend sesungguhnya, jalankan Mock Server dengan:

```bash
cd dofirst/mock-server
npm start
```
Terminal akan menampilkan:
> `Mock Backend Server is running at http://localhost:3000/api`

## 3. Menjalankan Aplikasi Flutter

Berdasarkan `dofirst/lib/shared/services/api_client.dart`, default dari `_baseUrl` adalah `http://localhost:3000/api`.

Secara default, Anda cukup menjalankan Flutter seperti biasa:
```bash
flutter run
```

Atau jika menggunakan real device Android/iOS yang memerlukan IP Local (misal IP komputer adalah `192.168.1.5`):
1. Buka file `server.js` di dalam folder `mock-server`, ubah `app.listen(PORT, ...)` menjadi `app.listen(PORT, '0.0.0.0', ...)`.
2. Saat running Flutter, tambahkan `--dart-define` untuk menembak IP komputer:
```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.5:3000/api
```

## Daftar Endpoint yang Dimock

Mock Server ini sementara mendukung endpoint berikut yang disesuaikan dengan `TaskRepository` & `AuthRepository`:
* **POST** `/api/auth/login` - Simulasi login (mengembalikan mock token).
* **POST** `/api/auth/signup` - Simulasi register.
* **GET** `/api/auth/me` - Mendapatkan data user mock.
* **GET** `/api/dashboard` - Menampilkan stat/metrik palsu (Total tugas, productivity score, dsb.)
* **GET** `/api/tasks` - List tasks sementara.
* **POST** `/api/tasks` - Membuat Task baru ke dalam list.
* **GET** `/api/tasks/:id` - Menampilkan detail task.
* **DELETE** `/api/tasks/:id/complete` - Menghapus / complete sebuah task dari list.

## Modifikasi Data

Jika Anda ingin mengubah respon JSON (misalnya ingin merubah status loading, error 500, atau bentuk list task), Anda cukup mengedit file `dofirst/mock-server/server.js` lalu melakukan *restart* mock server tersebut (`Ctrl+C` lalu `npm start` lagi).
