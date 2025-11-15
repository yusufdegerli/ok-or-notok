const pool = require('../db');

// Popüler kullanıcıları getir
async function getPopularUsers(req, res) {
    try {
        // En çok liste oluşturan veya en çok yorum yapan kullanıcılar
        const result = await pool.query(`
            SELECT u.id, u.username, u.email, u.country,
                   COUNT(DISTINCT l.id) as lists_count,
                   COUNT(DISTINCT c.id) as comments_count
            FROM users u
            LEFT JOIN lists l ON u.id = l.user_id
            LEFT JOIN comments c ON u.id = c.user_id
            GROUP BY u.id, u.username, u.email, u.country
            ORDER BY (COUNT(DISTINCT l.id) + COUNT(DISTINCT c.id)) DESC
            LIMIT 20
        `);

        const users = result.rows.map(row => ({
            id: String(row.id),
            username: row.username,
            email: row.email,
            country: row.country
        }));

        res.json({ users });
    } catch (error) {
        console.error('Error getting popular users:', error);
        res.status(500).json({ error: 'Failed to load popular users' });
    }
}

module.exports = {
    getPopularUsers
};

