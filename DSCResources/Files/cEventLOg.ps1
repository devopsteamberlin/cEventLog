#Name the Resource
#$ResourceName = '<ResourceName'
$ResourceName = 'cEventLog'

#Create Module Path
$ResourcePath = <SomePath>

Import-Module -Name xDSCResourceDesigner

#Create the Resource and define Resource properties
    New-xDSCResource -Name $ResourceName -Path $ResourcePath -ClassVersion 1.0 -Force -Property $(
    New-xDscResourceProperty -Name LogName -Type String -Attribute Key -Description "Name of the event log"
    New-xDscResourceProperty -Name MaximumSizeInBytes -Type Sint64 -Attribute Write -Description "sizethat the event log file is allowed to be When the file reaches this maximum size it is considered full"
    New-xDscResourceProperty -Name IsEnabled -Type Boolean -Attribute Write -Description "Enable or Disable the specified event log"
    New-xDscResourceProperty -Name LogMode -Type String -Attribute Write -ValidateSet "AutoBackup","Circular","Retain"
    New-xDscResourceProperty -Name SecurityDescriptor -Type String -Attribute Write
    New-xDSCResourceProperty -Name LogPath -Type String -Attribute Write -Description "Path the log file should be stored in"
    )

#If needed, use Update-xDSCResource if you add/remove any parameters from the resource
#Update-xDscResource -Name $ResourceName -Property $ProductKey,$Activate -ClassVersion 1.0 -Force
Update-xDscResource -Name $ResourceName -ClassVersion 1.0 -Force -Property $(
    New-xDscResourceProperty -Name LogName -Type String -Attribute Key -Description "Name of the event log"
    New-xDscResourceProperty -Name MaximumSizeInBytes -Type Sint64 -Attribute Write -Description "sizethat the event log file is allowed to be When the file reaches this maximum size it is considered full"
    New-xDscResourceProperty -Name IsEnabled -Type Boolean -Attribute Write -Description "Enable or Disable the specified event log"
    New-xDscResourceProperty -Name LogMode -Type String -Attribute Write -ValidateSet "AutoBackup","Circular","Retain"
    New-xDscResourceProperty -Name SecurityDescriptor -Type String -Attribute Write
    New-xDSCResourceProperty -Name LogPath -Type String -Attribute Write -Description "Path the log file should be stored in"
    )

#Test the schema after updating or creating
Test-xDscSchema -Path ($ResourcePath + 'DSCResources\' + $ResourceName + ("\$ResourceName" + '.schema.mof'))