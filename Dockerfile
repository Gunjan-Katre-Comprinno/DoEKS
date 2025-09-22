# Use a specific version of Debian slim as the base image
FROM debian:stable-slim

# Set default values for build arguments
ARG BUNDLE_UID=1001
ARG BUNDLE_USER=terraform
ARG BUNDLE_GID=0

# Create a non-root user and use the root group (0)
RUN useradd --uid ${BUNDLE_UID} --gid ${BUNDLE_GID} --create-home ${BUNDLE_USER}

# Use shell form for RUN commands to improve readability and avoid potential issues
RUN set -eux; \
    apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        wget \
        unzip \
        gnupg2 \
        git \
        curl \
    && rm -rf /var/lib/apt/lists/*

# Install Terraform
ARG TERRAFORM_VERSION=1.10.4
RUN set -eux; \
    wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -O terraform.zip \
    && unzip terraform.zip -d /usr/local/bin \
    && rm terraform.zip

# Install kubectl
ARG KUBECTL_VERSION=1.32.0
RUN set -eux; \
    curl -LO https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl \
    && install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl \
    && rm kubectl

# Install AWS CLI
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
     && unzip awscliv2.zip \
     && ./aws/install --bin-dir /usr/local/bin --install-dir /usr/local/aws-cli --update \
     && rm -rf awscliv2.zip ./aws

# Set the PATH for the non-root user
ENV PATH="/home/${BUNDLE_USER}/.local/bin:${PATH}"

# Set the working directory
WORKDIR /terraform

# Copy the bundle directory into the image
COPY . .

# Set ownership of the bundle directory
RUN chown -R ${BUNDLE_USER}:${BUNDLE_UID} /terraform

# Switch to the non-root user
USER ${BUNDLE_USER}

# Entrypoint for the container
CMD ["./run.sh", "apply", "all"]
