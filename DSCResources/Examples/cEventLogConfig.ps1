Configuration cTestEventLog{

    Import-DSCResource -Name cEventLog

    node $YourNode{

        cEventLog Test{

            LogName = "Application"
            LogPath = "E:\EventViewer"
            LogMode = "Circular"
            MaximumSizeinBytes = 4096MB

        }
    }
}

cTestEventLog -OutputPath $YourPath

Copy-Item -Path $YourModuleFolder -Destination $DestinationModuleFolder -Recurse -Force -Verbose

Start-DSCConfiguration -Wait -Force -Verbose -Path $YourPath
