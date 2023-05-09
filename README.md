# openshift-vcenter-permissions
Configure your OpenShift IPI installer's vCenter account with the needed permissions.

## Description
This is a PowerCLI script that prompts you for where in vCenter you'll be installing OpenShift, similar to how the `openshift-install` tool prompts you. It then creates the vCenter roles needed for installer-provisioned infrastructure (IPI). Finally, it applies these roles to the installer's vCenter account, at the prompted locations within the vCenter hierarchy.

## Collisions
During role creation, if it finds an existing role with the same name, it assumes it must be there from a previous run of this script, so it uses the role as-is to assign the permissions. If you want to make sure that the role has all the needed permissions, you can delete it and let this script recreate it.

## Optional VM Folder and Resource Pool
If you wish to install OpenShift into a specific VM Folder and/or Resource Pool in vCenter, then provide those values when this script prompts you (or press ENTER to skip them). You'll also need to add the corresponding lines to the `platform.vsphere` section of your install-config.yaml:
```
...
platform:
  vsphere:
  ...
    folder: /<datacenter_name>/vm/<folder_name>
    resourcePool: /<datacenter_name>/host/<cluster_name>/Resources/<resource_pool_name>
...
```
Note that the `/vm/`, `/host/` and `/Resources/` sections of the paths are required and should not be changed.

## Updates
Last updated for OpenShift 4.12 and vCenter 7.0.2+, as detailed in this doc with a comically long URL:
https://docs.openshift.com/container-platform/4.12/installing/installing_vsphere/installing-vsphere-installer-provisioned.html#installation-vsphere-installer-infra-requirements_installing-vsphere-installer-provisioned

To update this script for new versions, simply copy the new list of privileges from the doc and paste it into the corresponding text file in the [privileges](/privileges) directory. There is one text file for each group of privileges listed in the doc.
