const express = require('express');
const router = express.Router();
const { getUserLists, createList } = require('../controllers/listController');
const authenticateToken = require('../middleware/auth');

router.get('/', getUserLists);
router.post('/', authenticateToken, createList);

module.exports = router;

