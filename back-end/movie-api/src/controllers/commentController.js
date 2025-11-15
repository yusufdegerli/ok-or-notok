const pool = require('../db');

// Film yorumlarını getir
async function getFilmComments(req, res) {
    try {
        const { id } = req.params;
        const result = await pool.query(`
            SELECT c.*, u.id as user_id, u.username, u.email
            FROM comments c
            JOIN users u ON c.user_id = u.id
            WHERE c.film_id = $1 AND c.parent_id IS NULL
            ORDER BY c.created_at DESC
        `, [id]);

        const comments = await Promise.all(result.rows.map(async (row) => {
            const replies = await pool.query(`
                SELECT c.*, u.id as user_id, u.username, u.email
                FROM comments c
                JOIN users u ON c.user_id = u.id
                WHERE c.parent_id = $1
                ORDER BY c.created_at ASC
            `, [row.id]);

            return {
                id: String(row.id),
                content: row.content,
                author: {
                    id: String(row.user_id),
                    username: row.username,
                    email: row.email
                },
                created_at: row.created_at.toISOString(),
                updated_at: row.updated_at ? row.updated_at.toISOString() : null,
                likes_count: row.likes_count || 0,
                parent_id: row.parent_id ? String(row.parent_id) : null,
                replies: replies.rows.map(reply => ({
                    id: String(reply.id),
                    content: reply.content,
                    author: {
                        id: String(reply.user_id),
                        username: reply.username,
                        email: reply.email
                    },
                    created_at: reply.created_at.toISOString(),
                    updated_at: reply.updated_at ? reply.updated_at.toISOString() : null,
                    likes_count: reply.likes_count || 0,
                    parent_id: reply.parent_id ? String(reply.parent_id) : null,
                    replies: []
                }))
            };
        }));

        res.json({ comments });
    } catch (error) {
        console.error('Error getting film comments:', error);
        res.status(500).json({ error: 'Failed to load comments' });
    }
}

// Film yorumu ekle
async function postFilmComment(req, res) {
    try {
        const { id } = req.params;
        const { content } = req.body;
        const userId = req.user?.id;

        if (!userId) {
            return res.status(401).json({ error: 'Unauthorized' });
        }

        if (!content || content.trim().length === 0) {
            return res.status(400).json({ error: 'Comment content is required' });
        }

        const result = await pool.query(`
            INSERT INTO comments (film_id, user_id, content)
            VALUES ($1, $2, $3)
            RETURNING *
        `, [id, userId, content.trim()]);

        const user = await pool.query('SELECT id, username, email FROM users WHERE id = $1', [userId]);

        const comment = {
            id: String(result.rows[0].id),
            content: result.rows[0].content,
            author: {
                id: String(user.rows[0].id),
                username: user.rows[0].username,
                email: user.rows[0].email
            },
            created_at: result.rows[0].created_at.toISOString(),
            updated_at: result.rows[0].updated_at ? result.rows[0].updated_at.toISOString() : null,
            likes_count: result.rows[0].likes_count || 0,
            parent_id: null,
            replies: []
        };

        res.status(201).json({ comment });
    } catch (error) {
        console.error('Error posting comment:', error);
        res.status(500).json({ error: 'Failed to post comment' });
    }
}

// Liste yorumlarını getir
async function getListComments(req, res) {
    try {
        const { id } = req.params;
        const result = await pool.query(`
            SELECT c.*, u.id as user_id, u.username, u.email
            FROM comments c
            JOIN users u ON c.user_id = u.id
            WHERE c.list_id = $1 AND c.parent_id IS NULL
            ORDER BY c.created_at DESC
        `, [id]);

        const comments = await Promise.all(result.rows.map(async (row) => {
            const replies = await pool.query(`
                SELECT c.*, u.id as user_id, u.username, u.email
                FROM comments c
                JOIN users u ON c.user_id = u.id
                WHERE c.parent_id = $1
                ORDER BY c.created_at ASC
            `, [row.id]);

            return {
                id: String(row.id),
                content: row.content,
                author: {
                    id: String(row.user_id),
                    username: row.username,
                    email: row.email
                },
                created_at: row.created_at.toISOString(),
                updated_at: row.updated_at ? row.updated_at.toISOString() : null,
                likes_count: row.likes_count || 0,
                parent_id: row.parent_id ? String(row.parent_id) : null,
                replies: replies.rows.map(reply => ({
                    id: String(reply.id),
                    content: reply.content,
                    author: {
                        id: String(reply.user_id),
                        username: reply.username,
                        email: reply.email
                    },
                    created_at: reply.created_at.toISOString(),
                    updated_at: reply.updated_at ? reply.updated_at.toISOString() : null,
                    likes_count: reply.likes_count || 0,
                    parent_id: reply.parent_id ? String(reply.parent_id) : null,
                    replies: []
                }))
            };
        }));

        res.json({ comments });
    } catch (error) {
        console.error('Error getting list comments:', error);
        res.status(500).json({ error: 'Failed to load comments' });
    }
}

module.exports = {
    getFilmComments,
    postFilmComment,
    getListComments
};

