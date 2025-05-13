# Inception of things

## Part 1 : Setting Up K3s with Vagrant
This section will cover configuring a Vagrant setup to use the stable Alpine Linux version to build two virtual machines. On both of them, we will install K3s. The first machine will run as the controller (Server), and the second as the agent (ServerWorker).
 ## Part 2: Using K3s to Deploy Three Web Applications
In this phase, we will set up three web applications on a single virtual machine to improve our understanding of K3S. Install K3s in server mode with the most latest stable version of your choice Linux distribution.
The goal is to set up three different web applications in your K3s instance. These applications should be accessible based on the HOST headers in requests sent to the IP address 192.168.56.110.
Basically how it should work:
  * If 'app1.com' is set as the HOST header, the server will display 'app1'.
  * If 'app2.com' is set as the HOST header, the server will display 'app2'.
  * 'app3' require to be shown on the server by default.
## Part 3: K3d and Argo CD
In this stage of the project, we installed K3d, a light Kubernetes distribution that runs on Docker, and then integrated continuous deployment using Argo CD without the use of Vagrant. The procedure followed was:

Installation of K3d on a virtual machine, and preparation of Docker with its software.
Differentiate between K3s and K3d.
Here, I will show how to create a CI/CD pipeline using the Argo CD on a cluster with two namespaces: one for Argo CD itself and another named 'dev' for deploying apps via Argo CD from a GitHub repository.
Create public repositories on GitHub and Docker Hub to store application configurations with Docker images, including versioning using tags, i.e., v1 and v2.

## Bonus: Integrating GitLab with K3d and Argo CD
This advanced bonus exercise is the next step following the previous work of K3d and Argo CD; that would be integrating them further with the addition of GitLab into this set-up. I wanted to see this extended integration because:

A recent version of GitLab was installed on localhost.
I configured the settings for GitLab to integrate it perfectly into the cluster.
I created on this cluster a namespace called 'gitlab'.
Make sure the continuous integration/deployment pipeline of Part 3 runs without hiccups with the local GitLab server.

This bonus assignment was done in a new 'bonus' folder at the root of my repository; it includes all configurations and scripts necessary for the cluster to work as intended
