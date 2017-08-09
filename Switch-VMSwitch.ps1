<#
.Synopsis
Changes the switch of all network adapters from a specific switch to another one.
.DESCRIPTION
Actual SYNTAX

Switch-VMSwitch [-From] <String> [-To] <String> [[-VMName] <String[]>] [[-ComputerName] <String[]>] [[-Credential] <PSCredential>] [-WhatIf] [-Confirm] [<CommonParameters>]

This is useful if you're running VMs on a notebook and want to switch from your Wi-Fi vSwitch to the Ethernet one.
Every network adapter that's connected to the switch specified in the '-From'-parameter will get connected to the switch specified in the '-To'-parameter instead.

DYNAMIC PARAMETERS
Since Dynamic Parameter don't get recognized by PowerShell's help system here they are:

-From <String>
    The switch the network adapter is currently connected to.

    Required?                   true
    Position?                   1
    Default value               none
    Accept pipeline input       false
    Accept wildcard characters  false

-To <String>
    The switch the network adapter should get connected to.

    Required?                   true
    Position?                   2
    Default value               none
    Accept pipeline input       false
    Accept wildcard characters  false

-VMName <String[]>
    Name of VMs whose virtual switch should get changed.

    Required?                   false
    Position?                   3
    Default value               *
    Accept pipeline input       ByPropertyName
    Accept wildcard characters  false

.EXAMPLE
Switch-VMSwitch -From WiFiSwitch -To EthernetSwitch

This will change the virtual switch connected to the network adapters that are currently connected to the 'WifiSwitch' to 'EthernetSwitch' for all VMs of a local Hyper-V installation.
.EXAMPLE
Switch-VMSwitch -From WiFiSwitch -To EthernetSwitch -VMName 'TestVM'

This will change the virtual switch connected to the network adapters that are currently connected to the 'WifiSwitch' to 'EthernetSwitch' only for 'TestVM' on a local Hyper-V installation.
#>

function Switch-VMSwitch {

    [CmdletBinding()]
    Param ()

    DynamicParam {
        # https://blogs.technet.microsoft.com/pstips/2014/06/09/dynamic-validateset-in-a-dynamic-parameter/
        # Set DynamicParam attributes and create AttributeCollections for each DynamicParam

        # From Parameter
        $FromName = 'From'
        $FromAttributeProperty = @{
            Mandatory = $true;
            HelpMessage = 'The switch the network adapter is currently connected to';
            Position = 0
        }
        $FromAttribute = New-Object System.Management.Automation.ParameterAttribute -Property $FromAttributeProperty

        $FromValidateSet = Get-VMSwitch | Select-Object -ExpandProperty Name
        $FromValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($FromValidateSet)

        $FromAttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
        $FromAttributeCollection.Add($FromAttribute)
        $FromAttributeCollection.Add($FromValidateSetAttribute)

        $FromRuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($FromName, [string], $FromAttributeCollection)


        # To Parameter
        $ToName = 'To'
        $ToAttributeProperty = @{
            Mandatory = $true;
            HelpMessage = 'The switch the network adapter should get connected to';
            Position = 1
        }
        $ToAttribute = New-Object System.Management.Automation.ParameterAttribute -Property $ToAttributeProperty

        $ToValidateSet = Get-VMSwitch | Select-Object -ExpandProperty Name
        $ToValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($ToValidateSet)

        $ToAttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
        $ToAttributeCollection.Add($ToAttribute)
        $ToAttributeCollection.Add($ToValidateSetAttribute)

        $ToRuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ToName, [string], $ToAttributeCollection)


        # VMName Parameter
        $VMNameName = 'VMName'
        $VMNameAttributeProperty = @{
            HelpMessage = 'VMs whose virtual switch should get changed';
            Position = 2;
            ValueFromPipelineByPropertyName = $true
        }
        $VMNameAttribute = New-Object System.Management.Automation.ParameterAttribute -Property $VMNameAttributeProperty

        $VMNameValidateSet = Get-VM | Select-Object -ExpandProperty Name
        $VMNameValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($VMNameValidateSet)

        $VMNameAttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
        $VMNameAttributeCollection.Add($VMNameAttribute)
        $VMNameAttributeCollection.Add($VMNameValidateSetAttribute)

        $VMNameRuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($VMNameName, [string], $VMNameAttributeCollection)


        # Create and return parameter dictionary
        $RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        $RuntimeParameterDictionary.Add($FromName, $FromRuntimeParameter)
        $RuntimeParameterDictionary.Add($ToName, $ToRuntimeParameter)
        $RuntimeParameterDictionary.Add($VMNameName, $VMNameRuntimeParameter)

        $RuntimeParameterDictionary
    }

    Begin {

        # Assign DynamicParams to actual variables
        foreach ($Parameter in $PSBoundParameters.Keys) {
            if (!(Get-Variable -Name $Parameter -scope 0 -ErrorAction SilentlyContinue)) {
                New-Variable -Name $Parameter -Value $PSBoundParameters.$Parameter
            }
        }

        # Set default value for $VMNames if not specified
        if (!$VMName) {
            $VMName = '*'
        }

    }

    Process {

        $VMNetworkAdapters = (Get-VM -Name $VMName).NetworkAdapters

        Foreach ($Adapter in $VMNetworkAdapters | Where-Object SwitchName -eq $From) {
            $Adapter | Connect-VMNetworkAdapter -SwitchName $To
            $Adapter
        }

    }

}
