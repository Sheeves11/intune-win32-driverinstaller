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
