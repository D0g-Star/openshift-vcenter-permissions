<#
.NOTES
  Author: Ted Spinks
  Last updated for OpenShift 4.12 and vCenter 7.0.2+, as detailed in this doc with a comically long URL:
  https://docs.openshift.com/container-platform/4.12/installing/installing_vsphere/installing-vsphere-installer-provisioned.html#installation-vsphere-installer-infra-requirements_installing-vsphere-installer-provisioned

  To update this script with new permissions, edit the text files in the `privileges` directory. There is one text file for each group of permissions specified in the doc.
.SYNOPSIS
  Creates the vCenter roles needed for the OpenShift IPI installer. Applies these roles to the installer's vCenter service account.
.DESCRIPTION 
  This script creates the needed vCenter roles and applies them to the OpenShift IPI installer's vCenter service account. It prompts you for where you'll be installing OpenShift, similar to how the openshift-install tool prompts you. It then uses this information to create the needed permissions.

  During role creation, if it finds an existing role with the same name, it assumes it must be there from a previous run of this script, so it uses it as-is to assign the permissions. If you want to make sure that the Role has all the needed permissions, you can delete it and let this script recreate it.
#>

$ErrorActionPreference = "Stop"
$RolePrefix = "OCP"


function Read-TextFileList([string]$filename) {
# Reads each line from a text file into an array. Returns the array.
  $ArrayOfStrings = @()
  Get-Content $filename | Foreach-Object{
    $ArrayOfStrings += $_
  }
  return $ArrayOfStrings
}


function New-RoleAndPermission([string]$RoleName, [string[]]$Privileges, $User, $Entity) {
# Creates the Role with the specified Privileges. Applies the role to the User at the point in the vCenter 
# hierarchy of $Entity.
  $confirmation = Read-Host "Proceed with creating role $RoleName, Y or N [N]?"
  if ($confirmation.ToLower() -eq 'y') {
    $Role = New-VIRole -Name $RoleName -Privilege (Get-VIPrivilege -Id $Privileges) -ea Continue
    if (-Not $Role) {
      $Role = Get-VIRole -Name $RoleName
    }
    if ($Role) {
      New-VIPermission -Entity $Entity -Principal $User -Role $Role -Propagate $true
    }
  }
  else {
    Write-Host "Skipping $RoleName."
  }
}


# Read OpenShift IPI's required vCenter privileges from text files
$vCenterPrivileges = Read-TextFileList "privileges/vCenter.txt"
$ClusterPrivileges = Read-TextFileList "privileges/Cluster.txt"
$ResourcePoolPrivileges = Read-TextFileList "privileges/ResourcePool.txt"
$DatastorePrivileges = Read-TextFileList "privileges/Datastore.txt"
$PortgroupPrivileges = Read-TextFileList "privileges/Portgroup.txt"
$VMFolderPrivileges = Read-TextFileList "privileges/VMFolder.txt"

# Prompt user for where they will be installing OpenShift
$Server = Read-Host "vCenter FQDN"
$vCenter = Connect-VIServer -Force -Server $Server
$Username = Read-Host "OCP service account username (either DOMAIN\user or user@domain.com)"
if ($Username.Contains("@")) {
  $UserPortion = $Username.Split("@")[0]
  $DomainPortion = $Username.Split("@")[1]
  $UserObject = Get-VIAccount $UserPortion -Domain $DomainPortion
}
else {
  $DomainPortion = $Username.Split('\')[0]
  $UserPortion = $Username.Split('\')[1]
  $UserObject = Get-VIAccount $UserPortion -Domain $DomainPortion
}
$DatacenterName = Read-Host "Datacenter"
$Datacenter = Get-Datacenter $DatacenterName
$ClusterName = Read-Host "Cluster"
$Cluster = Get-Cluster $ClusterName -Location $Datacenter 
$DatastoreName = Read-Host "Datastore"
$Datastore = Get-Datastore $DatastoreName -Location $Datacenter
$VDSwitchName = Read-Host "VDSwitch"
$VDSwitch = Get-VDSwitch $VDSwitchName -Location $Datacenter
$PortgroupName = Read-Host "Portgroup"
$Portgroup = Get-VDPortgroup $PortgroupName -VDSwitch $VDSwitch
$VMFolderName = Read-Host "VMFolder - name only (Optional)"
if ($VMFolderName) {
  $VMFolder = Get-Folder $VMFolderName -Location $Datacenter -Type "VM"
  if ($VMFolder.Count -gt 1) {
    $VMFolder | Format-List
    throw "More than 1 folder matched that name. Use a unique folder name or apply this role manually."
  }
}
$ResourcePoolName = Read-Host "Resource Pool (Optional)"
if ($ResourcePoolName) {
  $ResourcePool = Get-ResourcePool $ResourcePoolName -Location $Cluster
}

# Create the roles and permissions

# I tried passing $vCenter as the $Entity and it threw an error. To figure out the equivalent entity, I
# manually created the vCenter-level permission via the UI, and then used Get-VIPermission to see what
# entity it targeted: the root Datacenters folder.
$RootFolder = Get-Folder "Datacenters" -Type Datacenter | Where-Object { $_.ParentId -eq $null }
New-RoleAndPermission "$RolePrefix-vCenter" $vCenterPrivileges $UserObject $RootFolder
New-RoleAndPermission "$RolePrefix-Cluster" $ClusterPrivileges $UserObject $Cluster
New-RoleAndPermission "$RolePrefix-Datastore" $DatastorePrivileges $UserObject $Datastore
New-RoleAndPermission "$RolePrefix-Portgroup" $PortgroupPrivileges $UserObject $Portgroup
if ($VMFolderName){
  New-RoleAndPermission "$RolePrefix-VMFolder" $VMFolderPrivileges $UserObject $VMFolder
}
if ($ResourcePoolName) {
  New-RoleAndPermission "$RolePrefix-ResourcePool" $ResourcePoolPrivileges $UserObject $ResourcePool
}

Disconnect-VIServer -server $Server -Force -Confirm:$False
