
$srcstorage = "<source_storagename>"
$containers = @()
$containers += "<containername1>"
$containers += "<containername2>"
$containers += "<containername3>"
$trgtstorage = "<target_storagename>"

$srcsas = "<source_SAStoken>"
$trgtsas = "<target_SAStoken>"

$source = "https://${srcstorage}.blob.core.windows.net/${container}?$srcsas"
$dest = "https://${trgtstorage}.blob.core.windows.net/${container}?$trgtsas"

foreach ($container in $containers) {
echo "................copying ${container} ....................."
.\azcopy.exe copy $source $dest  --recursive
}

