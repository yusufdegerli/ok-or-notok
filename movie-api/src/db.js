const { Pool } = require('pg');
const { db } = require('./config');

const pool = new Pool({
    user: 'movie_user',
    host: 'localhost',
    database: 'ok_or_notokdb',
    password: '12345',
    port: 5432,
});

module.exports = pool;