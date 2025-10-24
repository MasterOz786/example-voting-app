# Authentication Microservices Application

A full-stack microservices application with user authentication features (Login, Signup, and Forgot Password), containerized with Docker and orchestrated with Kubernetes on Minikube.

## 🏗️ Architecture

This application demonstrates a microservices architecture with the following services:

- **Frontend Service**: React application with responsive UI for user interactions
- **Backend Service**: Node.js/Express API for handling user requests and business logic
- **Authentication Service**: Dedicated JWT-based authentication microservice
- **Database Service**: PostgreSQL database for persistent data storage
- **Redis Service**: In-memory data store for session management and caching

## 🚀 Features

### User Authentication
- **Signup**: User registration with email validation
- **Login**: Secure authentication with JWT tokens
- **Forgot Password**: Password reset functionality with secure tokens
- **Session Management**: Redis-based session storage with token blacklisting

### Security Features
- JWT-based authentication with secure token management
- Password hashing using bcrypt
- Rate limiting on authentication endpoints
- CORS protection
- Security headers with Helmet.js
- Input validation and sanitization

### Scalability
- Microservices architecture for independent scaling
- Containerized services with Docker
- Kubernetes orchestration with 3 replicas per service
- Health checks and readiness probes
- Persistent volume storage for databases

## 📋 Prerequisites

Before running this application, ensure you have the following installed:

- [Docker](https://www.docker.com/products/docker-desktop) (v20.10+)
- [Docker Compose](https://docs.docker.com/compose/install/) (v2.0+)
- [Minikube](https://minikube.sigs.k8s.io/docs/start/) (v1.25+)
- [kubectl](https://kubernetes.io/docs/tasks/tools/) (v1.24+)
- [Node.js](https://nodejs.org/) (v18+) - for local development

## 🛠️ Technology Stack

### Frontend
- **React 18**: Modern React with hooks and context
- **React Router**: Client-side routing
- **Axios**: HTTP client for API calls
- **js-cookie**: Cookie management
- **Nginx**: Production web server

### Backend
- **Node.js**: JavaScript runtime
- **Express.js**: Web application framework
- **PostgreSQL**: Relational database
- **Redis**: In-memory data store
- **JWT**: JSON Web Tokens for authentication
- **bcryptjs**: Password hashing
- **Helmet**: Security middleware
- **CORS**: Cross-origin resource sharing

### Infrastructure
- **Docker**: Containerization
- **Docker Compose**: Multi-container orchestration
- **Kubernetes**: Container orchestration
- **Minikube**: Local Kubernetes cluster

## 🚀 Quick Start

### Option 1: Docker Compose (Recommended for Development)

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd MLOps-A2
   ```

2. **Start all services**
   ```bash
   docker-compose up --build
   ```

3. **Access the application**
   - Frontend: http://localhost:3000
   - Backend API: http://localhost:3001
   - Auth Service: http://localhost:3002
   - Database: localhost:5432
   - Redis: localhost:6379

4. **Test the application**
   - Open http://localhost:3000 in your browser
   - Create a new account or use the test account:
     - Email: `test@example.com`
     - Password: `test123`

### Option 2: Kubernetes with Minikube

1. **Start Minikube**
   ```bash
   minikube start
   ```

2. **Build Docker images in Minikube**
   ```bash
   # Set Docker environment to use Minikube's Docker daemon
   eval $(minikube docker-env)
   
   # Build images
   docker build -t auth-frontend:latest ./frontend
   docker build -t auth-backend:latest ./backend
   docker build -t auth-service:latest ./auth-service
   ```

3. **Deploy to Kubernetes**
   ```bash
   # Create persistent volumes and config maps
   kubectl apply -f k8s-specifications/persistent-volumes.yaml
   kubectl apply -f k8s-specifications/db-init-configmap.yaml
   
   # Deploy all services
   kubectl apply -f k8s-specifications/
   ```

4. **Check deployment status**
   ```bash
   kubectl get pods
   kubectl get services
   ```

5. **Access the application**
   ```bash
   # Get the frontend URL
   minikube service frontend-service --url
   ```

6. **Clean up**
   ```bash
   kubectl delete -f k8s-specifications/
   ```

## 📁 Project Structure

```
MLOps-A2/
├── frontend/                 # React frontend application
│   ├── public/
│   ├── src/
│   │   ├── components/      # React components
│   │   ├── context/         # React context for state management
│   │   └── App.js
│   ├── Dockerfile
│   └── package.json
├── backend/                  # Node.js backend API
│   ├── config/              # Database configuration
│   ├── middleware/          # Express middleware
│   ├── routes/              # API routes
│   ├── Dockerfile
│   └── package.json
├── auth-service/            # Dedicated authentication service
│   ├── config/              # Database and Redis configuration
│   ├── routes/              # Authentication routes
│   ├── Dockerfile
│   └── package.json
├── database/                # Database initialization scripts
│   └── init.sql
├── k8s-specifications/      # Kubernetes YAML files
│   ├── frontend-deployment.yaml
│   ├── frontend-service.yaml
│   ├── backend-deployment.yaml
│   ├── backend-service.yaml
│   ├── auth-service-deployment.yaml
│   ├── auth-service-service.yaml
│   ├── db-deployment.yaml
│   ├── db-service.yaml
│   ├── redis-deployment.yaml
│   ├── redis-service.yaml
│   ├── persistent-volumes.yaml
│   └── db-init-configmap.yaml
├── healthchecks/            # Health check scripts
├── docker-compose.yml       # Docker Compose configuration
└── README.md
```

## 🔧 Configuration

### Environment Variables

#### Frontend
- `REACT_APP_API_URL`: Backend API URL
- `REACT_APP_AUTH_URL`: Authentication service URL

#### Backend & Auth Service
- `NODE_ENV`: Environment (development/production)
- `PORT`: Service port
- `DB_HOST`: Database host
- `DB_PORT`: Database port
- `DB_NAME`: Database name
- `DB_USER`: Database user
- `DB_PASSWORD`: Database password
- `JWT_SECRET`: JWT signing secret
- `REDIS_URL`: Redis connection URL
- `FRONTEND_URL`: Frontend URL for CORS

### Database Schema

#### Users Table
```sql
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    reset_token VARCHAR(255),
    reset_token_expires TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

#### Password Resets Table
```sql
CREATE TABLE password_resets (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL,
    token VARCHAR(255) NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    used BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

#### Sessions Table
```sql
CREATE TABLE sessions (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    token_jti VARCHAR(255) UNIQUE NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## 🔍 API Endpoints

### Authentication Service (Port 3002)

#### POST /auth/signup
Register a new user
```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "password123"
}
```

#### POST /auth/login
Authenticate user
```json
{
  "email": "john@example.com",
  "password": "password123"
}
```

#### GET /auth/verify
Verify JWT token (requires Authorization header)

#### POST /auth/logout
Logout user (requires Authorization header)

#### POST /auth/forgot-password
Request password reset
```json
{
  "email": "john@example.com"
}
```

#### POST /auth/reset-password
Reset password with token
```json
{
  "token": "reset-token",
  "password": "newpassword123"
}
```

### Backend Service (Port 3001)

#### GET /health
Health check endpoint

#### GET /users/profile
Get current user profile (requires authentication)

#### PUT /users/profile
Update user profile (requires authentication)

#### GET /users
Get all users (requires authentication)

## 🐳 Docker Commands

### Build Images
```bash
# Build all images
docker-compose build

# Build specific service
docker-compose build frontend
docker-compose build backend
docker-compose build auth-service
```

### Run Services
```bash
# Start all services
docker-compose up

# Start in background
docker-compose up -d

# Start specific service
docker-compose up frontend
```

### View Logs
```bash
# View all logs
docker-compose logs

# View specific service logs
docker-compose logs frontend
docker-compose logs backend
docker-compose logs auth-service
```

### Stop Services
```bash
# Stop all services
docker-compose down

# Stop and remove volumes
docker-compose down -v
```

## ☸️ Kubernetes Commands

### Deploy Application
```bash
# Deploy all resources
kubectl apply -f k8s-specifications/

# Deploy specific resource
kubectl apply -f k8s-specifications/frontend-deployment.yaml
```

### Check Status
```bash
# Check pods
kubectl get pods

# Check services
kubectl get services

# Check deployments
kubectl get deployments

# Check persistent volumes
kubectl get pv,pvc
```

### View Logs
```bash
# View pod logs
kubectl logs <pod-name>

# View logs with follow
kubectl logs -f <pod-name>

# View logs from all containers in deployment
kubectl logs deployment/<deployment-name>
```

### Scale Services
```bash
# Scale deployment
kubectl scale deployment frontend-deployment --replicas=5

# Scale all deployments
kubectl scale deployment --all --replicas=3
```

### Access Services
```bash
# Port forward to access service locally
kubectl port-forward service/frontend-service 3000:80

# Get service URL in Minikube
minikube service frontend-service --url
```

### Clean Up
```bash
# Delete all resources
kubectl delete -f k8s-specifications/

# Delete specific resource
kubectl delete -f k8s-specifications/frontend-deployment.yaml
```

## 🔧 Troubleshooting

### Common Issues

#### 1. Database Connection Issues
```bash
# Check database pod status
kubectl get pods -l app=db

# Check database logs
kubectl logs -l app=db

# Test database connection
kubectl exec -it <db-pod-name> -- psql -U postgres -d postgres
```

#### 2. Frontend Not Loading
```bash
# Check frontend pod status
kubectl get pods -l app=frontend

# Check frontend logs
kubectl logs -l app=frontend

# Check service endpoints
kubectl get endpoints frontend-service
```

#### 3. Authentication Issues
```bash
# Check auth service logs
kubectl logs -l app=auth-service

# Check Redis connection
kubectl exec -it <redis-pod-name> -- redis-cli ping
```

#### 4. Persistent Volume Issues
```bash
# Check persistent volumes
kubectl get pv,pvc

# Check volume mounts
kubectl describe pod <pod-name>
```

### Health Checks

All services include health check endpoints:
- Frontend: `GET /`
- Backend: `GET /health`
- Auth Service: `GET /health`
- Database: `pg_isready` command
- Redis: `redis-cli ping` command

### Monitoring

```bash
# Check resource usage
kubectl top pods
kubectl top nodes

# Check events
kubectl get events --sort-by=.metadata.creationTimestamp

# Check service status
kubectl get services -o wide
```

## 🧪 Testing

### Manual Testing

1. **Signup Flow**
   - Navigate to http://localhost:3000
   - Click "Sign Up"
   - Fill in the form with valid data
   - Verify account creation

2. **Login Flow**
   - Use created credentials to login
   - Verify JWT token is stored in cookies
   - Check dashboard access

3. **Forgot Password Flow**
   - Click "Forgot Password"
   - Enter email address
   - Check console logs for reset token
   - Use token to reset password

4. **Logout Flow**
   - Click logout button
   - Verify token is invalidated
   - Check redirect to login page

### API Testing

Use tools like Postman or curl to test API endpoints:

```bash
# Test health endpoint
curl http://localhost:3001/health

# Test signup
curl -X POST http://localhost:3002/auth/signup \
  -H "Content-Type: application/json" \
  -d '{"name":"Test User","email":"test@example.com","password":"password123"}'

# Test login
curl -X POST http://localhost:3002/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123"}'
```

## 📊 Performance Considerations

### Scaling
- Each service can be scaled independently
- Frontend: 3 replicas (can be increased based on load)
- Backend: 3 replicas (can be increased based on API load)
- Auth Service: 3 replicas (can be increased based on auth load)
- Database: 1 replica (PostgreSQL primary)
- Redis: 1 replica (can be clustered for high availability)

### Resource Limits
- Frontend: 256Mi memory, 200m CPU
- Backend: 512Mi memory, 500m CPU
- Auth Service: 512Mi memory, 500m CPU
- Database: 512Mi memory, 500m CPU
- Redis: 256Mi memory, 200m CPU

### Optimization
- Use Redis for session caching
- Implement database connection pooling
- Add CDN for frontend static assets
- Use horizontal pod autoscaling (HPA)
- Implement circuit breakers for service communication

## 🔒 Security Best Practices

### Implemented Security Features
- JWT tokens with expiration
- Password hashing with bcrypt
- Rate limiting on authentication endpoints
- CORS protection
- Security headers with Helmet
- Input validation and sanitization
- SQL injection prevention with parameterized queries

### Additional Security Recommendations
- Use HTTPS in production
- Implement API rate limiting
- Add request logging and monitoring
- Use secrets management for sensitive data
- Implement RBAC (Role-Based Access Control)
- Regular security audits and dependency updates

## 📈 Monitoring and Logging

### Logging
- Structured logging with timestamps
- Error tracking and reporting
- Request/response logging
- Health check logging

### Monitoring
- Kubernetes health checks
- Resource usage monitoring
- Service availability monitoring
- Database performance monitoring

### Recommended Tools
- Prometheus for metrics collection
- Grafana for visualization
- ELK Stack for log aggregation
- Jaeger for distributed tracing

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Ensure all tests pass
6. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

For support and questions:
- Create an issue in the repository
- Check the troubleshooting section
- Review the logs for error messages
- Ensure all prerequisites are installed

## 🎯 Future Enhancements

- [ ] Add user roles and permissions
- [ ] Implement email notifications
- [ ] Add two-factor authentication
- [ ] Implement API versioning
- [ ] Add comprehensive test suite
- [ ] Implement CI/CD pipeline
- [ ] Add monitoring and alerting
- [ ] Implement backup and recovery
- [ ] Add API documentation with Swagger
- [ ] Implement caching strategies