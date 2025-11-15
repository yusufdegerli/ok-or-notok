const express = require('express');
const router = express.Router();
const { getMoviesByGenre } = require('../controllers/movieController');

router.get('/genre/:id', getMoviesByGenre);

module.exports = router;
