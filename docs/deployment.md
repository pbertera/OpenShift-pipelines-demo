The application is deployed on Kubernetes via a `Deployment` manifest located under the `k8s/Deployment.yaml`.
The application is a very simple static website served by an NGINX pod.

The static content is built using an [MkDocs](https://www.mkdocs.org) container triggered by an OpenShift Pipeline.

The static content is stored into a `persistentVolumeClaim` with name `html-mkdocs`.

The pipeline is designed to build the mkdocs container image, build the documentation or deploy the application depending on the value of the `action` parameter.

## How to deploy the demo

- Create the namespace

```
$ oc new-project pipelines-demo
```

- fork the repo
- clone the repo
- create the `html-mkdocs` PVC

```
$ cat << EOF | oc create -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: html-mkdocs
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 500Mi
EOF
$ oc create -f cd/pvc.yaml
```

- Create the Pipelines resurces

```
$ oc create -f https://raw.githubusercontent.com/pbertera/OpenShift-pipelines-demo/main/cd/pipeline/pipeline.yaml
```

- Create the trigger resources

```
$ oc create -f https://raw.githubusercontent.com/pbertera/OpenShift-pipelines-demo/main/cd/triggers/triggerbinding.yaml
$ oc create -f https://raw.githubusercontent.com/pbertera/OpenShift-pipelines-demo/main/cd/triggers/triggertemplate.yaml
$ oc create -f https://raw.githubusercontent.com/pbertera/OpenShift-pipelines-demo/main/cd/triggers/trigger.yaml
$ oc create -f https://raw.githubusercontent.com/pbertera/OpenShift-pipelines-demo/main/cd/triggers/eventlistner.yaml
```

- Confirm that an eventlistner service has been created and expose it

```
$ oc get svc
$ oc expose svc el-mkdocs
```

- Get the URL route

```
$ echo "URL: $(oc  get route el-mkdocs --template='http://{{.spec.host}}')"
```

- Start building the image:

```
$ cd tests
$ ./run.sh build-image
```

- Check if the pipeline is started

```
$ tkn pipelinerun list
$ tkn pipeline logs -f <pipelinerun-name>
```
- Once the pipline terminated successfully you can deploy the application

```
$ cd tests                                                           
$ ./run.sh deploy
```


