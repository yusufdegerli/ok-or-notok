const express = require('express');
const router = express.Router();
const { getListComments } = require('../controllers/commentController');

// Liste yorumları - /api/lists/comments/:id
router.get('/:id', getListComments);

module.exports = router;

