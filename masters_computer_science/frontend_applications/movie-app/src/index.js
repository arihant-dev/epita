import React from 'react';
import ReactDOM from 'react-dom/client';
import './index.css';
import App from './App';
import AppStateProvider from './context/AppStateProvider';

const root = ReactDOM.createRoot(document.getElementById('root'));
root.render(
  <React.StrictMode>
    <AppStateProvider>
    <App />
    </AppStateProvider>
  </React.StrictMode>
);


