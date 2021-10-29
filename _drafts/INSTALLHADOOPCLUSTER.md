# INSTALL HADOOP CLUSTER

## What is hadoop.
Apache Hadoop is a collection of open-source software utilities that facilitates using a network of many computers to solve problems involving massive amounts of data and computation. It provides a software framework for distributed storage and processing of big data using the MapReduce programming model.

The core of Apache Hadoop consists of a storage part, known as Hadoop Distributed File System (HDFS), and a processing part which is a MapReduce programming model. Hadoop splits files into large blocks and distributes them across nodes in a cluster. It then transfers packaged code into nodes to process the data in parallel. This approach takes advantage of data locality, where nodes manipulate the data they have access to. This allows the dataset to be processed faster and more efficiently than it would be in a more conventional supercomputer architecture that relies on a parallel file system where computation and data are distributed via high-speed networking.

The base Apache Hadoop framework is composed of the following modules:

* Hadoop Common – contains libraries and utilities needed by other Hadoop modules;
* Hadoop Distributed File System (HDFS) – a distributed file-system that stores data on commodity machines, providing very high aggregate bandwidth across the cluster;
* Hadoop YARN – (introduced in 2012) a platform responsible for managing computing resources in clusters and using them for scheduling users' applications;
* Hadoop MapReduce – an implementation of the MapReduce programming model for large-scale data processing.
* Hadoop Ozone – (introduced in 2020) An object store for Hadoop

The term Hadoop is often used for both base modules and sub-modules and also the ecosystem, or collection of additional software packages that can be installed on top of or alongside Hadoop, such as Apache Pig, Apache Hive, Apache HBase, Apache Phoenix, Apache Spark, Apache ZooKeeper, Cloudera Impala, Apache Flume, Apache Sqoop, Apache Oozie, and Apache Storm.

Hadoop is an open-source Apache project that allows creation of parallel processing applications on large data sets, distributed across networked nodes. It is composed of the Hadoop Distributed File System (HDFS) that handles scalability and redundancy of data across nodes, and Hadoop YARN, a framework for job scheduling that executes data processing tasks on all nodes.

1. Add a Private IP Address to each Linode so that your Cluster can communicate with an additional layer of security.

2. Follow the Securing Your Server guide to harden each of the three servers. Create a normal user for the Hadoop installation, and a user called hadoop for the Hadoop daemons. Do not create SSH keys for hadoop users. SSH keys will be addressed in a later section.

```
useradd -m hadoop
useradd -aG sudo hadoop
```

3. Install the JDK using the appropriate guide for your distribution, Debian, CentOS or Ubuntu, or install the latest JDK from Oracle.
```
sudo apt-get install openjdk-8-jdk
```

4. The steps below use example IPs for each node. Adjust each example according to your configuration:

node-master: 192.0.2.1
node1: 192.0.2.2
node2: 192.0.2.3

This guide is written for a non-root user. Commands that require elevated privileges are prefixed with sudo. If you’re not familiar with the sudo command, see the Users and Groups guide. All commands in this guide are run with the hadoop user if not specified otherwise.

## Architecture of a Hadoop Cluster

A master node maintains knowledge about the distributed file system, like the inode table on an ext3 filesystem, and schedules resources allocation. node-master will handle this role in this guide, and host two daemons:

* The NameNode manages the distributed file system and knows where stored data blocks inside the cluster are.

* The ResourceManager manages the YARN jobs and takes care of scheduling and executing processes on worker nodes.

Worker nodes store the actual data and provide processing power to run the jobs. They’ll be node1 and node2, and will host two daemons:

* The DataNode manages the physical data stored on the node; it’s named, NameNode.

* The NodeManager manages execution of tasks on the node.


## Con

For each node to communicate with each other by name, edit the /etc/hosts file to add the private IP addresses of the three servers. Don’t forget to replace the sample IP with your IP:

File: /etc/hosts

```
192.0.2.1    node-master
192.0.2.2    node1
192.0.2.3    node2
````

Distribute Authentication Key-pairs for the Hadoop User

The master node will use an SSH connection to connect to other nodes with key-pair authentication. This will allow the master node to actively manage the cluster.

Login to node-master as the hadoop user, and generate an SSH key:

```
ssh-keygen -b 4096
```

When generating this key, leave the password field blank so your Hadoop user can communicate unprompted.
View the node-master public key and copy it to your clipboard to use with each of your worker nodes.

```
less /home/hadoop/.ssh/id_rsa.pub
```

In each Linode, make a new file master.pub in the /home/hadoop/.ssh directory. Paste your public key into this file and save your changes.

Copy your key file into the authorized key store.

```
cat ~/.ssh/master.pub >> ~/.ssh/authorized_keys
```

Download and Unpack Hadoop Binaries

Log into node-master as the hadoop user, download the Hadoop tarball from Hadoop project page, and unzip it:

cd
wget https://dlcdn.apache.org/hadoop/common/hadoop-3.3.1/hadoop-3.3.1.tar.gz
tar -xzf hadoop-3.3.1.tar.gz
mv hadoop-3.3.1 hadoop





