const express = require("express");
const router = express.Router();
const multer = require("multer");
const path = require("path");
const db = require("../config/db");

// Setup upload PDF
const storage = multer.diskStorage({
  destination: "./uploads/",
  filename: (req, file, cb) => {
    cb(null, Date.now() + path.extname(file.originalname));
  }
});

const upload = multer({ storage });

// ===== API TAMBAH SURAT =====
router.post("/tambah-surat", upload.single("file_surat"), (req, res) => {
  const {
    no_surat,
    tanggal_surat,
    tanggal_terima,
    dari,
    perihal,
    asal_surat
  } = req.body;

  const file_surat = req.file ? req.file.filename : null;

  const sql = `
    INSERT INTO surat_masuk 
    (no_surat, tanggal_surat, tanggal_terima, dari, perihal, file_surat, status, created_at, asal_surat)
    VALUES (?, ?, ?, ?, ?, ?, 'baru', NOW(), ?)
  `;

  db.query(
    sql, 
    [no_surat, tanggal_surat, tanggal_terima, dari, perihal, file_surat, asal_surat],
    (err, result) => {
      if (err) {
        console.error(err);
        return res.status(500).json({ message: "Gagal menambah surat" });
      }
      res.json({ message: "Surat berhasil ditambahkan", id: result.insertId });
    }
  );
});

module.exports = router;
