# Terraform

This repository contains all of my Terraform learnings

Below is a description of of the Azure resources I have created in the other files in this repository. 
Primarily the sequential creation of resources in "main.tf".

9 Azure resources are created in the following order using Powershell in Microsoft Visual Studio Code:

Resource Group
Virtual Network
Subnet
Network Security Group
Network Security Rule
Network Security Group Association
Public IP address
Network Interface Card
Virtual Machine

Additionally, there are two other files in this repository, "customdata.tpl" and "windows-ssh-script.tpl";

customdata.tpl is a file referenced in "main.tf", and contains a bash script to install
all the depencies necessary to install Docker on the linux virtual machine.

windows-ssh-script.tpl is a template file specifying the variable used for creating a local-exec provisioning account
for the virtuak machine (line 122 in "main.tf"). This allows me to execute in the terminal from my local command-line tools.
