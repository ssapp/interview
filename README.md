# Technical Interview Task

## Prerequisites

`az account show`

`az account list --query "[?user.name=='<ms_account_email>'].{Name:name, ID:id, Default:isDefault}" --output Table`

`az ad sp create-for-rbac --role Contributor --scopes /subscriptions/<subscription-id>`

`cp example.tfvars terraform.tfvars`
