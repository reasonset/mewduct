const instance_name = (MEWDUCT_CONFIG.instance_name || "Unnamed instance")
document.title = instance_name + " - Mewduct"
document.getElementById("InstanceName")?.appendChild(document.createTextNode(instance_name))