Login-AzureRmAccount

# Get the current subscription context.
$ctx = Get-AzureRmContext
$subscriptonId = $ctx.Subscription.SubscriptionId
$subscriptionScope = "/subscriptions/" + $subscriptionId


# Define the policy name and path to the local file.
$policyName = "ES-Approved-Regions-Local-File"
$policyDescription = "This is a sample policy definition with local file syntax in PowerShell."

# Edit to reflect your local repository of policy json files.
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