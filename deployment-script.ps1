$subscriptionID = ''
$tenantID = ''
$deploymentName = ''
$resourceGroupName = ''
$templatePath = ''
$context = Get-AzContext

if (($context.Subscription -ne $subscriptionID) -and ($context.Tenant -ne $tenantID)) {
  Clear-Host
  Write-Output 'You need to log in'
}
  Clear-Host
  Write-Output 'You good.'




New-AzResourceGroupDeployment -Name $deploymentName `
  -ResourceGroupName $resourceGroupName `
  -TemplateFile $templatePath
  -Mode Incremental `
  -Verbose