import React from 'react';
import { useAuth } from '../context/AuthContext';

const Dashboard = () => {
  const { user } = useAuth();

  return (
    <div className="dashboard">
      <h2>Dashboard</h2>
      <div className="user-info">
        <h3>Welcome to your dashboard!</h3>
        <p><strong>Name:</strong> {user?.name}</p>
        <p><strong>Email:</strong> {user?.email}</p>
        <p><strong>User ID:</strong> {user?.id}</p>
        <p><strong>Account Created:</strong> {new Date(user?.createdAt).toLocaleDateString()}</p>
      </div>
      
      <div className="user-info">
        <h3>Microservices Architecture</h3>
        <p>This application demonstrates a full-stack microservices architecture with:</p>
        <ul>
          <li><strong>Frontend Service:</strong> React application (this service)</li>
          <li><strong>Backend Service:</strong> Node.js/Express API</li>
          <li><strong>Authentication Service:</strong> JWT-based authentication</li>
          <li><strong>Database Service:</strong> PostgreSQL database</li>
        </ul>
        <p>All services are containerized with Docker and orchestrated with Kubernetes on Minikube.</p>
      </div>
    </div>
  );
};

export default Dashboard;
