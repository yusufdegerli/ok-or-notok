const axios = require('axios');
const { tmdbApiKey } = require('../config');

async function fetchMoviesByGenre(genreId, page = 1) {
    const response = await axios.get(`https://api.themoviedb.org/3/discover/movie`, {
        params: {
            api_key: tmdbApiKey,
            with_genres: genreId,
            page: page
        }
    });
    return response.data.results;
}

module.exports = { fetchMoviesByGenre };
