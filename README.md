# Microsoft Azure Enterprise Scaffold
The Azure Enterprise Scaffold is a set of templates and scripts to jumpstart the automation of a governance framework for enterprises using Microsoft Azure. In real life, scaffolding is used to create the basis of the structure. The scaffold guides the general outline, and provides anchor points for more permanent systems to be mounted. An enterprise scaffold is the same: a set of flexible controls and Azure capabilities that provide structure to the environment, and anchors for services built on the public cloud. It provides the builders (IT and business groups) a foundation to create and attach new services. 

## Powershell Sample Scripts
This repo has a set of sample PowerShell scripts, automation runbooks and policy json files to jumpstart your own governance framework with [Azure Resource Manager Policies](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-manager-policy). The repo folders contain the following:
### /policydef
A set of sample json files that define sample policies. [Other examples](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-manager-policy#policy-definition-examples) can be found on azure.microsoft.com. Some of which I have cribbed here.
### /runbooks
An example Azure Automation runbook to demonstrate the creation of Azure Resource Manager policies from policy json files in an Azure Storage Account using the Run-As Account (Service Principal). This demonstrates defining and applying policies across multiple subscriptions.
### /scripts
Sample PowerShell scripts meant to be run interactively that demonstrate the policy definition and policy assignment cmdlets.
## More Reading
* For a full discussion of the Azure Enterprise Scaffold see [Azure Enterprise Scaffold - Prescriptive Subscription Governance](https://azure.microsoft.com/en-us/documentation/articles/resource-manager-subscription-governance/).
