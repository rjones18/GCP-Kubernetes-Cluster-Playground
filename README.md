# GCP-Kubernetes-Cluster-Playground


In the GCP Kubernetes Cluster Playground project, I've successfully orchestrated a Kubernetes cluster, leveraging GCP's robust infrastructure to configure three virtual machines: one master node and two worker nodes. The project's backbone is a streamlined Continuous Deployment (CD) pipeline, achieved by integrating a GitHub repository with Google Cloud Source Repositories. This setup ensures a smooth development workflow and consistent updates.

Enhancing the reliability of the project, Cloud Build is integrated for the automated deployment of Terraform IAC for the creation of the Virtual Machines/Pipeline. Additionally, three custom bash scripts were crafted to automate the initial configuration of each VM, laying the groundwork for a seamless cluster formation. Security is fortified with the inclusion of Snyk, providing vigilant vulnerability monitoring and maintaining the cluster's defenses against emerging threats.

## Architecture Breakdown

![app](https://github.com/rjones18/Images/blob/main/Kubernetes%20Playground.png)
