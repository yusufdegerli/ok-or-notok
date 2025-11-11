const pool = require('./db');

(async () => {
    try{
        const res = await pool.query('SELECT * FROM users;');
        console.log(res.rows);
    }catch (err){
        console.error(err);
    } finally {
        await pool.end();
    }
})();