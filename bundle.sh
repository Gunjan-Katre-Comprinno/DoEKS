#!/bin/bash

# List of supported modules
SUPPORTED_MODULES=("calico" "jaeger" "cni_metrics_helper" "kubernetes_dashboard" "container_insights" "karpenter" "cluster_autoscaler")

# Check if no arguments were provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 module1 module2 ..."
    exit 1
fi

# Flag to track if any errors occurred
error_occurred=false

# Function to check if a module is supported
is_supported_module() {
    local module=$1
    for supported in "${SUPPORTED_MODULES[@]}"; do
        if [ "$supported" == "$module" ]; then
            return 0
        fi
    done
    return 1
}

# Loop through each argument
for folder in "$@"; do
    # Check if the folder is a supported module
    if is_supported_module "$folder"; then
        module_path="optional_modules/${folder}_module/${folder}"
        
        # Check if the folder exists inside 'optional_modules'
        if [ -d "$module_path" ]; then
            # Copy the folder to the current working directory
            cp -r "$module_path" ./modules/kubernetes/ || { echo "Error copying module '$folder' folder"; error_occurred=true; break; }
            
            # Check if the '${folder}.tf' file exists
            if [ -f "${module_path}.tf" ]; then
                # Copy the '${folder}.tf' file to 'kubernetes_service_infra' folder
                cp "${module_path}.tf" "kubernetes_service_infra/" || { echo "Error copying '${folder}.tf' file for module '$folder'"; error_occurred=true; break; }
                echo "Bundled module '$folder' and '${folder}.tf' file"
            else
                echo "Warning: '${folder}.tf' file not found for module '$folder'"
            fi
        else
            echo "Error: Module folder '$folder' does not exist inside 'optional_modules'"
            error_occurred=true
            break
        fi
    else
        echo "Module '$folder' is not supported! Supported modules: [${SUPPORTED_MODULES[*]}]"
        error_occurred=true
        break
    fi
done

# Build the Docker image if no errors occurred
if [ "$error_occurred" = false ]; then
    # Get the current date in YYYYMMDD format
    current_date=$(date +%Y%m%d)
    image_name="boilerplate:1_28_$current_date"
    
    echo "Building Docker image with tag '$image_name'..."
    docker build -t "$image_name" . || { echo "Docker build failed"; exit 1; }
    echo "Docker image built successfully with tag '$image_name'"
else
    echo "Script encountered errors, Docker image not built"
    exit 1
fi