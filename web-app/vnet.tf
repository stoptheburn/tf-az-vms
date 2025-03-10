resource "azurerm_virtual_network" "app_network" {
  name                      = var.app_environment.production.virtualNetworkName
  location                  = local.resource_location
  resource_group_name       = azurerm_resource_group.appgrp.name
  address_space             = [var.app_environment.production.virtualNetworkCidrblock]
}

resource "azurerm_subnet" "app_network_subnets" {
  for_each = var.app_environment.production.subnets
  name                      = each.key
  resource_group_name       = azurerm_resource_group.appgrp.name
  virtual_network_name      = azurerm_virtual_network.app_network.name
  address_prefixes          = [each.value.cidrblock]
}

resource "azurerm_network_interface" "web_int" {
  for_each  = var.app_environment.production.subnets["websubnet01"].machines
  name                      = each.value.networkInterfaceName
  location                  = azurerm_resource_group.appgrp.location
  resource_group_name       = azurerm_resource_group.appgrp.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.app_network_subnets["websubnet01"].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.webip[each.key].id 
  }
}

resource "azurerm_network_interface" "app_int" {
  for_each  = var.app_environment.production.subnets["appsubnet01"].machines
  name                      = each.value.networkInterfaceName
  location                  = azurerm_resource_group.appgrp.location
  resource_group_name       = azurerm_resource_group.appgrp.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.app_network_subnets["appsubnet01"].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.appip[each.key].id 
  }
}

resource "azurerm_public_ip" "webip" {
  for_each  = var.app_environment.production.subnets["websubnet01"].machines
  name                = each.value.publicIpAddressName
  resource_group_name = azurerm_resource_group.appgrp.name
  location            = azurerm_resource_group.appgrp.location
  allocation_method   = "Static"

  tags = {
    environment = local.environment
  }
}

resource "azurerm_public_ip" "appip" {
  for_each  = var.app_environment.production.subnets["appsubnet01"].machines
  name                = each.value.publicIpAddressName
  resource_group_name = azurerm_resource_group.appgrp.name
  location            = azurerm_resource_group.appgrp.location
  allocation_method   = "Static"

  tags = {
    environment = local.environment
  }
}


resource "azurerm_network_security_group" "app_nsg" {
  name                = "app-nsg"
  location            = azurerm_resource_group.appgrp.location
  resource_group_name = azurerm_resource_group.appgrp.name

  security_rule {
    name                       = "AllowRDP"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowHTTP"
    priority                   = 310
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowSSH"
    priority                   = 320
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = "Production"
  }
}

resource "azurerm_subnet_network_security_group_association" "subnet_appnsg" {
  for_each = azurerm_subnet.app_network_subnets
  subnet_id                 = azurerm_subnet.app_network_subnets[each.key].id
  network_security_group_id = azurerm_network_security_group.app_nsg.id
}

# Bastion Subnet
resource "azurerm_subnet" "bastionsubnet" {
  #for_each = var.app_environment.production.subnets
  name                      = "AzureBastionSubnet"
  resource_group_name       = azurerm_resource_group.appgrp.name
  virtual_network_name      = var.app_environment.production.virtualNetworkName
  #address_prefixes          = [each.value.cidrblock]
  address_prefixes          = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "bastionip" {
  #for_each  = var.app_environment.production.subnets["appsubnet01"].machines
  #name                = each.value.publicIpAddressName
  name                = "bastionip"
  resource_group_name = azurerm_resource_group.appgrp.name
  location            = azurerm_resource_group.appgrp.location
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    environment = local.environment
  }
}

