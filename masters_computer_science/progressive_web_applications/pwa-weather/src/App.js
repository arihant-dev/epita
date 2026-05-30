import React, { useState } from 'react'
import { fetchWeather } from './api/fetchWeather'

const App = () => {
  const [cityname, setCityname] = useState('')
  const [weather, setWeather] = useState(null)
  const [error, setError] = useState(null)
  const [lastSearchedCities, setLastSearchedCities] = useState(() => {
    const saved = localStorage.getItem('lastSearchedCities')
    return saved ? JSON.parse(saved) : []
  })
  const [temperatureUnit, setTemperatureUnit] = useState(() => {
    const savedUnit = localStorage.getItem('temperatureUnit')
    return savedUnit ? savedUnit : 'C'
  })

  const fetchData = async (e) => {
    if (e.key === 'Enter') {
      try {
        const data = await fetchWeather(cityname)
        if (!lastSearchedCities.includes(cityname)) {
          setLastSearchedCities([...lastSearchedCities, cityname])
          localStorage.setItem('lastSearchedCities', JSON.stringify([...lastSearchedCities, cityname]))
        }
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
  const listClik = async (city) => {
    try {
      const data = await fetchWeather(city)
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
  function tempUnitChangeButtonClicked() {
    setTemperatureUnit(temperatureUnit === 'C' ? 'F' : 'C')
    localStorage.setItem('temperatureUnit', temperatureUnit === 'C' ? 'F' : 'C')
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
          <p>Temperature: {temperatureUnit === 'C' ? weather.current.temp_c ?? 'N/A' :weather.current.temp_f ?? 'N/A'}°{temperatureUnit}</p>
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
      <div>
          <h3>Last Searched Cities</h3>
          <ul>
            {lastSearchedCities.map((city, index) => (
              <li key={index} onClick={() => listClik(city)}>
                {city}
              </li>
            ))}
          </ul>
        </div>
    <div>
            <button onClick={tempUnitChangeButtonClicked}>
              Toggle Temperature Unit 
            </button>
    </div>
    </div>
  )
}

export default App

