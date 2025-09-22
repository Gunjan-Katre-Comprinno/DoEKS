
#!/bin/bash

# Exit immediately if a command exits with a non-zero status
# set -e

# Global variables
LOG_FILE="terraform_apply.log"
BASE_INFRA_TFSTATE_FILE="base_infra_terraform.tfstate"
K8S_INFRA_TFSTATE_FILE="k8s_infra_terraform.tfstate"
CURRENT_DATETIME=$(date +"%d %b %Y, %I:%M %p")

# Function to generate the HTML report header
generate_html_header() {
    cat <<EOL > terraform_report.html
<!DOCTYPE html>
<html>
<head>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 20px;
            background-color: #f7f7f7;
        }

        .header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-bottom: 2px solid #333;
            padding-bottom: 10px;
            margin-bottom: 20px;
        }

        .header-left {
            display: flex;
            align-items: center;
        }

        .header img {
            height: 60px;
            margin-right: 20px;
        }

        .header-text {
            line-height: 1.2;
        }

        .header-text h1 {
            font-size: 24px;
            color: #333;
            margin: 0;
        }

        .header-text p {
            font-size: 14px;
            color: #555;
            margin: 5px 0;
        }

        .header-right {
            text-align: right;
        }

        .header-right p {
            font-size: 14px;
            color: #555;
            margin: 5px 0;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            background-color: white;
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
            margin-bottom: 20px;
        }

        th, td {
            padding: 12px;
            text-align: left;
            border: 1px solid #ddd;
            word-wrap: break-word; 
            white-space: normal; 
            min-width: 150px;
        }

        th {
            background-color: #54656e; 
            color: white;
            font-size: 14px;
            text-transform: uppercase;
        }

        td {
            font-size: 14px;
        }

        .pass {
            background-color: #dff0d8;
            color: #3c763d;
            font-weight: bold;
        }

        .fail {
            background-color: #f2dede;
            color: #a94442;
            font-weight: bold;
        }

        .error-log {
            color: #a94442;
            font-family: 'Courier New', Courier, monospace;
            white-space: pre-wrap;
            word-wrap: break-word;
            overflow-wrap: break-word;
            word-break: break-all;
        }

        .footer {
            text-align: center;
            font-size: 12px;
            color: #999;
        }
    </style>
</head>
<body>

    <!-- Report Header with Logo and Metadata -->
    <div class="header">
        <!-- Left section with logo and title -->
        <div class="header-left">
            <img src="https://comprinno.net/wp-content/uploads/2022/03/logoComprinno.ai_.resized.png" alt="Comprinno Logo">
            <div class="header-text">
                <h1>EKS Boilerplate Test Report</h1>
                <p>Report generated on: ${CURRENT_DATETIME}</p>
            </div>
        </div>

        <!-- Right section with commit details -->
        <div class="header-right">
            <p><strong>Last Commit ID:</strong> ${CODEBUILD_RESOLVED_SOURCE_VERSION}</p>
            <p><strong>Commit Message:</strong> "${COMMIT_MESSAGE}"</p>
        </div>
    </div>

    <!-- Test Results Summary -->
    <h2>Automated Test Results Summary</h2>

    <!-- Test Results Table -->
    <table>
        <tr>
            <th>Module Name</th>
            <th>Status</th>
            <th>Error Details</th>
        </tr>
EOL
}


process_modules() {
    echo "Extracting errors from log file..."
    declare -A module_errors
    local total_errors=0
    
    # Extract all complete error occurrences first
    local error_messages=()
    local capturing_error=false
    local current_error=""
    
    while IFS= read -r line; do
        if echo "$line" | grep -q "│ Error:"; then
            capturing_error=true
            current_error="$line"
        elif [[ "$capturing_error" == true ]]; then
            current_error+=$'\n'"$line"
            if [[ -z "$line" || "$line" =~ ^╵ ]]; then
                capturing_error=false
                error_messages+=("$current_error")
                current_error=""
            fi
        fi
    done < "$LOG_FILE"
    
    echo "Total errors found: ${#error_messages[@]}"
    
    # Associate errors with modules
    for error in "${error_messages[@]}"; do
        if [[ "$error" =~ with\ module\.([a-zA-Z0-9_-]+) ]]; then
            module_name="${BASH_REMATCH[1]}"
            module_errors[$module_name]+="$error\n"
            ((total_errors++))
        fi
    done
    
    # Extract expected modules from the log file
    local expected_modules
    expected_modules=$(grep -oP '^module\.\K[\w-]+(?=\[?\d*\]?\.?)' "$LOG_FILE" | sort -u)
    # Extract modules present in the state file
    local state_modules
    state_modules=$(
        (
            jq -r '.resources[].module' "$BASE_INFRA_TFSTATE_FILE" 2>/dev/null
            jq -r '.resources[].module' "$K8S_INFRA_TFSTATE_FILE" 2>/dev/null
        ) | grep -v "null" | sed 's/module\.//' | sed 's/\.module\..*//' | sed 's/\[0\]//' | sort | uniq
    )
    # Iterate over each expected module
    for module in $expected_modules; do
        echo "Processing Module: ${module}"   
        local error_found=false
        local error_details="N/A"
        
        # Check if errors exist for this module
        if [[ -n "${module_errors[$module]}" ]]; then
            error_found=true
            error_details="${module_errors[$module]}"
        fi
        
        # Check if module is present in the state file
        local module_in_state=false
        if echo "$state_modules" | grep -q "^$module$"; then
            module_in_state=true
        fi
        
        # Determine status, (If either of the above checks are failed it will mark the status as "Failed", else it will mark "Pass")
        local status
        if [ "$error_found" = true ] || [ "$module_in_state" = false ]; then
            status="Fail"
            if [ -z "$error_details" ]; then
                error_details="Module not present in state file"
            fi
        else
            status="Pass"
            error_details="N/A"
        fi
        
        # echo "Module: $module, Status: $status, Errors: $(echo "$error_details" | wc -l)"
        
        # Add the module details to the report
        cat <<EOL >> terraform_report.html
        <tr>
            <td>${module}</td>
            <td class='${status,,}'>${status}</td>
            <td class='error-log'><pre>${error_details}</pre></td>
        </tr>
EOL
    done
}




# Function to generate the HTML report footer
generate_html_footer() {
    cat <<EOL >> terraform_report.html
    </table>

    <!-- Footer -->
    <div class="footer">
        <p>Generated by DevOps Regression Pipeline | Comprinno</p>
    </div>
</body>
</html>
EOL
}

# Main function
main() {
    generate_html_header
    process_modules
    generate_html_footer
    echo "Report generated: terraform_report.html"
}

# Call the main function
main
