#file:commands log
@"
create vdisk file=D:\Win10.vhdx maximum=95600 type=fixed
attach vdisk
create partition primary
format quick label=vhdx
assign letter=v
exit
Dism /Apply-Image /ImageFile:install.wim /index:1 /ApplyDir:V:\
#mount Win10_22h2.iso 
dism /Get-WimInfo /WimFile:e:\sources\install.esd
#get index of needed OS version
set X_VERSION_DE_WINDOWS 
#dism /export-image /SourceImageFile:e:\sources\install.esd /SourceIndex:X_VERSION_DE_WINDOWS /DestinationImageFile:install.wim /Compress:max /CheckIntegrity
dism /export-image /SourceImageFile:e:\sources\install.esd /SourceIndex:6 /DestinationImageFile:%tmp%\install.wim /Compress:max /CheckIntegrity
Dism /Apply-Image /ImageFile:%tmp%\install.wim /index:1 /ApplyDir:V:\
diskpart
select vdisk file=D:\Win10.vhdx

#detach vdisk
select disk 0
list partition
#<x> is the 100 megabyte (MB) EFI system partition
#select partition <x>
select partition 1
bcdboot v:\windows


"@

