
====================================
# [description]
## [EA]
Develop a mql5 EA by using my supertrend indicator
EA name: DTT TREND CATCHER
make the ea for client to install without once more putting.
Include the supertrend indicator in the ea directly.
Bar color is red when trend is down and green when trend is up.
When trend change, make a trade with SL and TPs.
SL is lowest price in last 9 bars.
and I want to use trailing stop.
If close price reaches TP1, it moves SL to BE.
if close price reaches TP2, it moves SL to TP1.
if close price reaches TP3, it moves SL to TP2.
if close price over TP3, it moves SL to TP3.
the pips of TPs is preseted in input setting.

if it reaches TP3 +/- step(ex: 20 pips), move SL to TP3.
add the flag "Close if trend changed" into setting,
the flag is true: a position is opened and then when trend is changed, it doesn't reach TP or SL, close the position.
the flag is false: do nothing.

--------------------------------
Display on the right side the information like trend catcher indicator.
Timeframe
Current Signal
SL
TP1
TP2
TP3
PRICE
EA Name
--------------------------------
The EA has license function and it supports trial 7 days for new client.
after 7 days, it shows machine ID and it requires the client to contact with support team and buy License key about the machine ID.
Alert: "You can use this EA for 7 days trial. after 7 days, you should pay. Please, contact @mykyta9090."

--------------------------------
## [webpanel]
need a filter "Payment status" in the user page of webpanel.
The filter has these options- all, trial, paid, expired.
The filter will be left-side to "Filter by file" filter.
So you can add a column "Payment status" next to "Status" column.

## [installer]
client doesn't know how to install ex5 file so we need to make an executable file that will install and run the ex5 file automatically.

The exe file can copy the ex5 file automatically.
But, it's impossible that the exe file run ex5 in metatrader.
Instead, by using exe I can show the clients the guide how to run the ex5 file.
====================================
[info]
This is web panel login info.
https://gtmetodo.com/
email test@test.com
pass test123

FTPs Host: ftps-s1.us.cloudlogin.co
kkabbara_trendcatcher.ai
TC2024^%$#@


FTP Username: trendcatcher@trendcatcher.ai
FTP Password: DevFtp2024@
FTP server: ftp.dttconnect.com
FTP & explicit FTPS port: 21

Host: itpro1.fcomet.com
Port: 21
email: devtrendcatcher@trendcatcher.ai
password: Catcher@dev2024


Username: operations@globaldtt.com
Password: DTToperations2025@

Username: w.ead@globaldtt.com
Password: DTTwalid2025@

Username: risk@globaldtt.com
Password: DTTrisk2025@

Username: k.kabbara@globaldtt.com
Password: DTTkhaled2025@
==================================
[install guide]
Let's start.
first, let's check webpanel. 

you can set login info in the .loads/.env file.
PAINEL_USER=test@test.com
PAINEL_PASS=test123

in webpanel/api/.htaccess file, you should update AuthUserFile path.
AuthUserFile "/home2/gtmeto31/public_html/TESTE/api/.htpasswd"

in mql5/Elon_license.mqh file, you should update HOST value.
http://trendcatcher.ai/api/

in mql5 directory, if "DTT TREND CATCHER.mq5" exits, you should remove source file-mq5

and copy ex5 file I gave you into this directory.

and next, run metatrader
find ea file and put it into main chart.

As shown, it gives 7 trial days.
put it again

expired date: 10.03
let's check webpanel

here you can give the client(user) more activated term. like this
you can deactive the user.
user can have serveral EAs

The admin can put the EAs in webpanel. like this, goto Files menu

And the admin can show the performance  of the user. like this
and the admin can delete the user by clicking the button "Delete"
the admin can search the user.

That's all
If you have any questions, text me.

==================================
https://www.mql5.com/en/articles/7815

I'm looking for a developer who can fix and update my EA.
I have a EA that I want to fix and update.

1. in Short, SL should be (highest price in last 9 bars) + 10 pips. In Long, SL should be (lowest price in last 9 bars) - 10 pips.
2. it should be automated, anytime you have a chart which include this indicator and this indicator switches signals, a pop up Alert notification shows up on your screen with a sound.
3. the trendcatcher line is showing another Indicator's name (Supertrend2) as well. everyone knows this indicator so it might cause an issue. 
You can change "supertrend" into "dtttrend" in the source code
4. Tps (30, 60, 90) should be set in input setting. All TPs should be fixed.
when signal comes, Tps are fixed. Until next signal comes, Tps shouldn't change. Default values:(30, 60, 90). 
5. whenever the TC confirms a new signal and the TP1 is not reached twice. the third time, the candles becomes BLUE
as you can see from the screenshot I've shared

Trendcatcher confirmed Red at first but the price went up and we didnt reach TP1 
then confirmed GREEN and we didnt reach TP1 again 
then confirmed RED so the candles instead of showing RED color, they showed BLUE (because it means a stronger signal than the usual confirmation)
In case when the current signal is Long, the candles should be also BLUE.
Thus, in last 2 trends, price didn't reach TP1 so the candles are BLUE without considering the current signal.

You can refer TrendCatcherIndicatorV23 indicator. I'll attach you. I don't have the souce code of this indicator. So I use supertrend indicator similar with TrendCatcherIndicatorV23 now. Please, check this indicator. you can know about blue candle.
So you should update supertrend indicator.
Do you understand?
This work will be long term. If you're interested, please let me know.

==================================
Hello guys, 

after a thorough check

1-the Trendcatcher Line (Level) is still inaccurate and in my opinion this is mainly due to the correlation between each Trendcatcher signal switch with eachother 
Trendcatcher Line (level) should be exactly equal to highest price of the last 9 candles if the signal is SELL OR lowest price of the last 9 candles if the signal is BUY

I think this requirement is not correct. Did you check the Trendcatcher indicator? The indicator doesn't work like your words.

therefore, stop loss is still incorrect as well, STOP LOSSES on the Trendcatcher should be the Trendcatcher Line +10 pips if the Signal is SELL OR Trendcatcher Line -10pips if the Signal is BUY

2- Take Profits (TP1 TP2 TP3) should be fixed at all time, as mentioned in our conversation, and it shouldnt be updated live  
TP1 20 pips from the confirmation signal candle
TP2 37 pips from the confirmation signal candle
TP3 63 pips from the confirmation signal candle


3- BLUE CANDLES signal is triggered correctly, when the last 2 confirmation signal switch didnt hit TP, but the minute a BLUE CANDLE is shown, all the previous candles, which doesnt have anything to do with the current Signal, are BLUE


==================================
# How to deploy the web service into GCP vm.

## Install Apache Web Server:
sudo apt update
sudo apt install apache2

## Install PHP along with the necessary Apache module:
php -v

## install nano by running the following command:
sudo apt install nano

## Create a simple PHP file in the web directory:
sudo nano /var/www/html/info.php

## Add the following PHP code:
<?php
phpinfo();
?>

## Open your browser and navigate to http://<VM_EXTERNAL_IP>/info.php to see the PHP info page.

## (Optional) Install MySQL or MariaDB (Database Server)
sudo apt install mysql-server
sudo mysql_secure_installation

sudo chmod -R 777 /var/www/html