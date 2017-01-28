<#
    .DESCRIPTION
        Cleanup script to delete all Azure Resource Manager policy assignments and definitions across all subscriptions
        available to the logged in account. One has to delete all assignments related to a definition before the definition can be deleted.
        This script is a delete action with no "are you sure?" dialog, so use carefully.
    
    .NOTES
        AUTHOR: Karl Kuhnhausen
        LASTEDIT: January 26, 2017
#>

Login-AzureRmAccount

# Get all subscriptions for the current logged in account.
$subscriptions = Get-AzureRmSubscription

foreach ($subscription in $subscriptions) {

    Set-AzureRmContext -SubscriptionId $subscription.SubscriptionId
    $subscriptionScope = "/subscriptions/" + $subscription.SubscriptionId

     # Get all of the policy assignments with subscription scope. 
    $policyAssignments = Get-AzureRmPolicyAssignment `
                            -Scope $subscriptionScope

    # Iterate through each and delete.
    foreach ($policyAssignment in $policyAssignments) {
        Write-Output "Deleting Policy Assignment:" $policyAssignment.Name
        Remove-AzureRmPolicyAssignment `
            -Name $policyAssignment.Name `
            -Scope $subscriptionScope `
            -ErrorAction SilentlyContinue
    }

    # Get and delete all of the policy definitions. Skip over the built in policy definitions.
    $policyDefinitions = Get-AzureRmPolicyDefinition
    
    foreach ($policyDefinition in $policyDefinitions) {
        if ($policyDefinition.Properties.policyType -ne 'BuiltIn') {
            Write-Output "Deleting Policy Definition:" $policyDefinition.Name
            Remove-AzureRmPolicyDefinition `
                -Name $policyDefinition.Name `
                -Force `
                -ErrorAction SilentlyContinue
        }

    }
}
