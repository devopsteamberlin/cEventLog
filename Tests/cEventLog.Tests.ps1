#$Module = ".\DSCResources\cEventLog\cEventLog.psm1"
# Make sure the module is not loaded already
if (Get-Module cEventLog) {
    Remove-Module cEventLog -Force -ErrorAction SilentlyContinue
}

$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
Import-Module "$Here\..\cEventLog" -Force -ErrorAction Stop

    Describe "cEventLog"{

        Context Test-TargetResource{
            It 'Returns True if Log Exists'{
                {Test-TargetResource -LogName "Application"} | Should Be $True
            }
            It 'Returns False if Log Does Not Exist'{
                {Test-TargetResource -LogName "MyApp"} | Should be $False
            }

        }
    }