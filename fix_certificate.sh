#!/bin/bash

echo "=== Certificate ARN Fix Script ==="

# Check existing certificates in the correct account
echo "1. Checking existing certificates in account 277707111485..."
aws acm list-certificates --region us-east-1

echo -e "\n2. Current certificate ARN in values.tfvars:"
grep "elb_certificate_arn" values.tfvars

echo -e "\n3. Please update values.tfvars with the correct certificate ARN from account 277707111485"
echo "   Or create a new certificate if none exists:"
echo "   aws acm request-certificate --domain-name '*.yourdomain.com' --validation-method DNS --region us-east-1"
