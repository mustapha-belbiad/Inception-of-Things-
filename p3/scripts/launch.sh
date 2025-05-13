#!/bin/bash
if [ "$(uname)" = "Linux" ]; then
    k3d cluster list inception > /dev/null 2>&1
    if [ $? -eq 1 ]; then
        echo "The cluster does not exist."
        read -p 'Do you want us to create the cluster? (y/n): ' input
        if [ "$input" = "y" ] || [ "$input" = "Y" ]; then
            ./scripts/setup.sh
        elif [ "$input" = "n" ] || [ "$input" = "N" ]; then
            echo "Operation cancelled."
            exit 1
        else
            echo "Invalid input."
            exit 1
        fi
    else
        tput setaf 2; echo "WAITING FOR ARGO-CD PODS TO RUN... (This can take up to 6minutes)" ; tput sgr0;
        # if ["$1"] > /dev/null 2>&1; then
        #     # echo "sleep her" 
        # fi
        sleep 10
        SECONDS=0
        kubectl wait pods -n argocd --all --for condition=Ready --timeout=600s > /dev/null 2>&1
        if [ $? -eq 1 ]; then
            echo "probleme to creation argocd pods"
            echo "deleting cluster"
            k3d cluster delete inception
            exit 1
        fi
        echo "$((SECONDS / 60)) minutes and $((SECONDS % 60))  seconds elapsed since waiting for Argo-CD pods creation."
        kill $(ps | grep kubectl | cut -d ' ' -f2) 2> /dev/null
        kubectl port-forward svc/argocd-server -n argocd 9000:443 &>/dev/null &
        ARGOCD_PASSWD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo)
        argocd login localhost:9000 --username admin --password $ARGOCD_PASSWD --insecure --grpc-web
        kubectl config set-context --current --namespace=argocd
        argocd app create will --repo https://github.com/iel-mach/iot.git --path 'p3/confs' --dest-server https://kubernetes.default.svc --dest-namespace 'dev' --grpc-web
        if [ $? -eq 20 ]; then
            echo "An error occurred when creating argo-cd app 'will'."
            echo "Probably because the argo-cd app 'will' already exists."
            read -p 'Do you want us to delete and recreate the app? (y/n): ' input
	        if [ $input = 'y' ]; then
		        echo "We will delete the app for you."
		        yes | argocd app delete will --grpc-web &>/dev/null
		        echo "Now we will relaunch argo-cd for you."
		        ./scripts/launch.sh
		        exit 0
	        fi
	        exit 1
        fi
        tput setaf 2; echo "View created app before sync and configuration"; tput sgr0;
            argocd app get will --grpc-web
            sleep 5
        tput setaf 2; echo "Sync the app and configure for automated synchronization"; tput sgr0;
            argocd app sync will --grpc-web
            sleep 5
        tput setaf 2; echo "Set Automated Sync Policy"; tput sgr0;
            argocd app set will --sync-policy automated --grpc-web
            sleep 5
        tput setaf 2; echo "Set Auto Prune Policy"; tput sgr0;
            argocd app set will --auto-prune --allow-empty --grpc-web
            sleep 10
        tput setaf 2; echo "View created app after sync and configuration"; tput sgr0;
            argocd app get will --grpc-web
        ./scripts/argo.sh $ARGOCD_PASSWD $1
    fi
else
	echo "This script is supported only on Linux operating systems."
	exit 1
fi