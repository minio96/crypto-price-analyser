.ONESHELL:
.SILENT: install-java

install-java: SHELL := bash
install-java: 
	export RELEASE=$$(awk -F= '/^NAME/{print $$2}' /etc/os-release | tr -d "\"")
	if [[ $${RELEASE} != "Ubuntu" ]]; then 
		echo "$${RELEASE} not supported for this installation method"
		exit 1; 
	fi
	if command -v java -version > /dev/null; then 
		echo "Already installed"
		exit 0; 
	fi
	sudo apt-get install -y openjdk-11-jdk

install-extra-tools: install-k3d install-dive install-dockle install-trivy install-docker-slim

install-k3d:
	export K3D_VERSION=5.2.2

	if command -v k3d >> /dev/null; then exit 0; fi
	wget -nc -q https://github.com/rancher/k3d/releases/download/v$${K3D_VERSION}/k3d-linux-amd64
	chmod +x k3d-linux-amd64
	sudo mv k3d-linux-amd64 /usr/local/bin/k3d

install-dive:
	export DIVE_VERSION=0.10.0

	if command -v dive; then exit 0; fi
	wget -nc -q https://github.com/wagoodman/dive/releases/download/v$${DIVE_VERSION}_dive_$${DIVE_VERSION}_linux_amd64.tar.gz
	mkdir dive
	tar zxvf dive_$${DIVE_VERSION}_linux_amd64.tar.gz --directory=dive
	chmod +x dive/dive
	sudo mv dive/dive /usr/local/bin/dive
	rm -rf dive
	rm dive_$${DIVE_VERSION}_linux_amd64.tar.gz

install-dockle:
	export DOCKLE_VERSION=0.4.3

	if command -v dockle; then exit 0; fi
	wget -nc -q https://github.com/goodwithtech/dockle/releases/download/v$${DOCKLE_VERSION}_/dockle_$${DOCKLE_VERSION}_Linux-64bit.tar.gz
	mkdir dockle
	tar zxvf dockle_$${DOCKLE_VERSION}_Linux-64bit.tar.gz --directory=dockle
	chmod +x dockle/dockle
	sudo mv dockle/dockle /usr/local/bin/dockle
	rm -rf dockle
	rm dockle_$${DOCKLE_VERSION}_linux_amd64.tar.gz

install-trivy:
	export TRIVY_VERSION=0.22.0

	if command -v trivy; then exit 0; fi
	wget -nc -q https://github.com/aquasecurity/trivy/releases/download/v$${TRIVY_VERSION}/trivy_$${TRIVY_VERSION}_Linux-64bit.tar.gz
	mkdir trivy
	tar zxvf trivy_$${TRIVY_VERSION}_Linux-64bit.tar.gz --directory=trivy
	chmod +x trivy/trivy
	sudo mv trivy/trivy /usr/local/bin/trivy
	rm -rf trivy
	rm trivy_$${TRIVY_VERSION}_Linux-64bit.tar.gz

install-docker-slim:
	export DOCKER_SLIM_VERSION=1.37.3

	if command -v docker-slim; then exit 0; fi
	wget -nc -q https://downloads.dockerslim.com/releases/$${DOCKER_SLIM_VERSION}/dist_linux.tar.gz
	tar -xvf dist_linux.tar.gz
	sudo mv  dist_linux/docker-slim /usr/local/bin/
	sudo mv  dist_linux/docker-slim-sensor /usr/local/bin/
	rm dist_linux.tar.gz

test-dive:
	dive --ci --config=cicd/dive-config.yaml hello-world:latest

test-dockle:
	dockle --exit-code 1 --exit-level fatal hello-world:latest

test-trivy:
	trivy image golang:1.16