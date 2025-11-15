const pool = require('../db');
const { fetchMoviesByGenre } = require('../services/tmdbService');
const axios = require('axios');
const { tmdbApiKey } = require('../config');

// TMDB'den film verilerini çek ve veritabanına kaydet
async function fetchAndStoreFilm(tmdbId) {
    try {
        const response = await axios.get(`https://api.themoviedb.org/3/movie/${tmdbId}`, {
            params: { api_key: tmdbApiKey }
        });
        const movie = response.data;

        // Film veritabanında var mı kontrol et
        const existing = await pool.query('SELECT * FROM films WHERE tmdb_id = $1', [tmdbId]);
        
        if (existing.rows.length === 0) {
            // Film yoksa ekle
            await pool.query(`
                INSERT INTO films (id, title, original_title, description, poster_url, backdrop_url, 
                    release_date, duration, rating, tmdb_id)
                VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
            `, [
                String(movie.id),
                movie.title,
                movie.original_title,
                movie.overview,
                movie.poster_path ? `https://image.tmdb.org/t/p/w500${movie.poster_path}` : null,
                movie.backdrop_path ? `https://image.tmdb.org/t/p/w500${movie.backdrop_path}` : null,
                movie.release_date || null,
                movie.runtime || null,
                movie.vote_average || null,
                movie.id
            ]);

            // Genres ekle
            if (movie.genres && movie.genres.length > 0) {
                for (const genre of movie.genres) {
                    await pool.query(
                        'INSERT INTO film_genres (film_id, genre) VALUES ($1, $2) ON CONFLICT DO NOTHING',
                        [String(movie.id), genre.name]
                    );
                }
            }

            // Countries ekle
            if (movie.production_countries && movie.production_countries.length > 0) {
                for (const country of movie.production_countries) {
                    await pool.query(
                        'INSERT INTO film_countries (film_id, country) VALUES ($1, $2) ON CONFLICT DO NOTHING',
                        [String(movie.id), country.name]
                    );
                }
            }
        }

        return movie;
    } catch (error) {
        console.error('Error fetching film from TMDB:', error);
        throw error;
    }
}

// Film verilerini formatla
async function formatFilm(filmId) {
    const film = await pool.query('SELECT * FROM films WHERE id = $1', [filmId]);
    if (film.rows.length === 0) return null;

    const filmData = film.rows[0];
    
    const genres = await pool.query('SELECT genre FROM film_genres WHERE film_id = $1', [filmId]);
    const countries = await pool.query('SELECT country FROM film_countries WHERE film_id = $1', [filmId]);
    const cast = await pool.query('SELECT actor_name FROM film_cast WHERE film_id = $1 ORDER BY id LIMIT 5', [filmId]);
    
    const likesCount = await pool.query('SELECT COUNT(*) FROM film_likes WHERE film_id = $1', [filmId]);
    const watchedCount = await pool.query('SELECT COUNT(*) FROM film_watched WHERE film_id = $1', [filmId]);
    const watchlistCount = await pool.query('SELECT COUNT(*) FROM film_watchlist WHERE film_id = $1', [filmId]);

    return {
        id: String(filmData.id),
        title: filmData.title,
        original_title: filmData.original_title,
        description: filmData.description,
        poster_url: filmData.poster_url,
        backdrop_url: filmData.backdrop_url,
        release_date: filmData.release_date ? filmData.release_date.toISOString().split('T')[0] : null,
        duration: filmData.duration,
        rating: filmData.rating ? parseFloat(filmData.rating) : null,
        vote_count: filmData.vote_count || 0,
        likes_count: parseInt(likesCount.rows[0].count),
        watched_count: parseInt(watchedCount.rows[0].count),
        watchlist_count: parseInt(watchlistCount.rows[0].count),
        genres: genres.rows.map(r => r.genre),
        countries: countries.rows.map(r => r.country),
        director: filmData.director || null,
        cast: cast.rows.map(r => r.actor_name)
    };
}

// Popüler filmleri getir (veritabanından, en çok oy alanlar)
async function getPopularFilms(req, res) {
    try {
        // Veritabanından en çok oy alan filmleri çek
        const result = await pool.query(`
            SELECT id FROM films 
            WHERE vote_count > 0 
            ORDER BY vote_count DESC, rating DESC 
            LIMIT 50
        `);
        
        const films = [];
        for (const row of result.rows) {
            const formatted = await formatFilm(row.id);
            if (formatted) films.push(formatted);
        }

        res.json({ films });
    } catch (error) {
        console.error('Error getting popular films:', error);
        res.status(500).json({ error: 'Failed to load popular films' });
    }
}

// En yüksek puanlı filmleri getir
async function getTopRatedFilms(req, res) {
    try {
        // Veritabanından en yüksek puanlı filmleri çek
        const result = await pool.query(`
            SELECT id FROM films 
            WHERE rating IS NOT NULL AND vote_count >= 100
            ORDER BY rating DESC, vote_count DESC 
            LIMIT 50
        `);
        
        const films = [];
        for (const row of result.rows) {
            const formatted = await formatFilm(row.id);
            if (formatted) films.push(formatted);
        }

        res.json({ films });
    } catch (error) {
        console.error('Error getting top rated films:', error);
        res.status(500).json({ error: 'Failed to load top rated films' });
    }
}

// Ülkeye göre filmleri getir
async function getCountryFilms(req, res) {
    try {
        const { country } = req.params;
        // TMDB'den ülkeye göre filmleri çek
        const response = await axios.get('https://api.themoviedb.org/3/discover/movie', {
            params: { 
                api_key: tmdbApiKey, 
                with_origin_country: country,
                page: 1
            }
        });

        const films = [];
        for (const movie of response.data.results.slice(0, 20)) {
            await fetchAndStoreFilm(movie.id);
            const formatted = await formatFilm(String(movie.id));
            if (formatted) films.push(formatted);
        }

        res.json({ films });
    } catch (error) {
        console.error('Error getting country films:', error);
        res.status(500).json({ error: 'Failed to load country films' });
    }
}

// Tüm filmleri getir
async function getAllFilms(req, res) {
    try {
        const result = await pool.query(`
            SELECT id FROM films 
            ORDER BY vote_count DESC, rating DESC, created_at DESC 
            LIMIT 100
        `);
        const films = [];
        for (const row of result.rows) {
            const formatted = await formatFilm(row.id);
            if (formatted) films.push(formatted);
        }
        res.json({ films });
    } catch (error) {
        console.error('Error getting all films:', error);
        res.status(500).json({ error: 'Failed to load films' });
    }
}

// Film detayını getir
async function getFilmDetail(req, res) {
    try {
        const { id } = req.params;
        const formatted = await formatFilm(id);
        
        if (!formatted) {
            // TMDB'den çekmeyi dene
            try {
                await fetchAndStoreFilm(parseInt(id));
                const formatted2 = await formatFilm(id);
                if (formatted2) {
                    return res.json({ film: formatted2 });
                }
            } catch (e) {
                // Ignore
            }
            return res.status(404).json({ error: 'Film not found' });
        }

        res.json({ film: formatted });
    } catch (error) {
        console.error('Error getting film detail:', error);
        res.status(500).json({ error: 'Failed to load film detail' });
    }
}

// Filmi beğen
async function likeFilm(req, res) {
    try {
        const { id } = req.params;
        const userId = req.user?.id; // Auth middleware'den gelecek

        if (!userId) {
            return res.status(401).json({ error: 'Unauthorized' });
        }

        // Film var mı kontrol et
        const film = await pool.query('SELECT id FROM films WHERE id = $1', [id]);
        if (film.rows.length === 0) {
            return res.status(404).json({ error: 'Film not found' });
        }

        // Zaten beğenilmiş mi kontrol et
        const existing = await pool.query(
            'SELECT * FROM film_likes WHERE film_id = $1 AND user_id = $2',
            [id, userId]
        );

        if (existing.rows.length > 0) {
            // Beğeniyi kaldır
            await pool.query(
                'DELETE FROM film_likes WHERE film_id = $1 AND user_id = $2',
                [id, userId]
            );
            res.json({ message: 'Like removed' });
        } else {
            // Beğen
            await pool.query(
                'INSERT INTO film_likes (film_id, user_id) VALUES ($1, $2)',
                [id, userId]
            );
            res.json({ message: 'Film liked' });
        }
    } catch (error) {
        console.error('Error liking film:', error);
        res.status(500).json({ error: 'Failed to like film' });
    }
}

// Filmi izlendi olarak işaretle
async function watchFilm(req, res) {
    try {
        const { id } = req.params;
        const userId = req.user?.id;

        if (!userId) {
            return res.status(401).json({ error: 'Unauthorized' });
        }

        const film = await pool.query('SELECT id FROM films WHERE id = $1', [id]);
        if (film.rows.length === 0) {
            return res.status(404).json({ error: 'Film not found' });
        }

        const existing = await pool.query(
            'SELECT * FROM film_watched WHERE film_id = $1 AND user_id = $2',
            [id, userId]
        );

        if (existing.rows.length > 0) {
            await pool.query(
                'DELETE FROM film_watched WHERE film_id = $1 AND user_id = $2',
                [id, userId]
            );
            res.json({ message: 'Watched removed' });
        } else {
            await pool.query(
                'INSERT INTO film_watched (film_id, user_id) VALUES ($1, $2)',
                [id, userId]
            );
            res.json({ message: 'Film marked as watched' });
        }
    } catch (error) {
        console.error('Error watching film:', error);
        res.status(500).json({ error: 'Failed to mark film as watched' });
    }
}

// Filmi watchlist'e ekle
async function addToWatchlist(req, res) {
    try {
        const { id } = req.params;
        const userId = req.user?.id;

        if (!userId) {
            return res.status(401).json({ error: 'Unauthorized' });
        }

        const film = await pool.query('SELECT id FROM films WHERE id = $1', [id]);
        if (film.rows.length === 0) {
            return res.status(404).json({ error: 'Film not found' });
        }

        const existing = await pool.query(
            'SELECT * FROM film_watchlist WHERE film_id = $1 AND user_id = $2',
            [id, userId]
        );

        if (existing.rows.length > 0) {
            await pool.query(
                'DELETE FROM film_watchlist WHERE film_id = $1 AND user_id = $2',
                [id, userId]
            );
            res.json({ message: 'Removed from watchlist' });
        } else {
            await pool.query(
                'INSERT INTO film_watchlist (film_id, user_id) VALUES ($1, $2)',
                [id, userId]
            );
            res.json({ message: 'Added to watchlist' });
        }
    } catch (error) {
        console.error('Error adding to watchlist:', error);
        res.status(500).json({ error: 'Failed to add to watchlist' });
    }
}

module.exports = {
    formatFilm,
    getPopularFilms,
    getTopRatedFilms,
    getCountryFilms,
    getAllFilms,
    getFilmDetail,
    likeFilm,
    watchFilm,
    addToWatchlist,
    getMoviesByGenre: async (req, res) => {
        const genreId = req.params.id;
        let allMovies = [];
        try {
            for (let page = 1; page <= 5; page++) {
                const movies = await fetchMoviesByGenre(genreId, page);
                allMovies = allMovies.concat(movies);
            }
            const simplified = allMovies.map(movie => ({
                id: movie.id,
                title: movie.title,
                overview: movie.overview,
                rating: movie.vote_average,
                poster: `https://image.tmdb.org/t/p/w500${movie.poster_path}`
            }));
            res.json(simplified);
        } catch (error) {
            console.error('ERROR! Something went wrong. Code: ', error.message);
            res.status(500).json({ error: 'None data taken!' });
        }
    }
};

