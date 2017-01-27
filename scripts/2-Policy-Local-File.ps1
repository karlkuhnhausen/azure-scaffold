<#
    .DESCRIPTION
        Sample script to demonstrate the creation of an Azure Resource Manager policy using local file syntax.
        This policy json file can be found in the policydef folder in this repo.
        The policy only allows resource creation in West US and East US regions.
    
    .NOTES
        AUTHOR: Karl Kuhnhausen
        LASTEDIT: January 26, 2017
#>

Login-AzureRmAccount

# Get the current subscription context.
$ctx = Get-AzureRmContext
$subscriptonId = $ctx.Subscription.SubscriptionId
$subscriptionScope = "/subscriptions/" + $subscriptionId


# Define the policy name and path to the local file.
$policyName = "ES-Approved-Regions-Local-File"
$policyDescription = "This is a sample policy definition with local file syntax in PowerShell."

# Download the json file to your local machine and edit the path to reflect your local repository of policy json files.
$localFile = "C:\Source\Repos\azure-scaffold\policydef\ES-Approved-Regions.json"

# Only allow resources in West US and East US regions.
$policyDefinition = New-AzureRmPolicyDefinition `
                        -Name $policyName `
                        -Description $policyDescription `
                        -Policy $localFile
                       

Write-Output "Defining Policy:" $policyDefinition

# Assign it at a subscription scope.
$policyAssignment = New-AzureRmPolicyAssignment `
                        -Name $policyName"-Policy-Sub-Scope" `
                        -PolicyDefinition $policyDefinition `
                        -Scope $subscriptionScope

Write-Output "Assigning Policy:" $policyAssignment