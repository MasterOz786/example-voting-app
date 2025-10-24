# Quick Start Guide

## 🚀 Get Started in 5 Minutes

### Prerequisites
- Docker and Docker Compose installed
- OR Minikube, kubectl, and Docker installed (for Kubernetes)

### Option 1: Docker Compose (Recommended)

1. **Clone and Deploy**
   ```bash
   git clone <repository-url>
   cd MLOps-A2
   ./deploy.sh docker
   ```

2. **Access Application**
   - Open http://localhost:3000 in your browser
   - Use test account: `test@example.com` / `test123`

3. **Test the Application**
   ```bash
   ./test.sh
   ```

### Option 2: Kubernetes with Minikube

1. **Deploy to Kubernetes**
   ```bash
   ./deploy.sh k8s
   ```

2. **Access Application**
   - The script will show you the Minikube service URL
   - Use test account: `test@example.com` / `test123`

3. **Test the Application**
   ```bash
   ./test.sh custom <minikube-url> <backend-url> <auth-url>
   ```

## 🧪 Test Features

### User Authentication
- **Signup**: Create a new account
- **Login**: Authenticate with credentials
- **Forgot Password**: Reset password functionality
- **Dashboard**: Protected user dashboard

### API Testing
```bash
# Test health endpoints
curl http://localhost:3001/health
curl http://localhost:3002/health

# Test authentication
curl -X POST http://localhost:3002/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"test123"}'
```

## 🔧 Management Commands

### Docker Compose
```bash
# View logs
./deploy.sh logs docker

# Check status
./deploy.sh status docker

# Clean up
./deploy.sh cleanup docker
```

### Kubernetes
```bash
# View logs
./deploy.sh logs k8s

# Check status
./deploy.sh status k8s

# Clean up
./deploy.sh cleanup k8s
```

## 📊 Architecture Overview

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│  Frontend   │    │   Backend   │    │ Auth Service│
│  (React)    │───▶│ (Node.js)   │───▶│ (Node.js)   │
│  Port: 3000 │    │ Port: 3001  │    │ Port: 3002  │
└─────────────┘    └─────────────┘    └─────────────┘
                           │                   │
                           ▼                   ▼
                    ┌─────────────┐    ┌─────────────┐
                    │ PostgreSQL  │    │    Redis    │
                    │ Port: 5432  │    │ Port: 6379  │
                    └─────────────┘    └─────────────┘
```

## 🎯 Key Features Demonstrated

- ✅ **Microservices Architecture**: Separate services for frontend, backend, auth, and database
- ✅ **User Authentication**: Complete auth flow with JWT tokens
- ✅ **Containerization**: Docker containers for all services
- ✅ **Orchestration**: Kubernetes deployment with 3 replicas
- ✅ **Security**: Password hashing, rate limiting, CORS protection
- ✅ **Scalability**: Independent service scaling
- ✅ **Monitoring**: Health checks and logging
- ✅ **Persistence**: Database and Redis storage

## 🆘 Troubleshooting

### Common Issues

1. **Port conflicts**: Make sure ports 3000, 3001, 3002, 5432, 6379 are available
2. **Docker not running**: Start Docker Desktop
3. **Minikube issues**: Run `minikube start` and `minikube status`
4. **Permission issues**: Make sure scripts are executable (`chmod +x *.sh`)

### Get Help
- Check logs: `./deploy.sh logs docker` or `./deploy.sh logs k8s`
- View status: `./deploy.sh status docker` or `./deploy.sh status k8s`
- Run tests: `./test.sh` to verify functionality

## 📚 Next Steps

1. **Explore the Code**: Check out the source code in each service directory
2. **Modify Features**: Add new authentication features or UI components
3. **Scale Services**: Increase replicas in Kubernetes YAML files
4. **Add Monitoring**: Integrate with Prometheus and Grafana
5. **CI/CD Pipeline**: Set up automated deployment pipeline

## 🎓 Learning Objectives Achieved

This project demonstrates:
- Full-stack microservices development
- Container orchestration with Kubernetes
- User authentication and security
- Database design and management
- API development and testing
- DevOps practices and deployment
- Monitoring and health checks
- Scalable architecture patterns

Happy coding! 🚀
