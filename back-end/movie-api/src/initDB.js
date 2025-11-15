// initDB.js - Veritabanı tablolarını ve test kullanıcılarını oluşturur
const pool = require('./db');
const bcrypt = require('bcrypt');

(async () => {
    try {
        console.log('Veritabanı başlatılıyor...');

        // Users tablosunu oluştur
        await pool.query(`
            CREATE TABLE IF NOT EXISTS users (
                id SERIAL PRIMARY KEY,
                username VARCHAR(50) UNIQUE NOT NULL,
                email VARCHAR(100) UNIQUE NOT NULL,
                password_hash VARCHAR(255) NOT NULL,
                country VARCHAR(50),
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            );
        `);
        console.log('✓ Users tablosu oluşturuldu/kontrol edildi');

        // Films tablosunu oluştur
        await pool.query(`
            CREATE TABLE IF NOT EXISTS films (
                id VARCHAR(50) PRIMARY KEY,
                title VARCHAR(255) NOT NULL,
                original_title VARCHAR(255),
                description TEXT,
                poster_url TEXT,
                backdrop_url TEXT,
                release_date DATE,
                duration INTEGER,
                rating DECIMAL(3,1),
                vote_count INTEGER DEFAULT 0,
                director VARCHAR(255),
                tmdb_id INTEGER UNIQUE,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            );
        `);
        console.log('✓ Films tablosu oluşturuldu/kontrol edildi');

        // Films tablosuna vote_count ve director kolonlarını ekle (eğer yoksa)
        try {
            await pool.query('ALTER TABLE films ADD COLUMN IF NOT EXISTS vote_count INTEGER DEFAULT 0');
            await pool.query('ALTER TABLE films ADD COLUMN IF NOT EXISTS director VARCHAR(255)');
            await pool.query('ALTER TABLE films ADD CONSTRAINT IF NOT EXISTS films_tmdb_id_unique UNIQUE (tmdb_id)');
        } catch (e) {
            // Kolonlar zaten varsa hata vermesin
        }

        // Film genres tablosu
        await pool.query(`
            CREATE TABLE IF NOT EXISTS film_genres (
                film_id VARCHAR(50) REFERENCES films(id) ON DELETE CASCADE,
                genre VARCHAR(100),
                PRIMARY KEY (film_id, genre)
            );
        `);
        console.log('✓ Film genres tablosu oluşturuldu/kontrol edildi');

        // Film countries tablosu
        await pool.query(`
            CREATE TABLE IF NOT EXISTS film_countries (
                film_id VARCHAR(50) REFERENCES films(id) ON DELETE CASCADE,
                country VARCHAR(100),
                PRIMARY KEY (film_id, country)
            );
        `);
        console.log('✓ Film countries tablosu oluşturuldu/kontrol edildi');

        // Film cast tablosu
        await pool.query(`
            CREATE TABLE IF NOT EXISTS film_cast (
                id SERIAL PRIMARY KEY,
                film_id VARCHAR(50) REFERENCES films(id) ON DELETE CASCADE,
                actor_name VARCHAR(255) NOT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                UNIQUE(film_id, actor_name)
            );
        `);
        console.log('✓ Film cast tablosu oluşturuldu/kontrol edildi');

        // Film likes tablosu
        await pool.query(`
            CREATE TABLE IF NOT EXISTS film_likes (
                id SERIAL PRIMARY KEY,
                film_id VARCHAR(50) REFERENCES films(id) ON DELETE CASCADE,
                user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                UNIQUE(film_id, user_id)
            );
        `);
        console.log('✓ Film likes tablosu oluşturuldu/kontrol edildi');

        // Film watched tablosu
        await pool.query(`
            CREATE TABLE IF NOT EXISTS film_watched (
                id SERIAL PRIMARY KEY,
                film_id VARCHAR(50) REFERENCES films(id) ON DELETE CASCADE,
                user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                UNIQUE(film_id, user_id)
            );
        `);
        console.log('✓ Film watched tablosu oluşturuldu/kontrol edildi');

        // Film watchlist tablosu
        await pool.query(`
            CREATE TABLE IF NOT EXISTS film_watchlist (
                id SERIAL PRIMARY KEY,
                film_id VARCHAR(50) REFERENCES films(id) ON DELETE CASCADE,
                user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                UNIQUE(film_id, user_id)
            );
        `);
        console.log('✓ Film watchlist tablosu oluşturuldu/kontrol edildi');

        // Lists tablosu (Comments'tan önce oluşturulmalı)
        await pool.query(`
            CREATE TABLE IF NOT EXISTS lists (
                id SERIAL PRIMARY KEY,
                user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
                title VARCHAR(255) NOT NULL,
                description TEXT,
                is_public BOOLEAN DEFAULT true,
                likes_count INTEGER DEFAULT 0,
                comments_count INTEGER DEFAULT 0,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            );
        `);
        console.log('✓ Lists tablosu oluşturuldu/kontrol edildi');

        // Comments tablosu
        await pool.query(`
            CREATE TABLE IF NOT EXISTS comments (
                id SERIAL PRIMARY KEY,
                film_id VARCHAR(50) REFERENCES films(id) ON DELETE CASCADE,
                list_id INTEGER REFERENCES lists(id) ON DELETE CASCADE,
                user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
                content TEXT NOT NULL,
                parent_id INTEGER REFERENCES comments(id) ON DELETE CASCADE,
                likes_count INTEGER DEFAULT 0,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                CHECK ((film_id IS NOT NULL AND list_id IS NULL) OR (film_id IS NULL AND list_id IS NOT NULL))
            );
        `);
        console.log('✓ Comments tablosu oluşturuldu/kontrol edildi');

        // List films tablosu
        await pool.query(`
            CREATE TABLE IF NOT EXISTS list_films (
                list_id INTEGER REFERENCES lists(id) ON DELETE CASCADE,
                film_id VARCHAR(50) REFERENCES films(id) ON DELETE CASCADE,
                added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                PRIMARY KEY (list_id, film_id)
            );
        `);
        console.log('✓ List films tablosu oluşturuldu/kontrol edildi');

        // Test kullanıcılarını oluştur
        const testUsers = [
            {
                username: 'testuser1',
                email: 'test1@example.com',
                password: 'password123',
                country: 'Turkey'
            },
            {
                username: 'testuser2',
                email: 'test2@example.com',
                password: 'password123',
                country: 'USA'
            },
            {
                username: 'admin',
                email: 'admin@example.com',
                password: 'admin123',
                country: 'Turkey'
            }
        ];

        for (const user of testUsers) {
            // Kullanıcı zaten var mı kontrol et
            const existing = await pool.query(
                'SELECT * FROM users WHERE email = $1',
                [user.email]
            );

            if (existing.rows.length === 0) {
                const hashedPassword = await bcrypt.hash(user.password, 10);
                await pool.query(
                    'INSERT INTO users (username, email, password_hash, country) VALUES ($1, $2, $3, $4)',
                    [user.username, user.email, hashedPassword, user.country]
                );
                console.log(`✓ Test kullanıcısı oluşturuldu: ${user.username} (${user.email})`);
            } else {
                console.log(`- Kullanıcı zaten mevcut: ${user.email}`);
            }
        }

        console.log('\n✓ Veritabanı başlatma tamamlandı!');
        console.log('\nTest Kullanıcıları:');
        console.log('1. Email: test1@example.com, Şifre: password123');
        console.log('2. Email: test2@example.com, Şifre: password123');
        console.log('3. Email: admin@example.com, Şifre: admin123');

    } catch (err) {
        console.error('Veritabanı başlatma hatası:', err);
        await pool.end();
        process.exit(1); // Hata durumunda çık
    }
    
    // Eğer standalone olarak çalıştırılıyorsa (npm run init-db), pool'u kapat
    // Eğer container içinde çalıştırılıyorsa, pool açık kalmalı
    if (process.argv[1].includes('initDB.js') && !process.env.DOCKER_CONTAINER) {
        await pool.end();
        console.log('\n✓ Veritabanı başlatma tamamlandı ve bağlantı kapatıldı.\n');
        process.exit(0);
    } else {
        console.log('\n✓ Veritabanı hazır, uygulama başlatılıyor...\n');
    }
})();

