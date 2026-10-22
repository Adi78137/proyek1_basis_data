-- ============================================================
-- SKRIP UTAMA PROYEK BASIS DATA (POSTGRESQL)
-- Jalankan sebagai user postgres pada database salam_db
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
VALUES ('1247050127', 'adi k', 'adi@mail.com', 20, 3.50);

-- b. Uji Unique Constraint - NIM Duplikat (Harus Error)
-- INSERT INTO SALAM.mahasiswas (nim, nama, email, usia, ipk)
-- VALUES ('1247050127', 'Ani', 'ani@mail.com', 19, 3.75);

-- c. Uji Check Constraint - Usia < 17 (Harus Error)
-- INSERT INTO SALAM.mahasiswas (nim, nama, email, usia, ipk)
-- VALUES ('1247050122', 'Citra', 'citra@mail.com', 15, 3.80);

-- ------------------------------------------------------------
-- 4. MANAJEMEN PENGGUNA DAN HAK AKSES (ROLES & PRIVILEGES)
-- ------------------------------------------------------------

-- Pembuatan User
CREATE USER backend_dev   WITH PASSWORD 'pass_backend';
CREATE USER bi_dev        WITH PASSWORD 'pass_bi';
CREATE USER data_engineer WITH PASSWORD 'pass_de';

-- data_engineer: pemilik skema dan tabel, sehingga dapat CREATE, ALTER, DROP
ALTER SCHEMA SALAM OWNER TO data_engineer;
ALTER TABLE SALAM.mahasiswas OWNER TO data_engineer;
ALTER SEQUENCE SALAM.mahasiswas_id_seq OWNER TO data_engineer;
GRANT CREATE ON DATABASE salam_db TO data_engineer;

-- backend_dev: CRUD pada semua tabel (sequence perlu agar kolom SERIAL bisa di-INSERT)
GRANT USAGE ON SCHEMA SALAM TO backend_dev, bi_dev;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA SALAM TO backend_dev;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA SALAM TO backend_dev;

-- bi_dev: hanya SELECT pada semua tabel/view
GRANT SELECT ON ALL TABLES IN SCHEMA SALAM TO bi_dev;

-- Objek baru yang dibuat data_engineer otomatis mendapat hak akses yang sama
ALTER DEFAULT PRIVILEGES FOR ROLE data_engineer IN SCHEMA SALAM
    GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO backend_dev;
ALTER DEFAULT PRIVILEGES FOR ROLE data_engineer IN SCHEMA SALAM
    GRANT SELECT ON TABLES TO bi_dev;
ALTER DEFAULT PRIVILEGES FOR ROLE data_engineer IN SCHEMA SALAM
    GRANT USAGE, SELECT ON SEQUENCES TO backend_dev;

-- ------------------------------------------------------------
-- 5. FITUR TAMBAHAN (PEMBEDA): KRS, AUDIT TRIGGER, VIEW
-- ------------------------------------------------------------
SET ROLE data_engineer;

-- a. Tabel mata kuliah dan KRS (foreign key + unique)
CREATE TABLE SALAM.mata_kuliah (
    kode VARCHAR(10) PRIMARY KEY,
    nama VARCHAR(100) NOT NULL,
    sks  INT NOT NULL CHECK (sks BETWEEN 1 AND 6)
);

CREATE TABLE SALAM.krs (
    id SERIAL PRIMARY KEY,
    mahasiswa_id INT NOT NULL REFERENCES SALAM.mahasiswas(id) ON DELETE CASCADE,
    kode_mk VARCHAR(10) NOT NULL REFERENCES SALAM.mata_kuliah(kode),
    semester INT NOT NULL CHECK (semester BETWEEN 1 AND 14),
    UNIQUE (mahasiswa_id, kode_mk)
);

-- b. Tabel audit dan trigger pada tabel mahasiswas
CREATE TABLE SALAM.audit_log (
    id SERIAL PRIMARY KEY,
    waktu TIMESTAMP NOT NULL DEFAULT now(),
    db_user TEXT NOT NULL,
    aksi TEXT NOT NULL,
    tabel TEXT NOT NULL,
    data_lama JSONB,
    data_baru JSONB
);

CREATE OR REPLACE FUNCTION SALAM.fn_audit() RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER SET search_path = salam, pg_temp AS $$
BEGIN
    INSERT INTO salam.audit_log(db_user, aksi, tabel, data_lama, data_baru)
    VALUES (COALESCE(NULLIF(current_setting('role'), 'none'), session_user),
            TG_OP, TG_TABLE_NAME,
            CASE WHEN TG_OP <> 'INSERT' THEN to_jsonb(OLD) END,
            CASE WHEN TG_OP <> 'DELETE' THEN to_jsonb(NEW) END);
    RETURN COALESCE(NEW, OLD);
END $$;

CREATE TRIGGER trg_audit_mahasiswas
AFTER INSERT OR UPDATE OR DELETE ON SALAM.mahasiswas
FOR EACH ROW EXECUTE FUNCTION SALAM.fn_audit();

-- audit_log tidak boleh diubah oleh backend_dev
REVOKE ALL ON SALAM.audit_log FROM backend_dev;

-- c. View ringkasan untuk bi_dev
CREATE VIEW SALAM.v_ringkasan_mahasiswa AS
SELECT m.nim, m.nama, m.ipk,
       COUNT(k.id) AS jumlah_mk,
       COALESCE(SUM(mk.sks), 0) AS total_sks
FROM SALAM.mahasiswas m
LEFT JOIN SALAM.krs k ON k.mahasiswa_id = m.id
LEFT JOIN SALAM.mata_kuliah mk ON mk.kode = k.kode_mk
GROUP BY m.id;

RESET ROLE;

-- d. Data contoh
INSERT INTO SALAM.mata_kuliah VALUES
    ('MBD01', 'Manajemen Basis Data', 3),
    ('PBO01', 'Pemrograman Berorientasi Objek', 3);
INSERT INTO SALAM.krs (mahasiswa_id, kode_mk, semester)
SELECT id, 'MBD01', 5 FROM SALAM.mahasiswas WHERE nim = '1247050127';

-- ------------------------------------------------------------
-- 6. PEMBUKTIAN HAK AKSES (jalankan satu per satu)
-- ------------------------------------------------------------
-- SET ROLE bi_dev;
-- SELECT * FROM SALAM.mahasiswas;                      -- berhasil
-- DELETE FROM SALAM.krs WHERE id = 1;                  -- ditolak (permission denied)
-- RESET ROLE;
--
-- SET ROLE backend_dev;
-- UPDATE SALAM.mahasiswas SET ipk = 3.70 WHERE nim = '1247050127';  -- berhasil
-- CREATE TABLE SALAM.tes (id INT);                     -- ditolak (permission denied)
-- RESET ROLE;
--
-- SET ROLE data_engineer;
-- CREATE TABLE SALAM.tes (id INT);                     -- berhasil
-- DROP TABLE SALAM.tes;                                -- berhasil
-- RESET ROLE;
--
-- SELECT * FROM SALAM.audit_log;                       -- db_user terisi backend_dev
