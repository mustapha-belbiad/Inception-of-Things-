#!/bin/bash

if [ "$(uname)" = "Linux" ]; then
    if [ -z "$1"]; then
        kill $(ps | grep kubectl | cut -d ' ' -f2) 2> /dev/null
        kubectl port-forward svc/argocd-server -n argocd 9000:443 &>/dev/null &
        ARGOCD_PASSWD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo)
    else
        ARGOCD_PASSWD=$1
    fi
    tput bold; tput setaf 2; echo "=== Connect to ArgoCD user-interfice (UI) ==="; tput sgr0;
    tput bold; echo "=== ARGO CD USERNAME: admin ==="; tput sgr0;
    tput bold; echo "=== ARGO CD PASSWORD: $ARGOCD_PASSWD ==="; tput sgr0;
    echo $ARGOCD_PASSWORD | xsel --clipboard --input
    xdg-open 'https://localhost:9000' &>/dev/null
    sleep 5
    tput bold; tput setaf 2; echo "=== URL Will App ==="; tput sgr0;
    URL_APP=$(kubectl -n dev get all | grep service | cut -d ' ' -f10)
    tput bold; echo "=== URL: http://$URL_APP:8888 ==="; tput sgr0;
    tput bold; tput setaf 2; echo "=== Test Will App ==="; tput sgr0;
    curl http://$URL_APP:8888
else
	echo "This script is supported only on Linux operating systems."
	exit 1
fi



