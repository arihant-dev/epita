import React from 'react';
import { Routes, Route, BrowserRouter } from 'react-router-dom';
import Home from './pages/Home';
import MovieDetails from './pages/MovieDetailsPage';
import Login from './pages/Login';
import NotFound from './pages/NotFound';
import PrivateRoute from './routes/PrivateRoute';

function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route  element={<PrivateRoute />}>
          <Route path="/home" element={<Home />} />

        </Route>
        <Route path="/movie/:id" element={<MovieDetails />} />
        <Route path="/login" element={<Login />} />
        <Route path="*" element={<NotFound />} />
      </Routes>
    </BrowserRouter>
    
  );
}

export default App;
