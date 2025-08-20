# Terraform
Repository containing all of my Terraform learnings

Below is a description of of the Azure resources I have created in the other files in this repository. Primarily the sequential creation of resources in "main.tf".

9 Azure resources are created in the following order using Powershell in Microsoft Visual Studio Code:

1. Resource Group
2. Virtual Network
3. Subnet
4. Network Security Group
5. Network Security Rule
6. Network Security Group Association
7. Public IP address
8. Network Interface Card
9. Virtual Machine

Additionally, there are two other files in this repository, "customdata.tpl" and "windows-ssh-script.tpl";

customdata.tpl is a file referenced in "main.tf", and contains a bash script to install all the depencies necessary to install Docker on the linux virtual machine.

windows-ssh-script.tpl is a template file specifying the variable used for creating a local-exec provisioning account for the virtuak machine (line 122 in "main.tf"). This allows me to execute in the terminal from my local command-line tools.



