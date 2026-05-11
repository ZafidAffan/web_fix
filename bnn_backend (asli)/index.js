require('dotenv').config();

const express = require("express");
const cors = require("cors");

const app = express();

// ================= MIDDLEWARE =================
app.use(cors());
app.use(express.json());
app.use("/uploads", express.static("uploads"));

// ================= ROUTES =================
app.use("/api/auth", require("./routes/auth"));
app.use("/api/tracking", require("./routes/trackingRoutes"));
app.use("/api/surat-masuk", require("./routes/suratMasuk"));
app.use("/api/aksi", require("./routes/suratAksiRoutes"));
app.use("/api/disposisi", require("./routes/disposisiRoutes"));
app.use("/api/template-perintah", require("./routes/templatePerintahRoutes"));



// ================= START SERVER (local) =================
const PORT = process.env.PORT || 3000;
//app.listen(PORT, () => {
//  console.log(`Server running on http://localhost:${PORT}`);
//});

// ================= START SERVER (bisa di akses komputer lain yang satu jaringan) =================
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server running on http://0.0.0.0:${PORT}`);
});