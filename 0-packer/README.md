* This requires Azure credentials be present in your local environment
* Before running Packer please edit the variables section in `web-server.json` as you see fit. You'll for sure need to set a value for `managed_image_resource_group_name` which defines the resource group where the resulting image will be saved.
* Docs [here](https://www.packer.io/docs/builders/azure/arm)

Then run `packer build web-server.json`