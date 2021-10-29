


NODES

sudo touch /etc/systemd/zram-generator.conf
sudo grubby --update-kernel=ALL --args="systemd.unified_cgroup_hierarchy=0"
sudo reboot

sudo su
modprobe br_netfilter
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

sysctl --system
firewall-cmd --list-all

## PORTS IN MASTER
firewall-cmd --add-port=6443/tcp --permanent
firewall-cmd --add-port=2379-2380/tcp --permanent
firewall-cmd --add-port=10250-10252/tcp --permanent

#PORTS IN NODES
firewall-cmd --add-port=10250/tcp  --permanent
firewall-cmd --add-port=30000-32767/tcp --permanent

cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-\$basearch
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kubelet kubeadm kubectl
EOF

# Set SELinux in permissive mode (effectively disabling it)
setenforce 0
sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes

systemctl enable --now kubelet



kubeadm join 172.16.39.176:6443 --token 8w2tjn.u7m719zsp0smoww8 \
	--discovery-token-ca-cert-hash sha256:97abc720d6f8c1fa078c2eb6781f37bd172c3bf11ba417245b121238d866fd57
