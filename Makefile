IMAGE_REPO ?= open-grid
IMAGE_NAME ?= admission-controller

GIT_HOST ?= github.com/pellepedro

PWD := $(shell pwd)
BASE_DIR := $(shell basename $(PWD))

# Keep an existing GOPATH, make a private one if it is undefined
GOPATH_DEFAULT := $(PWD)/.go
export GOPATH ?= $(GOPATH_DEFAULT)
TESTARGS_DEFAULT := "-v"
export TESTARGS ?= $(TESTARGS_DEFAULT)
DEST := $(GOPATH)/src/$(GIT_HOST)/$(BASE_DIR)
#IMAGE_TAG ?= $(shell date +v%Y%m%d)-$(shell git describe --match=$(git rev-parse --short=8 HEAD) --tags --always --dirty)
IMAGE_TAG ?= 0.0.1

LOCAL_OS := $(shell uname)
ifeq ($(LOCAL_OS),Linux)
    TARGET_OS ?= linux
    XARGS_FLAGS="-r"
else ifeq ($(LOCAL_OS),Darwin)
    TARGET_OS ?= darwin
    XARGS_FLAGS=
else
    $(error "This system's OS $(LOCAL_OS) isn't recognized/supported")
endif

all: fmt lint test build image

ifeq (,$(wildcard go.mod))
ifneq ("$(realpath $(DEST))", "$(realpath $(PWD))")
    $(error Please run 'make' from $(DEST). Current directory is $(PWD))
endif
endif

############################################################
# Help
############################################################

help: ## Display this help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)


############################################################
# format section
############################################################

fmt:
	@echo "Run go fmt..."

############################################################
# lint section
############################################################

lint:
	@echo "Runing the golangci-lint..."

############################################################
# test section
############################################################

test:
	@echo "Running the tests for $(IMAGE_NAME)..."
	@go test $(TESTARGS) ./...

############################################################
# build section
############################################################

build:
	@echo "Building the $(IMAGE_NAME) binary..."
	@CGO_ENABLED=0 go build -o build/$(IMAGE_NAME) ./cmd/

############################################################
# image section
############################################################
KIND_CLUSTER_NAME=kind

.PHONY: create-cluster
create-cluster: ## launch kind cluster
	if [ ! "$(shell kind get clusters | grep $(KIND_CLUSTER_NAME))" ]; then \
		cd test/config; ./start-cluster.sh ${KIND_CLUSTER_NAME}; \
	fi

.PHONY: delete-cluster
delete-cluster: ## delete cluster
	@kind delete cluster --name ${KIND_CLUSTER_NAME}

deploy-admission-controller: ## Deploy admission controller
    # cd deployments/webhook && $(KUSTOMIZE) edit set image =${IMG_NAME}:${IMAGE_TAG}
	@kubectl create ns tsf-system
	@kustomize build deployments/default | kubectl apply -f -

image: build-image load-image

build-arg:=--build-arg BUILD_DIR=/go/src/pellep.io/webhook 

.PHONY: bundle-image
build-image: ## Build Container Image
	@echo "Building the docker image: $(IMAGE_REPO)/$(IMAGE_NAME):$(IMAGE_TAG)..."
	@docker build --progress plain --force-rm  $(build-arg) -t $(IMAGE_REPO)/$(IMAGE_NAME):$(IMAGE_TAG) . 

.PHONY: run-image
run-image: ## Test Run Container Image with docker
	@echo "Test running the docker image: $(IMAGE_REPO)/$(IMAGE_NAME):$(IMAGE_TAG)..."
	@docker run --rm $(IMAGE_REPO)/$(IMAGE_NAME):$(IMAGE_TAG)

.PHONY: load-image
load-image: ## Load Conttainer Image to Kind Cluster
	@echo "Loading $(IMAGE_REPO)/$(IMAGE_NAME):$(IMAGE_TAG) to kind cluster"
	@kind load docker-image --name ${KIND_CLUSTER_NAME}  $(IMAGE_REPO)/$(IMAGE_NAME):$(IMAGE_TAG) 

push-image: push-image ## Push Image to remote repository
	@echo "Pushing the docker image for $(IMAGE_REPO)/$(IMAGE_NAME):$(IMAGE_TAG) and $(IMAGE_REPO)/$(IMAGE_NAME):latest..."
	@docker tag $(IMAGE_REPO)/$(IMAGE_NAME):$(IMAGE_TAG) $(IMAGE_REPO)/$(IMAGE_NAME):latest
	@docker push $(IMAGE_REPO)/$(IMAGE_NAME):$(IMAGE_TAG)
	@docker push $(IMAGE_REPO)/$(IMAGE_NAME):latest

############################################################
# Toolbox Container
############################################################

TOOLBOX_IMG=toolbox:0.0.1

.PHONY: build-toolbox-image
build-toolbox-image: ## Build and deploy toolbox image
	@docker build --progress plain --force-rm  -t $(TOOLBOX_IMG) -f Dockerfile.toolbox .
	@kind load docker-image $(TOOLBOX_IMG)

############################################################
# clean section
############################################################
clean:
	@rm -rf bin

.PHONY: clearclean
clearclean: ## Clean all terminated containers and interim builds
	@echo "Clean untaged images and stoped containers..."
	@docker ps -a | grep "Exited" | awk '{print $$1}' | sort -u | xargs -L 1 docker rm
	@docker images | grep '<none>' | awk '{print $$3}' | sort -u | xargs -L 1 docker rmi -f


.PHONY: all fmt help build create-cluster delete-cluster build-image load-image push-image