import React from 'react';
import { useAuth } from '../context/AuthContext';

const Navbar = () => {
  const { user, logout, isAuthenticated } = useAuth();

  return (
    <nav className="nav">
      <div className="nav-content">
        <h1>Auth Microservices App</h1>
        {isAuthenticated && (
          <div className="nav-buttons">
            <span style={{ color: 'white', marginRight: '10px' }}>
              Welcome, {user?.name}!
            </span>
            <button onClick={logout}>Logout</button>
          </div>
        )}
      </div>
    </nav>
  );
};

export default Navbar;
