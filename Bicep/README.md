# Bicep

Bicep est un langage spécifique à un domaine (DSL) qui utilise la syntaxe déclarative pour déployer des ressources Azure. 

Ce dossier représente un exemple de mise en place d'un script Bicep permettant de créer des App Services, bases de données Azure SQL Databases et un compte de stockage.

Pour convertir le modèle Bicep en modèle ARM nommé main.json :
`az bicep build -file main.bicep`

Pour plus d'info, consulter :
https://learn.microsoft.com/fr-fr/azure/azure-resource-manager/bicep/overview?tabs=bicep
