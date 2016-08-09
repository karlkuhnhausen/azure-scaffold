Write-Host "Adding group to contributor role" -ForegroundColor Green

New-AzureRmRoleAssignment -Scope $scope `
                          -RoleDefinitionName "Contributor" `
                          -ObjectId $groupObjectId
