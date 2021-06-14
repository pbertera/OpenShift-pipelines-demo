#!/bin/bash

. demo.sh.inc

clear

export SPEED=2

pi '# Create the the pipelines-demo project'
pe 'oc new-project pipelines-demo'

pi '# Create the html-mkdocs PVC'
p 'cat << EOF | oc create -f -
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
EOF'

cat << EOF | oc create -f -
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

pi '# Create the custom tasks:'
pi '#   build-docs'
pe 'oc create -f https://raw.githubusercontent.com/pbertera/OpenShift-pipelines-demo/main/cd/tasks/build-docs.yaml'
pi '#   apply-manifests'
pe 'oc create -f https://raw.githubusercontent.com/pbertera/OpenShift-pipelines-demo/main/cd/tasks/apply-manifests.yaml'
pi '#   update-deployment'
pe 'oc create -f https://raw.githubusercontent.com/pbertera/OpenShift-pipelines-demo/main/cd/tasks/update-deployment.yaml'

pi '# Create the Pipeline resource'
pe 'oc create -f https://raw.githubusercontent.com/pbertera/OpenShift-pipelines-demo/main/cd/pipeline/pipeline.yaml'

pi '# Create the Triggers resource'
pe 'oc create -f https://raw.githubusercontent.com/pbertera/OpenShift-pipelines-demo/main/cd/triggers/triggerbinding.yaml'
pe 'oc create -f https://raw.githubusercontent.com/pbertera/OpenShift-pipelines-demo/main/cd/triggers/triggertemplate.yaml'
pe 'oc create -f https://raw.githubusercontent.com/pbertera/OpenShift-pipelines-demo/main/cd/triggers/trigger.yaml'
pe 'oc create -f https://raw.githubusercontent.com/pbertera/OpenShift-pipelines-demo/main/cd/triggers/eventlistner.yaml'

pi '# EventListner creates a service'
pe 'oc get svc'
pi '# Exposing the service we can receive Webhooks triggers'
pe 'oc expose svc el-mkdocs'
pe 'oc get route el-mkdocs'

pi '# Build the mkdocs-image'
p 'cat << EOF | curl $(oc  get route el-mkdocs --template='http://{{.spec.host}}') --header "Content-Type: application/json" -v --data @-
{
    "repository": {
        "html_url": "https://github.com/pbertera/OpenShift-pipelines-demo",
        "name": "OpenShift-pipelines-demo",
        "head_commit": { "id": "main" }
    },
    "action": "build-image",
    "mkdocs-image": "image-registry.openshift-image-registry.svc:5000/pipelines-demo/mkdocs"
}
EOF'

cd tests/

./run.sh build-image

pi '# Deploy the application'
p 'cat << EOF | curl $(oc  get route el-mkdocs --template='http://{{.spec.host}}') --header "Content-Type: application/json" -v --data @-
{
    "repository": {
        "html_url": "https://github.com/pbertera/OpenShift-pipelines-demo",
        "name": "OpenShift-pipelines-demo",
        "head_commit": { "id": "main" }
    },
    "action": "deploy",
    "mkdocs-image": "image-registry.openshift-image-registry.svc:5000/pipelines-demo/mkdocs"
}
EOF'

./run.sh deploy
