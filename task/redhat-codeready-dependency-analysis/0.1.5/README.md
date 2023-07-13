# `redhat-codeready-dependency-analysis`
**Note: this Task is only compatible with Tekton Pipelines versions 0.19.0 and greater!**

## Overview
The redhat-codeready-dependency-analysis task is an interface between Tekton and Red Hat CodeReady Dependency Analytics platform. 
It provides vulnerability and compliance analysis for your applications dependencies, along with recommendations to address security vulnerabilities and licensing issues.

This task reflects [Dependency Analytics VS Code plugin](https://marketplace.visualstudio.com/items?itemName=redhat.fabric8-analytics) for Tekton Pipelines.

**Note: Currently this Task only supports Maven ecosystem, support for other ecosystems will be provided very soon.**

## Prerequisite

#### 1. Workspace
Workspace is used as a common filesystem between tasks. It provides a designated area for the input, output, and intermediate files used during the execution of the pipeline by the redhat-codeready-dependency-analysis task.

This [sample](sample/workspace.yaml) file can be referred to in order to create a workspace.

The following command can be used to create a workspace from the sample file.

```
kubectl apply -f sample/workspace.yaml -n <NAMESPACE>
```

#### 2. Manifest
The redhat-codeready-dependency-analysis task scans dependency manifest files (ex. pom.xml, requirements.txt etc.) for vulnerabilities by first collecting them from the manifest file itself. In order for the task to do so, it is necessary to place the target manifest file into workspace prior to running this task. 
The path to the manifest file must be passed as a parameter to the task.

#### 3. Secret
The redhat-codeready-dependency-analysis task uses the `CRDA_SNYK_TOKEN` token to authenticate with Snyk (vulnerability data provider).
This Token must be saved in a secret by the name of `crda`.<br />
To generate a new Snyk token please visit the following [link](https://app.snyk.io/login?utm_campaign=Code-Ready-Analytics-2020&utm_source=code_ready&code_ready=FF1B53D9-57BE-4613-96D7-1D06066C38C9.).

This [sample](sample/secret.yaml) file can be referred to in order to create a secret, replace `{{ CRDA_SNYK_TOKEN }}` with the generated Snyk token before running.

The following command can be used to create a secret from the sample file.

```
kubectl apply -f sample/secret.yaml -n <NAMESPACE>
```

## Task Parameters
- **manifest-file-path**: Path to target manifest file within the project directory to perform analysis upon.
- **pkg-installation-directory**: Path to directory within workspace, where the project is installed. `(default: project-package)`
- **output-file-name**: Path to file within workspace, where the analysis report is saved. `(default: redhat-codeready-dependency-analysis-report.json)`
- **image**: Image where CRDA Javascript API and required dependencies are installed. `(default: quay.io/ecosystem-appeng/crda-javascript-api:1.0)`. <br />
List of images for different ecosystem and versions can be found [here](https://github.com/fabric8-analytics/crda-images)

## Output
The response of the redhat-codeready-dependency-analysis task is saved in JSON format within the workspace directory under file name defined by parameter `output-file-name`. <br />
This response provides both a summary and a comprehensive report detailing all discovered vulnerabilities. <br />
The provided response may be used by a subsequent task for decision making, such as Passing or Failing a build.  

In the logs, a simplified report summary will be displayed, example:
```
RedHat CodeReady Dependency Analysis task is being executed.
==================================================
RedHat CodeReady Dependency Analysis Report
==================================================
Total Scanned Dependencies            :  10 
Total Scanned Transitive Dependencies :  218 
Total Vulnerabilities                 :  22 
Direct Vulnerable Dependencies        :  5 
Snyk Provider Status                  :  OK 
Critical Vulnerabilities              :  1 
High Vulnerabilities                  :  3 
Medium Vulnerabilities                :  12 
Low Vulnerabilities                   :  6 
==================================================
Full report is saved into file: redhat-codeready-dependency-analysis-report.json
Task is completed.
```

## Installing the Task
```
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/redhat-codeready-dependency-analysis/0.1.5/raw -n <NAMESPACE>
```

## Platforms

The Task can be run on `linux/amd64` platform.

## Usage Demo

An example PipelineRun and TaskRun are provided in the `samples` directory in order to demonstrate the usage of the redhat-codeready-dependency-analysis task. 

### Deployment Instructions:

1. Deploy a new workspace with [workspace.yaml](sample/workspace.yaml), run:
```
kubectl apply -f sample/workspace.yaml -n <NAMESPACE>
```

2. In [secret.yaml](sample/secret.yaml), first replace `{{ CRDA_SNYK_TOKEN }}` with a generated Snyk token, then create the secret, run:
```
kubectl apply -f sample/secret.yaml -n <NAMESPACE>
```

3. Deploy the redhat-codeready-dependency-analysis task with [redhat-codeready-dependency-analysis.yaml](redhat-codeready-dependency-analysis.yaml), run:
```
kubectl apply -f redhat-codeready-dependency-analysis.yaml -n <NAMESPACE>
```

#### For PipelineRun:

1. Deploy the git-clone-project pre task with [pre-task-git-clone-project.yaml](sample/pre-task-git-clone-project.yaml), run:
```
kubectl apply -f sample/pre-task-git-clone-project.yaml -n <NAMESPACE>
```

2. Deploy the ripeline with [pipeline.yaml](sample/pipeline.yaml), run:
```
kubectl apply -f sample/pipeline.yaml -n <NAMESPACE>
```

3. In [pipeline-run.yaml](sample/pipeline-run.yaml), first replace `{{ HTTPS_GIT_URL }}` with the HTTPS Github URL to the project repository where the target manifest file resides, next replace `{{ MANIFEST_FILE_PATH }}` with the path to the target manifest file within the project directory, finally create the pipelinerun, run:
```
kubectl apply -f sample/pipeline-run.yaml -n <NAMESPACE>
```

#### For TaskRun:

1. Within workspace, create a new project directory (update parameter `project-directory-path` if needed).

2. Store the target manifest file into a desired location inside the project directory.

2. In [task-run.yaml](sample/task-run.yaml), replace `{{ MANIFEST_FILE_PATH }}` with the path to the target manifest file within the project directory, then create the taskrun, run:
```
kubectl apply -f sample/task-run.yaml -n <NAMESPACE>
```

<small>**NOTE:** The redhat-codeready-dependency-analysis task expects to have a secret by the name of `crda` configured with the `CRDA_SNYK_TOKEN` key, 
as well as an attached workspace with the target manifest file stored within.</small>
