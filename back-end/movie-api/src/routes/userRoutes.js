const express = require('express');
const router = express.Router();
const { getPopularUsers } = require('../controllers/userController');

router.get('/popular', getPopularUsers);

module.exports = router;

