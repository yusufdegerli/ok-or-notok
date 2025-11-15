require('dotenv').config();

module.exports = {
    db: {
        user: process.env.DB_USER || 'movie_user',
        password: process.env.DB_PASSWORD || '12345',
        host: process.env.DB_HOST || 'localhost',
        port: process.env.DB_PORT || 5432,
        database: process.env.DB_NAME || 'ok_or_notokdb'
    },
    jwtSecret: process.env.JWT_SECRET || 'supersecretkey123456789',
    tmdbApiKey: process.env.TMDB_API_KEY || ''
};
