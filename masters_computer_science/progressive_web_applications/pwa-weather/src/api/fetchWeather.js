import axios from 'axios';

const URL = 'https://api.weatherapi.com/v1/current.json'
const API_KEY = process.env.REACT_APP_WEATHER_API_KEY

export const fetchWeather = async (city) => {
    const { data } = await axios.get(URL, {
        params: {
            key: API_KEY,
            q: city,
        }
    });
    console.log('API Response:', data);
    return data;
};

export default fetchWeather;