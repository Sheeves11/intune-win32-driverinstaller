Hi!  

There are times when you need to install a driver or set of drivers to a large group of Windows computers and unfortunately Microsoft Intune does not currently include a tool to do so! The option to deploy powershell scripts exists, but it has some limitations that make me prefer Win32 Apps. With this, you'll be able to quickly assign and monitor deployments of the script.

However, if you've tried to deploy a powershell script via Intune, you'll find that it has some oddities. This script is robust and works around all of those oddities. Just drop your .INF files into the driver folder, compile the intune.win package, and upload to Intune!

This script creates a logfile at C:\tmp\installdriver.txt and does context switching between system32 and sysnative file paths for easy testing on your local machine. It will also take care of most certificate issues by importing them into the local cert store.

For more information about the actual deployment process and writing a detection script, you can view the readme included in my intune-win32-print project.

https://github.com/Sheeves11/intune-win32-print


```powershell
#start logging
start-transcript -Path "C:\tmp\installdriver.txt"

#Get the driver certificate. This is not needed for all drivers
$AuthCodeSig = Get-AuthenticodeSignature .\YOURDRIVERNAMEHERE.cat

# Export it to file to be used later
Export-Certificate -Cert $AuthCodeSig.SignerCertificate -FilePath .\certificate.cer

# Import the certificate into the TrustedPublisher store
Import-Certificate -FilePath .\certificate.cer -CertStoreLocation Cert:\LocalMachine\TrustedPublisher

#Now we have the certificate in the driver store. We'll install the actual driver now 
#The try-catch block tries both sysnative and system32 in search of pnputil.exe

#This part of the script is recursive and will install ALL .inf files in the folder.

Try
{ 
    Get-ChildItem "$PSScriptRoot\Drivers" -Recurse -Filter "*inf" | ForEach-Object { C:\Windows\sysnative\pnputil.exe /add-driver $_.FullName /install }  
    Write-Host "SYSNATIVE ACCESS SUCCESSFUL" 
}
Catch
{ 
    Get-ChildItem "$PSScriptRoot\Drivers" -Recurse -Filter "*inf" | ForEach-Object { C:\Windows\system32\pnputil.exe /add-driver $_.FullName /install }  
    Write-Host "SYSTEM32 ACCESS SUCCESSFUL" 
}

stop-transcript
```

After you've got this script ready, you'll just package it up and add a detection script, as described in my intune-win32-print project.

Do some testing, read the logs if you have any issues, and you're good to go!
