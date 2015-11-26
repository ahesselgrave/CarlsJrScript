screenOff=`dumpsys power | grep "mScreenOn=false"` #empty string if screen on
lockAtEnd=0 #do not lock at end
if [[ "x" != "x$screenOff"  ]]; then
	#screen is locked, so we will lock it at the end
	lockAtEnd=1
	echo "Screen off, unlocking"
	input keyevent 26
fi
#open the fake GPS
am force-stop com.lexa.fakegps
am start com.lexa.fakegps/.PickPoint
sleep 1
input tap 200 250
sleep 1
#kill any previous instant of the app
am force-stop com.cke.happystarrewards
am start com.cke.happystarrewards/com.cke.happystarrewards.presentation.activity.SplashActivity
echo "Opening Carls App"
sleep 13 #sleep for loading
#Check if there is signal

signalOn=`ping -c 1 -w 3 google.com`
#echo "signal on is \"$signalOn\""
count=0
#Ping at least 10 times
until [[ "x$signalOn" != "x" ]] || [[ $count -gt 10 ]]; do 	
	signalOn=`ping -c 1 -w 3 google.com`
	if [[ "x$signalOn" == "x" ]]; then
		sleep 3
	fi
	let count=count+1
	echo "Testing connection, attempt $count"
done
if [[ $count -gt 10 ]]; then
	echo "No signal, running in 1 hour"
	am force-stop com.cke.happystarrewards
	input keyevent 26
	sleep 3600
	echo "Recursively calling script"
	./$0
else
	input tap 500 1650
	echo "Entering check in screen"
	#now we are in the check in screen
	sleep 15 #for loading
	input tap 500 1500
	sleep 20
	am force-stop com.cke.happystarrewards
	am force-stop com.lexa.fakegps
	if [[ $lockAtEnd -eq 1 ]]; then
		echo "Locking screen, check in successful"
		input keyevent 26
	fi
fi
