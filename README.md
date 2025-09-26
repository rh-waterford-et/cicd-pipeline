# CICD pipeline for rh-waterford-et projects

## Prerequisites

1. Openshift/Kubernetes cluster is available, with admin access.

2. Github bot account (machine) to use in the cicd pipeline.

3. Once the 'bot' account has been created execute the following steps

   - a. Navigate to github page for the bot and click on the icon (top right)
   - b. Click on "Settings"
   - c. On the menu that appears click on "Developer Settings" (should be at the bottom)
   - d. Click on Personal Access Token (PAT) and create a fine grained access token
   - e. Save the token locally in a safe place
   - f. Create an openshift secret (using a base64 version of the token) and deploy to namespace rh-waterforf-et (on the Waltons cluster)

4. Navigate to the repository "Settings" (top right on repo menu) and click on it

5. Click on Rules => Ruleset and ccreate a new RuleSet

6. Enable "Require a pull request before merging"
   
   - a. Under "Required Approvals" enable "Dismiss stale pull request approvals when new commits are pushed"
   - b. Enable "Require review from Code Owners"
   - c. Enable "Require status checks to pass"
   - d. Enable "Require branches to be up to date before merging"
   - e. Add a check (this requires a github api call to pick items in the list - see Appendix below)
   - f. Save changes

7. Navigate to the menu and click on Webhooks
  
   - Add the webhook "https://pr-opened-webhook-rh-waterford-et.apps.ocp-rh-ai.waltoninstitute.ie/"

8. Create an OWNERS file in the repository (see Appendix)

9. Apply all the OpenShift Pipeline templates

```bash
oc apply -k environments/waltons-institute
```

You will now be able to trigger the pipeline when you create a PR in the repository

The current pipeline will

- 1. Clone the repo and checkout the PR
- 2. Use golangci-lint to verify the project (uses a strict set of linting rules borrowed from the OpenShift org pipeline)
- 3. Builds the application
- 4. Uses a git api post to update the status check for the repository (pass or fail), if it fails it will block a merge



## Run the pipeline (manually)

Launch the pipeline run.

Example 
```bash
oc create -f environments/waltons-institute/pipelineruns/rh-waterford-et-all-pipelinerun.yaml
```

## Appendix

### Create a secret

Execute the following

```bash

echo -n “<token>” | base64

```

Create the secret yaml file 

```
kind: Secret
apiVersion: v1
metadata:
  name: github-token
  namespace: rh-waterford-et
data:
  token: <base64 token>
type: Opaque
```

Apply the secret to the cluster

```
oc apply -f <path-to-secret>
```

### Create an OWNERS file 

In the root of the repository create a file called OWNERS with content

Add the relevant reviewers and approvers (people working on the project), tech lead, project lead, staff engineer etc

```
reviewers:
  - github user 1
  - github user 2

approvers:
  - github user1
  - github project lead
```

### Create a check (to add to status check list)

Execute the following command

```bash

curl -L \
  -X POST \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer <YOUR-TOKEN>" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/repos/OWNER/REPO/statuses/SHA \
  -d '{"state":"success","target_url":"https://example.com/build/status","description":"The build succeeded!","context":"openshift-cicd-pipeline"}'

```

Replace the obvious "YOUR-TOKEN", "OWNER", "REPO" , "target_url" and "context" 

### Ccreate a container to execute in the pipeline

This is specifically for golang projects

```
podman build -t <registry>/<namespace>/rh-waterford-golang:v1.24.5 -f containerfile

podman push <registry>/<namespace>/rh-waterford-golang:v1.24.5

```

Update the files base/tekton.dev/tasks/*.yaml files (i.e spec.steps.image with the container created above)
