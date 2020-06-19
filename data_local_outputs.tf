variable "compute_list" {
  type = list(string)
  default = ["test01", "test02"]
}

variable "disk_details" {
  type = list(map(any))
  default = [
  {
     compute_data_disks = "test01-data-01,test01-data-02"
     compute_data_disk_type = "pd-ssd"
     compute_data_disk_size = "30,40"
  },
  {
    compute_data_disks = "test02-data-01,test02-data-02"
    compute_data_disk_type = "pd-ssd"
    compute_data_disk_size = "30,40"
  }
]
}





data "null_data_source" "disks" {
  count            = length(var.disk_details)
  inputs = {
     name             = lookup(var.disk_details[count.index], "compute_data_disks")
     type             = lookup(var.disk_details[count.index], "compute_data_disk_type")
     size             = lookup(var.disk_details[count.index], "compute_data_disk_size")
  }
}

locals {
  total_disks = [ 
	for names in data.null_data_source.disks : 
		[for disk in split("," , names.outputs["name"]) : disk ]
  ]
}

locals {
  compute_disk_name = [ for names in data.null_data_source.disks : names.outputs["name"] ]
  compute_data_disk_type = [ for types in data.null_data_source.disks : types.outputs["type"] ] 
  compute_data_disk_size = [ for sizes in data.null_data_source.disks : sizes.outputs["size"] ] 
}

output "name" {
   value = local.compute_disk_name
}
output "type" {
   value = local.compute_data_disk_type
}
output "size" {
   value = local.compute_data_disk_size
}

output "total_disks" {
   value = flatten(local.total_disks)
}
