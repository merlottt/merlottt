function cd...  { cd ..\.. }
function cd.... { cd ..\..\.. }
function edit ($file) { & "${env:ProgramFiles(x86)}\Notepad++\notepad++.exe" $file }
function explore { "explorer.exe `"$(pwd)`"" | iex }
function download ($url, $file) {(new-object Net.WebClient).DownloadFile($url, $file)}
function wget ($url) {(new-object Net.WebClient).DownloadString("$url")}
function admin
{
    if ($args.Count -gt 0)    {  $argList = "& '" + $args + "'";       Start-Process "$psHome\powershell.exe" -Verb runAs -ArgumentList $argList    }
    else    {       Start-Process "$psHome\powershell.exe" -Verb runAs    }
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

if (-not(Test-Path $ENV:userprofile\env\)) {
    git clone https://github.com/merlottt/merlottt.git $ENV:userprofile\env\
}
else {
    git -C $ENV:userprofile\env\ pull
}
if (Test-Path $ENV:userprofile\env\profile.ps1)
{
    Copy-Item "$ENV:userprofile\env\profile.ps1" -Destination "$PROFILE.CurrentUserAllHosts"
}