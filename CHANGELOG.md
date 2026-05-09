# Changelog

Semua perubahan penting pada proyek ini akan didokumentasikan di sini.

Format mengacu pada [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

---

## [Unreleased]

### Added
- Dokumentasi lengkap berstandar industri: README, ARCHITECTURE, API_REFERENCE, CONTRIBUTING, CHANGELOG
- Template GitHub Issue (Bug Report & Feature Request)
- Template Pull Request

---

## [1.0.0] — 2025-05-09

### Added

#### Backend
- REST API dengan Express 5 + TypeScript
- Modul autentikasi: email/password signup & login via Supabase Auth
- Autentikasi Google (Google ID Token → Supabase)
- Endpoint refresh token (`POST /api/auth/refresh`)
- Endpoint profil pengguna (`GET /api/auth/me`)
- Modul tugas: CRUD dasar (create, list, get by ID, complete/delete)
- **Deadline-Dominant Weighted Scoring Model**: skor prioritas dihitung dinamis setiap kali data diambil
- Kalkulasi deadline score berbasis granularitas jam (10 level dari overdue hingga 7+ hari)
- Label prioritas tugas otomatis: `LOW` / `MEDIUM` / `HIGH`
- Modul dashboard: hero task, upcoming tasks, total tasks
- Prisma ORM dengan skema `Profile` + `Task`
- Global error handler yang terstruktur
- Auth middleware (verifikasi JWT via Supabase Admin API)
- Helmet & CORS sebagai security middleware
- Konfigurasi environment terpisah untuk development dan production (`.env.development` / `.env.production`)

#### Frontend (Flutter)
- Halaman login dengan email/password dan Google Sign-In
- Halaman signup
- Halaman dashboard (home) dengan hero task & upcoming tasks
- Halaman daftar semua tugas (diurutkan berdasarkan skor)
- Form input tugas: judul, deskripsi, importance, urgency, difficulty, deadline, tags
- Focus mode: timer sesi fokus (Pomodoro-style) dengan notifikasi lokal
- Halaman profil pengguna dengan tombol logout
- `ApiClient`: HTTP client terpusat dengan auto-refresh token saat `401`
- Cache data lokal via `SharedPreferences` untuk mode offline
- Manajemen sesi 7 hari — auto-logout saat sesi kedaluwarsa
- Redirect otomatis ke login saat sesi tidak valid
- Konfigurasi URL backend via `--dart-define` (tanpa hardcode di source code)
- Mock Server Express untuk development Flutter tanpa backend asli
- Makefile shortcut: `make run-local`, `make run-prod`, `make build-prod`

### Infrastructure
- Deployment backend ke Azure VM dengan PM2
- Script deploy otomatis (`deploy.sh`)
