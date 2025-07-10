locals {
  enable_high_log_scale_mode = false # contains("ContainerInsightsExtension", "Microsoft-ContainerLogV2-HighScale")
  ingestion_dce_name_full    = "MSCI-ingest-${var.location}-${azurerm_kubernetes_cluster.this.name}"
  ingestion_dce_name_trimmed = substr(local.ingestion_dce_name_full, 0, 43)
  ingestion_dce_name         = endswith(local.ingestion_dce_name_trimmed, "-") ? substr(local.ingestion_dce_name_trimmed, 0, 42) : local.ingestion_dce_name_trimmed
  streams = [
    "Microsoft-ContainerLog",
    "Microsoft-ContainerLogV2",
    "Microsoft-KubeEvents",
    "Microsoft-KubePodInventory"
  ]
}

resource "azurerm_monitor_data_collection_endpoint" "ingestion_dce" {
  count               = local.enable_high_log_scale_mode ? 1 : 0
  name                = local.ingestion_dce_name
  resource_group_name = var.resource_group_name
  location            = var.location
  kind                = "Linux"
}


resource "azurerm_monitor_data_collection_rule" "log_dcr" {
  name                = "MSCI-${var.location}-${azurerm_kubernetes_cluster.this.name}"
  resource_group_name = var.resource_group_name
  location            = var.location
  kind                = "Linux"

  destinations {
    log_analytics {
      workspace_resource_id = var.log_analytics_workspace_id
      name                  = "ciworkspace"
    }
  }

  data_flow {
    streams = local.streams
    destinations = ["ciworkspace"]
  }

  data_sources {
    extension {
      streams = local.streams
      extension_name = "ContainerInsights"
      extension_json = jsonencode({
        "dataCollectionSettings" : {
          "interval" : "1m",
          "namespaceFilteringMode" : "Off",
          "enableContainerLogV2" : true
        }
      })
      name = "ContainerInsightsExtension"
    }
  }

  data_collection_endpoint_id = local.enable_high_log_scale_mode ? azurerm_monitor_data_collection_endpoint.ingestion_dce[0].id : null


  description = "DCR for Azure Monitor Container Insights"
}

resource "azurerm_monitor_data_collection_rule_association" "log_dcra" {
  name                    = "ContainerInsightsExtension"
  target_resource_id      = azurerm_kubernetes_cluster.this.id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.log_dcr.id
  description             = "Association of container insights data collection rule. Deleting this association will break the data collection for this AKS Cluster."
}