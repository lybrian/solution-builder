![Alt](http://www.scientificcomputing.com/sites/scientificcomputing.com/files/openpower_foundation_ml.jpg#right)

OpenPOWER Solution Enablement Kit
====================================
## Solution Builder - A Service Oriented Orchestrator

### The goal of this project is build a modular but expandable solution orchestrator that deploys a solution quickly with minimum intervention in single node, docker nodes, virtual nodes, and multi nodes bare-metal cluster. In additional, this project aim is to develop a framework that allows for easy repeatability and for sharing of complex, multi-service deployments.

### Key Features:
- Deploy a service or collection of services (Solution) in a distributed fashion 
- Configure 
- Manage
- Scale
- Expandable
- Shareable - i.e Application-specific knowledge
- Repeatable

##### Suported platform:
- Bare metal.
- Docker container
- VM 

##### Suported OS:
- Ubuntu 
- Fedora, Centos, and RHEL 

##### Supported Cluster Type:
- OpenPOWER
- Intel 
- Hybrid (x86 and OpenPower)
- VMs and Docker
- Cloud

##### Installer Platform:
- Any Linux or OS X platform with SSH support

##### A Brief Outline of scripts and files included in this project and their function follows:
-   **solution_definition_template** - A Solution Definition file defines a collection of services and their relationships. It is designed to give you an entire working deployment in one easy to use collection. It can be use in two distinct ways. One is to use it locally ( using Docker or KVM cluster) from your computer, which is useful to initially ensure that your solution works and for experimenting. After you are satisfied with the solution definition file, you can push it to github where it will be available to you and others.
-   **deploy_solution.sh** - Downloads, installs, configures, and starts all of the servicess defined in the solution definition file.
-	  **remove_solution.sh** - Remove all servicess defined in the solution definition file.
-   **start_solution.sh** - Start all servicess defined in the solution definition file.
-   **stop_solution.sh** - Stop all servicess defined in the solution definition file.
-   **solution_status.sh** - Display status of all servicess defined in the solution definition file.
-	  **init_ssh_nodes.sh** - A utiltiy script to set ssh passwordless connection to all the nodes defined in the solution definition file.
- **services** - Conllection of services contributed by their domanin expert.

##### A Sample Solution - Apache Bigtop Orchestrator.
- Java Open JDK 1.8 
- Apache Bigtop  v1.2+ 
  * Hadoop  v2.7.3
  * Spark  v1.6.2 / Spark 2.1
  * Zeppelin  v0.6.2
  * Bigtop-groovy  v2.4.4
  * jsvc  v1.0.15
  * Tomcat  v6.0.36
  * Apache Zookeeper  v3.4.6
- Scala  v2.10.4
- python
- openssl
- snappy
- lzo

Lets Start 
========
###Typical Deployment Flow
![Alt](https://github.com/OpenPOWER-BigData/solution-builder/blob/master/doc/deployment-flow.png)
###Solution Managment Flow
![Alt](https://github.com/OpenPOWER-BigData/solution-builder/blob/master/doc/solution_man.png)

### Cluster prep
- Creating User Account in All Nodes

Example for Ubuntu:
```
sudo useradd bd_user -U -G sudo -m
sudo passwd bd_user
```
Example for RHEL/Centos/Fedora:
```
sudo useradd bd_user -U -G wheel -m
sudo passwd bd_user
```
**IMPORTANT - The username must match service's username defined in the solution definition file **
- Ensure the root password is the same on all cluster  nodes
- Ensure the username (i.e. bd_user) has the same password on all cluster node.
- Ensure SSH daemon is running on all the nodes.
- Mapping the nodes - You have to edit hosts file in /etc/ folder on ALL nodes, specify the IP address of each system followed by their host names. Example
```
# sudo vim /etc/hosts
Append the following lines in the /etc/hosts file.
192.168.1.1 hadoop-master 
192.168.1.2 hadoop-slave-1 
192.168.1.3 hadoop-slave-2
.....
.....
```
- RHEL bug workaround - default requiretty field in /etc/sudoers is problematic 
Red Hat has acknowledged the problem nad it will be removed in future releases https://bugzilla.redhat.com/show_bug.cgi?id=1020147
Workaround: Remove below field from /etc/sudoers on all nodes
```
Defaults requiretty
```
###Installer Node 
####Node Requirements
- Any Linux or OS x system
  * Must have ssh and sshpass installed
  * sshpass for Mac OS x - https://fauxzen.com/installing-sshpass-os-x/   
- OpenPower or x86 architecture 
####Installer Node Setup
- download Solution Builder
> git clone https://github.com/OpenPOWER-BigData/solution-builder.git 
- Use the solution_definition_template file to build your own custom solution
- Add/remove services as needed - Please refer to section "Create a New Solution"
- Example of solution definition file for deploying Apache Bigtop 1.2
```code
# A Solution Definition File is a collection of services and their relationships, designed to
# give you an entire deployment in one easy to use step. Defines the topology of the solutions.
# Each line represent a service and is consist of comma-separated fields:
# 1) Service Name
# 2) Aditional required service on the same node
# 3) Target node's IP/Hostname
# 4) Service's user (not root) 
# 5) Configuration and connections values for the service, must be comma-separated.
# Example: Apache Bigtop Deployment
#################### Master node #############################
#### Hadoop master node includes namenode, resourcemanager, and spark-master services      ###
#### All Hadoop services have depdency on hadoop-client service
#### Note: last three arguments must be the hostname of the master node                    ### 
hadoop-namenode,hadoop-client,172.17.0.2,bd_user,master,master,master
hadoop-resourcemanager,hadoop-client,172.17.0.2,bd_user,master,master,master
spark-master,hadoop-client,172.17.0.2,bd_user,master,master,master
#################### Worker Node 1 #############################
#### Includes datanode, nodemanager, and spark worker services          ###
#### Note: last three arguments must be the hostname of the master node ### 
hadoop-datanode,hadoop-client,172.17.0.3,bd_user,master,master,master
hadoop-nodemanager,hadoop-client,172.17.0.3,bd_user,master,master,master
spark-worker,hadoop-client,172.17.0.3,bd_user,master,master,master
#################### Worker Node 2 #############################
hadoop-datanode,hadoop-client,172.17.0.4,bd_user,master,master,master
hadoop-nodemanager,hadoop-client,172.17.0.4,bd_user,master,master,master
spark-worker,hadoop-client,172.17.0.4,bd_user,master,master,master
#################### Worker Node 3 #############################
hadoop-datanode,hadoop-client,172.17.0.5,bd_user,master,master,master
hadoop-nodemanager,hadoop-client,172.17.0.5,bd_user,master,master,master
spark-worker,hadoop-client,172.17.0.5,bd_user,master,master,master
#################### Apache Zeppelin Serivce  #####################
zeppelin,hadoop-client,172.17.0.6,bd_user,master,master,master
```
## Solution Management 
### Deployment
- deploy_solution.sh --sd <solution definition file name> {solution level arguments}. Solution level arguments are vsisble to all install.sh and config.sys scripts
```
./deploy_solution.sh --sd solution_definition_template --spark-version 2.1
```
### Status of Services
```
./solution_status.sh --sd solution_definition_template
```
### Test Hadoop/Spark Services
- Test Spark deployment using ssh: **ssh {solution user name}:{namenode IP address} "bash -s" < test/sparkTest.sh**
```
ssh ubuntu@172.17.0.2 "basg -s < test/sparkTest.sh"
```
- Test Hadoop Deployment: **ssh {solution user name}:{namenode IP address} "bash -s" < test/hadoopTest.sh**
```
ssh ubuntu@172.17.0.2 "bash -s" < test/hadoopTest.sh 
```
### Stop Services
```
./stop_solution.sh --sd solution_def_bigtop
```
### Start Services
```
./start_solution.sh --sd solution_def_bigtop
```
