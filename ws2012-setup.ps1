Write-Host "Starting file script..." 

Write-Host 'Executing [DateTime]::Now...' 
[DateTime]::Now

Write-Host 'Executing Install-WindowsFeature -Name "XPS-Viewer" -IncludeAllSubFeature' 
Install-WindowsFeature -Name "XPS-Viewer" -IncludeAllSubFeature

Write-Host 'Installing Octopus Deploy Tentacle...' 
$filename = "Octopus.Tentacle.3.8.2-x64";
$link = "https://octopus.com/downloads/latest/WindowsX64/OctopusTentacle";
$dstDir = "c:\ShchFileFolder";
New-Item $dstDir -type directory -force | Out-Null
$remotePath = Join-Path $dstDir $filename;
(New-Object System.Net.Webclient).downloadfile($link, $remotePath);
$msiAgrumentList = "-i $remotePath /quiet"
Start-Process msiexec -Wait -Argument $msiAgrumentList;

Write-Host 'Configure OD Listening Tentacle...'
$odInstallPath = "C:\Program Files\Octopus Deploy\Tentacle";
$exeName = "Tentacle.exe";
$exePath = Join-Path $odInstallPath $exeName;
Start-Process $exePath -NoNewWindow -Wait -Argument "create-instance --instance "Tentacle" --config "C:\Octopus\Tentacle.config" --console";
Start-Process $exePath -NoNewWindow -Wait -Argument "new-certificate --instance "Tentacle" --if-blank --console";
Start-Process $exePath -NoNewWindow -Wait -Argument "configure --instance "Tentacle" --reset-trust --console";
Start-Process $exePath -NoNewWindow -Wait -Argument "configure --instance "Tentacle" --home "C:\Octopus" --app "C:\Octopus\Applications" --port "10933" --console";
Start-Process $exePath -NoNewWindow -Wait -Argument "configure --instance "Tentacle" --trust "YOUR_OCTOPUS_THUMBPRINT" --console";
Start-Process netsh -NoNewWindow -Wait -Argument "advfirewall firewall add rule "name=Octopus Deploy Tentacle" dir=in action=allow protocol=TCP localport=10933";
Start-Process $exePath -NoNewWindow -Wait -Argument "service --instance "Tentacle" --install --start --console";

Write-Host "File script finished!" 
