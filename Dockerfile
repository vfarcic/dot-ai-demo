FROM qdrant/qdrant:latest

# Copy pre-loaded qdrant data to the container
COPY qdrant_storage/ /qdrant/storage/