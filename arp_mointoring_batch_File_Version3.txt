@echo off

set ip="192.168.1.1" 
set mac="00-66-4b-d2-7e-69"
set /A maxSizeOfFile=10000 # 1000 mean 1 KB 
set /A repeatmeevery=20

set mycurrentTime=%time:~0,2%_%time:~3,2%

set established=established_%mycurrentTime%.txt
set Listen=Listen_%mycurrentTime%.txt
set sync=sync_%mycurrentTime%.txt
set arp=arp_%mycurrentTime%.txt
set chkOriginalMac=chkOriginalMac_%mycurrentTime%.txt
set poisingMACDetails=poisingMACDetails_%mycurrentTime%.txt
set GWMACHistory=GWMACHistory_%mycurrentTime%.txt

:startExecuation
cls
rem -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
rem Creating Working Directory 

set month=%date:~4,2%
set day=%date:~7,2%
set year=%date:~10,4%
set fileName= connectionStatus_%day%_%month%_%year%

if exist %fileName%  echo %fileName% Working Directory already exists
if not exist %fileName%  mkdir %fileName%
echo [*] Moving to Working Directory 
cd %fileName%


rem -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
rem running Connections

echo [*] Check Established Connection

echo ---------------------------- >> %established%
echo %date% %time%>> %established%
echo ---------------------------- >> %established%
netstat -an  | findstr "ESTABLISHED" >> %established%
rem -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
rem Open Ports 
echo [*] Checking the open port

echo ---------------------------- >> %Listen%
echo %date% %time%>>%Listen%
echo ---------------------------- >> %Listen%
netstat -an  | findstr "LISTENING" >> %Listen%
rem -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
rem Syn Connection 

echo [*] Checking Sync Connection

echo ---------------------------- >> %sync%
echo %date% %time% >> %sync%
echo ---------------------------- >> %sync%
netstat -an  | findstr "SYN_SENT" >> %sync%
rem -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
rem arp Connection

echo [*] Check ARP Cache 

echo ---------------------------- >> %arp%
echo %date% %time% >>  %arp%
echo ---------------------------- >> %arp%
arp -a >> %arp%
rem -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
rem first parameter must be gateway 

echo [*] Check Original MaC Address Existance 

echo ---------------------------- >> %chkOriginalMac%
echo %date% %time% >> %chkOriginalMac%
echo "If You don't Find result then there is arp posing now, Please Check arp.txt file">> %chkOriginalMac%
echo ---------------------------- >> %chkOriginalMac%
arp -a | findstr %mac% >> %chkOriginalMac%
rem -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

echo [*] Checking the IP address for the Poisner 

echo ---------------------------- >> %poisingMACDetails%
echo %date% %time% >> %poisingMACDetails%
echo ---------------------------- >> %poisingMACDetails%
FOR /f "Tokens=2,*" %%G IN ('arp -a %ip% ') DO (
 echo %%G > gwMAC.txt 
 
  )
set /p gwMAC=< gwMAC.txt  
echo **************
echo --------------------------------- >> %GWMACHistory%
echo %date% %time% >> %GWMACHistory%
echo --------------------------------- >> %GWMACHistory%
arp -a | findstr  %gwMAC% >> %poisingMACDetails%
echo %gwMAC%  >> %GWMACHistory%
del gwMac.txt
type %poisingMACDetails%
rem -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

set mycurrentTime=%time:~0,2%_%time:~3,2%

set size=0 
call :fileSize %established%
if %size% GTR %maxSizeOfFile% set established=established_%mycurrentTime%.txt

set size=0 
call :fileSize %Listen%
if %size% GTR %maxSizeOfFile% set Listen=Listen_%mycurrentTime%.txt

set size=0 
call :fileSize %sync%
if %size% GTR %maxSizeOfFile% set sync=sync_%mycurrentTime%.txt

set size=0 
call :fileSize %arp%
if %size% GTR %maxSizeOfFile% set arp=arp_%mycurrentTime%.txt

set size=0 
call :fileSize %chkOriginalMac%
if %size% GTR %maxSizeOfFile% set chkOriginalMac=chkOriginalMac_%mycurrentTime%.txt


set size=0 
call :fileSize %poisingMACDetails%
if %size% GTR %maxSizeOfFile%  set poisingMACDetails=poisingMACDetails_%mycurrentTime%.txt


set size=0 
call :fileSize %GWMACHistory%
if %size% GTR %maxSizeOfFile% set GWMACHistory=GWMACHistory_%mycurrentTime%.txt

set size=0 

rem be out of the Working Directory 

cd ..
GOTO banner

:fileSize 

set size=%~z1
exit /b 0

:banner
cls
echo ---------------------------------------------------------------
echo  This Script is Checking you system Connectivity 
echo  Please Don't Stop or Edit the Script
echo  All Copyright are reserved for Raya Corporate 
echo ---------------------------------------------------------------
timeout %repeatmeevery%

GOTO startExecuation
 
