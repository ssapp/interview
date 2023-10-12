# Technical Interview Task

## Prerequisites

Subscription ID:

 `az account list --query "[?user.name=='<ms_account_email>'].{Name:name, ID:id, Default:isDefault}" --output Table`

Create SP:

 `az ad sp create-for-rbac --role Contributor --scopes /subscriptions/<subscription-id>`

```shell
{
  "appId": "00000000-0000-0000-0000-000000000000",
  "displayName": "azure-cli-xxxx-xx-xx-xx-xx-xx",
  "name": "http://azure-cli-xxxx-xx-xx-xx-xx-xx",
  "password": "0000-0000-0000-0000-000000000000",
  "tenant": "00000000-0000-0000-0000-000000000000"
}
```

Copy example.tfvars and enter the details

 `cp example.tfvars terraform.tfvars`

```shell
# Azure Configuration
client_id       = "" # <appId>
client_secret   = "" # <password>
tenant_id       = "" # <tenant>
subscription_id = "" # <subscription-id>
```

## Remote State

In order to setup a remote state storage to track the current state of the infrastructure that is being deployed and managed, i've used the `azurerm` backend [[docs]](https://developer.hashicorp.com/terraform/language/settings/backends/azurerm) like this:

```shell
# Set the variables
$ LOCATION="<location>";RG_NAME="<name>";STORAGE_ACCOUNT="<name>";CONTAINER_NAME="<name>";

# Create new resource group
$ az group create --location "$LOCATION" --name "$RG_NAME"

# Create new storage account
$ az storage account create --name "$STORAGE_ACCOUNT" --resource-group "$RG_NAME" --location "$LOCATION" --sku Standard_LRS

$ az storage container create --name "$CONTAINER_NAME" --account-name "$STORAGE_ACCOUNT"
```

Now `cp remote_state.tf.example remote_state.tf` and fill the details:

```hcl
terraform {
    backend "azurerm" {
    resource_group_name  = "" # The value of $RG_NAME
    storage_account_name = "" # The value of $STORAGE_ACCOUNT
    container_name       = "" # The value of $CONTAINER_NAME
    key                  = "interview.terraform.tfstate" #  You can left this unchanged
  }
}
```

## Terraform

Initialize Terraform - `terraform init`

Perform dry-run to check what will be deployed - `terraform plan`

Deploy - `terraform apply`

Check the resources once the deployment complete:

```shell
az aks list -o table
Name         Location    ResourceGroup    KubernetesVersion    CurrentKubernetesVersion    ProvisioningState    Fqdn
-----------  ----------  ---------------  -------------------  --------------------------  -------------------  ---------------------------------------------
aks-cluster  westus2     aks-rg           1.28.0               1.28.0                      Succeeded            swag-interview-xxxxx.hcp.xxxx.azmk8s.io
```

To get your kubeconfig - `terraform output kubeconfig > kubeconfig`

Check `software-ag` namespace:

```shell
$ kubectl get all -n software-ag

NAME                           READY   STATUS    RESTARTS   AGE
pod/web-app-6dd77586db-hp4v2   1/1     Running   0          12h30m

NAME              TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
service/web-app   ClusterIP   10.0.255.183   <none>        80/TCP    12h30m

NAME                      READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/web-app   1/1     1            1           12h30m

NAME                                 DESIRED   CURRENT   READY   AGE
replicaset.apps/web-app-6dd77586db   1         1         1       12h30m

$ kubectl get ing -n software-ag

NAME      CLASS   HOSTS   ADDRESS       PORTS   AGE
web-app   nginx   *       20.98.96.68   80      8h
```

You can see the fqdn for the ingress IP address with `terraform output ingress_fqdn`

## Variables

| Variable | Description |
|----------|-------------|
| `dns_prefix` | DNS prefix to be used for the Kubernetes cluster.|
| `environment` | Environment in which the Kubernetes cluster is being deployed.|
| `rg_name` | Name of the resource group in which the Kubernetes cluster is being deployed.|
| `location` | Azure region in which the Kubernetes cluster is being deployed.|
| `kubernetes_cluster_name` | Name of the Kubernetes cluster.|
| `kubernetes_version` | Version of Kubernetes to be used for the Kubernetes cluster.|
| `vm_size` | Size of the virtual machines to be used for the Kubernetes cluster nodes.|
| `default_node_pool_name` | Name of the default node pool for the Kubernetes cluster.|
| `vnet_name` | Name of the virtual network to be used for the Kubernetes cluster.|
| `vnet_address_space` | Address space of the virtual network to be used for the Kubernetes cluster.|
| `subnet_name` | Name of the subnet to be used for the Kubernetes cluster.|
| `subnet_address_prefixes` | Address prefix of the subnet to be used for the Kubernetes cluster.|
| `node_count` | An integer value that represents the number of nodes to be used for the Kubernetes cluster.|
| `client_id` | Client ID of the service principal to be used for the Kubernetes cluster.|
| `client_secret` | Client secret of the service principal to be used for the Kubernetes cluster.|
| `tenant_id` | Tenant ID of the service principal to be used for the Kubernetes cluster.|
| `subscription_id` | Subscription ID of the Azure subscription to be used for the Kubernetes cluster.|
