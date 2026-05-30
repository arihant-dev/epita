import React, { useState } from 'react'
import { fetchWeather } from './api/fetchWeather'

const App = () => {
  const [cityname, setCityname] = useState('')
  const [weather, setWeather] = useState(null)
  const [error, setError] = useState(null)

  const fetchData = async (e) => {
    if (e.key === 'Enter') {
      try {
        const data = await fetchWeather(cityname)
        if (data.error) {
          setError(data.error.message)
        } else {
          setWeather(data)
          setCityname('')
          setError(null)
        }
      } catch (err) {
        setError(err.message)
      }
    }
  }
  return (
    <div>
      <input
        type="text"
        placeholder="Enter city name"
        value={cityname}
        onChange={(e) => setCityname(e.target.value)}
        onKeyDown={fetchData}
      />
      {error && <p style={{color: 'red'}}>{error}</p>}
      {weather && (
        <div>
          <h2>{weather.location.name}, {weather.location.country}</h2>
          <p>Temperature: {weather.current.temp_c ?? 'N/A'}°C</p>
          <p>Latitude: {weather.location.lat ?? 'N/A'}</p>
          <p>Longitude: {weather.location.lon ?? 'N/A'}</p>
          <p>Condition: {weather.current.condition?.text}</p>
          <img src={weather.current.condition?.icon} alt={weather.current.condition?.text} />
          <p>Humidity: {weather.current.humidity ?? 'N/A'}%</p>
          <p>Wind Speed: {weather.current.wind_kph ?? 'N/A'} km/h</p>
          <p>Pressure: {weather.current.pressure_mb ?? 'N/A'} mb</p>
          <p>Last Updated: {weather.current.last_updated}</p>
        </div>
      )}
    </div>
  )
}

export default App

