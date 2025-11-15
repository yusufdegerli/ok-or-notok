const express = require('express');
const router = express.Router();
const { getFilmComments, postFilmComment, getListComments } = require('../controllers/commentController');
const authenticateToken = require('../middleware/auth');

// Film yorumları - /api/films/comments/:id
router.get('/:id', getFilmComments);
router.post('/:id', authenticateToken, postFilmComment);

module.exports = router;

