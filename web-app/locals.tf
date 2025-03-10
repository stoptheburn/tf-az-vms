locals {
  
  #resource_location   = "North Central US"
  resource_location = "East US"
  #resource_location   = "Central India"
  environment = "staging"
  
  virtual_network = {
    name = "app-network"
    address_prefixes = ["10.0.0.0/16"]
  }
  subnet_addr_prefix = ["10.0.0.0/24","10.0.1.0/24"]
  subnets = [
    {
      name = "websubnet01"
      address_prefixes = ["10.0.0.0/24"]
    },
    {
      name = "appsubnet01"
      address_prefixes = ["10.0.1.0/24"]
    }
  ]

  networkSecurityGroup_rules = [
    {
      priority = 300
      destination_port_range = "3389"
    },
    {
      priority = 310
      destination_port_range = "80"
    },
    {
      priority = 321
      destination_port_range = "22"
    }
  ]
}