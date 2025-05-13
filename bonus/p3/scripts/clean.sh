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
#--------------------------------------------------------------
function play_loading_animation_loop() {
	while true ; do
		for FRAME in "${ACTIVE_LOADING[@]}" ; do
			printf "\r%s" "${FRAME}"
			sleep $ANIMATION_RATE
		done
	done
}
#--------------------------------------------------------------
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
#--------------------------------------------------------------
function stop_loading_animation() {
	# kill background process
	kill "${LOADING_LOOP_PID}" 2> /dev/null
	printf "\n"
	# Restore the terminal cursor
	tput cnorm
	# enable terminal monitoring back
	set -m
}
#--------------------------------------------------------------
if [ "$(uname)" = "Linux" ]; then
    tput setaf 2; echo "======== Cleaning up the Argo CD app ========"; tput sgr0;
    start_loading_animation "${metro[@]}" 2> /dev/null
    kill $(ps | grep kubectl | cut -d ' ' -f2) 2> /dev/null
    kubectl port-forward svc/argocd-server -n argocd 9000:443 &>/dev/null &
    sleep 5
    yes | argocd app delete will --grpc-web &>/dev/null
    kill $(ps | grep kubectl | cut -d ' ' -f2) 2> /dev/null
    sleep 2
	stop_loading_animation
    tput setaf 2; echo "======== Cleaning is finished ========"; tput sgr0;
else
	echo "This script is supported only on Linux operating systems."
	exit 1
fi