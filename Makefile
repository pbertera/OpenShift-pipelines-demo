.PHONY: prebuild build serve build cleanup

CONTAINER_IMAGE=mkdocs
CONTAINER_NAME=mkdocs
CONTAINER_PORT=8001
LOCAL_PORT=8001
LISTEN_ADDR=0.0.0.0

cleanup:
	-podman kill $(CONTAINER_NAME)
	-podman rm $(CONTAINER_NAME)

cbuild:
	cd build; podman build -t $(CONTAINER_IMAGE) .

build: cleanup
	podman run -it -v $(PWD):/opt/data:z --name $(CONTAINER_NAME) --rm -p $(LOCAL_PORT):$(CONTAINER_PORT) $(CONTAINER_IMAGE) build --clean

serve: cleanup build
	podman run -it -v $(PWD):/opt/data:z --name $(CONTAINER_NAME) --rm -p $(LOCAL_PORT):$(CONTAINER_PORT) $(CONTAINER_IMAGE) serve -a $(LISTEN_ADDR):$(CONTAINER_PORT)
