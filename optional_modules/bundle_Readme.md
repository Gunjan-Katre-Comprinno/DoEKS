# Bundle.sh Script Overview

This bash script is designed to manage and bundle specified Kubernetes modules from a predefined list of supported modules. It checks for the presence of the specified module folders and their corresponding Terraform files, and then copies them to the appropriate locations. If no errors occur, it proceeds to build a Docker image with a timestamped tag.

## Usage

```bash
./bundle.sh module1 module2 ...
```

- `module1 module2 ...`: List of modules to bundle. Only supported modules will be processed.

## Supported modules with version 

| Module                     |  Helm Chart Versions |
|-------------------------------|----------|
| cni_metrics_helper            | 1.16.3   |
| kubernetes_dashboard          | 6.0.8    |
| jaeger                        | 1.0.2    |
| container_insights            | 0.22.0   |
| calico                        | v3.27.2  |
| cluster_autoscaler            | v1.26.2  |

## Script Details

1. **Check for Arguments**
    - The script checks if any arguments are provided. If no arguments are given, it displays usage information and exits.

2. **Validate Supported Modules**
    - The script validates each provided module against the list of supported modules. If an unsupported module is detected, the script prints an error message and exits.

3. **Process Each Module**
    - For each supported module, the script:
        - Checks if the module folder exists within `optional_modules`.
        - Copies the module folder to the `./modules/kubernetes/` directory.
        - Checks for the existence of the corresponding Terraform file (`${folder}.tf`) and copies it to the `kubernetes_service_infra` directory.
        - Prints a warning if the Terraform file is not found.

4. **Build Docker Image**
    - If no errors occurred during the module processing, the script builds a Docker image with a tag that includes the current date in `YYYYMMDD` format.
    - If an error occurs, the script exits without building the Docker image.

## Example

To bundle the `cluster_autoscaler`, `kuberntes_dashboard` and `karpenter` modules and build the Docker image:

```bash
./bundle.sh cluster_autoscaler kubernetes_dashboard karpenter
```

## Output

- The script prints detailed messages indicating the progress and any errors encountered.
- If successful, the Docker image is built and tagged with the format `boilerplate:1_28_YYYYMMDD`.

## Error Handling

- The script exits with an appropriate message if any errors occur during the process.
- Errors may include unsupported modules, missing module folders, or failed file copies.

## Notes

- Ensure the module folders and Terraform files are correctly placed within the `optional_modules` directory.
- The script assumes the existence of a Docker environment configured to build images.
