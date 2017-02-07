# Azure Automation Runbook
The PolicyDefinitionManagementSample1.ps1 Azure automation runbook demonstrates how to read policy definition json files from an Azure storage account and apply it to multiple subscriptions. (Steps 5, 6 and 7 in the graphic below).
## End to End Automation
To make it simple to manage and deploy Azure Resource Manager policies, the policy definition files should be treated as infrastructure as code. An automated build process could be put in place to apply and update the policies across all or targeted subscriptions in your organization. The diagram below represents one approach to do this leveraging GitHub, Visual Studio Team Services and Azure Automation. This would enable one to simply edit, commit and push a set of policy definition files to GitHub, and all of these policies would be created or updated across an entire organization in a single operation.
![Automation Pipeline](https://github.com/karlkuhnhausen/media/blob/master/azure-scaffold/Pipeline-Architecture.png?raw=true)

1. Edit your policy json files with your favorite editor.
2. Commit and Push your changes to GitHub.
3. Webhook integration with Visual Studio Team Services (This could be Jenkins or other build and deployment solutions).
4. Automate or schedule build / deployment to copy policy definition json files from your repo to a designated Azure storage account.
5. Webhook to initiate Azure Automation Runbook on successful copy of files.
6. Runbook reads in policy definition files, checking for new or updated policies.
7. Runbook defines and assigns new or updated policies to target subscriptions.
