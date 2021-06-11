This repository contains a demo application demostrating the OpenShift Tekton pipelines.

The built website is also availabe on GitHub Pages at [https://pbertera.github.io/OpenShift-pipelines-demo/](https://pbertera.github.io/OpenShift-pipelines-demo/)

The application is a static website generated with [MkDocs](https://www.mkdocs.org), the Pipeline can
- build the mkdocs image
- build the static content out of the [docs](tree/main/docs) directory
- deploy the application applying the [k8s](tree/main/k8s) Kubernetes manifests
