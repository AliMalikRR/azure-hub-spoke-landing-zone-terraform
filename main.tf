data "azurerm_client_config" "current" {}
data "azurerm_subscription" "current" {}
data "azurerm_policy_definition" "allowed_locations" {
  name = "e56962a6-4747-49cd-b67b-bf8b01975c4c"
}

// Resource group creation
resource "azurerm_resource_group" "compute" {
  name     = "RG-Compute"
  location = var.region
  tags     = local.common_tags
}

resource "azurerm_resource_group" "networking" {
  name     = "RG-Networking"
  location = var.region
  tags     = local.common_tags
}

resource "azurerm_resource_group" "storage" {
  name     = "RG-Storage"
  location = var.region
  tags     = local.common_tags
}

resource "azurerm_resource_group" "backup" {
  name     = "RG-Backup"
  location = var.region
  tags     = local.common_tags
}

resource "azurerm_resource_group" "monitor" {
  name     = "RG-Monitor"
  location = var.region
  tags     = local.common_tags
}

// Allowed locations policy
resource "azurerm_subscription_policy_assignment" "allowed_locations" {
  name                 = "Allowed-US-Regions"
  subscription_id      = data.azurerm_subscription.current.id
  policy_definition_id = data.azurerm_policy_definition.allowed_locations.id
  display_name         = "Allowed US Regions"
  description          = "Restrict deployments to approved US regions only."

  parameters = jsonencode({
    listOfAllowedLocations = {
      value = [
        "eastus",
        "eastus2",
        "westus",
        "westus2",
        "centralus"
      ]
    }
  })
}

// Hub VNet
resource "azurerm_virtual_network" "hub_vnet" {
  name                = "Hub-VNet"
  resource_group_name = azurerm_resource_group.networking.name
  location            = var.region
  address_space       = var.hub_address_space
  tags                = local.common_tags
}

// Bastion Server Subnet
resource "azurerm_subnet" "bastion_subnet" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.networking.name
  virtual_network_name = azurerm_virtual_network.hub_vnet.name
  address_prefixes     = var.bastion_subnet
}

// Private Endpoint Subnet
resource "azurerm_subnet" "private_endpoint_subnet" {
  name                 = "Private-Endpoint-Subnet"
  resource_group_name  = azurerm_resource_group.networking.name
  virtual_network_name = azurerm_virtual_network.hub_vnet.name
  address_prefixes     = var.private_endpoint_subnet
}

// App VNet
resource "azurerm_virtual_network" "app_vnet" {
  name                = "App-VNet"
  resource_group_name = azurerm_resource_group.networking.name
  location            = var.region
  address_space       = var.app_address_space
  tags                = local.common_tags
}

// Application Subnet
resource "azurerm_subnet" "application_subnet" {
  name                 = "Application-Subnet"
  resource_group_name  = azurerm_resource_group.networking.name
  virtual_network_name = azurerm_virtual_network.app_vnet.name
  address_prefixes     = var.app_subnet
}

// Management VNet
resource "azurerm_virtual_network" "management_vnet" {
  name                = "Management-VNet"
  resource_group_name = azurerm_resource_group.networking.name
  location            = var.region
  address_space       = var.management_address_space
  tags                = local.common_tags
}

// Management Subnet
resource "azurerm_subnet" "management_subnet" {
  name                 = "Management-Subnet"
  resource_group_name  = azurerm_resource_group.networking.name
  virtual_network_name = azurerm_virtual_network.management_vnet.name
  address_prefixes     = var.management_subnet
}

// VNet peering - Hub to App
resource "azurerm_virtual_network_peering" "hub_to_app" {
  name                      = "hub-to-app"
  resource_group_name       = azurerm_resource_group.networking.name
  virtual_network_name      = azurerm_virtual_network.hub_vnet.name
  remote_virtual_network_id = azurerm_virtual_network.app_vnet.id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
}

// VNet peering App to Hub
resource "azurerm_virtual_network_peering" "app_to_hub" {
  name                      = "app-to-hub"
  resource_group_name       = azurerm_resource_group.networking.name
  virtual_network_name      = azurerm_virtual_network.app_vnet.name
  remote_virtual_network_id = azurerm_virtual_network.hub_vnet.id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
}

// VNet peering - Hub to Management
resource "azurerm_virtual_network_peering" "hub_to_management" {
  name                      = "hub-to-management"
  resource_group_name       = azurerm_resource_group.networking.name
  virtual_network_name      = azurerm_virtual_network.hub_vnet.name
  remote_virtual_network_id = azurerm_virtual_network.management_vnet.id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
}

// VNet peering - Management to Hub
resource "azurerm_virtual_network_peering" "management_to_hub" {
  name                      = "management-to-hub"
  resource_group_name       = azurerm_resource_group.networking.name
  virtual_network_name      = azurerm_virtual_network.management_vnet.name
  remote_virtual_network_id = azurerm_virtual_network.hub_vnet.id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
}

// Bastion server public IP
resource "azurerm_public_ip" "bastion_public_ip" {
  name                = "bastion-public-ip"
  location            = var.region
  resource_group_name = azurerm_resource_group.networking.name

  allocation_method = "Static"
  sku               = "Standard"
}

// Bastion server
resource "azurerm_bastion_host" "bastion_server" {
  name                = "hub-bastion"
  location            = var.region
  resource_group_name = azurerm_resource_group.networking.name

  sku = "Basic"

  ip_configuration {
    name                 = "bastion-public-ip"
    subnet_id            = azurerm_subnet.bastion_subnet.id
    public_ip_address_id = azurerm_public_ip.bastion_public_ip.id
  }

  tags = local.common_tags
}

// Application VM NIC
resource "azurerm_network_interface" "application_vm_nic" {
  name                = "nic-application-vm"
  resource_group_name = azurerm_resource_group.networking.name
  location            = var.region

  ip_configuration {
    name                          = "app-internal"
    subnet_id                     = azurerm_subnet.application_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

// Management VM NIC
resource "azurerm_network_interface" "management_vm_nic" {
  name                = "nic-management-vm"
  resource_group_name = azurerm_resource_group.networking.name
  location            = var.region

  ip_configuration {
    name                          = "mgmt-internal"
    subnet_id                     = azurerm_subnet.management_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

// Application VM - Windows server
resource "azurerm_windows_virtual_machine" "app_virtual_machine" {
  name                = "application-vm"
  resource_group_name = azurerm_resource_group.compute.name
  location            = var.region
  size                = "Standard_F1als_v7"

  admin_username = var.appsrv_winadmin_username
  admin_password = var.appsrv_winadmin_password

  network_interface_ids = [
    azurerm_network_interface.application_vm_nic.id
  ]

  identity {
    type = "SystemAssigned"
  }

  provision_vm_agent        = true
  automatic_updates_enabled = true
  patch_mode                = "AutomaticByPlatform"

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2025-datacenter-azure-edition"
    version   = "latest"
  }
  tags = local.common_tags
}

// Application VM Data disk
resource "azurerm_managed_disk" "appvm_data_disk" {
  name                = "appvm-datadisk"
  resource_group_name = azurerm_resource_group.storage.name
  location            = var.region

  storage_account_type = "Standard_LRS"
  disk_size_gb         = 32
  create_option        = "Empty"
}

// Application VM data disk attachment
resource "azurerm_virtual_machine_data_disk_attachment" "appvm_data_disk_attachment" {
  managed_disk_id    = azurerm_managed_disk.appvm_data_disk.id
  virtual_machine_id = azurerm_windows_virtual_machine.app_virtual_machine.id

  lun     = 0
  caching = "ReadWrite"
}

// SSH key for Management sever
resource "tls_private_key" "management_vm_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

// Management VM
resource "azurerm_linux_virtual_machine" "management_vm" {
  name                = "management-vm"
  resource_group_name = azurerm_resource_group.compute.name
  location            = var.region

  size = "Standard_F1als_v7"

  admin_username = "azureadmin"

  network_interface_ids = [
    azurerm_network_interface.management_vm_nic.id
  ]

  disable_password_authentication = true

  admin_ssh_key {
    username   = "azureadmin"
    public_key = tls_private_key.management_vm_ssh_key.public_key_openssh
  }

  identity {
    type = "SystemAssigned"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }
}

// Key Vault
resource "azurerm_key_vault" "main_kv" {
  name                = "hubandspoke-kv"
  resource_group_name = azurerm_resource_group.compute.name
  location            = var.region

  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  rbac_authorization_enabled = true
  soft_delete_retention_days = 30
  purge_protection_enabled   = true
  tags                       = local.common_tags
}

// Key vault permissions - RBAC
resource "azurerm_role_assignment" "keyvault_admin" {
  scope                = azurerm_key_vault.main_kv.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id // get the object id of the account
}

// Adding private key to kv
resource "azurerm_key_vault_secret" "management_vm_private_key" {
  name         = "management-vm-private-key"
  value        = tls_private_key.management_vm_ssh_key.private_key_pem
  key_vault_id = azurerm_key_vault.main_kv.id

  depends_on = [
    azurerm_role_assignment.keyvault_admin
  ]
}

// Adding windows local admin to kv
resource "azurerm_key_vault_secret" "application_vm_admin_password" {
  name         = "application-vm-admin-password"
  value        = var.appsrv_winadmin_password
  key_vault_id = azurerm_key_vault.main_kv.id

  depends_on = [
    azurerm_role_assignment.keyvault_admin
  ]
}

// Managed idemtities
resource "azurerm_role_assignment" "application_vm_keyvault_access" {
  scope                = azurerm_key_vault.main_kv.id
  role_definition_name = "Key Vault Secrets User"

  principal_id = azurerm_windows_virtual_machine.app_virtual_machine.identity[0].principal_id
}

resource "azurerm_role_assignment" "management_vm_keyvault_access" {
  scope                = azurerm_key_vault.main_kv.id
  role_definition_name = "Key Vault Secrets User"

  principal_id = azurerm_linux_virtual_machine.management_vm.identity[0].principal_id
}

// Storage account
resource "azurerm_storage_account" "hub_and_spoke_sa" {
  name                = "hubspokestoragemm01"
  resource_group_name = azurerm_resource_group.storage.name
  location            = var.region

  account_tier             = "Standard"
  account_replication_type = "LRS"

  access_tier                   = "Hot"
  public_network_access_enabled = true

  shared_access_key_enabled = true

  blob_properties {
    versioning_enabled  = true
    change_feed_enabled = true

    delete_retention_policy {
      days = 14
    }

    container_delete_retention_policy {
      days = 14
    }

    restore_policy {
      days = 13
    }
  }

  tags = local.common_tags
}

// Private DNS zone
resource "azurerm_private_dns_zone" "blob_dns" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.networking.name
}

// Hub VNet link
resource "azurerm_private_dns_zone_virtual_network_link" "hub_blob_dns_link" {
  name                  = "hub-blob-dns-link"
  resource_group_name   = azurerm_resource_group.networking.name
  private_dns_zone_name = azurerm_private_dns_zone.blob_dns.name

  virtual_network_id = azurerm_virtual_network.hub_vnet.id

  registration_enabled = false
}

// App VNet link
resource "azurerm_private_dns_zone_virtual_network_link" "application_blob_dns_link" {
  name                  = "application-blob-dns-link"
  resource_group_name   = azurerm_resource_group.networking.name
  private_dns_zone_name = azurerm_private_dns_zone.blob_dns.name

  virtual_network_id = azurerm_virtual_network.app_vnet.id

  registration_enabled = false
}

// Management VNet link
resource "azurerm_private_dns_zone_virtual_network_link" "management_blob_dns_link" {
  name                  = "management-blob-dns-link"
  resource_group_name   = azurerm_resource_group.networking.name
  private_dns_zone_name = azurerm_private_dns_zone.blob_dns.name

  virtual_network_id = azurerm_virtual_network.management_vnet.id

  registration_enabled = false
}

// Private endpoint
resource "azurerm_private_endpoint" "storage_blob_private_endpoint" {
  name                = "pe-storage-blob"
  location            = var.region
  resource_group_name = azurerm_resource_group.networking.name

  subnet_id = azurerm_subnet.private_endpoint_subnet.id

  private_service_connection {
    name = "storage-blob-connection"

    private_connection_resource_id = azurerm_storage_account.hub_and_spoke_sa.id //private endpoint should connect to this storage account

    subresource_names = ["blob"]

    is_manual_connection = false
  }

  private_dns_zone_group {
    name = "blob-zone-group"

    private_dns_zone_ids = [
      azurerm_private_dns_zone.blob_dns.id
    ]
  }
}

// Recovery services vault
resource "azurerm_recovery_services_vault" "rsv_main" {
  name                = "rsv-hubspoke"
  location            = var.region
  resource_group_name = azurerm_resource_group.backup.name

  sku                          = "Standard"
  storage_mode_type            = "GeoRedundant"
  soft_delete_enabled          = true
  cross_region_restore_enabled = true

  tags = local.common_tags
}

// Backup policy - Standard
resource "azurerm_backup_policy_vm" "daily_backup_policy" {
  name                = "daily-backup-policy"
  resource_group_name = azurerm_resource_group.backup.name
  recovery_vault_name = azurerm_recovery_services_vault.rsv_main.name

  timezone = "GMT Standard Time"

  instant_restore_retention_days = 5

  backup {
    frequency = "Daily"
    time      = "23:00"
  }

  retention_daily {
    count = 30
  }
}

// Application VM protection
resource "azurerm_backup_protected_vm" "application_vm_backup" {
  resource_group_name = azurerm_resource_group.backup.name

  recovery_vault_name = azurerm_recovery_services_vault.rsv_main.name

  source_vm_id = azurerm_windows_virtual_machine.app_virtual_machine.id

  backup_policy_id = azurerm_backup_policy_vm.daily_backup_policy.id
}

// Management VM protection
resource "azurerm_backup_protected_vm" "management_vm_protection" {
  resource_group_name = azurerm_resource_group.backup.name

  recovery_vault_name = azurerm_recovery_services_vault.rsv_main.name

  source_vm_id = azurerm_linux_virtual_machine.management_vm.id

  backup_policy_id = azurerm_backup_policy_vm.daily_backup_policy.id
}

// LAW
resource "azurerm_log_analytics_workspace" "law_main" {
  name                = "law-hubspoke"
  location            = var.region
  resource_group_name = azurerm_resource_group.monitor.name

  tags = local.common_tags
}

//  Application VM monitoring agent
resource "azurerm_virtual_machine_extension" "app_vm_monitoring" {
  name               = "AzureMonitorWindowsAgent"
  virtual_machine_id = azurerm_windows_virtual_machine.app_virtual_machine.id

  publisher            = "Microsoft.Azure.Monitor"
  type                 = "AzureMonitorWindowsAgent"
  type_handler_version = "1.0"

  auto_upgrade_minor_version = true
}

// Management VM monitoring agent
resource "azurerm_virtual_machine_extension" "management_vm_monitoring" {
  name               = "AzureMonitorLinuxAgent"
  virtual_machine_id = azurerm_linux_virtual_machine.management_vm.id

  publisher            = "Microsoft.Azure.Monitor"
  type                 = "AzureMonitorLinuxAgent"
  type_handler_version = "1.0"

  auto_upgrade_minor_version = true
}

// DCR
resource "azurerm_monitor_data_collection_rule" "vm_monitoring_dcr" {
  name                = "dcr-vm-monitoring"
  location            = var.region
  resource_group_name = azurerm_resource_group.monitor.name

  destinations {
    log_analytics {
      workspace_resource_id = azurerm_log_analytics_workspace.law_main.id
      name                  = "logAnalyticsDestination"
    }
  }

  data_flow {
    streams = [
      "Microsoft-Perf"
    ]

    destinations = [
      "logAnalyticsDestination"
    ]
  }

  data_flow {
    streams = [
      "Microsoft-Event"
    ]

    destinations = [
      "logAnalyticsDestination"
    ]
  }

  data_flow {
    streams = [
      "Microsoft-Syslog"
    ]

    destinations = [
      "logAnalyticsDestination"
    ]
  }

  data_sources {

    performance_counter {
      name                          = "performanceCounters"
      streams                       = ["Microsoft-Perf"]
      sampling_frequency_in_seconds = 60

      counter_specifiers = [
        "\\Processor(_Total)\\% Processor Time",
        "\\Memory\\Available MBytes"
      ]
    }

    windows_event_log {
      name = "windowsEvents"

      streams = [
        "Microsoft-Event"
      ]

      x_path_queries = [
        "Application!*[System[(Level=1 or Level=2 or Level=3)]]",
        "System!*[System[(Level=1 or Level=2 or Level=3)]]",
        "Security!*[System[(Level=1 or Level=2 or Level=3)]]"
      ]
    }

    syslog {
      name = "linuxSyslog"

      streams = [
        "Microsoft-Syslog"
      ]

      facility_names = [
        "*"
      ]

      log_levels = [
        "Error",
        "Warning",
        "Critical"
      ]
    }
  }
}

// Assosiations - App VM
resource "azurerm_monitor_data_collection_rule_association" "application_vm_dcr" {
  name               = "application-vm-dcr"
  target_resource_id = azurerm_windows_virtual_machine.app_virtual_machine.id

  data_collection_rule_id = azurerm_monitor_data_collection_rule.vm_monitoring_dcr.id
}

// Assosiations - Management VM
resource "azurerm_monitor_data_collection_rule_association" "management_vm_dcr" {
  name               = "management-vm-dcr"
  target_resource_id = azurerm_linux_virtual_machine.management_vm.id

  data_collection_rule_id = azurerm_monitor_data_collection_rule.vm_monitoring_dcr.id
}

// Application Subnet NSG
resource "azurerm_network_security_group" "application_subnet_nsg" {
  name                = "nsg-application-subnet"
  location            = var.region
  resource_group_name = azurerm_resource_group.networking.name

  security_rule {
    name      = "Allow-Bastion-RDP"
    priority  = 100
    direction = "Inbound"
    access    = "Allow"
    protocol  = "Tcp"

    source_port_range      = "*"
    destination_port_range = "3389"

    source_address_prefix      = "10.0.1.0/24"
    destination_address_prefix = "*"
  }

  tags = local.common_tags
}

// Application Subnet NSG assosiation
resource "azurerm_subnet_network_security_group_association" "application_subnet_nsg_association" {
  subnet_id                 = azurerm_subnet.application_subnet.id
  network_security_group_id = azurerm_network_security_group.application_subnet_nsg.id
}


// Management Subnet NSG
resource "azurerm_network_security_group" "management_subnet_nsg" {
  name                = "nsg-management-subnet"
  location            = var.region
  resource_group_name = azurerm_resource_group.networking.name

  security_rule {
    name      = "Allow-Bastion-SSH"
    priority  = 100
    direction = "Inbound"
    access    = "Allow"
    protocol  = "Tcp"

    source_port_range      = "*"
    destination_port_range = "22"

    source_address_prefix = "10.0.1.0/24" # AzureBastionSubnet

    destination_address_prefix = "*"
  }

  tags = local.common_tags
}

// Management Subnet NSG assosiation
resource "azurerm_subnet_network_security_group_association" "management_subnet_nsg_association" {
  subnet_id                 = azurerm_subnet.management_subnet.id
  network_security_group_id = azurerm_network_security_group.management_subnet_nsg.id
}

// Azure Firewall Subnet
resource "azurerm_subnet" "azure_firewall" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.networking.name
  virtual_network_name = azurerm_virtual_network.hub_vnet.name
  address_prefixes     = ["10.0.3.0/26"]
}

// Firewall public IP
resource "azurerm_public_ip" "firewall" {
  name                = "pip-fw-hub"
  location            = var.region
  resource_group_name = azurerm_resource_group.networking.name

  allocation_method = "Static"
  sku               = "Standard"
}

// Firewall policy
resource "azurerm_firewall_policy" "hub_fw_policy" {
  name                = "fw-policy-hub"
  resource_group_name = azurerm_resource_group.networking.name
  location            = var.region
}

// Azure Firewall
resource "azurerm_firewall" "hub_fw" {
  name                = "fw-hub-eastus"
  location            = var.region
  resource_group_name = azurerm_resource_group.networking.name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"

  firewall_policy_id = azurerm_firewall_policy.hub_fw_policy.id

  ip_configuration {
    name                 = "fw-ipconfig"
    subnet_id            = azurerm_subnet.azure_firewall.id
    public_ip_address_id = azurerm_public_ip.firewall.id
  }

  tags = local.common_tags
}

// Route Table
resource "azurerm_route_table" "spoke_rt" {
  name                = "rt-spokes"
  location            = var.region
  resource_group_name = azurerm_resource_group.networking.name
}

// Default route
resource "azurerm_route" "default_route" {
  name                   = "default-to-firewall"
  resource_group_name    = azurerm_resource_group.networking.name
  route_table_name       = azurerm_route_table.spoke_rt.name
  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = azurerm_firewall.hub_fw.ip_configuration[0].private_ip_address
}

// Route table assosiations - Application subnet
resource "azurerm_subnet_route_table_association" "app_spoke_rt_assoc" {
  subnet_id      = azurerm_subnet.application_subnet.id
  route_table_id = azurerm_route_table.spoke_rt.id
}

// Route tabel assosiations - Management subnet
resource "azurerm_subnet_route_table_association" "mgmt_spoke_rt_assoc" {
  subnet_id      = azurerm_subnet.management_subnet.id
  route_table_id = azurerm_route_table.spoke_rt.id
}