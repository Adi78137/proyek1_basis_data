-- ============================================================
-- SKRIP UTAMA PROYEK BASIS DATA (POSTGRESQL)
-- ============================================================

-- ------------------------------------------------------------
-- 1. PEMBUATAN SKEMA
-- ------------------------------------------------------------
CREATE SCHEMA SALAM;

-- ------------------------------------------------------------
-- 2. PEMBUATAN TABEL DAN CONSTRAINTS
-- ------------------------------------------------------------
CREATE TABLE SALAM.mahasiswas (
    id SERIAL PRIMARY KEY,
    nim VARCHAR(20) UNIQUE NOT NULL,
    nama VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    usia INT CHECK (usia >= 17),
    ipk NUMERIC(3,2) CHECK (ipk >= 0.00 AND ipk <= 4.00)
);

-- ------------------------------------------------------------
-- 3. PENGUJIAN VALIDASI CONSTRAINTS
-- ------------------------------------------------------------

-- a. Insert data valid (Harus Berhasil)
INSERT INTO SALAM.mahasiswas (nim, nama, email, usia, ipk) 
VALUES ('1247050127', 'Adi K', 'adi@mail.com', 20, 3.50);

-- b. Uji Unique Constraint - NIM Duplikat (Harus Error)
INSERT INTO SALAM.mahasiswas (nim, nama, email, usia, ipk) 
VALUES ('1247050127', 'Ani', 'ani@mail.com', 19, 3.75);

-- c. Uji Check Constraint - Usia < 17 (Harus Error)
 INSERT INTO SALAM.mahasiswas (nim, nama, email, usia, ipk) 
 VALUES ('1247050122', 'Citra', 'citra@mail.com', 15, 3.80);

-- ------------------------------------------------------------
-- 4. MANAJEMEN PENGGUNA DAN HAK AKSES (ROLES & PRIVILEGES)
-- ------------------------------------------------------------

-- Pembuatan User/Role
CREATE USER backend_dev WITH PASSWORD 'pass_backend';
CREATE USER bi_dev WITH PASSWORD 'pass_bi';
CREATE USER data_engineer WITH PASSWORD 'pass_de';

-- a. Hak Akses backend_dev (CRUD pada skema SALAM)
GRANT USAGE ON SCHEMA SALAM TO backend_dev;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA SALAM TO backend_dev;
ALTER DEFAULT PRIVILEGES IN SCHEMA SALAM GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO backend_dev;

-- b. Hak Akses bi_dev (Read/Select Only pada skema SALAM)
GRANT USAGE ON SCHEMA SALAM TO bi_dev;
GRANT SELECT ON ALL TABLES IN SCHEMA SALAM TO bi_dev;
ALTER DEFAULT PRIVILEGES IN SCHEMA SALAM GRANT SELECT ON TABLES TO bi_dev;

-- c. Hak Akses data_engineer (Full Privileges pada skema SALAM)
GRANT ALL PRIVILEGES ON SCHEMA SALAM TO data_engineer;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA SALAM TO data_engineer;
ALTER DEFAULT PRIVILEGES IN SCHEMA SALAM GRANT ALL PRIVILEGES ON TABLES TO data_engineer;