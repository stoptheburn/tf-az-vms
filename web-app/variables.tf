variable "vm_name" {
  type          = string
  description   = "This is the name of the VM"
  default       = "webwinvm01"
}   

variable "client_id" {
  type 		= string
  description   = "This is client id from Azure Portal"
}
  
variable "client_secret" {
  type 		= string
  description   = "This is client secret from Azure Portal"
}

variable "tenant_id" {
  type 		= string
  description   = "This is tenant id from Azure Portal - Subscription blade"
}

variable "subscription_id" {
  type 		= string
  description   = "This is subscription_id from Azure Portal - Subscription blade"
}

variable "admin_username" {
    type            = string
    description   = "This is the admin user for the Win VM"
    default         = "appadmin"    
}

variable "vm_size" {
  type = string
  description = "This is the size of the machine"
  default = "Standard_B2s"
}

variable "admin_password" {
  type = string
  description = "This is the password for VM"
  # Force terraform to prompt the password
  sensitive = true
}
/*
variable "network_interface_count" {
  type = number
  description = "No of Interfaces"
}
*/
variable "app_environment" {
   type = map(object(
    {
      virtualNetworkName      = string
      virtualNetworkCidrblock = string
      subnets = map(object(
      {
        cidrblock             =  string
        machines = map(object(
        {
          networkInterfaceName = string
          publicIpAddressName = string
        }
        ))
      }))     
    }
   ))
}

/*
variable "subnet_information" {
  type = map(object(
  {
    cidrblock = string
    
  }))
}
*/
