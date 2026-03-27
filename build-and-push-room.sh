#!/bin/bash
set -e

ECR_REPO="457806912465.dkr.ecr.eu-west-1.amazonaws.com/showcase/excalidraw-room:latest"

echo "Logging into ECR..."
aws ecr get-login-password --region eu-west-1 | docker login --username AWS --password-stdin 457806912465.dkr.ecr.eu-west-1.amazonaws.com

echo "Building and pushing excalidraw-room (ARM64)..."
docker buildx build --platform linux/arm64 -f - -t "$ECR_REPO" --push . <<'DOCKERFILE'
FROM node:20-alpine
WORKDIR /excalidraw-room
RUN apk add --no-cache git && \
    git clone --depth 1 https://github.com/excalidraw/excalidraw-room.git .
RUN yarn
RUN yarn build
ENV PORT=80
EXPOSE 80
CMD ["yarn", "start"]
DOCKERFILE

echo "Done. Image pushed to $ECR_REPO"
