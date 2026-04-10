# 🚀 DoFirst Development Flow Guide

Panduan ini merangkum alur kerja terpadu (Frontend & Backend) dari tahap penulisan kode di lokal hingga perilisan ke Production (Azure VM). Semua sistem kini telah menggunakan standar industri, terpusat melalui Git, serta terisolasi dengan aman antara *Environment Local* dan *Production*.

---

## 🛠️ 1. Alur Pengembangan Backend (Node.js & Prisma)

Backend beroperasi menggunakan pemisahan file konfigurasi (`.env`).

### Step 1: Penulisan Kode Lokal
1. Buka folder `backend` di Text Editor Anda.
2. Tambahkan fitur baru (misal: API endpoint baru atau migrasi database baru di Prisma).
3. Selalu uji sistem Anda di lokal dengan menjalankan:
   ```bash
   npm run start:dev
   ```
   > Keterangan: Database Anda akan terbaca dari file `.env.development` (jika sudah ada) atau mem-*fallback* ke `.env` utama di komputer Anda.

### Step 2: Push ke GitHub
Jika fitur API sudah selesai dan dites lolos:
1. Masukkan perubahan ke Git.
2. Push ke branch `main`:
   ```bash
   git add .
   git commit -m "feat: [tambahkan deskripsi fitur backend]"
   git push origin main
   ```

### Step 3: Deploy ke Azure VM (Production)
1. Buka terminal baru dan masuk ke server Azure melalui SSH:
   ```bash
   ssh -i backend/nadhia-key.pem nadhia@52.172.248.68
   ```
2. Jalankan script sakti kita:
   ```bash
   ./update.sh
   ```
   > Script ini secara otomatis: Mengambil kode terbaru dari GitHub (`git pull`) → Memasang dependensi baru (`npm install`) → Memperbarui prisma client (`npx prisma generate`) → Kompilasi TypeScript (`npm run build`) → Me-*restart* server PM2 secara mulus.

Backend fitur terbaru Anda sekarang sudah *Live* 🎉!

---

## 📱 2. Alur Pengembangan Frontend (Flutter)

Frontend kita memakai mekanisme `--dart-define` untuk menembak API tanpa harus mengganti baris kode program secara manual.

### Step 1: Membuat UI / Logika Baru
1. Buka folder `dofirst` di IDE Anda. 
2. Tambahkan / Edit halaman atau Integrasi API Client yang baru.

### Step 2: Testing Lokal (Development)
Saat Anda ingin menguji UI dengan data yang ada dari Backend Lokal Laptop Anda:
- **Dari Terminal:**
  ```bash
  make run-local
  ```
- **Dari VS Code:** 
  Buka tab *Run and Debug* 🐞 → Pilih **DoFirst (Local - Android Fisik/Emulator)** → Tekan ikon *Play* ▶️.
  
*(Catatan: Aplikasi akan menembak ke IP `192.168.1.147`)*

### Step 3: Testing Koneksi Prod (Sandbox)
Saat Anda ingin memastikan UI berfungsi dengan baik menghadapi struktur Database di Server Azure (namun tanpa Anda harus *build* APK-nya):
- **Dari Terminal:**
  ```bash
  make run-prod
  ```
- **Dari VS Code:** 
  Buka tab *Run and Debug* 🐞 → Pilih **DoFirst (Prod - Azure VM)** → Tekan ikon *Play* ▶️.
  
*(Catatan: Aplikasi Anda (baik di Emulator atau HP fisik) akan menembak langsung ke API `52.172.248.68`)*

### Step 4: Membangun Aplikasi APK Rilis
Bila seluruh fitur dirasa mantap, Anda perlu membangun (Build) file `.apk` untuk didistribusikan:
```bash
make build-prod
```
> APK siap rilis akan terbit dengan konfigurasi Backend Azure tertanam dengan aman di dalamnya.

---

## 🔄 Ringkasan Eksekutif Loop Standar Anda:
1. **Pagi hari:** `make run-local` > `ngoding frontend & backend`.
2. **Siang hari:** `git push` backend > SSH ke Azure > `./update.sh`.
3. **Sore hari:** `make run-prod` > pastikan semuanya berjalan lancar di backend Azure.
4. **Malam hari:** `make build-prod` > bagikan APK!.
