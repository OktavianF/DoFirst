# Panduan Berkontribusi ke DoFirst

Terima kasih telah meluangkan waktu untuk berkontribusi ke DoFirst! 🎉

Dokumen ini menjelaskan cara melaporkan bug, mengusulkan fitur, dan mengirimkan perubahan kode secara terstruktur.

---

## 📋 Daftar Isi

- [Kode Etik](#kode-etik)
- [Cara Melaporkan Bug](#cara-melaporkan-bug)
- [Cara Mengusulkan Fitur Baru](#cara-mengusulkan-fitur-baru)
- [Alur Kerja Pengembangan](#alur-kerja-pengembangan)
- [Standar Kode](#standar-kode)
- [Commit Message Convention](#commit-message-convention)
- [Pull Request](#pull-request)

---

## Kode Etik

Semua kontributor diharapkan untuk:
- Bersikap saling menghormati dalam setiap diskusi.
- Memberikan umpan balik yang konstruktif.
- Menerima kritik terhadap kode (bukan pribadi) dengan lapang dada.

---

## Cara Melaporkan Bug

Sebelum membuat issue baru, pastikan bug tersebut **belum pernah dilaporkan** di [halaman Issues](https://github.com/OktavianF/DoFirst/issues).

Gunakan template **Bug Report** saat membuat issue baru dan isi semua bagian yang relevan:
- Langkah-langkah untuk mereproduksi bug
- Perilaku yang diharapkan vs yang terjadi
- Environment (versi OS, versi Flutter, versi Node.js)
- Screenshot atau log error (jika ada)

---

## Cara Mengusulkan Fitur Baru

Gunakan template **Feature Request** dan jelaskan:
- Masalah yang ingin dipecahkan
- Solusi yang diusulkan
- Alternatif yang sudah dipertimbangkan
- Mockup atau contoh (jika ada)

---

## Alur Kerja Pengembangan

### 1. Fork & Clone

```bash
git clone https://github.com/OktavianF/DoFirst.git
cd DoFirst
```

### 2. Buat Branch Baru

Gunakan konvensi penamaan branch berikut:

| Jenis | Format | Contoh |
|---|---|---|
| Fitur baru | `feat/nama-fitur` | `feat/filter-tasks` |
| Perbaikan bug | `fix/nama-bug` | `fix/refresh-token-loop` |
| Refactoring | `refactor/nama-komponen` | `refactor/api-client` |
| Dokumentasi | `docs/nama-dokumen` | `docs/api-reference` |

```bash
git checkout -b feat/nama-fitur
```

### 3. Setup Lokal

**Backend:**
```bash
cd backend
npm install
# Buat file .env.development (lihat README.md)
npm run start:dev
```

**Flutter:**
```bash
cd dofirst
flutter pub get
make run-local  # atau: flutter run
```

### 4. Coding

Lihat [Standar Kode](#standar-kode) di bawah.

### 5. Test

Pastikan perubahan Anda tidak merusak fungsionalitas yang sudah ada:

```bash
# Flutter
cd dofirst
flutter test

# Backend (jika ada test runner yang dikonfigurasi)
cd backend
npm test
```

### 6. Commit

Lihat [Commit Message Convention](#commit-message-convention).

### 7. Push & Pull Request

```bash
git push origin feat/nama-fitur
```

Kemudian buat Pull Request di GitHub. Lihat [Pull Request](#pull-request).

---

## Standar Kode

### Flutter / Dart

- Ikuti panduan style resmi [Effective Dart](https://dart.dev/effective-dart).
- Gunakan `flutter analyze` untuk memeriksa lint sebelum commit.
- Setiap Widget utama harus memiliki key jika diperlukan (`const` constructor bila memungkinkan).
- ViewModel **tidak boleh** bergantung langsung ke `http` — gunakan Repository sebagai perantara.
- Hindari logika bisnis di dalam Widget/Page.

```bash
cd dofirst
flutter analyze
```

### Backend / TypeScript

- Semua file menggunakan `TypeScript` — tidak ada `any` yang tidak terjustifikasi.
- Ikuti pola yang sudah ada: Routes → Controller → Service → Repository.
- Gunakan `AppError` factory methods (`AppError.badRequest()`, `AppError.notFound()`, dll.) untuk semua error yang dikontrol.
- Tidak boleh ada credential atau secret yang di-hardcode.

---

## Commit Message Convention

Proyek ini menggunakan **Conventional Commits**:

```
<type>(<scope>): <deskripsi singkat>

[body opsional — jelaskan *mengapa*, bukan *apa*]

[footer opsional — referensi issue: Closes #123]
```

### Tipe yang Digunakan

| Tipe | Keterangan |
|---|---|
| `feat` | Fitur baru |
| `fix` | Perbaikan bug |
| `docs` | Perubahan dokumentasi saja |
| `style` | Formatting, tidak ada perubahan logika |
| `refactor` | Refactoring kode tanpa menambah fitur atau memperbaiki bug |
| `test` | Menambah atau memperbaiki test |
| `chore` | Perubahan pada build process, CI, atau konfigurasi |

### Contoh

```
feat(tasks): tambah filter tugas berdasarkan prioritas

Pengguna sekarang dapat memfilter daftar tugas berdasarkan label
prioritas (LOW, MEDIUM, HIGH) di halaman TaskList.

Closes #42
```

```
fix(auth): perbaiki infinite loop saat refresh token gagal
```

```
docs(api): tambah dokumentasi endpoint dashboard
```

---

## Pull Request

### Sebelum Membuat PR

- [ ] Kode sudah di-lint (`flutter analyze` untuk Flutter, tidak ada `tsc` error untuk backend)
- [ ] Tidak ada perubahan yang tidak berhubungan dengan scope PR ini
- [ ] Commit message mengikuti konvensi
- [ ] Branch sudah diperbarui dari `main` terbaru (`git pull origin main`)

### Saat Membuat PR

- Isi judul PR dengan format Conventional Commits: `feat(scope): deskripsi`
- Isi template PR yang tersedia
- Hubungkan ke issue yang relevan (`Closes #<nomor>`)
- Tambahkan screenshot jika ada perubahan UI

### Review Process

- Setiap PR minimal harus di-review oleh **1 anggota tim** sebelum di-merge.
- Reviewer berhak meminta perubahan.
- Author bertanggung jawab untuk merespons review dalam waktu yang wajar.
- Setelah disetujui, gunakan **Squash and Merge** untuk menjaga riwayat commit yang bersih.
