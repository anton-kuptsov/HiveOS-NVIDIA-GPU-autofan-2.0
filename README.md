# HiveOS NVIDIA GPU autofan ver.2.0
Nvidia gpu automatic fan speed script for HiveOS Ubuntu. Work on mixed RIGs with AMD and NVIDIA GPU's

If you upgrade HiveOS via account on website or by command ```selfupgrade``` not need re-install the script.
If you re-install HiveOS on disk - re-install ```autofan.sh``` too(!).

HiveОS: https://goo.gl/qXNH54

# Disclaimer
Use and change at your own risk! Not responsible for any damages or issues, changing temperature controls, fan speed, etc. might damage your computer hardwares.

# Install
- Go to ```/home/user``` directory on your HiveOS ( ```cd /home/user```). Check current dir by command ```pwd```.
For navigation use commands : ```cd ~``` (go to home dir),  ```cd ..``` (level up), ```cd dir``` (move to dir)
- ```~# wget https://raw.githubusercontent.com/Steambot33/HiveOS-NVIDIA-GPU-autofan-2.0/master/autofan.sh```
(or download and put autofan.sh via your sftp manager)
- ```~# chmod +x autofan.sh``` 
(change permission for run)
- ```~# autofan.sh``` (run)

Now follow the on-screen instructions step-by-step:
- setup settings (or leave default)
- run script in GHOST mode (like service) by printing "y"

# Settings
 - ```DELAY``` - time delay for fan control (in seconds)
 - ```MIN_SPEED``` - minimum possible fan speed (in %)
 - ```MIN_TEMP``` - GPU temperature at which the minimum coefficient is applied
 - ```MAX_TEMP``` - GPU temperature at which the maximum coefficient is applied
 - ```MIN_COEF``` - minimum coefficient
 - ```MAX_COEF``` - maximum coefficient


# Run with keys
The script has the following startup keys:

-s 		- start setup settings (terminate by Ctrl+C). Don't need restart the script.

-g 		- running script in GHOST mode or SCREEN mode (terminate by Ctrl+C)

-c 		- checking current script status and current GPU temperature/fan speed, updated every DELAY time (terminate by Ctrl+C)

-r 		- running script in SCREEN mode (terminate by Ctrl+C)

-k 		- kill script

  Run without any keys has follow steps: 
  - start setup settings
  - checking starup status
  - running script in GHOST mode or SCREEN mode
	
	Example : ```~# autofan.sh -c```
	
# Startup at boot
The script create file ```xinit.user.sh``` (or check availability) and configure to run ```autofan.sh``` at startup.
Also script create ```autofan.conf``` file to store user settings.

# Examples of temperature and fan speed (default script settings)
- 55 C : 38 %
- 60 C : 48 %
- 65 C : 65 %
- 67 C : 72 %
- 69 C : 80 %
- 72 C : 84 %
- 75 C : 97 %

# Donate

Nicehash: ```3JKA47P98c9JGCy3GN7qXFC2FzeuJmXuph```

Zec: ```t1fP9jWyqFEni2p4i9t3byqtimsMKv1y95T```

ETH: ```0xe835a7d5605a370e4750279b28f9ce0926061ea2```

	
