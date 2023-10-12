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
