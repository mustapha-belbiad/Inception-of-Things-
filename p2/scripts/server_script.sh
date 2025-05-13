curl -sfL https://get.k3s.io | K3S_KUBECONFIG_MODE="644" INSTALL_K3S_EXEC="--flannel-iface eth1" sh -
sleep 10


kubectl create configmap configmap-app1 --from-file=index.html=/vagrant/confs/app1/index.html
kubectl create configmap configmap-app2 --from-file=index.html=/vagrant/confs/app2/index.html
kubectl create configmap configmap-app3 --from-file=index.html=/vagrant/confs/app3/index.html

kubectl apply -f /vagrant/confs/app1/deployment.yml
kubectl apply -f /vagrant/confs/app2/deployment.yml
kubectl apply -f /vagrant/confs/app3/deployment.yml
