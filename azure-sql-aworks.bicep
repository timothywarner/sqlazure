@description('Name of primary SQL server')
param serverName string

@description('Name of secondary SQL server')
param secondaryServerName string

@description('Location of secondary sql server')
param secondaryLocation string = 'westus'

@description('The name of the SQL Database.')
param sqlDBName string = 'aworks'

@description('The administrator username of the SQL logical server.')
param administratorLogin string = 'tim'

@description('The administrator password of the SQL logical server.')
@secure()
param administratorLoginPassword string

resource serverName_resource 'Microsoft.Sql/servers@2019-06-01-preview' = {
  name: serverName
  location: resourceGroup().location
  properties: {
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
  }
}

resource serverName_sqlDBName 'Microsoft.Sql/servers/databases@2017-10-01-preview' = {
  parent: serverName_resource
  name: '${sqlDBName}'
  location: resourceGroup().location
  sku: {
    name: 'Standard'
    tier: 'Standard'
  }
  properties: {
    sampleName: 'AdventureWorksLT'
  }
}

resource serverName_nestedDeployment1 'Microsoft.Sql/servers/Microsoft.Resources/deployments@2019-10-01' = {
  name: '${serverName}/nestedDeployment1'
  properties: {
    expressionEvaluationOptions: {
      scope: 'outer'
    }
    mode: 'Incremental'
    template: {
      '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
      contentVersion: '1.0.0.0'
      parameters: {}
      variables: {}
      resources: [
        {
          name: secondaryServerName
          type: 'Microsoft.Sql/servers'
          apiVersion: '2014-04-01'
          location: secondaryLocation
          tags: {
            displayName: 'secondarysqlserver'
          }
          properties: {
            administratorLogin: administratorLogin
            administratorLoginPassword: administratorLoginPassword
          }
          resources: [
            {
              type: 'firewallRules'
              apiVersion: '2014-04-01'
              dependsOn: [
                resourceId('Microsoft.Sql/servers', concat(secondaryServerName))
              ]
              location: resourceGroup().location
              name: 'AllowAllWindowsAzureIps'
              properties: {
                startIpAddress: '0.0.0.0'
                endIpAddress: '0.0.0.0'
              }
            }
          ]
        }
      ]
      outputs: {}
    }
  }
  dependsOn: [
    serverName_resource
  ]
}