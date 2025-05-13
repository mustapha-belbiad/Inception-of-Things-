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
    tput setaf 2; echo "======== Deleting Cluster ========"; tput sgr0;
    start_loading_animation "${metro[@]}" 2> /dev/null
    kubectl delete ns gitlab > /dev/null 2>&1
    kubectl delete ns argocd > /dev/null 2>&1
    k3d cluster delete inception > /dev/null
    sleep 2
	stop_loading_animation
    tput setaf 2; echo "======== Deleting Cluster is finished ========"; tput sgr0;
else
	echo "This script is supported only on Linux operating systems."
	exit 1
fi