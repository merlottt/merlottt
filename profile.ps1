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
    Get-ADUser -filter "Name -like '*$username*'"  -properties:Created,Enabled,LockedOut,PasswordExpired,PasswordLastSet,PasswordNeverExpires,Manager,Title,mail -Server $config.ad1.host -Credential $ad1creds
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
    Get-WindowsCapability -Name RSAT* -Online | Add-WindowsCapability –Online
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

function Get-ADGroupTreeViewMemberOf {
#requires -version 4
<#
.SYNOPSIS
    Show UpStream tree view hierarchy of memberof groups recursively of a Active Directory user and Group.
.DESCRIPTION
    The Show-ADGroupTreeViewMemberOf list all nested group list of a AD user. It requires only valid parameter AD username, 
.PARAMETER UserName
    Prompts you valid active directory User name. You can use first character as an alias, If information is not provided it provides 'Administrator' user information. 
.PARAMETER GroupName
    Prompts you valid active directory Group name. You can use first character as an alias, If information is not provided it provides 'Domain Admins' group[ information.
.INPUTS
    Microsoft.ActiveDirectory.Management.ADUser
.OUTPUTS
    Microsoft.ActiveDirectory.Management.ADGroup
.NOTES
    Version:        1.0
    Author:         Kunal Udapi
    Creation Date:  10 September 2017
    Purpose/Change: Get the exact nested group info of user
    Useful URLs: http://vcloud-lab.com
.EXAMPLE
    PS C:\>.\Get-ADGroupTreeViewMemberOf -UserName Administrator

    This list all the upstream memberof group of an user.
.EXAMPLE
    PS C:\>.\Get-ADGroupTreeViewMemberOf -GroupName DomainAdmins

    This list all the upstream memberof group of a Group.
#>

[CmdletBinding(SupportsShouldProcess=$True,
    ConfirmImpact='Medium',
    HelpURI='http://vcloud-lab.com',
    DefaultParameterSetName='User')]
Param
(
    [parameter(ParameterSetName = 'User',Position=0, ValueFromPipelineByPropertyName=$true, ValueFromPipeline=$true, HelpMessage='Type valid AD username')]
    [alias('User')]
    [String]$UserName = 'Administrator',
    [parameter(ParameterSetName = 'Group',Position=0, ValueFromPipelineByPropertyName=$true, ValueFromPipeline=$true, HelpMessage='Type valid AD Group')]
    [alias('Group')]
    [String]$GroupName = 'Domain Admins',
    [parameter(ParameterSetName = 'Group', DontShow=$True)]
    [parameter(ParameterSetName = 'User', DontShow=$True)]
    [alias('U')]
    $UpperValue = [System.Int32]::MaxValue,
    [parameter(ParameterSetName = 'Group', DontShow=$True)]
    [parameter(ParameterSetName = 'User', DontShow=$True)]
    [alias('L')]
    $LowerValue = 2
)
    begin {
        if (!(Get-Module Activedirectory)) {
            try {
                Import-Module ActiveDirectory -ErrorAction Stop 
            }
            catch {
                Write-Host -Object "ActiveDirectory Module didn't find, Please install it and try again" -BackgroundColor DarkRed
                Break
            }
        }
        switch ($PsCmdlet.ParameterSetName) {
            'Group' {
                try {
                    $Group =  Get-ADGroup $GroupName -Properties Memberof -ErrorAction Stop 
                    $MemberOf = $Group | Select-Object -ExpandProperty Memberof 
                    $rootname = $Group.Name
                }
                catch {
                    Write-Host -Object "`'$GroupName`' groupname doesn't exist in Active Directory, Please try again." -BackgroundColor DarkRed
                    $result = 'Break'
                    Break
                }
                break            
            }
            'User' {
                try {
                    $User = Get-ADUser $UserName -Properties Memberof -ErrorAction Stop
                    $MemberOf = $User | Select-Object -ExpandProperty Memberof -ErrorAction Stop
                    $rootname = $User.Name
                    
                }
                catch {
                    Write-Host -Object "`'$($User.Name)`' username doesn't exist in Active Directory, Please try again." -BackgroundColor DarkRed
                    $result = 'Break'
                    Break
                }
                Break
            }
        }
    }
    Process {
        $Minus = $LowerValue - 2
        $Spaces = " " * $Minus
        $Lines = "__"
        "{0}{1}{2}{3}" -f $Spaces, '|', $Lines, $rootname        
        $LowerValue++
        $LowerValue++
        if ($LowerValue -le $UpperValue) {
            foreach ($member in $MemberOf) {
                $UpperGroup = Get-ADGroup $member -Properties Memberof
                $LowerGroup = $UpperGroup | Get-ADGroupMember
                $LoopCheck = $UpperGroup.MemberOf | ForEach-Object {$lowerGroup.distinguishedName -contains $_}
            
                if ($LoopCheck -Contains $True) {
                    $rootname = $UpperGroup.Name
                    Write-Host "Loop found on $($UpperGroup.Name), Skipping..." -BackgroundColor DarkRed
                    Continue
                }
                #"xxx $($LowerGroup.name)"
                #$Member
                #"--- $($UpperGroup.Name) `n"
                Get-ADGroupTreeViewMemberOf -GroupName $member -LowerValue $LowerValue -UpperValue $UpperValue
            } #foreach ($member in $MemberOf) {
        }
    } #Process
}


Function Connect-EXOnline{
 
$credentials = Get-Credential -Credential $config.o365.user
Write-Output "Getting the Exchange Online cmdlets"
 
$Session = New-PSSession -ConnectionUri https://outlook.office365.com/powershell-liveid/ `
-ConfigurationName Microsoft.Exchange -Credential $credentials `
-Authentication Basic -AllowRedirection
Import-PSSession $Session
 
}
function RemoteFirewallRules-Enable{
    Get-NetFirewallRule -DisplayName "Remote Scheduled*" | Set-NetFirewallRule -Enabled True
    Get-NetFirewallRule -DisplayName "Remote Assistance*" | Set-NetFirewallRule -Enabled True
    Get-NetFirewallRule -DisplayName "Remote Event Log Management*" | Set-NetFirewallRule -Enabled True
    Get-NetFirewallRule -DisplayName "Remote Volume Management*" | Set-NetFirewallRule -Enabled True
    Get-NetFirewallRule -DisplayName "Remote Event Monitor*" | Set-NetFirewallRule -Enabled True
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