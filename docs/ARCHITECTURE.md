# Arsitektur Sistem DoFirst

Dokumen ini menjelaskan arsitektur keseluruhan sistem DoFirst — mulai dari lapisan frontend mobile, komunikasi API, hingga lapisan backend dan database.

---

## 📐 Gambaran Umum Arsitektur

DoFirst menggunakan arsitektur **client-server** dengan pemisahan yang jelas antara:

- **Frontend**: Aplikasi mobile Flutter yang berkomunikasi dengan backend melalui REST API.
- **Backend**: REST API Node.js + Express yang menangani logika bisnis, autentikasi, dan persisten data.
- **Database & Auth**: Supabase (PostgreSQL + Auth JWT) yang diakses melalui Prisma ORM.

```
┌─────────────────────────────────────────────────────────────────────┐
│                        PENGGUNA (Android / iOS)                     │
└──────────────────────────────┬──────────────────────────────────────┘
                               │ HTTPS / REST API
                               ▼
┌─────────────────────────────────────────────────────────────────────┐
│                      BACKEND (Azure VM)                             │
│                                                                     │
│   Express 5  ──►  Auth Middleware (Supabase JWT)                    │
│       │                                                             │
│       ├──► /api/auth      ──►  AuthService    ──►  Supabase Auth   │
│       ├──► /api/tasks     ──►  TaskService    ──►  Prisma ORM      │
│       └──► /api/dashboard ──►  DashboardService ─►  Prisma ORM    │
│                                                                     │
└──────────────────────────────┬──────────────────────────────────────┘
                               │ SQL (via Prisma)
                               ▼
┌─────────────────────────────────────────────────────────────────────┐
│                      SUPABASE                                       │
│   PostgreSQL Database   +   Supabase Auth (JWT)                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 📱 Arsitektur Frontend (Flutter)

Frontend dibangun dengan pola **MVVM (Model-View-ViewModel)** menggunakan `Provider` sebagai state management.

### Lapisan Aplikasi

```
lib/
├── app/                    # Konfigurasi root aplikasi & routing
├── features/               # Fitur-fitur aplikasi (tiap fitur terisolasi)
│   ├── auth/
│   │   └── presentation/
│   │       ├── login/      # LoginPage + LoginViewModel
│   │       └── signup/     # SignupPage + SignupViewModel
│   ├── home/
│   │   └── presentation/   # HomePage + HomeViewModel
│   ├── tasks/
│   │   └── presentation/
│   │       ├── task_list/  # TaskListPage + TaskListViewModel
│   │       └── task_input/ # TaskInputPage + TaskInputViewModel
│   ├── focus/
│   │   └── presentation/
│   │       └── focus_session/ # FocusSessionPage + FocusSessionViewModel
│   ├── profile/
│   │   └── presentation/   # ProfilePage + ProfileViewModel
│   ├── notifications/      # Halaman notifikasi
│   └── success/            # Layar sukses setelah menyelesaikan tugas
└── shared/
    ├── repositories/       # Data layer — TaskRepository, AuthRepository
    ├── services/           # ApiClient, FocusNotificationService
    ├── theme/              # Tema visual aplikasi
    ├── navigation/         # NavigatorKey global
    └── widgets/            # Widget reusable
```

### Alur Data Frontend

```
UI (Page/Widget)
      │ action / event
      ▼
ViewModel (ChangeNotifier)
      │ memanggil
      ▼
Repository (TaskRepository / AuthRepository)
      │ memanggil
      ▼
ApiClient (http wrapper)
      │ HTTP request
      ▼
REST API Backend
```

### Manajemen State

State dikelola menggunakan `Provider` (`ChangeNotifier`). Setiap fitur memiliki ViewModel-nya sendiri:

| ViewModel | Tanggung Jawab |
|---|---|
| `HomeViewModel` | Data dashboard: nama pengguna, hero task, upcoming tasks, total tasks |
| `TaskListViewModel` | Daftar semua tugas pengguna |
| `LoginViewModel` | State form login & proses autentikasi |
| `SignupViewModel` | State form registrasi |
| `ProfileViewModel` | Data profil & logout |
| `FocusSessionViewModel` | Timer sesi fokus & notifikasi |

### Konfigurasi URL API

URL backend dikonfigurasi saat runtime melalui `--dart-define`, sehingga **tidak ada URL yang di-hardcode di kode sumber**:

```dart
// lib/shared/services/api_client.dart
static const String _baseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:3000/api',
);
```

---

## 🖥️ Arsitektur Backend (Node.js)

Backend dibangun dengan pola **layered architecture** (Controller → Service → Repository):

```
src/
├── config/
│   └── env.ts              # Validasi & ekspor environment variables
├── lib/
│   ├── AppError.ts         # Custom error class dengan factory methods
│   ├── prisma.ts           # Singleton Prisma client
│   └── supabase.ts         # Singleton Supabase admin client
├── middleware/
│   ├── auth.ts             # JWT verification middleware (Supabase)
│   └── errorHandler.ts     # Global error handler Express
├── modules/
│   ├── auth/
│   │   ├── auth.routes.ts      # Definisi route HTTP
│   │   ├── auth.controller.ts  # Parsing request, memanggil service, format response
│   │   └── auth.service.ts     # Logika bisnis autentikasi
│   ├── tasks/
│   │   ├── task.routes.ts
│   │   ├── task.controller.ts
│   │   ├── task.service.ts     # Logika scoring & prioritas
│   │   └── task.repository.ts  # Query database via Prisma
│   └── dashboard/
│       ├── dashboard.routes.ts
│       ├── dashboard.controller.ts
│       └── dashboard.service.ts # Agregasi data untuk dashboard
├── app.ts                  # Konfigurasi Express (middleware, routes)
└── server.ts               # Entry point — listen port
```

### Tanggung Jawab Tiap Lapisan

| Lapisan | Tanggung Jawab |
|---|---|
| **Routes** | Mendefinisikan path HTTP dan menghubungkan ke controller |
| **Controller** | Mem-parse request, validasi input dasar, memanggil service, memformat response JSON |
| **Service** | Logika bisnis (scoring, prioritas, validasi data) |
| **Repository** | Query database melalui Prisma ORM |

---

## 🗄️ Skema Database

Database menggunakan **PostgreSQL** yang dikelola oleh Supabase, dengan Prisma sebagai ORM.

### Model `Profile`

Menyimpan data profil pengguna. `id` adalah UUID yang sama dengan `auth.users.id` di Supabase Auth.

| Kolom | Tipe | Keterangan |
|---|---|---|
| `id` | UUID (PK) | Sinkron dengan Supabase Auth user ID |
| `full_name` | String | Nama lengkap pengguna |
| `avatar_url` | String? | URL foto profil (opsional) |
| `created_at` | DateTime | Waktu pembuatan akun |
| `updated_at` | DateTime | Waktu pembaruan terakhir |

### Model `Task`

Menyimpan semua tugas pengguna beserta metadata prioritasnya.

| Kolom | Tipe | Keterangan |
|---|---|---|
| `id` | UUID (PK) | Auto-generated |
| `user_id` | UUID (FK) | Referensi ke `profiles.id`, cascade delete |
| `title` | String | Judul tugas (wajib) |
| `description` | String? | Deskripsi opsional |
| `importance` | Int (1–5) | Seberapa penting tugas ini |
| `difficulty` | Int (1–5) | Tingkat kesulitan pengerjaan |
| `urgency` | Int (1–5) | Seberapa mendesak tugas ini |
| `score` | Float (0–10) | Skor prioritas yang dihitung otomatis |
| `priority` | String | `LOW` / `MEDIUM` / `HIGH` |
| `deadline` | DateTime? | Batas waktu (opsional) |
| `tags` | String[] | Label/kategori tugas |
| `created_at` | DateTime | Waktu pembuatan |
| `updated_at` | DateTime | Waktu pembaruan terakhir |

### Relasi

```
Profile (1) ──────── (*) Task
```

---

## 🧮 Algoritma Prioritas (Deadline-Dominant Weighted Scoring Model)

Ini adalah inti logika bisnis DoFirst. Setiap tugas mendapatkan skor 0–10 yang dihitung secara **dinamis** setiap kali data diambil dari database.

### Formula

```
Score = (0.10 × I_norm) + (0.15 × U_norm) + (0.10 × D_norm) + (0.65 × DL_score)
```

Keterangan:
- `I_norm` — Importance dinormalisasi dari skala 1–5 ke 0–10: `(importance - 1) × 2.5`
- `U_norm` — Urgency dinormalisasi: `(urgency - 1) × 2.5`
- `D_norm` — Difficulty dinormalisasi: `(difficulty - 1) × 2.5`
- `DL_score` — Skor deadline (0–10) berdasarkan kedekatan batas waktu

### Tabel Skor Deadline

| Kondisi | Skor |
|---|---|
| Sudah lewat deadline | 10 |
| ≤ 30 menit | 9.5 |
| 30 menit – 1 jam | 9 |
| 1–3 jam | 8 |
| 3–6 jam | 7 |
| 6–12 jam | 6 |
| 12–24 jam (hari ini) | 5 |
| 1–2 hari (besok) | 4 |
| 2–4 hari | 3 |
| 4–7 hari | 2 |
| > 7 hari | 1 |
| Tidak ada deadline | 0 |

### Derivasi Label Prioritas

| Rentang Skor | Label |
|---|---|
| 6.7 – 10 | **HIGH** |
| 3.4 – 6.6 | **MEDIUM** |
| 0 – 3.3 | **LOW** |

### Mengapa Deadline Mendominasi (65%)?

Deadline yang semakin dekat harus *selalu* mengangkat sebuah tugas ke urutan teratas, terlepas dari faktor lain. Bobot 65% memastikan bahwa tugas dengan deadline besok akan selalu lebih diprioritaskan daripada tugas yang penting tapi tidak mendesak.

---

## 🔐 Autentikasi & Keamanan

### Alur Autentikasi

```
Mobile App ──► POST /api/auth/login ──► Supabase Auth
                                              │
                                    ◄── access_token + refresh_token
                                              │
Mobile App menyimpan token di SharedPreferences
                                              │
Setiap request berikutnya:
Mobile App ──► Authorization: Bearer <access_token> ──► Backend
                                              │
                                    authMiddleware memverifikasi JWT ke Supabase
                                              │
                                    Request dilanjutkan / ditolak
```

### Manajemen Sesi (Frontend)

- **Access Token** disimpan di `SharedPreferences`.
- **Refresh Token** disimpan di `SharedPreferences`.
- Sesi dianggap **kedaluwarsa setelah 7 hari** sejak login terakhir.
- Jika API mengembalikan `401`, `ApiClient` secara otomatis mencoba **refresh token** sebelum mengarahkan pengguna ke halaman login.
- Saat logout, semua token dan cache dihapus.

### Keamanan Backend

- **Helmet**: Mengatur HTTP security headers secara otomatis.
- **CORS**: Mengizinkan cross-origin request (dapat dikonfigurasi lebih ketat di produksi).
- **JWT Verification**: Setiap request ke endpoint yang dilindungi diverifikasi via Supabase Admin API.
- **Environment Variables**: Semua kredensial disimpan di `.env` dan tidak pernah di-commit.

---

## 🔄 Alur Data: Membuat Tugas Baru

Berikut alur lengkap dari saat pengguna menekan tombol "Simpan Tugas":

```
1. User mengisi form tugas di TaskInputPage
2. TaskInputViewModel.createTask() dipanggil
3. TaskRepository.createTask() mengirim POST /api/tasks dengan body:
   { title, description, importance, urgency, difficulty, deadline, tags }
4. Backend: authMiddleware memverifikasi JWT
5. TaskController.create() → TaskService.createTask()
6. TaskService:
   a. Validasi input
   b. Normalisasi nilai 1–5
   c. Hitung deadlineScore berdasarkan waktu saat ini
   d. Hitung score = 0.10×I + 0.15×U + 0.10×D + 0.65×DL
   e. Derive priority (LOW/MEDIUM/HIGH)
7. TaskRepository.create() menyimpan ke PostgreSQL via Prisma
8. Response 201 dengan data tugas yang telah diskor
9. Flutter menerima respons dan memperbarui state TaskListViewModel
```

---

## 🚀 Deployment

### Backend (Production — Azure VM)

Backend dijalankan dengan **PM2** sebagai process manager di Azure VM.

```bash
# Di Azure VM
git pull origin main
npm install
npx prisma generate
npm run build        # Compile TypeScript → dist/
pm2 restart dofirst  # Restart tanpa downtime
```

Lihat `DEVELOPMENT_GUIDE.md` untuk alur deployment lengkap.

### Frontend (APK Release)

```bash
cd dofirst
make build-prod
# Output: build/app/outputs/flutter-apk/app-release.apk
```
