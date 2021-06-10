#!/bin/bash

action=$1
ns=$(oc project -q)
cat <<EOF | curl -v --header "Content-Type: application/json" --request POST --data @- $(oc  get route el-mkdocs --template='http://{{.spec.host}}')
{
    "repository": {
        "url": "https://github.com/pbertera/OpenShift-pipelines-demo",
        "name": "OpenShift-pipelines-demo",
        "head_commit": { "id": "main" }
    },
    "action": "${action}",
    "mkdocs-image": "image-registry.openshift-image-registry.svc:5000/${ns}/mkdocs"
}
