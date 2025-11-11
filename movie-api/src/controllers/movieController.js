const { fetchMoviesByGenre } = require('../services/tmdbService');

async function getMoviesByGenre(req, res) {
    const genreId = req.params.id;
    let allMovies = [];

    try{
        for (let page = 1; page <= 5; page++){
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
    }catch (error){
        console.error('ERROR! Something went wrong. Code: ', error.message);
        res.status(500).json({error: 'None data taken!'});
    }
}

module.exports = {
    getMoviesByGenre,
};