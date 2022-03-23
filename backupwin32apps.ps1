$path = "C:\install\intune" 
New-Item -ItemType Directory -Force -Path $path | Out-null


##### Convert sids to names ######

$objSID = New-Object System.Security.Principal.SecurityIdentifier ("S-1-5-18")
$objUser = $objSID.Translate( [System.Security.Principal.NTAccount])
$system = $objUser.Value

$objSID = New-Object System.Security.Principal.SecurityIdentifier ("S-1-1-0")
$objUser = $objSID.Translate( [System.Security.Principal.NTAccount])
$everyone = $objUser.Value



##### Showing warning prompt ######
Add-Type -AssemblyName PresentationCore,PresentationFramework
$ButtonType = [System.Windows.MessageBoxButton]::OkCancel
$MessageIcon = [System.Windows.MessageBoxImage]::Warning
$MessageBody = "After pressing OK, SYSTEM will be denied on the IMECACHE folder"
$MessageTitle = "Denying permissions"
$Result = [System.Windows.MessageBox]::Show($MessageBody,$MessageTitle,$ButtonType,$MessageIcon)
if ($result -eq 'ok'){

##### Setting deny permissions on the IMECache folder ######
$Dir = 'c:\windows\IMEcache'
$acl = Get-ACL $dir 
$acl.SetAccessRuleProtection($true,$true)
$acl |Set-Acl | out-null
$acl = Get-ACL $dir
$acl.Access |where {$_.IdentityReference -eq $system} |%{$acl.RemoveAccessRule($_)} | out-null
$acl |Set-Acl
$acl = Get-ACL $dir 
$sddl  = $acl.sddl 
$acl.SetSecurityDescriptorSddlForm($sddl)
$deny = New-Object System.Security.AccessControl.FileSystemAccessRule($system,"FullControl","Deny")
$acl.SetAccessRule($deny)
$acl |Set-Acl
}else{

#####Restoring imecache permissions########
$Dir = 'c:\windows\IMEcache'
$acl = Get-ACL $dir
$acl.Access |where {$_.IdentityReference -eq $system} |%{$acl.RemoveAccessRule($_)} | out-null
$acl |Set-Acl
$acl = Get-ACL $dir
$sddl  = $acl.sddl 
$acl.SetSecurityDescriptorSddlForm($sddl)
$allow = New-Object System.Security.AccessControl.FileSystemAccessRule($system,"FullControl","ContainerInherit,ObjectInherit","None", "allow")
$acl.SetAccessRule($allow)
$acl |Set-Acl
exit
} 

#### Showing prompt to continue ######

Add-Type -AssemblyName PresentationCore,PresentationFramework
$ButtonType = [System.Windows.MessageBoxButton]::OkCancel
$MessageIcon = [System.Windows.MessageBoxImage]::Warning
$MessageBody = "IMECache Permissions changed!, before pressing OK, please start the App install from the Company portal and wait untill the app status shows: Failed to install"
$MessageTitle = "Confirm Installation"
$Result = [System.Windows.MessageBox]::Show($MessageBody,$MessageTitle,$ButtonType,$MessageIcon)

if ($result -eq 'ok'){

##### fetching the zip file and copy it to c:\install\intune #######
$staging =  "C:\Program Files (x86)\Microsoft Intune Management Extension\Content\Staging\"
Start-Sleep -s 5
$zip  = Get-Childitem $staging -recurse | Where {$_.extension -like ".zip"} | Select-Object -ExpandProperty FullName
$path = "C:\install\intune"
copy-item  $zip $path

##### Showing prompt to start restoring permissions #######

Add-Type -AssemblyName PresentationCore,PresentationFramework
$ButtonType = [System.Windows.MessageBoxButton]::Ok
$MessageIcon = [System.Windows.MessageBoxImage]::Warning
$MessageBody = "Restoring permissions"
$MessageTitle = "Restoring permissions"
$Result = [System.Windows.MessageBox]::Show($MessageBody,$MessageTitle,$ButtonType,$MessageIcon)

######Restoring IMECACHE Permissions #######
$Dir = 'c:\windows\IMEcache'
$acl = Get-ACL $dir
$acl.Access |where {$_.IdentityReference -eq $system} |%{$acl.RemoveAccessRule($_)} | out-null
$acl |Set-Acl
$acl = Get-ACL $dir
$sddl  = $acl.sddl 
$acl.SetSecurityDescriptorSddlForm($sddl)
$allow = New-Object System.Security.AccessControl.FileSystemAccessRule($system,"FullControl","ContainerInherit,ObjectInherit","None", "allow")
$acl.SetAccessRule($allow)
$acl |Set-Acl

#####Removing Staging Subfolder########
$subfolder = Split-Path $zip
$aclStaging = Get-ACL $subfolder
$aclStaging.SetAccessRuleProtection($true,$true)
$aclStaging |Set-Acl
$aclStaging = Get-ACL $subfolder
$sddl  = $aclStaging.sddl 
$aclStaging.SetSecurityDescriptorSddlForm($sddl)
$allow = New-Object System.Security.AccessControl.FileSystemAccessRule($everyone,"FullControl","ContainerInherit,ObjectInherit","None", "allow")
$aclStaging.SetAccessRule($allow)
$aclStaging |Set-Acl
Start-Sleep -s 2
Get-ChildItem -Path $staging -Recurse| Foreach-object {Remove-item -Recurse -path $_.FullName } | out-null

######Show zip file ########
explorer.exe $path
$Dir = 'c:\windows\IMEcache'
$acl = Get-ACL $dir
$acl.Access |where {$_.IdentityReference -eq $system} |%{$acl.RemoveAccessRule($_)} | out-null
$acl |Set-Acl
$acl = Get-ACL $dir
$sddl  = $acl.sddl 
$acl.SetSecurityDescriptorSddlForm($sddl)
$allow = New-Object System.Security.AccessControl.FileSystemAccessRule($system,"FullControl","ContainerInherit,ObjectInherit","None", "allow")
$acl.SetAccessRule($allow)
$acl |Set-Acl
}else{
#####Restoring imecache permissions########
$Dir = 'c:\windows\IMEcache'
$acl = Get-ACL $dir
$acl.Access |where {$_.IdentityReference -eq $system} |%{$acl.RemoveAccessRule($_)} | out-null
$acl |Set-Acl
$acl = Get-ACL $dir
$sddl  = $acl.sddl 
$acl.SetSecurityDescriptorSddlForm($sddl)
$allow = New-Object System.Security.AccessControl.FileSystemAccessRule($system,"FullControl","ContainerInherit,ObjectInherit","None", "allow")
$acl.SetAccessRule($allow)
$acl |Set-Acl
exit
}   

