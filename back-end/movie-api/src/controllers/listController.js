const pool = require('../db');
const { formatFilm } = require('./filmController');

// Kullanıcı listelerini getir
async function getUserLists(req, res) {
    try {
        const { user_id } = req.query;
        
        if (!user_id) {
            return res.status(400).json({ error: 'user_id parameter is required' });
        }

        const result = await pool.query(`
            SELECT l.*, u.id as creator_id, u.username, u.email
            FROM lists l
            JOIN users u ON l.user_id = u.id
            WHERE l.user_id = $1 OR l.is_public = true
            ORDER BY l.created_at DESC
        `, [user_id]);

        const lists = await Promise.all(result.rows.map(async (row) => {
            const films = await pool.query(`
                SELECT f.* FROM films f
                JOIN list_films lf ON f.id = lf.film_id
                WHERE lf.list_id = $1
            `, [row.id]);

            const formattedFilms = await Promise.all(
                films.rows.map(f => formatFilm(f.id))
            );

            return {
                id: String(row.id),
                title: row.title,
                description: row.description,
                creator: {
                    id: String(row.creator_id),
                    username: row.username,
                    email: row.email
                },
                films: formattedFilms.filter(f => f !== null),
                created_at: row.created_at.toISOString(),
                updated_at: row.updated_at.toISOString(),
                likes_count: row.likes_count || 0,
                comments_count: row.comments_count || 0,
                is_public: row.is_public
            };
        }));

        res.json({ lists });
    } catch (error) {
        console.error('Error getting user lists:', error);
        res.status(500).json({ error: 'Failed to load lists' });
    }
}

// Liste oluştur
async function createList(req, res) {
    try {
        const { title, description, is_public } = req.body;
        const userId = req.user?.id;

        if (!userId) {
            return res.status(401).json({ error: 'Unauthorized' });
        }

        if (!title || title.trim().length === 0) {
            return res.status(400).json({ error: 'Title is required' });
        }

        const result = await pool.query(`
            INSERT INTO lists (user_id, title, description, is_public)
            VALUES ($1, $2, $3, $4)
            RETURNING *
        `, [userId, title.trim(), description || null, is_public !== false]);

        const user = await pool.query('SELECT id, username, email FROM users WHERE id = $1', [userId]);

        const list = {
            id: String(result.rows[0].id),
            title: result.rows[0].title,
            description: result.rows[0].description,
            creator: {
                id: String(user.rows[0].id),
                username: user.rows[0].username,
                email: user.rows[0].email
            },
            films: [],
            created_at: result.rows[0].created_at.toISOString(),
            updated_at: result.rows[0].updated_at.toISOString(),
            likes_count: result.rows[0].likes_count || 0,
            comments_count: result.rows[0].comments_count || 0,
            is_public: result.rows[0].is_public
        };

        res.status(201).json({ list });
    } catch (error) {
        console.error('Error creating list:', error);
        res.status(500).json({ error: 'Failed to create list' });
    }
}

module.exports = {
    getUserLists,
    createList
};

