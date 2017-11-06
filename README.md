Useful script if you are running Hyper-V on a notebook and want to quickly switch the network cards your VMs are connected to from WiFi to Ethernet.

**Usage**  

`Switch-VMSwitch -From WiFi -To Ethernet`  
WiFi and Ethernet would be the names of your Hyper-V switches, they will be auto suggested and validated against the actual existing switches.

You can specify only certain VMs with the VMName parameter like so:  
`Switch-VMSwitch -From OldSwitch -To NewSwitch -VMName MyVirtualMachine`  
The VMName parameter also takes values from the pipeline.

**Remote Hyper-V Hosts**

I removed the option the run this against remote machines from master since I didn't get to test it. You can still find the code on the `remote` branch if you would like to try it or extend it yourself.
