k3d cluster create lbcluster --api-port 6550 -p "8081:80@loadbalancer" --agents 2