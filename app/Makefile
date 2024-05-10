# Makefile

CONTAINER_NAME="password-generator"
IMAGE_NAME="password-generator"
IMAGE_TAG="v1.0.0"
APP_PORT=5000
EXPOSED_PORT=5000
TARGET_REPO="zayedmahmud/password-generator"

# Build container image & tag
build:
	echo "Building image from Dockerfile..."
	docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .
	docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${TARGET_REPO}:${IMAGE_TAG}
	echo "DONE: Docker image built & tagged as: '${IMAGE_NAME}:${IMAGE_TAG}' & '${TARGET_REPO}:${IMAGE_TAG}'"

# Run named container from image, deleting running container, if any
run: clean
	echo "Run container as (in foreground): ${CONTAINER_NAME}"
	docker run --rm -it --name ${CONTAINER_NAME} -p ${EXPOSED_PORT}:${APP_PORT} ${IMAGE_NAME}:${IMAGE_TAG}

# Run named container (in daemon mode) from image, deleting running container, if any
rund: clean
	echo "Run container as (in background): ${CONTAINER_NAME}"
	docker run -d --name ${CONTAINER_NAME} -p ${EXPOSED_PORT}:${APP_PORT} ${IMAGE_NAME}:${IMAGE_TAG}

# Stop & remove running container
clean:
	echo "Removing container (if any): '${CONTAINER_NAME}'..."
	docker rm -f ${CONTAINER_NAME} 2> /dev/null

# Stop & remove running container and remove image from local cache
clean_all: clean
	echo "Removing image(s) ('${IMAGE_NAME}:${IMAGE_TAG}' &'${TARGET_REPO}:${IMAGE_TAG}') from local cache..."
	docker rmi ${IMAGE_NAME}:${IMAGE_TAG} ${TARGET_REPO}:${IMAGE_TAG}

# Tag & publish image to Docker hub
publish:
	docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${TARGET_REPO}:${IMAGE_TAG}
	docker images | grep ${IMAGE_NAME}
	docker push ${TARGET_REPO}:${IMAGE_TAG}

all: build run