#!/bin/bash

# Authentication Microservices Deployment Script
# This script helps deploy the application using Docker Compose or Kubernetes

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    if ! command_exists docker; then
        print_error "Docker is not installed. Please install Docker first."
        exit 1
    fi
    
    if ! command_exists docker-compose; then
        print_error "Docker Compose is not installed. Please install Docker Compose first."
        exit 1
    fi
    
    print_success "All prerequisites are installed."
}

# Function to check Kubernetes prerequisites
check_k8s_prerequisites() {
    print_status "Checking Kubernetes prerequisites..."
    
    if ! command_exists kubectl; then
        print_error "kubectl is not installed. Please install kubectl first."
        exit 1
    fi
    
    if ! command_exists minikube; then
        print_error "Minikube is not installed. Please install Minikube first."
        exit 1
    fi
    
    print_success "All Kubernetes prerequisites are installed."
}

# Function to deploy with Docker Compose
deploy_docker_compose() {
    print_status "Deploying with Docker Compose..."
    
    # Stop any existing containers
    print_status "Stopping existing containers..."
    docker-compose down -v 2>/dev/null || true
    
    # Build and start services
    print_status "Building and starting services..."
    docker-compose up --build -d
    
    # Wait for services to be ready
    print_status "Waiting for services to be ready..."
    sleep 30
    
    # Check service health
    print_status "Checking service health..."
    
    # Check frontend
    if curl -f http://localhost:3000 >/dev/null 2>&1; then
        print_success "Frontend is running at http://localhost:3000"
    else
        print_warning "Frontend may not be ready yet. Check logs with: docker-compose logs frontend"
    fi
    
    # Check backend
    if curl -f http://localhost:3001/health >/dev/null 2>&1; then
        print_success "Backend is running at http://localhost:3001"
    else
        print_warning "Backend may not be ready yet. Check logs with: docker-compose logs backend"
    fi
    
    # Check auth service
    if curl -f http://localhost:3002/health >/dev/null 2>&1; then
        print_success "Auth service is running at http://localhost:3002"
    else
        print_warning "Auth service may not be ready yet. Check logs with: docker-compose logs auth-service"
    fi
    
    print_success "Docker Compose deployment completed!"
    print_status "Access the application at: http://localhost:3000"
    print_status "Test account: test@example.com / test123"
}

# Function to deploy with Kubernetes
deploy_kubernetes() {
    print_status "Deploying with Kubernetes on Minikube..."
    
    # Start Minikube if not running
    if ! minikube status >/dev/null 2>&1; then
        print_status "Starting Minikube..."
        minikube start
    fi
    
    # Set Docker environment to use Minikube's Docker daemon
    print_status "Setting up Docker environment for Minikube..."
    eval $(minikube docker-env)
    
    # Build Docker images
    print_status "Building Docker images..."
    docker build -t auth-frontend:latest ./frontend
    docker build -t auth-backend:latest ./backend
    docker build -t auth-service:latest ./auth-service
    
    # Deploy to Kubernetes
    print_status "Deploying to Kubernetes..."
    
    # Create persistent volumes and config maps first
    kubectl apply -f k8s-specifications/persistent-volumes.yaml
    kubectl apply -f k8s-specifications/db-init-configmap.yaml
    
    # Deploy all services
    kubectl apply -f k8s-specifications/
    
    # Wait for deployments to be ready
    print_status "Waiting for deployments to be ready..."
    kubectl wait --for=condition=available --timeout=300s deployment/frontend-deployment
    kubectl wait --for=condition=available --timeout=300s deployment/backend-deployment
    kubectl wait --for=condition=available --timeout=300s deployment/auth-service-deployment
    kubectl wait --for=condition=available --timeout=300s deployment/db-deployment
    kubectl wait --for=condition=available --timeout=300s deployment/redis-deployment
    
    # Get service URLs
    print_status "Getting service URLs..."
    FRONTEND_URL=$(minikube service frontend-service --url)
    
    print_success "Kubernetes deployment completed!"
    print_status "Access the application at: $FRONTEND_URL"
    print_status "Test account: test@example.com / test123"
    
    # Show pod status
    print_status "Pod status:"
    kubectl get pods
}

# Function to show logs
show_logs() {
    if [ "$1" = "k8s" ]; then
        print_status "Showing Kubernetes logs..."
        kubectl get pods
        echo ""
        print_status "To view logs for a specific pod, run:"
        print_status "kubectl logs <pod-name>"
        echo ""
        print_status "To follow logs, run:"
        print_status "kubectl logs -f <pod-name>"
    else
        print_status "Showing Docker Compose logs..."
        docker-compose logs
    fi
}

# Function to clean up
cleanup() {
    if [ "$1" = "k8s" ]; then
        print_status "Cleaning up Kubernetes deployment..."
        kubectl delete -f k8s-specifications/ 2>/dev/null || true
        print_success "Kubernetes cleanup completed!"
    else
        print_status "Cleaning up Docker Compose deployment..."
        docker-compose down -v
        print_success "Docker Compose cleanup completed!"
    fi
}

# Function to show status
show_status() {
    if [ "$1" = "k8s" ]; then
        print_status "Kubernetes deployment status:"
        kubectl get pods
        kubectl get services
        kubectl get deployments
    else
        print_status "Docker Compose deployment status:"
        docker-compose ps
    fi
}

# Main script logic
case "$1" in
    "docker")
        check_prerequisites
        deploy_docker_compose
        ;;
    "k8s"|"kubernetes")
        check_k8s_prerequisites
        deploy_kubernetes
        ;;
    "logs")
        show_logs "$2"
        ;;
    "cleanup")
        cleanup "$2"
        ;;
    "status")
        show_status "$2"
        ;;
    *)
        echo "Authentication Microservices Deployment Script"
        echo ""
        echo "Usage: $0 {docker|k8s|logs|cleanup|status} [docker|k8s]"
        echo ""
        echo "Commands:"
        echo "  docker     Deploy using Docker Compose"
        echo "  k8s        Deploy using Kubernetes on Minikube"
        echo "  logs       Show logs (specify 'docker' or 'k8s')"
        echo "  cleanup    Clean up deployment (specify 'docker' or 'k8s')"
        echo "  status     Show deployment status (specify 'docker' or 'k8s')"
        echo ""
        echo "Examples:"
        echo "  $0 docker              # Deploy with Docker Compose"
        echo "  $0 k8s                 # Deploy with Kubernetes"
        echo "  $0 logs docker         # Show Docker Compose logs"
        echo "  $0 logs k8s            # Show Kubernetes logs"
        echo "  $0 cleanup docker      # Clean up Docker Compose"
        echo "  $0 cleanup k8s         # Clean up Kubernetes"
        echo "  $0 status docker       # Show Docker Compose status"
        echo "  $0 status k8s          # Show Kubernetes status"
        echo ""
        echo "Prerequisites:"
        echo "  Docker Compose: Docker, Docker Compose"
        echo "  Kubernetes: Docker, kubectl, Minikube"
        exit 1
        ;;
esac
