# CIC pipeline for rh-waterford-et projects

## Prerequisites

1. Openshift/Kubernetes cluster is available, with admin access.

2. Apply:
```bash
oc apply -k environments/waltons-institute
```

## Run the pipeline
Launch the pipeline run with the Tekton client.

Example 
```bash
oc create -f environments/waltons-institute/pipelineruns/rh-waterford-et-all-pipelinerun.yaml
```

