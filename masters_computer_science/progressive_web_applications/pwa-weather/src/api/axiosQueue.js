import axios from 'axios'

let queue = []
let isProcessing = false

const axiosInstance = axios.create()

axiosInstance.interceptors.request.use(
    config => config,
    error => Promise.reject(error)
)

axiosInstance.interceptors.response.use(
    response => response,
    error => {
        if (!navigator.onLine && error.config) {
            queue.push(error.config)
            return new Promise(() => {})
        }
        return Promise.reject(error)
    }
)


const processQueue = async () => {
    if (isProcessing || queue.length === 0) return

    isProcessing = true

    let lastResponse = null
    while (queue.length > 0) {
        const config = queue.shift()
        try {
            const response = await axiosInstance(config)
            lastResponse = response.data
        } catch (err) {
            console.error('Error processing queued request:', err)
        }
    }

    if (lastResponse) {
        localStorage.setItem('lastApiResponse', JSON.stringify(lastResponse))
        window.dispatchEvent(new CustomEvent('apiResponseUpdated', { detail: lastResponse }))
    }

    isProcessing = false
}
window.addEventListener('online', processQueue)


export default axiosInstance