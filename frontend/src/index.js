

import React from 'react';
import ReactDOM from 'react-dom/client'; // Updated for React 18
import { UserProvider } from './context/userContext';
import App from './App';
import reportWebVitals from './reportWebVitals';
import './index.css';


const root = ReactDOM.createRoot(document.getElementById('root')); // Use createRoot instead of render
root.render(
  <React.StrictMode>
    <UserProvider>
      <App />
    </UserProvider>
  </React.StrictMode>
);

reportWebVitals();