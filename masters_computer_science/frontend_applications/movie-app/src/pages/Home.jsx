import React from 'react'
import Navbar from '../components/navbar'
import Banner from '../components/banner'
import Row from '../components/row'
import { useEffect, useState } from 'react'
import { movieApi } from '../constants/axios'
import { movieRequests } from '../constants/request'

const Home = () => {

  const [movies, setMovies] = useState([])
  useEffect(() => {
    const fetchData = async () => {
      try {
        const request = await movieApi.get(movieRequests.fetchAllMovies)
        setMovies(request.data.movies)
      } catch (error) {
        console.log(error)
      }
    }

    fetchData()
  }, [])
  return (
    <div>
      < Navbar />
      < Banner />

      {Object.keys(movies).map((category) => (
        <Row key={category} title={category} movies={movies[category]}/>
      ))}
    </div>
  )
}

export default Home
