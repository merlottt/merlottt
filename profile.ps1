function cd...  { cd ..\.. }
function cd.... { cd ..\..\.. }
function edit ($file) { & "${env:ProgramFiles}\Notepad++\notepad++.exe" $file }
function explore { "explorer.exe `"$(pwd)`"" | iex }
function download ($url, $file) {(new-object Net.WebClient).DownloadFile($url, $file)}
function wget ($url) {(new-object Net.WebClient).DownloadString("$url")}
function admin{
    if ($args.Count -gt 0)    {  $argList = "& '" + $args + "'";       Start-Process "$psHome\powershell.exe" -Verb runAs -ArgumentList $argList    }
    else    {       Start-Process "$psHome\powershell.exe" -Verb runAs    }
}
function grep {
  $input | out-string -stream | select-string $args
}
function add_sssdsudoGroups($hostname) {
$hostname |%{New-ADGroup SSSD-$_ -path "$config.ad1.g_sssd_path" -GroupCategory Security -GroupScope Global;New-ADGroup SUDO-$_ -path "$config.ad1.g_sudo_path" -GroupCategory Security -GroupScope Global}
}
Function New-RandomPassword{
    Param(
        [ValidateRange(8, 32)]
        [int] $Length = 16
    )   
    $AsciiCharsList = @()   
    foreach ($a in (33..126)){ $AsciiCharsList += , [char][byte]$a }
    $RegEx = "(?=^.{8,32}$)((?=.*\d)(?=.*[A-Z])(?=.*[a-z])|(?=.*\d)(?=.*[^A-Za-z0-9])(?=.*[a-z])|(?=.*[^A-Za-z0-9])(?=.*[A-Z])(?=.*[a-z])|(?=.*\d)(?=.*[A-Z])(?=.*[^A-Za-z0-9]))^.*"
    do {
        $Password = ""
        $loops = 1..$Length
        Foreach ($loop in $loops) { $Password += $AsciiCharsList | Get-Random }
    }
    until ($Password -match $RegEx )   
    return $Password   
}
function removeJpegPhotouserAD($userlogin) { set-aduser $userlogin -clear jpegPhoto }

function fuip_ad0($username) {
Get-aduser -filter "Name -like '*$username*'" -properties:Created,Enabled,LockedOut,PasswordExpired,PasswordLastSet,PasswordNeverExpires,Manager,Title
(Get-ADUser -filter "Name -like '*$username*'" –Properties MemberOf).MemberOf
} 

function rup_ad0($username) {
    New-RandomPassword
    $NewPassword = (Read-Host -Prompt "Provide New Password" -AsSecureString)
    Set-ADAccountPassword -identity $username -NewPassword $NewPassword -Reset
} 
function fuip_ad1($username) {
    while($env:ad1pass -eq $null)
    {
        $inputad1pass = Read-Host "Enter a Password from AD1 operator Account" -AsSecureString
        $bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($inputad1pass)
        $env:ad1pass = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)
    }
    $secpasswd = ConvertTo-SecureString $env:ad1pass -AsPlainText -Force
    $ad1creds = New-Object System.Management.Automation.PSCredential ($config.ad1.user, $secpasswd)
    Get-ADUser -filter "Name -like '*$username*'"  -properties:Created,Enabled,LockedOut,PasswordExpired,PasswordLastSet,PasswordNeverExpires,Manager,Title -Server $config.ad1.host -Credential $ad1creds
    (Get-ADUser -filter "Name -like '*$username*'" –Properties MemberOf -Server $config.ad1.host -Credential $ad1creds).MemberOf
} 

function rup_ad1($username) {
    while($env:ad1pass -eq $null)
    {
        $inputad1pass = Read-Host "Enter a Password from AD1 operator Account" -AsSecureString
        $bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($inputad1pass)
        $env:ad1pass = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)
    }
    $secpasswd = ConvertTo-SecureString $env:ad1pass -AsPlainText -Force
    $ad1creds = New-Object System.Management.Automation.PSCredential ($config.ad1.user, $secpasswd)
    New-RandomPassword
    $NewPassword = (Read-Host -Prompt "Provide New Password" -AsSecureString)
    Set-ADAccountPassword -identity $username -NewPassword $NewPassword -Reset -Server $config.ad1.host -Credential $ad1creds
} 

function umsGUID($username) {
    $msGorig = (Get-ADUser -Identity $username -properties:'ms-DS-ConsistencyGUID').'ms-DS-ConsistencyGUID'
    Write-host "Original ms-DS-ConsistencyGUID:" $msGorig -foreground green
    $msConv = [guid]$msGorig
    Write-host "Converted ms-DS-ConsistencyGUID:" $msConv -foreground red
    $Gorig = (Get-ADUser -Identity $username -properties:'ObjectGUID').'ObjectGUID'
    Write-host "Original objectGUID:" $Gorig -foreground red
    $Gconv=$Gorig.ToByteArray()
    Write-host "Converted objectGUID:" $Gconv -foreground green
}

Function sync_ad0_ad1_userinfo($username) {
    $cur_user= get-aduser $username -properties:Title,manager,division,description,Department,absrcdepartment
    $manager_cur_user=(get-aduser $cur_user.Manager).samaccountname
    $jobtitle_cur_user=$cur_user.Title
    while($env:ad1pass -eq $null)
    {
        $inputad1pass = Read-Host "Enter a Password from AD1 operator Account" -AsSecureString
        $bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($inputad1pass)
        $env:ad1pass = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)
    }
    $secpasswd = ConvertTo-SecureString $env:ad1pass -AsPlainText -Force
    $ad1creds = New-Object System.Management.Automation.PSCredential ($config.ad0.user, $secpasswd)
    set-ADUser $cur_user.samaccountname -manager $manager_cur_user -Title $jobtitle_cur_user -Description $jobtitle_cur_user -Server $config.ad1.host -Credential $ad1creds;
    Write-Host set-ADUser $cur_user.samaccountname -manager $manager_cur_user -Title `"$jobtitle_cur_user`" -Description `"$jobtitle_cur_user`"
} 

Set-Alias -Name su -Value admin
Set-Alias -Name sudo -Value admin
Set-Alias -Name vnc -Value "C:\Program Files\TightVNC\tvnviewer.exe"
#init profile
function init_profile {
    if (-not (Test-Path $PROFILE.CurrentUserAllHosts))
    {
        New-Item -Type File -Force $PROFILE.CurrentUserAllHosts
    }
}

function initEnv {
#example @"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"
    # Install Chocolatey if it's not already available
    if (!(Get-Command choco.exe -ErrorAction SilentlyContinue)) {
        Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))}
    SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"
    choco install -y python3
    choco install -y windirstat

    python -m pip install --pgrade pip
    # Install TightVNC without Password Authentication (defer to Console AD Auths)
    #choco install tightvnc -y --installArguments 'SET_USEVNCAUTHENTICATION=1 VALUE_OF_USEVNCAUTHENTICATION=0'
    # Install only VNC Viewer
    choco install tightvnc -iay "ADDLOCAL=Viewer"
    $data2 = @(
    @("notepadpp.exe","https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v8.1.5/npp.8.1.5.Installer.exe","/S"),
    @(4,5,6),
    @(7,8,9)
    )
    $url = "https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v8.1.5/npp.8.1.5.Installer.exe"
    $outpath = "$env:TEMP/npp.8.1.5.Installer.exe"
    Invoke-WebRequest -Uri $url -OutFile $outpath
    $args = @("/S")
    Start-Process -Filepath "$env:TEMP/npp.8.1.5.Installer.exe" -ArgumentList $args 
}

function ssh-copy-Key($user_host) {
cat ~/.ssh/id_rsa.pub | ssh $user_host "umask 077; test -d .ssh || mkdir .ssh ; cat >> .ssh/authorized_keys || exit 1"

}

#BEGIN
if (-not(Test-Path $ENV:userprofile\ps_profile.config)) { 
    $empty_config='
$Data = @{
 ad1 = @{
       host  = "ad1.com"
       user     = "name.operator"

 }
 ad0 = @{
       host  = "ad0.com"
       user     = "admin.name"
       g_sssd_path     = "OU=sssd,OU=groups,DC=ad0,DC=com"
       g_sudo_path     = "OU=sudo,OU=groups,DC=ado,DC=com"


 } 
jira = @{
       host  = "jira.com"
       user     = "admin.name"
       password     = ""
       ssh_username_host     = "admin.name@host"
       path_to_script = "/home/ldusers/admin.name/jira.sh"


 }

 }'
 $empty_config | Out-File $ENV:userprofile\ps_profile.config
}
$path_to_config="$ENV:userprofile\ps_profile.config"
$config=Import-PowerShellDataFile $path_to_config
clear
Write-Host -foregroundcolor Red Be careful, the script is in the public git. 
Write-Host -foregroundcolor Green Store confidential information in a config file 
Write-Host -foregroundcolor Green Path to current config file:  $path_to_config
Write-Host -foregroundcolor Green -BackgroundColor DarkGray Last modify config file: (Get-Item $path_to_config).LastWriteTime

if (-not(Test-Path $ENV:userprofile\env\)) {    git clone https://github.com/merlottt/merlottt.git $ENV:userprofile\env\ }
else {    git -C $ENV:userprofile\env\ pull }
if (Test-Path $ENV:userprofile\env\profile.ps1) { Copy-Item $ENV:userprofile\env\profile.ps1 -Destination $PROFILE.CurrentUserAllHosts -Force }