
Start-Transcript -Path C:\provision.log -Append

Function SetupPhase1 {
  Cscript $env:WinDir\System32\SCregEdit.wsf /AU 1
  Net stop wuauserv
  Net start wuauserv

  Set-MpPreference -DisableRealtimeMonitoring $true

  New-ItemProperty -Path HKCU:\Software\Microsoft\ServerManager -Name DoNotOpenServerManagerAtLogon -PropertyType DWORD -Value "1" -Force

  Write-Output "Installing Chocolatey"
  curl.exe -o install-chocolatey.ps1 https://chocolatey.org/install.ps1
  .\install-chocolatey.ps1
  choco feature disable --name showDownloadProgress
  choco install -y git
  choco install -y curl
  choco install -y packer -version 1.4.1
  # choco install -y vagrant -version 2.0.3
  choco install -y terraform -version 0.11.14
  choco install -y procexp
  choco install -y procmon
  choco install -y azure-cli

  Write-Output "Installing Hyper-V"
  Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All -NoRestart
  Install-WindowsFeature Hyper-V-Tools
  Install-WindowsFeature Hyper-V-PowerShell

#Write-Output Install all Windows Updates
#Get-Content C:\windows\system32\en-us\WUA_SearchDownloadInstall.vbs | ForEach-Object {
#  $_ -replace 'confirm = msgbox.*$', 'confirm = vbNo'
#} | Out-File $env:TEMP\WUA_SearchDownloadInstall.vbs
#"a`na" | cscript $env:TEMP\WUA_SearchDownloadInstall.vbs

  Write-Output "Rebooting"
  Restart-Computer
}

Function SetupPhase2 {

  # Write-Output "Installing Vagrant plugins"
  # vagrant plugin install vagrant-reload

  Write-Output "Adding NAT"
  New-VMSwitch -SwitchName "packer-hyperv-iso" -SwitchType Internal
  New-NetIPAddress -IPAddress 192.168.0.1 -PrefixLength 24 -InterfaceIndex (Get-NetAdapter -name "vEthernet (packer-hyperv-iso)").ifIndex
  New-NetNat -Name MyNATnetwork -InternalIPInterfaceAddressPrefix 192.168.0.0/24

  Write-Output "Adding DHCP scope"
  Install-WindowsFeature DHCP -IncludeManagementTools
  Add-DhcpServerv4Scope -Name "Internal" -StartRange 192.168.0.10 -EndRange 192.168.0.250 -SubnetMask 255.255.255.0 -Description "Internal Network"
  Set-DhcpServerv4OptionValue -ScopeID 192.168.0 -DNSServer 8.8.8.8 -Router 192.168.0.1

  Write-Output "Allow Packer http server"
  New-NetFirewallRule -DisplayName "Allow Packer" -Direction Inbound -Program "C:\ProgramData\chocolatey\lib\packer\tools\packer.exe" -RemoteAddress LocalSubnet -Action Allow

  Write-Output "Disabling autologon"
  New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name AutoAdminLogon -PropertyType DWORD -Value "0" -Force

  Write-Output "Downloading OpenSSH"
  curl.exe -o OpenSSH-Win64.zip -L https://github.com/PowerShell/Win32-OpenSSH/releases/download/v7.7.2.0p1-Beta/OpenSSH-Win64.zip
  
  Write-Output "Expanding OpenSSH"
  Expand-Archive OpenSSH-Win64.zip C:\
  Remove-Item -Force OpenSSH-Win64.zip

  Push-Location C:\OpenSSH-Win64

  Write-Output "Installing OpenSSH"
  & .\install-sshd.ps1

  if ( ! (Test-Path $env:ProgramData\ssh) ) {
    New-Item -Type Directory $env:ProgramData\ssh
  }

  Write-Output "Generating host keys"
  .\ssh-keygen.exe -A

  Write-Output "Fixing host file permissions"
  & .\FixHostFilePermissions.ps1 -Confirm:$false

  Write-Output "Fixing user file permissions"
  & .\FixUserFilePermissions.ps1 -Confirm:$false

  Pop-Location

  $newPath = 'C:\OpenSSH-Win64;' + [Environment]::GetEnvironmentVariable("PATH", [EnvironmentVariableTarget]::Machine)
  [Environment]::SetEnvironmentVariable("PATH", $newPath, [EnvironmentVariableTarget]::Machine)

  Write-Output "Adding public key to authorized_keys"
  $keyPath = "~\.ssh\authorized_keys"
  New-Item -Type Directory ~\.ssh > $null
  $sshKey | Out-File $keyPath -Encoding Ascii

  Write-Output "Setting sshd service startup type to 'Automatic'"
  Set-Service sshd -StartupType Automatic
  Set-Service ssh-agent -StartupType Automatic
  Write-Output "Setting sshd service restart behavior"
  sc.exe failure sshd reset= 86400 actions= restart/500

  Write-Output "Starting sshd service"
  Start-Service sshd
  Start-Service ssh-agent

  Write-Output "Opening firewall port 22"
  New-NetFirewallRule -Protocol TCP -LocalPort 22 -Direction Inbound -Action Allow -DisplayName SSH
  
  Write-Output "Removing scheduled job"
  Unregister-ScheduledJob -Name NewServerSetupResume -Force
}

if (!(Test-Path c:\ProgramData\chocolatey)) {
  $pwd = ConvertTo-SecureString -String $Password -AsPlainText -Force
  $cred = New-Object System.Management.Automation.PSCredential($Username, $pwd)
  $AtStartup = New-JobTrigger -AtStartup
  Register-ScheduledJob -Name NewServerSetupResume `
                        -Credential $cred `
                        -Trigger $AtStartup `
                        -ScriptBlock { c:\provision.ps1 }
  SetupPhase1
} else {
  SetupPhase2
}
