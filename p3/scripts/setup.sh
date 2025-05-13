#!/bin/bash
ANIMATION_RATE=0.3
declare -a ACTIVE_LOADING
metro=(	'[                        ]'
		'[=                       ]'
		'[==                      ]'
		'[===                     ]'
		'[====                    ]'
		'[=====                   ]'
		'[======                  ]'
		'[=======                 ]'
		'[========                ]'
		'[=========               ]'
		'[==========              ]'
		'[===========             ]'
		'[============            ]'
		'[ ============           ]'
		'[  ============          ]'
		'[   ============         ]'
		'[    ============        ]'
		'[     ============       ]'
		'[      ============      ]'
		'[       ============     ]'
		'[        ============    ]'
		'[         ============   ]'
		'[          ============  ]'
		'[           ============ ]'
		'[            ============]'
		'[             ===========]'
		'[              ==========]'
		'[               =========]'
		'[                ========]'
		'[                 =======]'
		'[                  ======]'
		'[                   =====]'
		'[                    ====]'
		'[                     ===]'
		'[                      ==]'
		'[                       =]' )

function play_loading_animation_loop() {
	while true ; do
		for FRAME in "${ACTIVE_LOADING[@]}" ; do
			printf "\r%s" "${FRAME}"
			sleep $ANIMATION_RATE
		done
	done
}

function start_loading_animation() {
	ACTIVE_LOADING=( "${@}" )
	# Hide the terminal cursor
	tput civis
	# disable terminal monitoring
	set +m
	# run loading loop on sub-shell
	play_loading_animation_loop &
	# get loading loop pid
	LOADING_LOOP_PID="${!}"
}

function stop_loading_animation() {
	# kill background process
	kill "${LOADING_LOOP_PID}" 2> /dev/null
	printf "\n"
	# Restore the terminal cursor
	tput cnorm
	# enable terminal monitoring back
	set -m
}


function create_cluster() {
	k3d cluster list inception > /dev/null 2>&1
    # k3d cluster create inception > /dev/null 2>&1
	if [ $? -eq 0 ]; then
        tput setaf 1; echo "======== Cluster creation failed ========"; tput sgr0;
        echo "Maybe The Cluster Already Exists"
        read -p 'Do you want us to delete and restart the cluster? (y/n): ' input
        if [ "$input" = "y" ] || [ "$input" = "Y" ]; then
            echo "Deleting and restarting the cluster..."
			echo "Deleting Cluster..."
			start_loading_animation "${metro[@]}" 2> /dev/null
			kubectl get ns dev > /dev/null
			if [ $? -eq 0 ]; then
				kubectl delete ns dev > /dev/null 2>&1
			fi
			kubectl get ns argocd > /dev/null
			if [ $? -eq 0 ]; then
				kubectl delete ns argocd > /dev/null 2>&1
			fi
            k3d cluster delete inception > /dev/null
			sleep 2
			stop_loading_animation
            create_cluster
        elif [ "$input" = "n" ] || [ "$input" = "N" ]; then
            echo "Operation cancelled."
            exit 1
        else
            echo "Invalid input."
            exit 1
        fi
	else
		echo "Creating Cluster..."
		start_loading_animation "${metro[@]}" 2> /dev/null
		k3d cluster create inception > /dev/null 2>&1
		sleep 2
		stop_loading_animation
		kubectl cluster-info
    fi
}


function install_docker() {
	sudo aptitude --version > /dev/null 2>&1
	if [ $? -eq 1 ]; then
		sudo apt install aptitude > /dev/null 2>&1
  	fi
	sudo aptitude install docker.io -y > /dev/null 2>&1
}



tput setaf 2; echo "======== Install prerequisites ========"; tput sgr0;
if [ "$(uname)" = "Linux" ]; then
    if which docker > /dev/null; then
        tput setaf 1; echo "======== Docker already installed ========"; tput sgr0;
    else
        tput setaf 2; echo "======== Install Docker ========"; tput sgr0;
		sudo apt-get update > /dev/null 2>&1
		sudo apt-get upgrade -y > /dev/null 2>&1
		start_loading_animation "${metro[@]}" 2> /dev/null
		install_docker
		sleep 2
		stop_loading_animation
		docker version
		if [ $? -eq 1 ]; then
			tput setaf 1; echo "======== Install Docker failed========"; tput sgr0;
		else
			tput setaf 2; echo "======== Docker installed ========"; tput sgr0;
		fi
    fi
    if which kubectl > /dev/null; then
        tput setaf 1; echo "======== Kubectl already installed ========"; tput sgr0;
    else
        tput setaf 2; echo "======== Install Kubectl ========"; tput sgr0;
		start_loading_animation "${metro[@]}" 2> /dev/null
		curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" > /dev/null 2>&1
		curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256" > /dev/null 2>&1
		sleep 2
		stop_loading_animation
		echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
		sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
		rm -rf kubectl
		rm -rf kubectl.sha256
		kubectl version --client
		if [ $? -eq 1 ]; then
			tput setaf 1; echo "======== Install Kubectl failed========"; tput sgr0;
		else
			tput setaf 2; echo "======== Kubectl installed ========"; tput sgr0;
		fi
	fi
    if which k3d > /dev/null; then
        tput setaf 1; echo "======== K3d already installed ========"; tput sgr0;
    else
        tput setaf 2; echo "======== Install K3d ========"; tput sgr0;
		start_loading_animation "${metro[@]}" 2> /dev/null
        curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash > /dev/null 2>&1
		sleep 2
		stop_loading_animation
		if which k3d > /dev/null; then
			tput setaf 2; echo "======== K3d installed ========"; tput sgr0;
		else
			tput setaf 1; echo "======== Install K3d failed========"; tput sgr0;
		fi

    fi
	if which argocd > /dev/null; then
        tput setaf 1; echo "======== ArgoCd already installed ========"; tput sgr0;
    else
        tput setaf 2; echo "======== Install ArgoCd ========"; tput sgr0;
		start_loading_animation "${metro[@]}" 2> /dev/null
        curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64 > /dev/null 2>&1
		sleep 2
		sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
		rm argocd-linux-amd64
		sleep 2
		stop_loading_animation
		if which k3d > /dev/null; then
			tput setaf 2; echo "======== ArgoCd installed ========"; tput sgr0;
		else
			tput setaf 1; echo "======== Install ArgoCd failed========"; tput sgr0;
		fi

    fi
	if which xsel > /dev/null; then
        tput setaf 1; echo "======== Xsel already installed ========"; tput sgr0;
	else
		tput setaf 2; echo "======== Install Xsel ========"; tput sgr0;
		start_loading_animation "${metro[@]}" 2> /dev/null
		sudo apt-get install -y xsel > /dev/null 2>&1
		sleep 2
		stop_loading_animation
	fi
    tput setaf 2; echo "======== K3D setup - Create kubernetes cluster on local machine ========"; tput sgr0;
    	create_cluster
	tput setaf 2; echo "======== Create kubernetes NameSpace  ========"; tput sgr0;
		kubectl create namespace argocd > /dev/null 2>&1
		kubectl create namespace dev > /dev/null 2>&1
		kubectl get namespace
	tput setaf 2; echo "======== Argo CD Setup  ========"; tput sgr0;
		kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
	./scripts/launch.sh "called from setup"
	exit 0
else
	echo "This script is supported only on Linux operating systems."
	exit 1
fi
