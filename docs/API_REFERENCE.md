# Referensi REST API DoFirst

Base URL: `http://<host>:3000/api`

Semua response menggunakan format JSON dengan struktur konsisten berikut:

**Response Sukses:**
```json
{
  "success": true,
  "data": { ... }
}
```

**Response Error:**
```json
{
  "success": false,
  "error": "Pesan error yang dapat dibaca"
}
```

---

## 🔐 Autentikasi

Endpoint yang dilindungi memerlukan header:

```
Authorization: Bearer <access_token>
```

---

## Daftar Isi

- [Health Check](#health-check)
- [Auth](#auth)
  - [POST /auth/signup](#post-authsignup)
  - [POST /auth/login](#post-authlogin)
  - [POST /auth/google](#post-authgoogle)
  - [GET /auth/me](#get-authme)
  - [POST /auth/refresh](#post-authrefresh)
- [Tasks](#tasks)
  - [POST /tasks](#post-tasks)
  - [GET /tasks](#get-tasks)
  - [GET /tasks/:id](#get-tasksid)
  - [DELETE /tasks/:id/complete](#delete-tasksidcomplete)
- [Dashboard](#dashboard)
  - [GET /dashboard](#get-dashboard)

---

## Health Check

### `GET /api/health`

Memeriksa status server.

**Autentikasi:** Tidak diperlukan

**Response 200:**
```json
{
  "status": "ok",
  "timestamp": "2025-01-01T00:00:00.000Z"
}
```

---

## Auth

### `POST /auth/signup`

Mendaftarkan pengguna baru. Membuat akun di Supabase Auth dan profil di database.

**Autentikasi:** Tidak diperlukan

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "password123",
  "fullName": "Nama Lengkap"
}
```

| Field | Tipe | Wajib | Keterangan |
|---|---|---|---|
| `email` | string | ✅ | Alamat email valid |
| `password` | string | ✅ | Minimal 6 karakter |
| `fullName` | string | ✅ | Nama lengkap pengguna |

**Response 201:**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "uuid-user",
      "email": "user@example.com"
    },
    "profile": {
      "id": "uuid-user",
      "fullName": "Nama Lengkap",
      "avatarUrl": null,
      "createdAt": "2025-01-01T00:00:00.000Z",
      "updatedAt": "2025-01-01T00:00:00.000Z"
    },
    "session": {
      "accessToken": "eyJ...",
      "refreshToken": "eyJ...",
      "expiresAt": 1735689600
    }
  }
}
```

**Response Error:**
| Status | Kondisi |
|---|---|
| 400 | Email/password/fullName tidak disertakan |
| 400 | Email sudah terdaftar |

---

### `POST /auth/login`

Autentikasi pengguna yang sudah terdaftar dengan email dan password.

**Autentikasi:** Tidak diperlukan

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

| Field | Tipe | Wajib | Keterangan |
|---|---|---|---|
| `email` | string | ✅ | Alamat email terdaftar |
| `password` | string | ✅ | Password akun |

**Response 200:**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "uuid-user",
      "email": "user@example.com"
    },
    "profile": {
      "id": "uuid-user",
      "fullName": "Nama Lengkap",
      "avatarUrl": null,
      "createdAt": "2025-01-01T00:00:00.000Z",
      "updatedAt": "2025-01-01T00:00:00.000Z"
    },
    "session": {
      "accessToken": "eyJ...",
      "refreshToken": "eyJ...",
      "expiresAt": 1735689600
    }
  }
}
```

**Response Error:**
| Status | Kondisi |
|---|---|
| 400 | Email atau password tidak disertakan |
| 401 | Email atau password salah |

---

### `POST /auth/google`

Autentikasi menggunakan Google ID Token (diperoleh dari Google Sign-In di sisi mobile).

**Autentikasi:** Tidak diperlukan

**Request Body:**
```json
{
  "idToken": "google-id-token-dari-client"
}
```

| Field | Tipe | Wajib | Keterangan |
|---|---|---|---|
| `idToken` | string | ✅ | ID token dari Google Sign-In SDK |

**Response 200:**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "uuid-user",
      "email": "user@gmail.com"
    },
    "profile": {
      "id": "uuid-user",
      "fullName": "Nama dari Google",
      "avatarUrl": "https://lh3.googleusercontent.com/...",
      "createdAt": "2025-01-01T00:00:00.000Z",
      "updatedAt": "2025-01-01T00:00:00.000Z"
    },
    "session": {
      "accessToken": "eyJ...",
      "refreshToken": "eyJ...",
      "expiresAt": 1735689600
    }
  }
}
```

**Response Error:**
| Status | Kondisi |
|---|---|
| 400 | `idToken` tidak disertakan |
| 401 | ID token tidak valid atau sudah kedaluwarsa |

---

### `GET /auth/me`

Mengambil data pengguna yang sedang login.

**Autentikasi:** ✅ Diperlukan

**Response 200:**
```json
{
  "success": true,
  "data": {
    "id": "uuid-user",
    "email": "user@example.com",
    "profile": {
      "id": "uuid-user",
      "fullName": "Nama Lengkap",
      "avatarUrl": null,
      "createdAt": "2025-01-01T00:00:00.000Z",
      "updatedAt": "2025-01-01T00:00:00.000Z"
    }
  }
}
```

**Response Error:**
| Status | Kondisi |
|---|---|
| 401 | Token tidak ada atau tidak valid |
| 404 | Profil tidak ditemukan |

---

### `POST /auth/refresh`

Memperbarui access token menggunakan refresh token yang masih valid.

**Autentikasi:** Tidak diperlukan

**Request Body:**
```json
{
  "refreshToken": "eyJ..."
}
```

| Field | Tipe | Wajib | Keterangan |
|---|---|---|---|
| `refreshToken` | string | ✅ | Refresh token dari sesi sebelumnya |

**Response 200:**
```json
{
  "success": true,
  "data": {
    "session": {
      "accessToken": "eyJ...",
      "refreshToken": "eyJ...",
      "expiresAt": 1735693200
    }
  }
}
```

**Response Error:**
| Status | Kondisi |
|---|---|
| 400 | `refreshToken` tidak disertakan |
| 401 | Refresh token tidak valid atau sudah kedaluwarsa |

---

## Tasks

Semua endpoint tasks memerlukan autentikasi. Tugas hanya dapat diakses oleh pemiliknya.

### `POST /tasks`

Membuat tugas baru. Skor dan prioritas dihitung otomatis oleh backend.

**Autentikasi:** ✅ Diperlukan

**Request Body:**
```json
{
  "title": "Kerjakan laporan bulanan",
  "description": "Laporan keuangan Q1 untuk manajemen",
  "importance": 4,
  "urgency": 5,
  "difficulty": 3,
  "deadline": "2025-01-15T17:00:00+07:00",
  "tags": ["kerja", "laporan"]
}
```

| Field | Tipe | Wajib | Default | Keterangan |
|---|---|---|---|---|
| `title` | string | ✅ | — | Judul tugas (tidak boleh kosong) |
| `description` | string | ❌ | `null` | Deskripsi opsional |
| `importance` | int (1–5) | ❌ | `3` | Seberapa penting tugas ini |
| `urgency` | int (1–5) | ❌ | `3` | Seberapa mendesak tugas ini |
| `difficulty` | int (1–5) | ❌ | `3` | Tingkat kesulitan pengerjaan |
| `deadline` | string (ISO 8601) | ❌ | `null` | Batas waktu dengan timezone |
| `tags` | string[] | ❌ | `[]` | Label/kategori tugas |

> **Catatan deadline:** Gunakan format ISO 8601 dengan informasi timezone (contoh: `2025-01-15T17:00:00+07:00`) untuk memastikan deadline dihitung dengan benar di server.

**Response 201:**
```json
{
  "success": true,
  "data": {
    "id": "uuid-task",
    "userId": "uuid-user",
    "title": "Kerjakan laporan bulanan",
    "description": "Laporan keuangan Q1 untuk manajemen",
    "importance": 4,
    "urgency": 5,
    "difficulty": 3,
    "score": 7.8,
    "priority": "HIGH",
    "deadline": "2025-01-15T10:00:00.000Z",
    "tags": ["kerja", "laporan"],
    "createdAt": "2025-01-10T08:00:00.000Z",
    "updatedAt": "2025-01-10T08:00:00.000Z"
  }
}
```

**Response Error:**
| Status | Kondisi |
|---|---|
| 400 | `title` kosong atau tidak disertakan |
| 401 | Token tidak valid |

---

### `GET /tasks`

Mengambil semua tugas milik pengguna yang login. Skor direcalculate secara dinamis berdasarkan waktu saat ini, lalu diurutkan dari skor tertinggi.

**Autentikasi:** ✅ Diperlukan

**Response 200:**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid-task-1",
      "userId": "uuid-user",
      "title": "Tugas mendesak",
      "description": null,
      "importance": 5,
      "urgency": 5,
      "difficulty": 2,
      "score": 9.2,
      "priority": "HIGH",
      "deadline": "2025-01-11T10:00:00.000Z",
      "tags": [],
      "createdAt": "2025-01-10T08:00:00.000Z",
      "updatedAt": "2025-01-10T08:00:00.000Z"
    }
  ],
  "count": 1
}
```

**Response Error:**
| Status | Kondisi |
|---|---|
| 401 | Token tidak valid |

---

### `GET /tasks/:id`

Mengambil detail satu tugas berdasarkan ID-nya.

**Autentikasi:** ✅ Diperlukan

**Path Parameter:**
| Parameter | Tipe | Keterangan |
|---|---|---|
| `id` | UUID string | ID tugas yang ingin diambil |

**Response 200:**
```json
{
  "success": true,
  "data": {
    "id": "uuid-task",
    "userId": "uuid-user",
    "title": "Kerjakan laporan bulanan",
    "description": "Laporan keuangan Q1 untuk manajemen",
    "importance": 4,
    "urgency": 5,
    "difficulty": 3,
    "score": 7.8,
    "priority": "HIGH",
    "deadline": "2025-01-15T10:00:00.000Z",
    "tags": ["kerja", "laporan"],
    "createdAt": "2025-01-10T08:00:00.000Z",
    "updatedAt": "2025-01-10T08:00:00.000Z"
  }
}
```

**Response Error:**
| Status | Kondisi |
|---|---|
| 401 | Token tidak valid |
| 404 | Tugas tidak ditemukan atau bukan milik pengguna ini |

---

### `DELETE /tasks/:id/complete`

Menyelesaikan dan menghapus sebuah tugas. Setelah dihapus, *hero task* di dashboard akan otomatis berganti ke tugas dengan skor tertinggi berikutnya.

**Autentikasi:** ✅ Diperlukan

**Path Parameter:**
| Parameter | Tipe | Keterangan |
|---|---|---|
| `id` | UUID string | ID tugas yang ingin diselesaikan |

**Response 200:**
```json
{
  "success": true,
  "data": {
    "message": "Task completed and removed",
    "task": {
      "id": "uuid-task",
      "title": "Kerjakan laporan bulanan",
      "score": 7.8,
      "priority": "HIGH"
    }
  }
}
```

**Response Error:**
| Status | Kondisi |
|---|---|
| 401 | Token tidak valid |
| 404 | Tugas tidak ditemukan atau bukan milik pengguna ini |

---

## Dashboard

### `GET /dashboard`

Mengambil data agregat untuk halaman beranda: nama pengguna, total tugas, hero task, dan 3 upcoming tasks. Semua skor tugas direcalculate secara dinamis.

**Autentikasi:** ✅ Diperlukan

**Response 200:**
```json
{
  "success": true,
  "data": {
    "userName": "Nama Lengkap",
    "totalTasks": 5,
    "heroTask": {
      "id": "uuid-task-1",
      "title": "Tugas paling penting",
      "score": 9.2,
      "priority": "HIGH",
      "deadline": "2025-01-11T10:00:00.000Z",
      "tags": ["mendesak"]
    },
    "upcomingTasks": [
      {
        "id": "uuid-task-2",
        "title": "Tugas kedua",
        "score": 6.5,
        "priority": "MEDIUM",
        "deadline": "2025-01-13T10:00:00.000Z"
      },
      {
        "id": "uuid-task-3",
        "title": "Tugas ketiga",
        "score": 4.1,
        "priority": "MEDIUM",
        "deadline": null
      }
    ]
  }
}
```

> **Catatan:** `heroTask` dan `upcomingTasks` bisa `null` / array kosong jika pengguna belum memiliki tugas.

**Response Error:**
| Status | Kondisi |
|---|---|
| 401 | Token tidak valid |

---

## Kode Status HTTP

| Kode | Arti |
|---|---|
| `200 OK` | Request berhasil |
| `201 Created` | Resource baru berhasil dibuat |
| `400 Bad Request` | Input tidak valid atau field wajib tidak ada |
| `401 Unauthorized` | Token tidak ada, tidak valid, atau sudah kedaluwarsa |
| `404 Not Found` | Resource tidak ditemukan |
| `500 Internal Server Error` | Kesalahan tak terduga di sisi server |
