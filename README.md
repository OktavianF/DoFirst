# DoFirst 🎯

**DoFirst** adalah aplikasi manajemen tugas berbasis prioritas cerdas yang membantu pengguna menentukan *task apa yang harus dikerjakan terlebih dahulu*, bukan sekadar mencatat daftar to-do.

Aplikasi ini menggunakan **Deadline-Dominant Weighted Scoring Model** untuk menghitung prioritas setiap tugas secara otomatis dan dinamis berdasarkan deadline, tingkat urgensi, kepentingan, dan tingkat kesulitan.

---

## 📋 Daftar Isi

- [Fitur Utama](#-fitur-utama)
- [Tech Stack](#-tech-stack)
- [Struktur Repositori](#-struktur-repositori)
- [Prasyarat](#-prasyarat)
- [Memulai (Quick Start)](#-memulai-quick-start)
- [Konfigurasi Environment](#-konfigurasi-environment)
- [Dokumentasi Tambahan](#-dokumentasi-tambahan)
- [Kontribusi](#-kontribusi)
- [Lisensi](#-lisensi)

---

## ✨ Fitur Utama

| Fitur | Deskripsi |
|---|---|
| **Smart Prioritization** | Skor prioritas dihitung otomatis berdasarkan 4 faktor: deadline, urgensi, kepentingan, kesulitan |
| **Dynamic Scoring** | Skor tugas diperbarui secara dinamis setiap kali data diambil — deadline yang semakin dekat otomatis menaikkan skor |
| **Hero Task** | Dashboard menampilkan 1 tugas terpenting (*hero task*) yang harus diselesaikan sekarang |
| **Focus Mode** | Mode fokus (Pomodoro-style) dengan timer dan notifikasi untuk mengerjakan *hero task* |
| **Google Sign-In** | Autentikasi via akun Google di samping email/password |
| **Offline Cache** | Data di-cache lokal sehingga aplikasi tetap dapat digunakan saat offline |
| **Session Management** | Token akses diperbarui otomatis; sesi berakhir setelah 7 hari |

---

## 🛠 Tech Stack

### Frontend (Mobile)
| Teknologi | Keterangan |
|---|---|
| **Flutter 3.x** | Framework UI cross-platform (Android & iOS) |
| **Dart 3.x** | Bahasa pemrograman |
| **Provider** | State management |
| **http** | HTTP client untuk komunikasi ke REST API |
| **shared_preferences** | Penyimpanan token & cache lokal |
| **google_sign_in** | Autentikasi Google |
| **flutter_local_notifications** | Notifikasi lokal untuk focus mode |
| **google_fonts** | Tipografi |

### Backend (REST API)
| Teknologi | Keterangan |
|---|---|
| **Node.js + Express 5** | Runtime & web framework |
| **TypeScript** | Bahasa pemrograman |
| **Prisma ORM** | Object-Relational Mapper untuk PostgreSQL |
| **Supabase** | Auth provider (JWT) & PostgreSQL hosting |
| **Helmet** | Security headers |
| **CORS** | Cross-Origin Resource Sharing |
| **PM2** | Process manager di production |

### Infrastructure
| Layanan | Keterangan |
|---|---|
| **Supabase** | PostgreSQL database & Auth |
| **Azure VM** | Server produksi backend |

---

## 📁 Struktur Repositori

```
DoFirst/
├── backend/                  # REST API (Node.js + TypeScript + Prisma)
│   ├── src/
│   │   ├── config/           # Konfigurasi environment
│   │   ├── lib/              # Shared library (Prisma client, Supabase client, AppError)
│   │   ├── middleware/       # Auth middleware & error handler
│   │   └── modules/
│   │       ├── auth/         # Modul autentikasi (signup, login, Google, refresh)
│   │       ├── tasks/        # Modul manajemen tugas (CRUD + scoring)
│   │       └── dashboard/    # Modul dashboard (hero task, upcoming, stats)
│   ├── prisma/
│   │   └── schema.prisma     # Skema database
│   └── package.json
│
├── dofirst/                  # Flutter mobile app
│   ├── lib/
│   │   ├── app/              # Entry point app & routing
│   │   ├── features/
│   │   │   ├── auth/         # Halaman login & signup
│   │   │   ├── home/         # Halaman dashboard
│   │   │   ├── tasks/        # Daftar tugas & form input tugas
│   │   │   ├── focus/        # Focus session (timer Pomodoro)
│   │   │   ├── profile/      # Halaman profil pengguna
│   │   │   ├── notifications/# Halaman notifikasi
│   │   │   └── success/      # Halaman setelah menyelesaikan tugas
│   │   └── shared/
│   │       ├── repositories/ # Data layer (TaskRepository, AuthRepository)
│   │       ├── services/     # ApiClient & FocusNotificationService
│   │       ├── theme/        # Tema aplikasi
│   │       ├── navigation/   # Navigasi global
│   │       └── widgets/      # Reusable widgets
│   ├── mock-server/          # Mock Express server untuk dev tanpa backend
│   ├── assets/               # Gambar, ikon
│   ├── Makefile              # Shortcut perintah flutter run/build
│   └── pubspec.yaml
│
├── docs/
│   ├── ARCHITECTURE.md       # Arsitektur sistem & alur data
│   └── API_REFERENCE.md      # Referensi REST API lengkap
│
├── CONTRIBUTING.md           # Panduan berkontribusi
├── CHANGELOG.md              # Riwayat perubahan
├── DEVELOPMENT_GUIDE.md      # Alur pengembangan backend + frontend
└── DEVELOPMENT_WITHOUT_BACKEND.md  # Panduan dev Flutter tanpa backend asli
```

---

## ✅ Prasyarat

Pastikan alat berikut sudah terinstal di mesin Anda:

| Alat | Versi Minimum | Tautan |
|---|---|---|
| Flutter SDK | 3.x | [flutter.dev](https://flutter.dev/docs/get-started/install) |
| Dart SDK | 3.x | (termasuk dalam Flutter) |
| Node.js | 18.x LTS | [nodejs.org](https://nodejs.org/) |
| npm | 9.x | (termasuk dalam Node.js) |
| Git | 2.x | [git-scm.com](https://git-scm.com/) |

---

## 🚀 Memulai (Quick Start)

### 1. Clone Repositori

```bash
git clone https://github.com/OktavianF/DoFirst.git
cd DoFirst
```

### 2. Setup Backend

```bash
cd backend
npm install
```

Buat file `.env.development` di dalam folder `backend/` (lihat [Konfigurasi Environment](#-konfigurasi-environment)):

```bash
npm run start:dev
```

Backend akan berjalan di `http://localhost:3000`.

### 3. Setup Flutter

```bash
cd dofirst
flutter pub get
```

**Menjalankan dengan Mock Server (tanpa backend asli):**
```bash
# Terminal 1 — jalankan mock server
cd dofirst/mock-server
npm install
npm start

# Terminal 2 — jalankan Flutter
cd dofirst
flutter run
```

**Menjalankan dengan Backend Lokal:**
```bash
cd dofirst
make run-local
```

**Menjalankan dengan Backend Produksi (Azure):**
```bash
cd dofirst
make run-prod
```

---

## ⚙️ Konfigurasi Environment

### Backend

Buat file `.env.development` (untuk development) dan `.env.production` (untuk production) di dalam folder `backend/`. Anda juga dapat menggunakan `.env` sebagai fallback.

```env
# Database (Supabase / PostgreSQL)
DATABASE_URL="postgresql://USER:PASSWORD@HOST:PORT/DB?pgbouncer=true"
DIRECT_URL="postgresql://USER:PASSWORD@HOST:PORT/DB"

# Supabase
SUPABASE_URL="https://your-project.supabase.co"
SUPABASE_SERVICE_ROLE_KEY="your-service-role-key"
SUPABASE_ANON_KEY="your-anon-key"

# Server
PORT=3000
NODE_ENV=development
```

> ⚠️ **Jangan pernah** meng-commit file `.env*` ke repositori. File-file ini sudah terdaftar di `.gitignore`.

### Flutter

URL backend dikonfigurasi via `--dart-define` saat menjalankan aplikasi. Nilai default adalah `http://localhost:3000/api`.

```bash
# Contoh: menembak ke server kustom
flutter run --dart-define=API_BASE_URL=http://192.168.1.5:3000/api
```

Lihat `dofirst/Makefile` untuk shortcut yang sudah tersedia.

---

## 📖 Dokumentasi Tambahan

| Dokumen | Deskripsi |
|---|---|
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | Diagram arsitektur sistem, alur data, dan keputusan teknis |
| [docs/API_REFERENCE.md](docs/API_REFERENCE.md) | Referensi lengkap seluruh endpoint REST API |
| [CONTRIBUTING.md](CONTRIBUTING.md) | Panduan berkontribusi ke proyek ini |
| [CHANGELOG.md](CHANGELOG.md) | Riwayat versi dan perubahan |
| [DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md) | Alur kerja pengembangan harian (frontend + backend + deploy) |
| [DEVELOPMENT_WITHOUT_BACKEND.md](DEVELOPMENT_WITHOUT_BACKEND.md) | Panduan mengembangkan Flutter menggunakan Mock Server |

---

## 🤝 Kontribusi

Kami menyambut kontribusi dari siapa pun! Silakan baca [CONTRIBUTING.md](CONTRIBUTING.md) untuk memahami alur kerja, standar kode, dan cara membuat pull request.

---

## 📄 Lisensi

Proyek ini bersifat privat. Seluruh hak cipta dimiliki oleh tim DoFirst.
