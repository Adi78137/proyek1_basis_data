# Proyek Basis Data - PostgreSQL Docker & DBeaver

Proyek ini berisi implementasi pengelolaan database PostgreSQL 15 dan pgAdmin 4 menggunakan Docker Compose, DBeaver, pembuatan skema `SALAM`, tabel `mahasiswas` beserta aturan *constraints*, serta pengolahan *role* dan *hak akses (privileges)*.

---

## 🛠️ Persyaratan Sistem & Alat
* [Docker Desktop](https://www.docker.com/)
* [DBeaver Community Edition](https://dbeaver.io/)
* Visual Studio Code / Text Editor

---

## 📂 Struktur Proyek
```text
proyek_basis_data/
├── .env                 # Variabel lingkungan (kredensial DB & pgAdmin)
├── docker-compose.yml   # Konfigurasi layanan Docker PostgreSQL & pgAdmin
├── script_proyek.sql    # Skrip SQL (Schema, Table, Constraints, User Roles)
└── README.md            # Dokumentasi proyek

```

---

## 🚀 Cara Menjalankan Kontainer Docker

1. Buka terminal (PowerShell / CMD) dan masuk ke direktori proyek:
```bash
cd C:\TUGAS\basis_data\proyek_basis_data

```


2. Jalankan kontainer menggunakan Docker Compose:
```bash
docker compose up -d

```


3. Pastikan kedua kontainer berjalan di Docker Desktop:
* `postgres_127` (Port Eksternal: `22127`)
* `pgadmin_127` (Port Eksternal: `44127`)



---

## 🔌 Informasi Koneksi Database (DBeaver)

* **Host:** `localhost`
* **Port:** `22127`
* **Database:** `salam_db`
* **Username:** `postgres`
* **Password:** `ifunggul`

---

## 🔐 Manajemen Hak Akses (User Roles)

| User | Role / Hak Akses |
| --- | --- |
| `backend_dev` | Akses CRUD (`SELECT`, `INSERT`, `UPDATE`, `DELETE`) pada semua tabel skema `SALAM`. |
| `bi_dev` | Akses Read-Only (`SELECT`) pada semua tabel skema `SALAM`. |
| `data_engineer` | Akses Penuh (`ALL PRIVILEGES`) pada skema dan tabel `SALAM`. |
