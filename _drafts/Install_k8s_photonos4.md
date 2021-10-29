# INSTALL KUBERNETES IN PHOTON 4 USING KUBEADM

## MASTER NODES

### OPEN PORTS

Open required ports editing file `/etc/systemd/scripts/ip4save`.
Add the following ports:

```
-A INPUT -p tcp -m tcp --dport 6443 -j ACCEPT
-A INPUT -p tcp -m tcp --dport 10250 -j ACCEPT
```

Restart iptables

```
systemctl restart iptables
```

### PREPARE DOCKER


start Docker
```
systemctl start docker
systemctl enable docker
```

Docker needs to be in the cgroup named systemd create file `/etc/docker/daemon.json`.

```
cat <<EOF > /etc/docker/daemon.json
{
"exec-opts": ["native.cgroupdriver=systemd"]
}
EOF
```

```
systemctl daemon-reload
systemctl restart docker
```

### INSTALL KUBEADM

```
curl -o /etc/pki/rpm-gpg/GOOGLE-RPM-GPG-KEY https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
chmod 644 /etc/pki/rpm-gpg/GOOGLE-RPM-GPG-KEY
rpm --import /etc/pki/rpm-gpg/GOOGLE-RPM-GPG-KEY

cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/GOOGLE-RPM-GPG-KEY
EOF

tdnf update
tdnf install kubectl kubeadm kubelet -y
```


### RUN KUBEADM

Defin cluster-endpoint in hosts

```
systemctl enable kubelet
kubeadm init --control-plane-endpoint=cluster-endpoint --pod-network-cidr=10.244.0.0/16
```

The `--pod-network-cidr=10.244.0.0/16` option is a requirement for Flannel - don't change that network address!


### As a  user run

```
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

### Access your cluster

You can also access your cluster easily with Lens, simply by copying the kubeconfig and pasting it to Lens:

```
sudo cat $HOME/.kube/config
```


You can now join any number of control-plane nodes by copying certificate authorities
and service account keys on each node and then running the following as root:
```
  kubeadm join cluster-endpoint:6443 --token ar7lke.hctup24dxvbhlvn1 \
    --discovery-token-ca-cert-hash sha256:c28b1ff9de549c6a152f548b5541d3f2160c55530c4b4ab2f3f9382537306350 \
    --control-plane 
```
Then you can join any number of worker nodes by running the following on each as root:
```
kubeadm join cluster-endpoint:6443 --token ar7lke.hctup24dxvbhlvn1 \
  --discovery-token-ca-cert-hash sha256:c28b1ff9de549c6a152f548b5541d3f2160c55530c4b4ab2f3f9382537306350
```

# WORKER 