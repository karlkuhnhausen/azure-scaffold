<#
.DESCRIPTION
    Sample script to demonstrate the creation of an Azure Resource Manager policies from policies in an Azure Storage Account.
    This demonstrates defining and applying policies across multiple subscriptions. The logged in account must have access to 
    multiple subscriptions with the rights to execute Microsoft.Authorization/* write privelages.
    Classic storage accounts are NOT supported in this script.
    By design, this script adds and updates policies. It does not delete policies.
    
.NOTES
    AUTHOR: Karl Kuhnhausen
    LASTEDIT: January 26, 2017
#>

Login-AzureRmAccount
    
# Edit here to add your subscription id, storage account, container name and resource group where you have stored the policy json files.
# Sample json files can be found in the /policydef folder in this repo.
$storageAccountSubscriptionId = "<Your SubscriptionID That Contains the Storage Account>"
$policyDefStorageAccountName = "<Your Storage Account Name>"
$containerName = "<Container in Storage Account>"
$policyRG = "<The Resource Group Your Storage Account is In>"

# Variables for testing.
$storageAccountSubscriptionId = "0a28e458-9f96-41cd-9312-b14dd595ef56"
$policyDefStorageAccountName = "tr23datauw2001"
$policyRG = "tr23-dev-rg"
$pathToPlaceBlob = "C:\"
$containerName = "policies"

# Get the storage account subscription for downloading the policy definition files.
Select-AzureRmSubscription `
    -SubscriptionId $storageAccountSubscriptionId

$storageAccount = Get-AzureRmStorageAccount `
                    -StorageAccountName $policyDefStorageAccountName `
                    -ResourceGroupName $policyRG

# Get the storage account primary key. Depending on the module version it is .Value[0] or Key1. Azure Automation needs .Key1
# This is a breaking change in newer versions of PowerShell, so if the script is failing, this is most likely the cause.
# Just comment / uncomment and select the syntax that will work.
$storagePrimaryKey = (Get-AzureRmStorageAccountKey `
                            -StorageAccountName $policyDefStorageAccountName `
                            -ResourceGroupName $policyRG).Value[0]
#$storagePrimaryKey = (Get-AzureRmStorageAccountKey -StorageAccountName $policyDefStorageAccountName -ResourceGroupName $policyRG).Key1

$ctx = New-AzureStorageContext `
        -StorageAccountName $policyDefStorageAccountName `
        -StorageAccountKey $storagePrimaryKey

# Get the all of the policy json files that are in the blob container and iterate through them to create new policy definitions.
$blobs = Get-AzureStorageBlob `
            -Context $ctx `
            -Container $containerName

# Get all subscriptions to apply policy definitions and assignments.
$subscriptions = Get-AzureRmSubscription
    
if ($blobs -ne $null) {
    foreach ($blob in $blobs) {
            
        # Make sure the current subscription context is for the master storage account for the policies before applying to other subscriptions.
        Set-AzureRmContext -SubscriptionId $storageAccountSubscriptionId
            
        # Remove the .json file extension for the policy name
        $policyName = $blob.Name.Substring(0,$blob.Name.LastIndexOf('.'))

        # Cast the UTC last modified date once.
        $jsonLastModified = $blob.LastModified.UtcDateTime.ToString()

        # Create the policy description with the last modified date of the json blob.
        $policyDescription = $blob.Name + " UTC last modified: " + $jsonLastModified
            
        # Create the reference to the policy json file in the local directory to be used in the Get-AzurePolicyDefinition cmdlet.
        $policyjsonFile = $pathToPlaceBlob + $blob.Name

        # Download the policy json file to a local directory from the storage container for processing.
        $blob | Get-AzureStorageBlobContent `
                    -Destination $pathToPlaceBlob -Force

        foreach($subscription in $subscriptions) {
            Set-AzureRmContext -SubscriptionId $subscription.SubscriptionID
            Try {
                # Check to see if the policy exists.
                $policyDefinition = Get-AzureRmPolicyDefinition `
                                        -Name $policyName `
                                        -ErrorAction SilentlyContinue
                                
                # If the json file was updated (by looking at last modified date in the description) update the policy definition.
                if ($policyDefinition.Properties.description -ne $policyDescription) {
                    
                    Set-AzureRmPolicyDefinition `
                        -Id $policyDefinition.ResourceId `
                        -Description $policyDescription `
                        -Policy $policyjsonFile

                    $msg = "Policy definition: " + $policyName + " exists. Updating with revised policy: " + $policyDescription
                    Write-Output $msg
                }
                else {
                    $msg = "Policy definition: " + $policyName + " exists and is current."
                    Write-Output $msg
                }
            }
            Catch [System.Exception] {
                
                # Policy definition does not exist, create a new one.
                $policyDefinition = New-AzureRmPolicyDefinition `
                                    -Name $policyName `
                                    -Description $policyDescription `
                                    -Policy $policyjsonFile

                $msg = "Creating New Policy Definition: " + $policyName + " with json file: " + $policyDescription
                Write-Output $msg
            }

            # Set the subscription scope for policy assignments to the current subscription context.
            $subscriptionScope = "/subscriptions/" + $subscription.SubscriptionId

            # Assign the policy definition to the current subscription
            New-AzureRmPolicyAssignment `
                -Name $policyName"-Policy-Sub-Scope" `
                -PolicyDefinition $policyDefinition `
                -Scope $subscriptionScope

            $msg = "Assigning policy definition: " + $policyName + " to subscription scope: " + $subscriptionScope
            Write-Output $msg
        }
    }
}
else { 
    Write-Output "No policy definitions to create."
}

$msg = "Policy definitions and assignments completed."
Write-Output $msg