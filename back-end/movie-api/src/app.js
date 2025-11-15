const express = require('express');
const movieRoutes = require('./routes/movieRoutes');
const filmRoutes = require('./routes/filmRoutes');
const app = express();
const cors = require('cors');
const authRoutes = require('./routes/authRoutes');
const commentRoutes = require('./routes/commentRoutes');
const listRoutes = require('./routes/listRoutes');
const userRoutes = require('./routes/userRoutes');

// CORS ayarları - Flutter uygulamasından gelen isteklere izin ver
app.use(cors({
  origin: '*', // Production'da spesifik origin'ler belirtilmeli
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
}));

app.use(express.json());
app.use('/api/movies', movieRoutes); // Eski route (genre için)
app.use('/api/films', filmRoutes); // Yeni film routes
app.use('/api/auth', authRoutes);
app.use('/api/films/comments', commentRoutes); // Film yorumları: /api/films/comments/:id
app.use('/api/lists', listRoutes);
app.use('/api/lists/comments', require('./routes/listCommentRoutes')); // Liste yorumları
app.use('/api/users', userRoutes);

app.get('/', (req, res) => {
  res.send('Hello, Movie API!');
});

const PORT = process.env.PORT || 4000;
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server is running on http://0.0.0.0:${PORT}`);
});

module.exports = app;