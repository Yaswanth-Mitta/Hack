#!/bin/bash

# Initialize the Kubernetes control plane.
# This command sets up all core components for the master node.
kubeadm init

# --- Kubectl Configuration ---
# Create the necessary directory for the Kubernetes config file.
mkdir -p /home/ubuntu/.kube
# Copy the admin config file, which allows you to interact with the cluster.
cp /etc/kubernetes/admin.conf /home/ubuntu/.kube/config
# Set the correct ownership so the 'ubuntu' user can access the config file.
chown ubuntu:ubuntu /home/ubuntu/.kube/config

# --- Networking (CNI) Setup ---
echo "Installing Weave Net..."
# Apply the Weave Net CNI to enable pod-to-pod communication.
sudo -u ubuntu kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml

# --- Cluster Validation ---
echo "Waiting for node to become Ready..."
# Wait in a loop until the node reports its status as 'Ready'.
until sudo -u ubuntu kubectl get nodes | grep -q ' Ready '; do
    echo "Node not ready yet, waiting..."
    sleep 5
done

# --- Taint Removal ---
echo "Removing control-plane taint..."
# Remove the taint from the master node so it can schedule pods.
sudo -u ubuntu kubectl taint node $(hostname) node-role.kubernetes.io/control-plane:NoSchedule- || true

# --- Pod Readiness Check ---
echo "Waiting for kube-system pods to be Ready..."
# Wait until all pods in the kube-system namespace are running or completed.
until sudo -u ubuntu kubectl get pods -n kube-system | grep -Ev 'STATUS|Running|Completed' | wc -l | grep -q '^0'; do
    echo "Waiting for system pods..."
    sleep 10
done

# --- Final Status ---
echo "Kubernetes control-plane setup complete!"
echo "Cluster status:"
# Display the final status of the nodes and pods.
sudo -u ubuntu kubectl get nodes
sudo -u ubuntu kubectl get pods --all-namespaces
