---
layout: post
title:  "Kubernetes Cluster on Fedora Coreos"
date:   2021-10-03 12:02:03
categories: [devops]
tags: [devops, k8s]
---

This post setup K8s Cluster on Fedora CoreOS (Fcos) with VirtualBox VM. However, if your host is Linux then Qemu/KVM is preferred choice and [K8s Cluster with Qemu/KVM](https://www.codetab.org/post/kubernetes-cluster-qemu) explains the setup for that environment.

## Fedora CoreOS

Fedora CoreOS (fcos) is a minimal operating system designed for running containerized workloads at scale. Fcos image is about 750MB and unlike Ubuntu server, comes with pre-installed Docker. I could spinoff VM with OS installation in 10 minutes and a three node fcos K8s cluster in 30 minutes. It takes just 12GB of disk space, and the cluster is blazing fast without the overhead of extra services.

However, there is a catch. The design of Fedora CoreOS is quite different from the regular, run-of-the-mill, Linux distro. Where else you can find /usr directory that is not writable; new package install spins of a new os image; ships with a single user without password and worst still, can’t set or reset that user. Nothing is same in Fcos because it is designed for fast and secured rollout of cluster nodes in high end data centers.

Frustrated, I almost gave up after a day. Then on second try, I got hang of it; in the end, it is much easier to setup K8s cluster on Fcos than on Ubuntu.

This post lists all the steps to create Fcos base VM and clone it to setup three node cluster. This is not a tutorial on how to spinoff a VM, how to change its settings, how to create a network adaptor or on kubernetes as there are enough tutorials out there on these things. Again, if you are new to Kubernetes then familiarize with K8s by working through [Kubernetes and Minikube Tutorial](https://kubernetes.io/docs/tutorials/) found in official site and then, try to setup a multi node cluster.

## Download Fedora CoreOS

We use Fedora CoreOS Bare Metal ISO and you can download it from [Fedora CoreOS Downloads](https://getfedora.org/en/coreos/download?tab=metal_virtualized&stream=stable)

## Setup VirtualBox Base VM

Steps to create VirtualBox VM for Fcos are as follows

* create Ignition File in host
* create and configure VM and networks
* start VM and boot into Fedora CoreOS Live Environment
* copy ignition file from host to guest
* install Fedora CoreOS

### Create Ignition File

On first boot, Fcos uses a json file known as Ignition file to configure and provision the new system. With text editor, create yaml file base-config.yaml with following contents,

{% highlight yaml %}
variant: fcos
version: 1.1.0
passwd:
  users:
    - name: k
      groups:
        - docker
        - wheel
        - sudo
      password_hash: <replace-this>
      ssh_authorized_keys:
        - <replace-this>
storage:
  files:
    - path: /etc/sysctl.d/20-silence-audit.conf
      contents:
        inline: |
                    kernel.printk=4
    - path: /etc/hostname
      mode: 420
      contents:
        source: "data:,fcos"
    - path: /etc/NetworkManager/system-connections/enp1s0.nmconnection
      mode: 0600
      overwrite: true
      contents:
        inline: |
          [connection]
          type=ethernet
          id="Wired connection 1"
          interface-name=enp0s3

          [ipv4]
          method=manual
          addresses=192.168.99.100/24
          gateway=192.168.99.1
          dns=192.168.99.1;8.8.8.8          
{% endhighlight %}

On first boot, the ignition file provisions

* a new user `k`
* adds the user to docker, wheel and sudo groups
* sets hostname to fcos
* reduces audit level to warn so that debug messages are not spewed to console
* configures static IP for the interface.

In the yaml file you have to replace two fields - `password_hash`, `sshAuthorizedKeys`.

For `password_hash`, generate password hash with `mkpasswd --method=md5crypt` , enter some password of your choice and copy the generated hash to password_hash field. Windows users have to use Cygwin mkpasswd utility to generate the hash.

The `sshAuthorizedKeys` allows password less login via ssh and in case, you don’t need this feature you may remove the field from the file. Otherwise, copy the content of your ssh public key to sshAuthorizedKeys field. On Linux, you can find it in $HOME/.ssh/id_rsa.pub or you can create a new one with ssh-keygen. In Windows, use Putty to generate and manage ssh key.

In the connection definition, interface and id may vary depending on the network setup. Only way to confirm is to create a test VM and boot Fedora CoreOS and find out the interface name with ip a and connection id with nmcli connection.

Now, compile yaml definition to ignition format. If you have docker, then you can compile with following command.

{% highlight bash %}
docker run -i --rm quay.io/coreos/fcct:release --pretty --strict < base-config.yaml > base-config.ign
{% endhighlight %}

In case, docker is not installed in your PC, then download appropriate fcct binary from [Coreos Fcct Releases](https://github.com/coreos/fcct/releases) and compile the yaml,

{% highlight bash %}
fcct --pretty --strict < base-config.yaml > base-config.ign
{% endhighlight %}

Once you are ready with the file, move on to create base VM.

### Create Base VM

We need two network interfaces on each VM - one interface to connect from PC (host) to VM (guest) and another interface to connect, from with VM, to the internet. Start VirtualBox Manager, open File -> Host Network Manager and create a Host-only network (normally, named as vboxnet0, vboxnet1 etc.,) and edit the properties as,

* Adapter
    * choose Configure Adapter Manually
    * IPv4 Address: 192.168.99.1
    * Mask: 255.255.255.0
* DHCP
    * Disable Server

When editing interface properties, if IP is not changing as expected, twice change and apply!

The host-only network is used to open ssh connection from host to guest. By default, K8s pod container network interface (cni) uses subnet 192.168.99.0/24, so we go with that.

Next, find out the network interface that is used by the your PC (host) to connect to the internet. For example, I use a wifi connection and its interface is something like wlx98dexxxx.

Create VM named `fcos` with following configuration,

* Type: Linux
* Version: Linux 64 bit
* RAM: 2048G
* Storage: VDI, dynamic disk, capacity 8 GB

After its creation, go to settings and set CPU count to 2. Next, in the VM Network settings, attach Adapter 1 to Host-Only Adapter and select the Host-Only network that we created earlier. Attach Adapter 2 to Bridge Adapter and select the interface used by the host to connect to the internet.

By default, K8s picks the first interface to configure its network, so make sure that Adapter 1 is attached to Host-Only Network. The Adapter 2 should be the interface to internet.

Enable net connection on host and start the VM. In Select Startup Disk window, choose the downloaded Fedora CoreOS image and start. Once os boots, it auto login to Fedora CoreOS Live Environment.

### Get Ignition File to Guest

Earlier, we had created Ignition file `base-config.ign` on host. To install OS, we have to get it from host to guest. Easiest option is to use python http server,

{% highlight bash %}
# on host, run from the ignition file's directory 
python3 -m http.server

# on guest
# find the interface name, normally enp0s3
ip a      

# temporarily allot static IP in guest
sudo ip addr add 192.168.99.100/24 dev enp0s3

curl -LO 192.168.99.1:8000/base-config.ign
{% endhighlight %}

As we have disabled DHCP while creating the virtual network, set static IP and the use curl. The ip addr add temporarily sets the static ip to interface. However, it is not stable, may unset before you do curl before you try scp. Use up-arrow, again set the ip and retry scp. I know this not elegant solution, but with couple of tries you should be able to copy the file to guest.

Alternatively, if you have ssh server on host, use scp to get the file to guest.

{% highlight bash %}
# on host - start open ssh server
sudo systemctl start ssh

# on guest
# find the interface name, normally ens3
ip a      

# temporarily allot static IP in guest
sudo ip addr add 192.168.99.100/24 dev ens3

# copy ignition file from host to VM
scp <user_id>@192.168.99.1:base-config.ign .
{% endhighlight %}

## Install Fedora CoreOS

At this point, Fedora CoreOS Live Environment runs entirely from system memory and we have manually install the os.

VM boots to CoreOS Live Environment which runs completely from memory and we have to manually install the os to disk. To install Fcos, run following command,

{% highlight bash %}
sudo coreos-installer install /dev/sda -i base-config.ign
{% endhighlight %}

It extracts the os (around 3GB) from image and copies it to VM storage file. Installation completes within 2 minutes and after installation, don’t reboot; instead shutdown with `sudo init 0`.

Once guest is shutdown, in VM Manager, open its Settings -> Storage and select Fedora-coreos-xxxx.iso installation media and type - key to remove the attached ISO image; otherwise on VM reboot, you will land again in Live Environment instead of installed OS. Start the guest and on first boot, fcos provisions the new system by running the `base-config.ign` and presents the login prompt. Login with user id k and the passwd your have provided to create the password hash earlier.

Troubleshoot:

fcos hangs on first boot after os installation: cause, syntax error in base-config.ign. Correct the ignition file and delete and create new VM; start fresh installation.
It is cumbersome to work in guest console, rather I prefer to work from host console with ssh. Run ip a on guest console to find its ip and use it to make ssh connection from host.

{% highlight bash %}
ssh k@192.168.99.100
{% endhighlight %}

## Install Packages

Kubeadm has dependency on conntrack and ethtool packages, so install them with,

{% highlight bash %}
sudo rpm-ostree install conntrack ethtool

sudo systemctl reboot
{% endhighlight %}

In case of “error: Transaction in progress: …”, wait for any running rpm-ostree process to finish. This happens when there is a new release of Fcos and node automatically upgrades to new version. As last resort, you can cancel transaction with sudo rpm-ostree cancel.

The rpm-ostree is the package manager used by Fcos, which installs packages as layers above the base os image. On reboot, in boot menu, we can see two os trees - ostree:0 (after installation of conntrack and ethtool) and ostree:1 (base os); and boot any of them. The top one is the latest. We can also view the ostree with sudo rpm-ostree status.

## Setup Docker
The container runtime, Docker uses either systemd or cgroupfs as cgroup managers. For a stable K8s cluster, it is advised to use systemd as cgroup manager. On guest, run

{% highlight bash %}
sudo systemctl start docker
sudo systemctl enable docker

sudo touch /etc/docker/daemon.json
cat <<EOF | sudo tee /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2",
  "storage-opts": [
    "overlay2.override_kernel_check=true"
  ]
}
EOF

sudo mkdir -p /etc/systemd/system/docker.service.d

sudo touch /etc/systemd/system/docker.service.d/docker.conf
cat <<EOF | sudo tee /etc/systemd/system/docker.service.d/docker.conf
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd
EOF

sudo systemctl daemon-reload
sudo systemctl restart docker
{% endhighlight %}

Check the docker setup by executing docker run hello-world

## Install K8s Toolbox

The K8s toolbox consists of kubeadm, kubectl and kubelet. Install them with,

{% highlight bash %}
CNI_VERSION="v0.8.2"
sudo mkdir -p /opt/cni/bin
curl -L "https://github.com/containernetworking/plugins/releases/download/${CNI_VERSION}/cni-plugins-Linux-amd64-${CNI_VERSION}.tgz" | sudo tar -C /opt/cni/bin -xz

DOWNLOAD_DIR=/usr/local/bin
sudo mkdir -p $DOWNLOAD_DIR

CRICTL_VERSION="v1.17.0"
curl -L "https://github.com/kubernetes-sigs/cri-tools/releases/download/${CRICTL_VERSION}/crictl-${CRICTL_VERSION}-Linux-amd64.tar.gz" | sudo tar -C $DOWNLOAD_DIR -xz

RELEASE="$(curl -sSL https://dl.k8s.io/release/stable.txt)"
cd $DOWNLOAD_DIR
sudo curl -L --remote-name-all https://storage.googleapis.com/kubernetes-release/release/${RELEASE}/bin/linux/amd64/{kubeadm,kubelet,kubectl}
sudo chmod +x {kubeadm,kubelet,kubectl}

RELEASE_VERSION="v0.4.0"
curl -sSL "https://raw.githubusercontent.com/kubernetes/release/${RELEASE_VERSION}/cmd/kubepkg/templates/latest/deb/kubelet/lib/systemd/system/kubelet.service" | sed "s:/usr/bin:${DOWNLOAD_DIR}:g" | sudo tee /etc/systemd/system/kubelet.service
sudo mkdir -p /etc/systemd/system/kubelet.service.d
curl -sSL "https://raw.githubusercontent.com/kubernetes/release/${RELEASE_VERSION}/cmd/kubepkg/templates/latest/deb/kubeadm/10-kubeadm.conf" | sed "s:/usr/bin:${DOWNLOAD_DIR}:g" | sudo tee /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

sudo systemctl enable --now kubelet
{% endhighlight %}

Allow iptables to see bridged traffic,

{% highlight bash %}
cat <<EOF | sudo tee /etc/sysctl.d/K8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

sudo sysctl --system
{% endhighlight %}

Shut it down with `sudo init 0`. We are done with the base VM, no more install or setup. We are ready to clone it to create other nodes - master and workers.

## Clone Master Node

Create a clone of `fcos` with these options,

* Name: master
* Clone Type: Full clone
* MAC Address Policy: Generate new MAC address for all network adapters
* Keep Disk Names: unchecked
* Keep Hardware UUIDs: unchecked

Start the master and login through `ssh k@192.168.99.100` and execute following commands,

{% highlight bash %}
sudo hostnamectl set-hostname master

# ensure that product_uuid is unique
sudo cat /sys/class/dmi/id/product_uuid

# reset machine id to product uuid
sudo rm /etc/machine-id
sudo systemd-machine-id-setup
sudo systemd-machine-id-setup --commit

# change static ip 
sudo nmcli connection   # find the <connection name>

sudo nmcli connection mod <connection-name> \
     ipv4.method manual \
     ipv4.addresses 192.168.99.101/24 \
     ipv4.gateway 192.168.99.1 \
     ipv4.dns 192.168.99.1 \
     +ipv4.dns 8.8.8.8 \
     connection.autoconnect yes

sudo systemctl restart NetworkManager
sudo systemctl reboot   
{% endhighlight %}

After VM reboot, login to master with the new ip `ssh k@192.168.99.101`.

## Setup Master Node with Control Plane

On master node, we initialize the kubeadm so that it works as K8s API Server and control plane. Normally, master node is initialized with `sudo kubeadm init --apiserver-advertise-address=192.168.99.101 --pod-network-cidr=192.168.0.0/16` . In FCOS, this is not going to work as the Fcos `/usr` directory is read-only and kublet-plugins are not able to write to it. To change kubelet plugins directory, we need to use a config file to pass initialization configs to kubeadm. Create config file, kubeadm-init.yaml, by executing following command in master node.

{% highlight bash %}
cat << EOF > kubeadm-init.yaml
apiVersion: kubeadm.k8s.io/v1beta2
kind: InitConfiguration
nodeRegistration:
  kubeletExtraArgs:
    volume-plugin-dir: "/opt/libexec/kubernetes/kubelet-plugins/volume/exec/"
localAPIEndpoint:
  advertiseAddress: "192.168.99.101"
---
apiVersion: kubeadm.k8s.io/v1beta2
kind: ClusterConfiguration
networking:
  podSubnet: "192.168.0.0/16"
controllerManager:
  extraArgs:
    flex-volume-plugin-dir: "/opt/libexec/kubernetes/kubelet-plugins/volume/exec/"
apiServer:
  extraArgs:
    advertise-address: 192.168.99.101

EOF
{% endhighlight %}

It indicates that,

* control manager and nodes should use `/opt/libexec` as the kubernetes volume instead of default `/usr/libexec`. The /opt is writable in Fcos.
* API server advertise address is 192.168.99.101, i.e. primary ip of master node.
* Pods subnet is 192.168.0.0/16

With the config file, run kubeadm init on master node.

{% highlight bash %}
sudo kubeadm init --config kubeadm-init.yaml
{% endhighlight %}

Init pulls K8s images and starts various pods. At the end of kubeadm init messages, a join command is displayed; save it somewhere as we need it to join worker nodes to cluster. Copy the admin.conf file to your $HOME/.kube directory so that you can run kubectl commands as normal user.

{% highlight bash %}
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

watch kubectl get pods --all-namespaces 
{% endhighlight %}

Watch cluster creation till all pods reach `Running` state except coredns pods which reach `ClusterCreating` or `Pending` state.

### Install Pod Network Add-on

Pods communicates through `Container Network Interface (CNI)` based Pod Network Add-on and Calico is one such add-on. To install calico, download `calico.yaml` and apply in master node.

{% highlight bash %}
curl https://docs.projectcalico.org/manifests/calico.yaml -O

# replace all `/usr/libexec` to `/opt/libexec`
sed -i 's/usr\/libexec/opt\/libexec/g' calico.yaml

kubectl apply -f calico.yaml

watch kubectl get pods --all-namespaces 
{% endhighlight %}

It pulls calico container images. Once Calico pods are up and running the coredns pods should change to Running state.

Now, master node, with K8s api server and control-plane, is ready and kubectl get nodes should now show one node cluster with master in Ready state.

If something goes wrong during init, clean up and revert back with sudo kubeadm reset and try init again.

For more info: [Calico Add on](https://docs.projectcalico.org/getting-started/kubernetes/self-managed-onprem/onpremises)

## Setup worker node

Create second clone of `fcos` and name it `worker1`. Steps are same as explained when we cloned master, but with following changes,

In virt-clone command,

* clone name: worker1
* file: worker1.qcow2

In hostnamectl command

* host name: worker1

In nmcli connection mod command,

* ipv4.addresses: 192.168.99.102/24

Reboot worker1 and login with `ssh k@192.168.99.102`.

## Join the K8s Cluster

As already explained in master node section, we can’t use kubeadm join cli method; so, we go with config file method.

To join the cluster, worker node needs `token` and `discovery-token-ca-cert-hash` which was part of join command displayed when we setup master. If you haven’t noted down the join command, then find out token and cert-hash with these commands in the `master` node.

{% highlight bash %}
# run in master node to get token
kubeadm token list

# run in master node to get caCertHash
openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //'
{% endhighlight %}

Next, in worker1 node, assign token and cert-hash values to variable and create kubeadm-join.yaml config file.

{% highlight bash %}
JOIN_TOKEN=<paste-token-from-master-here>
JOIN_CERT_HASH=<paste-cert-hash-from-master-here>

cat <<EOF > kubeadm-join.yaml
apiVersion: kubeadm.k8s.io/v1beta2
kind: JoinConfiguration
nodeRegistration:
  kubeletExtraArgs:
    volume-plugin-dir: "/opt/libexec/kubernetes/kubelet-plugins/volume/exec/"
discovery:
  bootstrapToken:
    apiServerEndpoint: 192.168.99.101:6443
    token: ${JOIN_TOKEN}
    caCertHashes:
    - sha256:${JOIN_CERT_HASH}
EOF

# verify whether variables are substituted properly 
cat kubeadm-join.yaml

# if variables are not replaced in config file then use envsubst 
{% endhighlight %}

To join the worker1 to cluster, execute sudo kubeadm join --config kubeadm-join.yaml in worker1 node.

On master run watch `kubectl get pods --all-namespaces`. It may take about 2 to 3 minutes as it pulls calico and K8s images. Once all pods are up and running, fire `kubectl get nodes` and both master and worker1 are part of K8s cluster and in `Ready` state.

Clone one more node, worker2, from base VM and join it to cluster.

For more info: [K8s - Join your nodes](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/#join-nodes)

Via systemctl, we have enabled docker and kubelet services to start on system boot. Once docker and kubelet are up, K8s cluster starts and synchronizes on its own.

## Access Cluster from Host
While it is fine to administer the cluster from master, it is quite convenient to do it from the host. For that, all you have to do is to install `kubectl` in the host and copy the `$HOME/.kube/config` file from master node to hosts `$HOME/.kube` directory and you are good to go.

 