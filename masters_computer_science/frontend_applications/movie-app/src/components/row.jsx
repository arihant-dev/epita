import movieTrailer from 'movie-trailer'
import React, { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import YouTube from 'react-youtube'
import "../styles/Row.css"

const Row = ({movies, title, isLarge}) => {
  const [movie, setMovie] = useState({
    movie_id: "",
    title: "",
    release_date: "",
    backdrop_poster: "",
    overview: ""
  })
  const [trailerUrl, setTrailerUrl] = useState("")
  const [showModal, setShowModal] = useState(false)

  const navigate = useNavigate()

  const handlePlayClick = (event) => {
    event.preventDefault()

    if (trailerUrl) {
      setTrailerUrl("")
    } else {
      movieTrailer(movie.title || "").then((url) => {
        console.log(url, movie.title)
        const urlParams = new URLSearchParams(new URL(url).search)
        setTrailerUrl(urlParams.get("v"))
      }).catch((error) => console.log(error))
    }
  }

  const handleViewClick = (event) => {
    event.preventDefault()
    navigate(`/movie/${movie.movie_id}`, {state: {movie}})
  }

  const handleMovieClick = (event, movie) => {
    event.preventDefault();
    setMovie(movie)

    if(trailerUrl){
      setTrailerUrl("")
    }
    setShowModal(!showModal)
  }

 return (
    <div className="row">
      <h2>{title}</h2>
      <div className="row_posters">
        {movies === undefined || movies.length === 0 ? (
          <span>No Movies Foudn</span>
        ) : (
          movies.map((movie) => (
            <img
              key={movie.movie_id}
              className={`row_poster ${isLarge && "row_posterLarger"}`}
              src={isLarge ? movie.poster : movie.backdrop_poster}
              alt={movie.title}
              onClick={(event) => handleMovieClick(event, movie)}
            />
          ))
        )}
      </div>
      {trailerUrl && (
        <YouTube
          videoId={trailerUrl}
          opts={{
            height: "400",
            width: "100%",
            playerVars: {
              autoplay: 1,
            },
          }}
        />
      )}
      {showModal && (
        <div className="movie_options">
          <button
            className="movie_button"
            onClick={(event) => handlePlayClick(event)}
          >
            Play
          </button>
          <button
            className="movie_button"
            onClick={(event) => handleViewClick(event)}
          >
            View
          </button>
        </div>
      )}
    </div>
  );
}

export default Row