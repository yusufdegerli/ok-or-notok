const express = require('express');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const pool = require('../db');
const { jwtSecret } = require('../config');

const router = express.Router();

const JWT_SECRET = 'supersecretkey';

router.post('/register', async (req, res) =>{
    const { username, email, password, country } = req.body;

    try{
        const existing = await pool.query(
            'SELECT * FROM users WHERE username = $1 OR email = $2',
            [username, email]
        );

        if (existing.rows.length > 0) {
            return res.status(400).json({ error: 'Kullanıcı adı veya email zaten kayıtlı' });
        }

        const hashedPassword = await bcrypt.hash(password, 10);

        const result = await pool.query(
            'INSERT INTO users (username, email, password_hash, country) VALUES ($1, $2, $3, $4) RETURNING *',
            [username, email, hashedPassword, country]
        );

        res.json({ user: result.rows[0] });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Kayıt sırasında hata oluştu' });
    }
});


router.post('/login', async (req, res) => {
    const { email, password } = req.body;

    try{
        const result = await pool.query('SELECT * FROM users WHERE email = $1', [email]);

        if (result.rows.length === 0){
            return res.status(400).json({ error: 'Kullanici bulunamadi'});
        }
        const user = result.rows[0];

        const isMatch = await bcrypt.compare(password, user.password_hash);//?
        if (!isMatch){
            return res.status(400).json({ error: 'Sifre yanlis' });
        }

        const token = jwt.sign({ id: user.id }, jwtSecret, { expiresIn: '1h' });

        res.json({ user: {id: user.id, username: user.username, email: user.email}, token });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Giris sirasinda hata olustu' });
    }
});

module.exports = router;