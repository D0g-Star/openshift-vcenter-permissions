# openshift-vcenter-permissions
In order to install OpenShift with [installer provisioned infrastructure](https://docs.openshift.com/container-platform/4.12/installing/installing-preparing.html#installing-preparing-existing-components) (IPI), we need to provide a vCenter account that OpenShift can use to not only create its initial nodes, but also to [add and remove them](https://docs.openshift.com/container-platform/4.12/installing/installing_bare_metal_ipi/ipi-install-expanding-the-cluster.html) as needed, post-installation.

This PowerCLI script will take a vCenter account that you provide, and add the vCenter permissions that are required for an OpenShift IPI installation.

## Description
This script prompts you for where in vCenter you'll be installing OpenShift, mirroring the prompts you'll receive later, when using the `openshift-install` tool. Note that this script will prompt you for 2 accounts: first for your credentials to connect to the vCenter API, and then for the name of the account that you'll use for the OpenShift IPI installation. It then connects to the vCenter API, creates the needed roles, and assigns them to the intallation account at the prompted locations within the vCenter hierarchy.

After running this script, you can then run the `openshift-install` tool and provide it with credentials of this installation account.

## Collisions
During role creation, if this script finds an existing role with the same name, it assumes it must be there from a previous run of itself, so it uses the role as-is to assign the permissions. If you want to make sure that the existing role has all the needed permissions, you can delete it and let this script recreate it.

## Optional VM Folder and Resource Pool
If you wish to install OpenShift into a specific VM Folder and/or Resource Pool in vCenter, then provide those values when the script prompts you (or press ENTER to skip them). You'll also need to add the corresponding lines to the `platform.vsphere` section of your **install-config.yaml**:
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
