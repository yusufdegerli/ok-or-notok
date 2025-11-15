// db.js
const { Pool } = require('pg');
const { db } = require('./config'); // config.js'ten DB ayarlarını çekiyoruz

const pool = new Pool({
    // db.js'deki sabit değerleri silin, config'ten gelen değerleri kullanın
    user: db.user,
    host: db.host, 
    database: db.database,
    password: db.password,
    port: db.port,
});

module.exports = pool;

// db.js dosyasını config.js'ye uygun olarak güncelledik. 
// Artık config.js'deki değerler, docker-compose.yml dosyasından gelen değerler (db, 5432, vs.) olacak.