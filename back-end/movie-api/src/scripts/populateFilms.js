// populateFilms.js - TMDB'den popüler ve top rated filmleri çekip veritabanına kaydeder
const pool = require('../db');
const axios = require('axios');
const { tmdbApiKey } = require('../config');

// TMDB'den film detaylarını çek
async function fetchMovieDetails(tmdbId) {
    try {
        const response = await axios.get(`https://api.themoviedb.org/3/movie/${tmdbId}`, {
            params: { 
                api_key: tmdbApiKey,
                append_to_response: 'credits'
            }
        });
        return response.data;
    } catch (error) {
        console.error(`Error fetching movie ${tmdbId}:`, error.message);
        return null;
    }
}

// Film verilerini veritabanına kaydet
async function storeFilm(movie) {
    try {
        // Film zaten var mı kontrol et
        const existing = await pool.query('SELECT id FROM films WHERE tmdb_id = $1', [movie.id]);
        
        if (existing.rows.length > 0) {
            // Güncelle
            await pool.query(`
                UPDATE films 
                SET title = $1, original_title = $2, description = $3, 
                    poster_url = $4, backdrop_url = $5, release_date = $6, 
                    duration = $7, rating = $8, vote_count = $9, updated_at = CURRENT_TIMESTAMP
                WHERE tmdb_id = $10
            `, [
                movie.title,
                movie.original_title,
                movie.overview,
                movie.poster_path ? `https://image.tmdb.org/t/p/w500${movie.poster_path}` : null,
                movie.backdrop_path ? `https://image.tmdb.org/t/p/w500${movie.backdrop_path}` : null,
                movie.release_date || null,
                movie.runtime || null,
                movie.vote_average || null,
                movie.vote_count || 0,
                movie.id
            ]);
        } else {
            // Yeni film ekle
            await pool.query(`
                INSERT INTO films (id, title, original_title, description, poster_url, backdrop_url, 
                    release_date, duration, rating, tmdb_id, vote_count)
                VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
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
                movie.id,
                movie.vote_count || 0
            ]);
        }

        // Genres ekle/güncelle
        if (movie.genres && movie.genres.length > 0) {
            // Önce mevcut genre'leri sil
            await pool.query('DELETE FROM film_genres WHERE film_id = $1', [String(movie.id)]);
            // Yeni genre'leri ekle
            for (const genre of movie.genres) {
                await pool.query(
                    'INSERT INTO film_genres (film_id, genre) VALUES ($1, $2) ON CONFLICT DO NOTHING',
                    [String(movie.id), genre.name]
                );
            }
        }

        // Countries ekle/güncelle
        if (movie.production_countries && movie.production_countries.length > 0) {
            // Önce mevcut ülkeleri sil
            await pool.query('DELETE FROM film_countries WHERE film_id = $1', [String(movie.id)]);
            // Yeni ülkeleri ekle
            for (const country of movie.production_countries) {
                await pool.query(
                    'INSERT INTO film_countries (film_id, country) VALUES ($1, $2) ON CONFLICT DO NOTHING',
                    [String(movie.id), country.name]
                );
            }
        }

        // Director ekle
        if (movie.credits && movie.credits.crew) {
            const director = movie.credits.crew.find(person => person.job === 'Director');
            if (director) {
                await pool.query(
                    'UPDATE films SET director = $1 WHERE id = $2',
                    [director.name, String(movie.id)]
                );
            }
        }

        // Cast ekle (ilk 5 oyuncu)
        if (movie.credits && movie.credits.cast) {
            // Önce mevcut cast'i sil
            await pool.query('DELETE FROM film_cast WHERE film_id = $1', [String(movie.id)]);
            // İlk 5 oyuncuyu ekle
            const topCast = movie.credits.cast.slice(0, 5);
            for (const actor of topCast) {
                await pool.query(
                    'INSERT INTO film_cast (film_id, actor_name) VALUES ($1, $2) ON CONFLICT DO NOTHING',
                    [String(movie.id), actor.name]
                );
            }
        }

        return true;
    } catch (error) {
        console.error(`Error storing film ${movie.id}:`, error.message);
        return false;
    }
}

// TMDB'den film listesi çek
async function fetchMoviesFromTMDB(endpoint, pages = 5) {
    const allMovies = [];
    try {
        for (let page = 1; page <= pages; page++) {
            const response = await axios.get(`https://api.themoviedb.org/3/movie/${endpoint}`, {
                params: {
                    api_key: tmdbApiKey,
                    page: page,
                    language: 'en-US'
                }
            });
            allMovies.push(...response.data.results);
            console.log(`Fetched page ${page} of ${endpoint} (${response.data.results.length} movies)`);
            // Rate limiting için kısa bekleme
            await new Promise(resolve => setTimeout(resolve, 250));
        }
    } catch (error) {
        console.error(`Error fetching ${endpoint}:`, error.message);
    }
    return allMovies;
}

// Ana fonksiyon
(async () => {
    try {
        console.log('🚀 TMDB film verilerini çekmeye başlıyor...\n');

        // 1. Popüler filmleri çek
        console.log('📽️  Popüler filmler çekiliyor...');
        const popularMovies = await fetchMoviesFromTMDB('popular', 10);
        console.log(`✓ ${popularMovies.length} popüler film bulundu\n`);

        // 2. Top rated filmleri çek
        console.log('⭐ En yüksek puanlı filmler çekiliyor...');
        const topRatedMovies = await fetchMoviesFromTMDB('top_rated', 10);
        console.log(`✓ ${topRatedMovies.length} top rated film bulundu\n`);

        // 3. Now playing filmleri çek
        console.log('🎬 Şu anda gösterimde olan filmler çekiliyor...');
        const nowPlayingMovies = await fetchMoviesFromTMDB('now_playing', 5);
        console.log(`✓ ${nowPlayingMovies.length} now playing film bulundu\n`);

        // Tüm film ID'lerini birleştir ve tekrarları kaldır
        const allMovieIds = [...new Set([
            ...popularMovies.map(m => m.id),
            ...topRatedMovies.map(m => m.id),
            ...nowPlayingMovies.map(m => m.id)
        ])];

        console.log(`📊 Toplam ${allMovieIds.length} benzersiz film işlenecek\n`);

        // Her film için detayları çek ve kaydet
        let successCount = 0;
        let failCount = 0;

        for (let i = 0; i < allMovieIds.length; i++) {
            const movieId = allMovieIds[i];
            console.log(`[${i + 1}/${allMovieIds.length}] Film ${movieId} işleniyor...`);
            
            const movieDetails = await fetchMovieDetails(movieId);
            if (movieDetails) {
                const stored = await storeFilm(movieDetails);
                if (stored) {
                    successCount++;
                    console.log(`  ✓ ${movieDetails.title} kaydedildi`);
                } else {
                    failCount++;
                    console.log(`  ✗ ${movieId} kaydedilemedi`);
                }
            } else {
                failCount++;
                console.log(`  ✗ ${movieId} çekilemedi`);
            }

            // Rate limiting
            await new Promise(resolve => setTimeout(resolve, 250));
        }

        console.log('\n✅ İşlem tamamlandı!');
        console.log(`✓ Başarılı: ${successCount}`);
        console.log(`✗ Başarısız: ${failCount}`);
        console.log(`📊 Toplam: ${allMovieIds.length}`);

        await pool.end();
        process.exit(0);
    } catch (error) {
        console.error('❌ Hata:', error);
        await pool.end();
        process.exit(1);
    }
})();

