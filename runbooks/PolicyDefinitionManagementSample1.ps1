<#
    .DESCRIPTION
        An example runbook which gets lists all policy definitions across subscriptions using the Run As Account (Service Principal)

    .NOTES
        AUTHOR: Karl Kuhnhausen
        LASTEDIT: July 22, 2016
#>

$connectionName = "AzureRunAsConnection"
try
{
    # Get the connection "AzureRunAsConnection "
    $servicePrincipalConnection=Get-AutomationConnection -Name $connectionName         

    "Logging in to Azure..."
    Add-AzureRmAccount `
        -ServicePrincipal `
        -TenantId $servicePrincipalConnection.TenantId `
        -ApplicationId $servicePrincipalConnection.ApplicationId `
        -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint 
}
catch {
    if (!$servicePrincipalConnection)
    {
        $ErrorMessage = "Connection $connectionName not found."
        throw $ErrorMessage
    } else{
        Write-Error -Message $_.Exception
        throw $_.Exception
    }
}

# Variables for testing.
$subscriptionId = "0a28e458-9f96-41cd-9312-b14dd595ef56"
$policyDefStorageAccountName = "tr23datauw2001"
$policyRG = "tr23-dev-rg"
$pathToPlaceBlob = "C:\"
$containerName = "runbooks"
$blobName = "Approved-Storage-SKUs.json"

# Get the storage account subscription for downloading the policy definition files.
Select-AzureRmSubscription -SubscriptionId $subscriptionId

# Set a subscription scope for policy assignments.
$subscriptionScope = "/subscriptions/" + $subscriptionId

$storageAccount = Get-AzureRmStorageAccount -StorageAccountName $policyDefStorageAccountName -ResourceGroupName $policyRG

# Get the storage account primary key. Depending on the module version it is .Value[0] or Key1. Automation needs .Key1
$storagePrimaryKey = (Get-AzureRmStorageAccountKey -StorageAccountName $policyDefStorageAccountName -ResourceGroupName $policyRG).Key1

$ctx = New-AzureStorageContext -StorageAccountName $policyDefStorageAccountName -StorageAccountKey $storagePrimaryKey

# Get the all of the policy json files that are in the blob container and iterate through them to create new policy definitions.
$blobs = Get-AzureStorageBlob -Context $ctx -Container $containerName

if ($blobs -ne $null) {
    foreach ($blob in $blobs) {

        # Remove the .json file extension for the policy name
        $policyName = $blob.Name.Substring(0,$blob.Name.LastIndexOf('.'))

        # Cast the UTC last modified date once.
        $jsonLastModified = $blob.LastModified.UtcDateTime.ToString()

        # Create the policy description with the last modified date of the json blob.
        $policyDescription = $blob.Name + " UTC last modified: " + $jsonLastModified
        
        # Create the reference to the policy json file in the local directory to be used in the Get-AzurePolicyDefinition cmdlet.
        $policyjsonFile = $pathToPlaceBlob + $blob.Name

        # Download the policy json file to a local directory from the storage container for processing.
        $blob | Get-AzureStorageBlobContent -Destination $pathToPlaceBlob -Force

        Try {
            # Check to see if the policy exists.
            $policyDefinition = Get-AzureRmPolicyDefinition -Name $policyName -ErrorAction SilentlyContinue
                            
            # If the json file was updated (by looking at last modified date in the description) update the policy definition.
            if ($policyDefinition.Properties.description -ne $policyDescription) {
                
                Set-AzureRmPolicyDefinition -Id $policyDefinition.ResourceId -Description $policyDescription -Policy $policyjsonFile
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
            $policyDefinition = New-AzureRmPolicyDefinition -Name $policyName -Description $policyDescription -Policy $policyjsonFile
            $msg = "Creating New Policy Definition: " + $policyName + " with json file: " + $policyDescription
            Write-Output $msg
        }

        # Assign the policy definition to the current subscription
        New-AzureRmPolicyAssignment -Name $policyName"-Policy-Sub-Scope" -PolicyDefinition $policyDefinition -Scope $subscriptionScope
        $msg = "Assigning policy definition: " + $policyName + " to subscription scope: " + $subscriptionScope
        Write-Output $msg 
    }
}
else { 
    Write-Output "No policy definitions to create."
}

Write-Output "Policy definitions and assignments completed."