output "cluster_id" {
  description = "The ID of the AKS cluster"
  value       = azurerm_kubernetes_cluster.this.id
}

output "cluster_name" {
  description = "The name of the AKS cluster"
  value       = azurerm_kubernetes_cluster.this.name
}

output "cluster_fqdn" {
  description = "The FQDN of the AKS cluster"
  value       = azurerm_kubernetes_cluster.this.fqdn
}

output "kube_config" {
  description = "The kubeconfig for the AKS cluster"
  value       = azurerm_kubernetes_cluster.this.kube_config_raw
  sensitive   = true
}

output "host" {
  description = "The Kubernetes cluster server host"
  value       = azurerm_kubernetes_cluster.this.kube_config[0].host
  sensitive   = true
}

output "client_certificate" {
  description = "The client certificate for authentication"
  value       = azurerm_kubernetes_cluster.this.kube_config[0].client_certificate
  sensitive   = true
}

output "oidc_issuer_url" {
  description = "The OIDC issuer URL of the cluster"
  value       = azurerm_kubernetes_cluster.this.oidc_issuer_url
}

output "kubelet_identity" {
  description = "The kubelet managed identity of the cluster"
  value       = azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id
}

output "monitor_workspace_id" {
  description = "The ID of the Azure Monitor workspace used by AKS"
  value       = var.monitor_workspace_id != null ? var.monitor_workspace_id : try(azurerm_monitor_workspace.prometheus[0].id, null)
}