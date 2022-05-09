#Requires -RunAsAdministrator
Set-Variable OCULUSDIR $Env:OCULUSBASE"Support\oculus-dash\dash\bin\"

#
# Remove modified installation of OculusDash, and revert to original
#
function Remove-OculusKiller {
    Remove-Item $OCULUSDIR"OculusDash.exe" -Confirm
    Copy-Item $OCULUSDIR"OculusDash.exe.bak" $OCULUSDIR"OculusDash.exe" -Confirm
    Remove-Item $OCULUSDIR"OculusDash.exe.bak" -Confirm

    Write-Output "OculusKiller removed, and original OculusDash installation reverted."

    net start OVRService

    Exit
}

#
# Install a modified version of OculusDash
#
function Install-OculusKiller {
    net stop OVRService

    Copy-Item $OCULUSDIR"OculusDash.exe" $PSScriptRoot"\OculusDash.exe.bak"
    Copy-Item $OCULUSDIR"OculusDash.exe" $OCULUSDIR"OculusDash.exe.bak"
    Remove-Item $OCULUSDIR"OculusDash.exe"
    Copy-Item $PSScriptRoot"\OculusDash.exe" $OCULUSDIR"OculusDash.exe" 

    Write-Output "OculusKiller is now installed."
    Write-Output "A backup copy of OculusDash.exe was left in the OculusKiller directory."

    Exit
}

#
# Main decision tree of OculusKiller installer
#
function Installer-Main {
    Write-Output "Checking if OculusKiller is installed..."

    $origPath = Test-Path -Path $Env:OCULUSBASE"Support\oculus-dash\dash\bin\OculusDash.exe"
    $backupPath = Test-Path -Path $Env:OCULUSBASE"Support\oculus-dash\dash\bin\OculusDash.exe.bak"

    Write-Output "Found Oculus Server installation in $Env:OCULUSBASE"

    if ($origPath) {
        if ($backupPath) { # Original + backup are present. Likely already installed
            Write-Output "Original OculusDash and backup file are present."
            $answer = Read-Host -Prompt "Restore installation? y\n"
            if ($answer -eq "y") {
                Remove-OculusKiller
            } else {
                Write-Output "No task recieved. Stopping."
                Exit
            }
        } else { # Original present, but not backup. Assuming not installed yet
            Write-Output "Backup of OculusDash not found. Assuming that original file is unmodified."
            $answer = Read-Host -Prompt "Install? y\n"
            if ($answer -eq "y") {
                Install-OculusKiller
            } else {
                Write-Output "No task recieved. Stopping."
                Exit
            }
        }
    } else {
        Write-Output "Original OculusDash installation not found. Stopping."
    }
}

Write-Output "========================================"
Write-Output "          OculusKiller Installer        "
Write-Output "========================================"
Installer-Main
pause