Login-AzureRmAccount

# Get the current subscription context.
$ctx = Get-AzureRmContext
$subscriptonId = $ctx.Subscription.SubscriptionId
$subscriptionScope = "/subscriptions/" + $subscriptionId

$policyName = "ES-Approved-Storage-SKUs-Inline"
$policyDescription = "This is a sample policy definition with inline syntax in PowerShell."

# Only allow LRS and GRS storage accounts.
$policyDefinition = New-AzureRmPolicyDefinition `
                        -Name $policyName `
                        -Description $policyDescription `
                        -Policy `
                        '{
                              "if": {
                                "allOf": [
                                  {
                                    "field": "type",
                                    "equals": "Microsoft.Storage/storageAccounts"
                                  },
                                  {
                                    "not": {
                                      "allOf": [
                                        {
                                          "field": "Microsoft.Storage/storageAccounts/sku.name",
                                          "in": [ "Standard_LRS", "Standard_GRS" ]
                                        }
                                      ]
                                    }
                                  }
                                ]
                              },
                              "then": {
                                "effect": "deny"
                              }

                        }'

Write-Output "Defining Policy:" $policyDefinition

# Assign it at a subscription scope.
$policyAssignment = New-AzureRmPolicyAssignment `
                        -Name $policyName"-Policy-Sub-Scope" `
                        -PolicyDefinition $policyDefinition `
                        -Scope $subscriptionScope

Write-Output "Assigning Policy:" $policyAssignment