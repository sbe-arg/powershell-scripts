$VMname = "TempVM"
$VMpath = $HOME + '\VirtualBox VMs\' + $VMname
$isopath = "C:\garbage\iso\ms-server-2016-eval.ISO"

# create vm
vboxmanage createvm --name $VMname --register
# show info of vm
vboxmanage showvminfo $VMname
# modify vm to work on desired ram, video, boot, network config
vboxmanage modifyvm $VMname –memory 2048 -vram 64 –acpi on –boot1 dvd –nic1 bridged –bridgeadapter1 eth0

# list vm types
# vboxmanage list ostypes

# set vm type
vboxmanage modifyvm $VMname –ostype Windows2012_64

# create disk 10gb
vboxmanage createvdi –filename “$VMname-disk01.vdi” -size 10240 -remember

# boot up order and add an IDE controller
vboxmanage storagectl $VMname –name “IDE Controller” –add ide
$hda = $VMpath + "\$VMname-disk01.vdi"
vboxmanage modifyvm “$VMname” –boot1 dvd –hda "$hda" –sata on

# specify iso as dbd
vboxmanage storageattach $VMname –storagectl “IDE Controller” –port 0 -device 0 –type hdd –medium “$hda”
vboxmanage storageattach $VMname –storagectl “IDE Controller” –port 1 -device 0 -type dvddrive -medium $isopath
vboxmanage modifyvm “$VMname” -dvd $isopath

# start vm
vboxmanage startvm $VMname

# turn off vm
# vboxmanage controlvm $VMname poweroff

vboxmanage startvm $VMname -headless
vboxmanage showvminfo $VMname –details
