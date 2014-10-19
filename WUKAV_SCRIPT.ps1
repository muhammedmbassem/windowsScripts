

$team = Read-Host "What is your Team Name " 
echo ("Welcom "+$team+"! ")
prompet "You are Going to Scan "

######################################Working Directories ###################################################
$r = get-date 
$ipList   = Read-Host "Full Qualified location to IP Address List (ex: C:\serverList.txt): "
$mydocument = [Environment]::GetFolderPath("MyDocuments")
$dirList = ($mydocument+'\Windows Update - AntiVirus(KAV) Update\'+($r.ToShortDateString()).replace("/","")+"\")
if(!(Test-Path -Path $dirList )){
    New-Item -ItemType directory -Path $dirList
} 
$csvFile = ($dirList +($r.ToShortDateString()).replace("/","") +"_WindowsKasperskyUpdate_Report.csv")
$logs = ($dirList+"Error.log")
$lines = Get-content $ipList
##############################################################################################################
#------------------------------------------------------------------------------------------------------------#
############################# Cred Settings ##################################################################

$chars = [Char[]]"qwertyuiopasdfghjklzxcvbnmQWERIOPASDFGHJKLZXCVBNM1234567890"
$username = Read-Host "Domain\Username "
$secPath  = ($dirList +(($chars | Get-Random -Count 128) -join "")+".txt")         #Randomized name according ~~ ObSec.
Read-Host "Type Your Password " -AsSecureString | ConvertFrom-SecureString | Out-File $secPath
$password = type $secPath | ConvertTo-SecureString
$cred = New-Object  -typename System.Management.Automation.PSCredential  -argumentList $username, $password
##################################################################################################################
#----------------------------------------------------------------------------------------------------------------#
####################################### Shreding Our Secret ######################################################
##################################################################################################################
echo (($chars | Get-Random -Count 1000000000) -join "") > $secPath
Remove-Item $secPath
##############################################################################################################
#------------------------------------------------------------------------------------------------------------#
##############################################################################################################
###############################Remote Connection to fetch Windows Updates#####################################
##############################################################################################################
echo "[*] Gathering the Information ... "
foreach ($line in $lines){
$serverNameOrIp = $line
echo "------------------------------------------------"
echo "[-] Checking $serverNameOrIp Windows Update ... " 
echo "------" > ($dirList+"windowsUpdate_$serverNameOrIp.txt”)
try {
 Get-WmiObject -Class Win32_QuickFixEngineering -ComputerName $serverNameOrIp  -Authentication default`  -Credential  $cred | select description,hotfixid,installedon | Sort-Object InstalledOn | Format-Table description,hotfixid,installedon -groupBy installedon | Out-File  -FilePath ($dirList+"windowsUpdate_$serverNameOrIp.txt”)
 $avp = (Get-Process -name avp -fileversioninfo -ComputerName $serverNameOrIp  -Authentication default`  -Credential  $cred | select filename | findstr "C:" | Get-Unique | Out-File  -FilePath ($dirList+"KasperUpdate_$serverNameOrIp.txt”))
$kav = (cmd /c $avp statistics updater )
$kav = (echo $kav | findstr "Finish").split()
$kav = $kav[9]
echo $kav
 type ($dirList+“windowsUpdate_$serverNameOrIp.txt”)
    }
catch {
   ($serverNameOrIp+" : $_") | Add-Content $logs
}
echo "-----------------------------------------------"

}
##################################################################################################################
#----------------------------------------------------------------------------------------------------------------#
##################################################################################################################
##########################################Summary CSV File######################################################## 
##################################################################################################################
echo "[*] Creating CSV File .... "
$list=ls $dirList | % {$_.BaseName} | findstr "windows"    
    "{0},{1}" -f "IP Address" , "WindowsUpdate" | add-content -path $csvFile
foreach($ip in $list){

    $ip=($ip -split "_")[1]
    $mypath = $dirList+“windowsUpdate_$ip.txt”
    $windowsupdateTime= (Get-Content $mypath | findstr "InstalledOn:")[-1..-1]
    $windowsupdateTime = -Split $windowsupdateTime
    $windowsupdateTime = $windowsupdateTime[1]
    if ($null -eq $windowsupdateTime) {$windowsupdateTime="XXXXXXXX"}
    echo "[-] $ip last update was @ $windowsupdateTime "
    "{0},{1}" -f ($ip),($windowsupdateTime) | add-content -path $csvFile
   
}
##################################################################################################################
#----------------------------------------------------------------------------------------------------------------#
##################################################################################################################
################################################Archive Logs######################################################
##################################################################################################################
echo "[*] Archieve Process .... " 
$archDir = ( $dirList + ($r.ToShortDateString()).replace("/","") + "_evidance_archieve")
mkdir $archDir
cd $archDir
foreach ($line in $lines){mv ($dirList+“windowsUpdate_$line.txt”) ./}
cd ..

##################################################################################################################
#----------------------------------------------------------------------------------------------------------------#
######################################### Watch Logger ###########################################################
##################################################################################################################
Get-History | Export-Clixml ($dirList+"cmdletHistory_"+($r.ToShortDateString()).replace("/","")+".xml")
notepad $logs
