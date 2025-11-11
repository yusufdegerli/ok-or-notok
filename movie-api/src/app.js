const express = require('express');
const movieRoutes = require('./routes/movieRoutes');
const app = express();
const authRoutes = require('./routes/authRoutes');

app.use('/api/movies', movieRoutes);
app.use(express.json());
app.use('/api/auth', authRoutes);

app.get('/', (req, res) => {
  res.send('Hello, Movie API!');
});

const PORT = 4000;
app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});

module.exports = app;