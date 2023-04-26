# openshift-vcenter-permissions
Configure your OpenShift IPI installer's vCenter account with the needed permissions

## Description
This is a PowerCLI script that creates the vCenter roles needed for the OpenShift IPI installer. It also applies these roles to the installer's vCenter account.

The script prompts you for where you'll be installing OpenShift, similar to how the openshift-install tool prompts you.

## Collisions
During role creation, if it finds an existing role with the same name, it assumes it must be there from a previous run of this script, so it uses the role as-is to assign the permissions. If you want to make sure that the Role has all the needed permissions, you can delete it and let this script recreate it.

## Updates
Last updated for OpenShift 4.12 and vCenter 7.0.2+, as detailed in this doc with a comically long URL:
https://docs.openshift.com/container-platform/4.12/installing/installing_vsphere/installing-vsphere-installer-provisioned.html#installation-vsphere-installer-infra-requirements_installing-vsphere-installer-provisioned

To update this script with new permissions, edit the text files in the [privileges](/privileges) directory. There is one text file for each group of permissions specified in the doc.
