const express = require('express');
const router = express.Router();
const {
    getPopularFilms,
    getTopRatedFilms,
    getCountryFilms,
    getAllFilms,
    getFilmDetail,
    likeFilm,
    watchFilm,
    addToWatchlist
} = require('../controllers/filmController');
const authenticateToken = require('../middleware/auth');

// Public routes
router.get('/popular', getPopularFilms);
router.get('/top-rated', getTopRatedFilms);
router.get('/country/:country', getCountryFilms);
router.get('/', getAllFilms);
router.get('/:id', getFilmDetail);

// Protected routes (require authentication)
router.post('/like/:id', authenticateToken, likeFilm);
router.post('/watch/:id', authenticateToken, watchFilm);
router.post('/watchlist/:id', authenticateToken, addToWatchlist);

module.exports = router;

