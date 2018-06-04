#!/bin/bash

##############################################################
## Thank you very much for your support! It's very impotant!##
##							    ##
## Nicehash donate: 3JKA47P98c9JGCy3GN7qXFC2FzeuJmXuph	    ##
## Zec donate: t1fP9jWyqFEni2p4i9t3byqtimsMKv1y95T	    ##
## ETH donate: 0xe835a7d5605a370e4750279b28f9ce0926061ea2   ##
##############################################################

DELAY=30
MIN_SPEED=40
MIN_TEMP=60 
MAX_TEMP=65
MIN_COEF=80
MAX_COEF=110
MINER_STOP=1
CRITICAL_TEMP_MINER_STOP=85
PL_LIMIT=1
CRITICAL_TEMP_PL=75

VERSION="2.3"
s_name="autofan.sh"
CONF_FILE="/home/user/autofan.conf"
export DISPLAY=:0
red=$(tput setf 4)
green=$(tput setf 2)
reset=$(tput sgr0)

function set_var {
read -p  "Enter DELAY (current $DELAY): "
[ ! -z "${REPLY##*[!0-9]*}" ] && DELAY=$REPLY
echo -n -e "${red}DELAY=$DELAY${reset}\n"
read -p  "Enter MIN_SPEED (current $MIN_SPEED): "
[ ! -z "${REPLY##*[!0-9]*}" ] && MIN_SPEED=$REPLY
echo -n -e "${red}MIN_SPEED=$MIN_SPEED${reset}\n"
read -p  "Enter MAX TEMP (current $MAX_TEMP): "
[ ! -z "${REPLY##*[!0-9]*}" ] && MAX_TEMP=$REPLY
echo -n -e "${red}MAX_TEMP=$MAX_TEMP${reset}\n"
read -p  "Enter MIN TEMP (current $MIN_TEMP): "
[ ! -z "${REPLY##*[!0-9]*}" ] && MIN_TEMP=$REPLY
echo -n -e "${red}MIN_TEMP=$MIN_TEMP${reset}\n"
read -p  "Switch on MINER_STOP (1-YES/0-NO, current state $MINER_STOP): "
[ ! -z "${REPLY##*[!0-9]*}" ] && [[ $REPLY < 2 ]] && MINER_STOP=$REPLY
echo -n -e "${red}MINER_STOP=$MINER_STOP${reset}\n"
if [[ $MINER_STOP == 1 ]]; then 
		read -p  "Enter CRITICAL_TEMP_MINER_STOP (current $CRITICAL_TEMP_MINER_STOP): "
		[ ! -z "${REPLY##*[!0-9]*}" ] && CRITICAL_TEMP_MINER_STOP=$REPLY
		echo -n -e "${red}CRITICAL_TEMP_MINER_STOP=$CRITICAL_TEMP_MINER_STOP${reset}\n"
fi
read -p  "Switch on PL_LIMIT (1-YES/0-NO, current state $PL_LIMIT): "
[ ! -z "${REPLY##*[!0-9]*}" ] && [[ $REPLY < 2 ]] && PL_LIMIT=$REPLY
echo -n -e "${red}PL_LIMIT=$PL_LIMIT${reset}\n"
if [[ $PL_LIMIT == 1 ]]; then 
		read -p  "Enter CRITICAL_TEMP_PL (current $CRITICAL_TEMP_PL): "
		[ ! -z "${REPLY##*[!0-9]*}" ] && CRITICAL_TEMP_PL=$REPLY
		echo -n -e "${red}CRITICAL_TEMP_PL=$CRITICAL_TEMP_PL${reset}\n"
fi
echo "Creating config..."
[ ! -f $CONF_FILE ] &&	touch $CONF_FILE
echo -n > $CONF_FILE
echo -e "DELAY=$DELAY\nMIN_SPEED=$MIN_SPEED\nMIN_TEMP=$MIN_TEMP\nMAX_TEMP=$MAX_TEMP\nMIN_COEF=$MIN_COEF\nMAX_COEF=$MAX_COEF\nMINER_STOP=$MINER_STOP\nCRITICAL_TEMP_MINER_STOP=$CRITICAL_TEMP_MINER_STOP\nPL_LIMIT=$PL_LIMIT\nCRITICAL_TEMP_PL=$CRITICAL_TEMP_PL" >> $CONF_FILE
echo "${green}[Status]: ${reset}Config created."		
}

function check_run {
if [ ! -f "/home/user/xinit.user.sh" ]; then
		touch /home/user/xinit.user.sh
		chmod +x /home/user/xinit.user.sh
		echo -e "#!/bin/bash\nscreen -dmS autofan /home/user/$s_name -r" >> /home/user/xinit.user.sh
		echo -n -e "${green}[Status]: ${reset}File xinit.user.sh created.\n"
else 
		if grep -q "screen -dmS autofan /home/user/$s_name -r" /home/user/xinit.user.sh; then
					echo -n -e "${green}[Status]: ${reset}Autorun switched on.\n"
		else 
					echo -e "screen -dmS autofan /home/user/$s_name -r" >> /home/user/xinit.user.sh
					echo -n -e "${green}[Status]: ${reset}Autorun created.\n"
		fi
fi
}

function safe_mode {
if [[ $1 == 1 ]]; then miner start && wd start; echo "${green}[Status]: ${reset} Miner started." 
elif [[ $1 == 2 ]]; then miner stop && wd stop; echo "${red}Critical temperature! Miner STOPPED!${reset}"
fi
}

function clock_limit_mode {
gpu_info=`nvidia-smi --query-gpu=power.min_limit,power.limit --format=csv,noheader,nounits -i $i`
pl_min=`awk -F', ' '{print $1}' <<< $gpu_info`
pl_cur=`awk -F', ' '{print $2}' <<< $gpu_info`
echo -en "${green}GPU${i}${reset} Minimal possible PL: $pl_min, curent PL: $pl_cur"
new_pl=$(( `sed 's/\.[0-9]*//' <<< $pl_cur`-5 ))
if [  `sed 's/\.[0-9]*//' <<< $pl_min` -lt $new_pl  ]
	then
		echo -en "     ${red}GPU${i}-> ${reset}Try to set PL to $new_pl"
		nvidia-settings -a [gpu:0]/GPUPowerMizerMode=1 > /dev/null 2>&1 
		nvidia-smi -i $i -pl $new_pl > /dev/null 2>&1 && echo "${green}GPU${i}-> ${reset} PL was set to $new_pl"
	else echo -en "     ${red}GPU${i}: ${reset}already done or PL too low."
fi
}

function change_coef {
if [[ $1 == 0 ]]; then 
	screen_count=`screen -ls miner | grep miner | wc -l`
	[[ $screen_count > 0 ]] && [[  $MIN_COEF > 70 ]] && MIN_COEF=$(( $MIN_COEF-1 )) && MAX_COEF=$(( $MAX_COEF-1 )) || echo "Low temp"
else MIN_COEF=$(( $MIN_COEF+2 )) && MAX_COEF=$(( $MAX_COEF+2 ))
fi
#			
echo -e " Set MIN_COEF ->$MIN_COEF & MAX_COEF ->$MAX_COEF"
#
sed -i "s/\(MIN_COEF *= *\).*/\1$MIN_COEF/" $CONF_FILE && sed -i "s/\(MAX_COEF *= *\).*/\1$MAX_COEF/" $CONF_FILE
CHANGE_COEF_FLAG=

}
function auto_fan {
CARDS_NUM=`nvidia-smi -L | wc -l`
echo "Found ${CARDS_NUM} GPU(s)"
echo -e -n "${green}Current AUTOFAN settings:${reset}\nDELAY=$DELAY\nMIN_SPEED=$MIN_SPEED\nMIN_TEMP=$MIN_TEMP\nMAX_TEMP=$MAX_TEMP\nMIN_COEF=$MIN_COEF\nMAX_COEF=$MAX_COEF\nMINER_STOP=$MINER_STOP\nCRITICAL_TEMP_MINER_STOP=$CRITICAL_TEMP_MINER_STOP\nPL_LIMIT=$PL_LIMIT\nCRITICAL_TEMP_PL=$CRITICAL_TEMP_PL\n"
sleep 2
while true
        do
			[[ -e $CONF_FILE ]] && . $CONF_FILE
            echo -n -e "${green}$(date +"%d/%m/%y %T")${reset}\n"
        for ((i=0; i<$CARDS_NUM; i++))
            do
                GPU_TEMP=`nvidia-smi -i $i --query-gpu=temperature.gpu --format=csv,noheader`
                if [[ $GPU_TEMP -lt $MIN_TEMP ]]
                    then
						[[ CHANGE_COEF_FLAG != 1 ]] && CHANGE_COEF_FLAG=0
                        FAN_SPEED=$(($GPU_TEMP * ($MIN_COEF-($MIN_TEMP - $GPU_TEMP) * 2)/100))
						[[ $FAN_SPEED -le $MIN_SPEED ]] && FAN_SPEED=$MIN_SPEED 
						GPU_TEMP_ALL=`nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader`
									GPU_TEMP_ALL=(${GPU_TEMP_ALL//\n/ })
									for gpu_count in "${GPU_TEMP_ALL[@]}"
										do
											  [[ "$gpu_count" > $MIN_TEMP ]] && MINER_STOP=0 && break 
										done
						[[ $MINER_STOP == 1 ]] && ! screen -ls | grep -q "miner" && safe_mode 1
						MINER_STOP=1
                elif [[ $GPU_TEMP -ge $MIN_TEMP  &&  $GPU_TEMP -le $MAX_TEMP ]]
                    then
					 if [[ -n $PREV_TEMP_ALL && $(( $GPU_TEMP+1 )) -eq ${PREV_TEMP_ALL[$i]} ]]; then
								FAN_SPEED=$(( ${PREV_FAN_ALL[$i]}-1 )) 
					 			# echo "     GPU${i}: FAN_SPEED->$FAN_SPEED" 
					 elif [[ $GPU_TEMP > ${PREV_TEMP_ALL[$i]} ]]; then
							FAN_SPEED=$((  $GPU_TEMP *(($GPU_TEMP - $MIN_TEMP) * 4 + $MIN_COEF)/100 ))
					 else FAN_SPEED=${PREV_FAN_ALL[i]}
					 fi

				elif [[ $GPU_TEMP -gt $MAX_TEMP ]]
                    then
						CHANGE_COEF_FLAG=1
						FAN_SPEED=$(( $GPU_TEMP *(($GPU_TEMP - $MAX_TEMP) * 4 + $MAX_COEF)/100 ))
                fi
				[[ $GPU_TEMP -ge $CRITICAL_TEMP_MINER_STOP   &&  $MINER_STOP == 1 ]] && safe_mode 2
				[[ $GPU_TEMP -ge $CRITICAL_TEMP_PL  &&  $PL_LIMIT == 1 ]] && clock_limit_mode $i
				[[ $FAN_SPEED -gt 100 ]] && FAN_SPEED=100
				nvidia-settings -a [gpu:$i]/GPUFanControlState=1 -a [fan:$i]/GPUTargetFanSpeed=$FAN_SPEED > /dev/null 2>&1 &
                echo "GPU${i} ${GPU_TEMP}°C -> ${FAN_SPEED}%"
				PREV_FAN_ALL[$i]=$FAN_SPEED
				PREV_TEMP_ALL[$i]=$GPU_TEMP
       done
	   [[ -n $CHANGE_COEF_FLAG ]] && change_coef $CHANGE_COEF_FLAG

sleep $DELAY
done
}

function ghost_run {
read -p  "Run script in GHOST mode? (y/n) "
if [[ $REPLY = "y" ]] ;then 
					session_count=`screen -ls autofan | grep autofan | wc -l`
						if [[ $session_count > 0 ]]; then
							echo -e "${red}AUTOFAN is already running${reset}"
							echo -e "Run autofan.sh -c to see the current status"
						else 
						echo "Your choice is ${green}[YES]${reset}."
						screen -dmS autofan /home/user/$s_name -r && echo -n -e "${green}[Status]: ${reset}Script started in GHOST mode.\n"
						fi
			
elif [[ $REPLY = "n" ]] ; then
							echo "Your choice is ${red}[NO]${reset}."
							read -p  "Run script in default mode? (y/n) "
							if [[ $REPLY = "y" ]] ; then $s_name -r
							else echo "Your choice is ${red}[NO]${reset}. See your later.."; exit
							fi
else 
echo "${red}[FAIL] ${reset} Please, make a choice."
ghost_run
fi
}

function selfupdate {
echo "${green}[Status]:${reset} Checking..."
new_version=`wget -q -O- https://raw.githubusercontent.com/Steambot33/HiveOS-NVIDIA-GPU-autofan-2.0/master/version | head`
if [[ $new_version != $VERSION ]] 
		then 
		echo "${green}NEW VERSION $new_version ${reset}"
		read -p  "Continue update? (y/n)"
		if [[ $REPLY = "y" ]]
				then 
				mv autofan.sh autofan.sh.old
				if wget -q https://raw.githubusercontent.com/Steambot33/HiveOS-NVIDIA-GPU-autofan-2.0/master/autofan.sh
				then 
				rm autofan.sh.old
				chmod +x autofan.sh
				echo "${green}[Status]:${reset} The script updated."
				echo "${green}[Status]:${reset} Restart script! (autofan.sh -k and autofan.sh -g)"
				else 
						echo "${red}[ FAIL ]{reset}"
						mv autofan.sh.old autofan.sh
				fi
		else echo "Your choice is ${red}[NO]${reset}."
		fi
else echo "${green}[Status]:${reset}You use actual version $new_version"
fi
}

[[ -e $CONF_FILE ]] && . $CONF_FILE 

case $1 in
	-t)
		change_coef 1
		;;
	-r)
		auto_fan
	;;
	
	-s)
		set_var
	;;
	
	-g)
		ghost_run
	;;
	
	-u)
		selfupdate
		
	;;
	
	-c)
		if screen -ls | grep -q "autofan"; then
		echo "${green}[Status]:${reset} The script is running."
		else echo "${green}[Status]:${reset} The script is ${red}NOT${reset} running."
		fi
		echo -en "${green}Current AUTOFAN settings:${reset}\nDELAY=$DELAY\nMIN_SPEED=$MIN_SPEED\nMIN_TEMP=$MIN_TEMP\nMAX_TEMP=$MAX_TEMP\nMIN_COEF=$MIN_COEF\nMAX_COEF=$MAX_COEF\nMINER_STOP=$MINER_STOP\nCRITICAL_TEMP_MINER_STOP=$CRITICAL_TEMP_MINER_STOP\nPL_LIMIT=$PL_LIMIT\nCRITICAL_TEMP_PL=$CRITICAL_TEMP_PL\n"
		CARDS_NUM=`nvidia-smi -L | wc -l`
		echo "Found ${CARDS_NUM} GPU(s):"
		while true
        do
			echo -n -e "${green}$(date +"%d/%m/%y %T")${reset}\n"
			for ((i=0; i<$CARDS_NUM; i++))
				do
					GPU_TEMP_C=`nvidia-smi -i $i --query-gpu=temperature.gpu --format=csv,noheader`
					GPU_FAN_C=`nvidia-smi -i $i --query-gpu=fan.speed --format=csv,noheader`
					echo "GPU${i} ${GPU_TEMP_C}°C - ${GPU_FAN_C}"
			done
		sleep $DELAY 
		done
	;;
	-k)
		pkill $s_name
	;;
	
	*)
	echo -n -e "${green}HiveOS autofan script for NVIDIA GPU.${reset} v.${VERSION}\n"
		set_var
		check_run
		ghost_run
	;;
esac
exit
