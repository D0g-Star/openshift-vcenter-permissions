# openshift-vcenter-permissions
Configure your OpenShift IPI installer's vCenter account with the needed permissions

## Description
This is a PowerCLI script that prompts you for where in vCenter you'll be installing OpenShift, similar to how the openshift-install tool prompts you. It creates the vCenter roles needed by the OpenShift IPI installer, and then it applies them to the installer's vCenter account, at the prompted locations with the vCenter hierarchy.

## Collisions
During role creation, if it finds an existing role with the same name, it assumes it must be there from a previous run of this script, so it uses the role as-is to assign the permissions. If you want to make sure that the Role has all the needed permissions, you can delete it and let this script recreate it.

## Updates
Last updated for OpenShift 4.12 and vCenter 7.0.2+, as detailed in this doc with a comically long URL:
https://docs.openshift.com/container-platform/4.12/installing/installing_vsphere/installing-vsphere-installer-provisioned.html#installation-vsphere-installer-infra-requirements_installing-vsphere-installer-provisioned

To update this script for new versions, simply copy a list of permissions from the doc to the corresponding text file in the [privileges](/privileges) directory. There is one text file for each group of permissions (i.e. role) listed in the doc.
