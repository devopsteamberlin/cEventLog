function New-TerminatingError
{
    param
    (
        [Parameter(Mandatory)]
        [String]$errorId,
        
        [Parameter(Mandatory)]
        [String]$errorMessage,

        [Parameter(Mandatory)]
        [System.Management.Automation.ErrorCategory]$errorCategory
    )
    
    $exception   = New-Object System.InvalidOperationException $errorMessage 
    $errorRecord = New-Object System.Management.Automation.ErrorRecord $exception, $errorId, $errorCategory, $null
    throw $errorRecord
}

function Get-TargetResource
{
	[CmdletBinding()]
	[OutputType([System.Collections.Hashtable])]
	param
	(
		[parameter(Mandatory = $true)]
		[System.String]
		$LogName
	)

    try
    {
        $log = Get-WinEvent -ListLog $logName
        $returnValue = @{
	        LogName = [System.String]$LogName
	        MaximumSizeInBytes = [System.Int64]$log.MaximumSizeInBytes
	        IsEnabled = [System.Boolean]$log.IsEnabled
	        LogMode = [System.String]$log.LogMode
	        SecurityDescriptor = [System.String]$log.SecurityDescriptor
            LogPath = $log.logfilepath
        }

        return $returnValue

    }catch
    {
        write-Debug "ERROR: $($_|fl * -force|out-string)"
        New-TerminatingError -errorId 'GetWinEventLogFailed' -errorMessage $_.Exception -errorCategory InvalidOperation
    }
}


function Set-TargetResource
{
	[CmdletBinding()]
	param
	(
		[parameter(Mandatory = $true)]
		[System.String]
		$LogName,

		[System.Int64]
		$MaximumSizeInBytes,

		[System.Boolean]
		$IsEnabled,

		[ValidateSet("AutoBackup","Circular","Retain")]
		[System.String]
		$LogMode,

		[System.String]
		$SecurityDescriptor,

        [String]
        $LogPath
	)

    Write-Verbose "Checking to see if $LogName Event Log exists"

    try
    {
        $log = Get-WinEvent -ListLog $logName
        if ($log) { Write-Verbose "$LogName was found.  Making specified changes" }
        if ($MaximumSizeInBytes){
             Write-Verbose "Setting MaximumSizeInBytes to $MaximumSizeInBytes"
             $log.MaximumSizeInBytes = $MaximumSizeInBytes
            }
        if ($LogMode){
             Write-Verbose "Setting LogMode to $LogMode"
             $log.LogMode = $LogMode
            }
        if ($SecurityDescriptor){
             Write-Verbose "Setting SecurityDescriptor to $SecurityDescriptor"
             $log.SecurityDescriptor = $SecurityDescriptor
            }
        if ($LogPath){
            Write-Verbose "Checking to see if $LogPath exists"
            $TestPath = Test-Path $LogPath
            If($TestPath -eq $False){
                Write-Verbose "$LogPath does not exist.  Creating folder structure and setting logging path"
                New-Item -ItemType Directory -Path $LogPath
                $log.LogFilePath = ($LogPath + '\' + $LogName + '.evtx')
            }
            Else{
                Write-Verbose "$LogPath Exists.  Setting log path"
                $log.LogFilePath = ($LogPath + '\' + $LogName + '.evtx')
            }
        }

        $log.SaveChanges()

        try
        {
            if ($PSBoundParameters.ContainsKey("IsEnabled")) 
            { $log.IsEnabled = $IsEnabled}
            $log.SaveChanges()
        }catch
        {
            New-TerminatingError -errorId 'SetWinEventLogFailed' -errorMessage "`nCannot change IsEnabled on [WinEventLog]$logName" -errorCategory InvalidOperation
        }

    }catch
    {
        Write-Verbose "$LogName Event Log does not exist"
        write-Debug "ERROR: $($_|fl * -force|out-string)"
        New-TerminatingError -errorId 'SetWinEventLogFailed' -errorMessage $_.Exception -errorCategory InvalidOperation
    }

}


function Test-TargetResource
{
	[CmdletBinding()]
	[OutputType([System.Boolean])]
	param
	(
		[parameter(Mandatory = $true)]
		[System.String]
		$LogName,

		[System.Int64]
		$MaximumSizeInBytes,

		[System.Boolean]
		$IsEnabled,

		[ValidateSet("AutoBackup","Circular","Retain")]
		[System.String]
		$LogMode,

		[System.String]
		$SecurityDescriptor,

        [String]
        $LogPath
	)

    Write-Verbose "Checking to see if $LogName Event Log exists"

    try
    {        
        $log = Get-WinEvent -ListLog $logName
        if ($log) { Write-Verbose "$LogName was found.  Checking other parameters" }
        if ($PSBoundParameters.ContainsKey("MaximumSizeInBytes") -and $log.MaximumSizeInBytes -ne $MaximumSizeInBytes ){
            Write-Verbose "The  MaximumSizeInBytes for $LogName does not match $MaximumSizeInBytes"
            return $false
        }
        if ($PSBoundParameters.ContainsKey("IsEnabled")          -and $log.IsEnabled -ne $IsEnabled                   ){
            Write-Verbose "The IsEnabled setting for $LogName does not match  $IsEnabled"
            return $false
        }
        if ($PSBoundParameters.ContainsKey("LogMode")            -and $log.LogMode -ne $LogMode                       ){
            Write-Verbose "The Log Mode for $LogName does not match $LogMode"
            return $false
        }
        if ($PSBoundParameters.ContainsKey("SecurityDescriptor") -and $log.SecurityDescriptor -ne $SecurityDescriptor ){
            Write-Verbose "The SecurityDescriptor for $LogName does not match $SecurityDescriptor"
            return $false
        }
        if ($PSBoundParameters.ContainsKey("LogPath")            -and $log.logfilepath -ne $LogPath                   ){
            Write-Verbose "The LogPath for $LogName does not match $LogPath"
            return $false
        }
        return $true
    }catch
    {
        Write-Verbose "$LogName Event Log does not exist"
        write-Debug "ERROR: $($_|fl * -force|out-string)"
        New-TerminatingError -errorId 'TestWinEventLogFailed' -errorMessage $_.Exception -errorCategory InvalidOperation
    }
    
}


Export-ModuleMember -Function *-TargetResource

