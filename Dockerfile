# Dockerfile for both frontend and backend

### Frontend Stage ###
FROM node:14 as frontend

# Set working directory for frontend
WORKDIR /super-resolution-master/frontend

# Copy the entire frontend source code
COPY frontend/srgan-website/ .

### Backend Stage ###
FROM tensorflow/serving as backend

# Set working directory for backend
WORKDIR /super-resolution-master/backend

# Create a directory for the SRGAN model
RUN mkdir -p /models/srgan/1

# Copy the contents of backend/tmp/srgan/1 to the SRGAN model directory
COPY backend/tmp/srgan/1 /models/srgan/1

# Expose the port for TensorFlow Serving
EXPOSE 8501

# Define environment variable for the model name
ENV MODEL_NAME=srgan

# Command to run TensorFlow Serving
CMD ["tensorflow_model_server", "--port=8501", "--model_name=srgan", "--model_base_path=/models/srgan"]

### Final Stage ###
FROM nginx:alpine

# Set working directory for final stage
WORKDIR /usr/share/nginx/html

# Copy the built frontend code to Nginx
COPY --from=frontend /super-resolution-master/frontend/ .

# Copy Nginx configuration
COPY frontend/nginx.conf /etc/nginx/conf.d/default.conf

# Expose port
EXPOSE 3000
