FROM codercom/code-server:v2

LABEL Name=Devbox Image=Ubuntu Ide=CodeServer

USER root

RUN apt-get update && apt-get install python3-pip unzip -y && \
    # TOOL 1 : AWSCLI + ANSIBLE
    pip3 install awscli ansible

    # TOOL 2 : KUBECTL
RUN KUBECTL_BIN=kubectl && \
    KUBECTL_URL=https://storage.googleapis.com/kubernetes-release/release && \
    curl -LO $KUBECTL_URL/$(curl -s $KUBECTL_URL/stable.txt)/bin/linux/amd64/$KUBECTL_BIN && \
    chmod +x ${KUBECTL_BIN} && \
    mv ${KUBECTL_BIN} /usr/local/bin/${KUBECTL_BIN}

    # TOOL 3 : KOPS
RUN KOPS_URL=https://api.github.com/repos/kubernetes/kops/releases/latest && \
    KOPS_URL_BASE=https://github.com/kubernetes/kops/releases/download && \
    KOPS_VERSION=$(curl -s $KOPS_URL | grep tag_name | cut -d '"' -f 4) && \
    curl -LO $KOPS_URL_BASE/$KOPS_VERSION/kops-linux-amd64 && \
    chmod +x kops-linux-amd64 && \
    mv kops-linux-amd64 /usr/local/bin/kops
    
    # TOOL 4 : TERRAFORM
RUN TERRAFORM_VERSION=$(curl https://api.github.com/repos/hashicorp/terraform/releases/latest | grep tag_name | cut -d '"' -f 4 | cut -d 'v' -f 2) && \
    TERRAFORM_ZIP_FILE=terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    TERRAFORM_URL=https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION} && \
    TERRAFORM_BIN=terraform && \
    curl -LO ${TERRAFORM_URL}/${TERRAFORM_ZIP_FILE} && \
    unzip ${TERRAFORM_ZIP_FILE} && \
    sudo mv ${TERRAFORM_BIN} /usr/local/bin/${TERRAFORM_BIN} && \
    rm -rf ${TERRAFORM_ZIP_FILE}

# Setting up user

RUN adduser --gecos '' --disabled-password devops && \
	echo "devops ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/nopasswd

USER devops
# We create first instead of just using WORKDIR as when WORKDIR creates, the user is root.
RUN mkdir -p /home/devops/project && \
    chgrp -R 0  /home/devops && \
    chmod -R g=u /home/devops

WORKDIR /home/devops/project

# Enable authentication (require PASSWORD env variable)
CMD ["code-server --auth password"]
