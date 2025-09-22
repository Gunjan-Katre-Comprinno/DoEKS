#!/bin/bash

# Define paths
aws_base_infra_dir=$(pwd)/aws_base_infra
k8s_service_infra_dir=$(pwd)/kubernetes_service_infra
values_tfvars=$(pwd)/values.tfvars

# Main script logic
if [ $# -lt 1 ] || ([ $1 != "apply" ] && [ $1 != "destroy" ]); then
    echo "Usage: $0 <apply/destroy> [infra] [flags_file]"
    echo "  apply/destroy: Specify whether to apply or destroy infrastructure."
    echo "  [infra]: Optional argument to specify which infrastructure to apply/destroy (aws, k8s, all). Default is all."
    echo "  [flags_file]: Optional argument to specify the flags file (without path). Default is flag.tfvars."
    exit 1
fi

action=$1
infra=${2:-"all"}
flags_file=${3:-"flag.tfvars"}
flag_tfvars=$(pwd)/$flags_file

# Check if flags file exists
if [ ! -f "$flag_tfvars" ]; then
    echo "Warning: $flags_file not specified or found. Using default flag.tfvars."
    flag_tfvars=$(pwd)/flag.tfvars
fi

# Function to manage AWS base infra
manage_aws_base_infra() {
    terraform_flags="--var-file=$flag_tfvars --var-file=$values_tfvars --auto-approve"
    cd $aws_base_infra_dir
    terraform init
    if [[ $1 == "apply" ]]; then
        echo "Applying AWS base infrastructure..."
        terraform apply $terraform_flags 2>&1
    elif [[ $1 == "destroy" ]]; then
        echo "Destroying AWS base infrastructure..."
        terraform destroy $terraform_flags
    else
        exit 1
    fi
    local result=$?
    cd ..
    return $result
}

# Function to manage Kubernetes service infra
manage_k8s_service_infra() {
    terraform_flags="--var-file=$flag_tfvars --var-file=$values_tfvars --auto-approve"
    cd $k8s_service_infra_dir
    ls -ltr
    terraform init
    if [[ $1 == "apply" ]]; then
        echo "Applying Kubernetes service infrastructure..."
        terraform apply $terraform_flags 2>&1
    elif [[ $1 == "destroy" ]]; then
        echo "Destroying Kubernetes service infrastructure..."
        terraform destroy $terraform_flags
    else
        exit 1
    fi
    local result=$?
    cd ..
    return $result
}

if [[ $action == "apply" ]]; then
    if [[ $infra == "aws" ]]; then
        manage_aws_base_infra $action
        aws_base_result=$?
        if [ $aws_base_result -eq 0 ]; then
            echo "AWS base infrastructure applied successfully."
        else
            echo "Failed to apply AWS base infrastructure."
            exit 1
        fi
    elif [[ $infra == "k8s" ]]; then
        manage_k8s_service_infra $action
        k8s_result=$?
        if [ $k8s_result -eq 0 ]; then
            echo "Kubernetes service infrastructure applied successfully."
        else
            echo "Failed to apply Kubernetes service infrastructure."
            exit 1
        fi
    elif [[ $infra == "all" ]]; then
        manage_aws_base_infra $action
        aws_base_result=$?
        if [ $aws_base_result -eq 0 ]; then
            echo "AWS base infrastructure applied successfully."
            manage_k8s_service_infra $action
            k8s_result=$?
            if [ $k8s_result -eq 0 ]; then
                echo "Kubernetes service infrastructure applied successfully."
            else
                echo "Failed to apply Kubernetes service infrastructure."
                exit 1
            fi
        else
            echo "Failed to apply AWS base infrastructure."
            exit 1
        fi
    else
        echo "Invalid argument apply $1 $2 "
        exit 1
    fi

elif [[ $action == "destroy" ]]; then
    if [[ $infra == "aws" ]]; then
        manage_aws_base_infra $action
        aws_base_result=$?
        if [ $aws_base_result -eq 0 ]; then
            echo "AWS base infrastructure destroyed successfully."
        else
            echo "Failed to destroy AWS base infrastructure."
            exit 1
        fi
    elif [[ $infra == "k8s" ]]; then
        manage_k8s_service_infra $action
        k8s_result=$?
        if [ $k8s_result -eq 0 ]; then
            echo "Kubernetes service infrastructure destroyed successfully."
        else
            echo "Failed to destroy Kubernetes service infrastructure."
            exit 1
        fi
    elif [[ $infra == "all" ]]; then
        manage_k8s_service_infra $action
        k8s_result=$?
        if [ $k8s_result -eq 0 ]; then
            echo "Kubernetes service infrastructure destroyed successfully."
            manage_aws_base_infra $action
            aws_base_result=$?
            if [ $aws_base_result -eq 0 ]; then
                echo "AWS base infrastructure destroyed successfully."
            else
                echo "Failed to destroy AWS base infrastructure."
                exit 1
            fi
        else
            echo "Failed to destroy Kubernetes service infrastructure."
            exit 1
        fi
    else
        echo "Invalid argument apply $1 $2 "
        exit 1
    fi
else
    echo "Invalid action: $action. Please use 'apply' or 'destroy'."
    exit 1
fi
exit 0