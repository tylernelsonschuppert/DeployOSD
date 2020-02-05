<#
Title: DeployOSD Function
Description: One-Liner CLI front-end for scripted OSD
Author: Tyler Nelson
Created: 4/6/18
Updated: 4/12/18
#>

Function DeployOSD {
               [CmdletBinding(DefaultParameterSetName="ComputeClusterAndDomainJoined")]
               Param (
                               [Parameter(Mandatory=$True)]
                               [string]$ComputerName,
                               [Parameter(Mandatory=$True)]
                               [int]$CPU,
                               [Parameter(Mandatory=$True)]
                               [int]$RAM,
                               [Parameter(Mandatory=$True)]
                               [string]$Datastore,
                               [Parameter(Mandatory=$False)]
                               [string]$NetworkAdapter,
                               [Parameter(Mandatory=$True)]
                               [string]$IPAddress,
                               [Parameter(Mandatory=$False)]
                               [string]$SubnetMask = "255.255.255.0",
                               [Parameter(Mandatory=$False)]
                               [string]$Gateway,
                               [Parameter(Mandatory=$True)]
                               [string]$PatchCollection,
                               [Parameter(Mandatory=$True)]
                               [ValidateSet('PS0','PQ0','PD0')]
                               [string]$SiteCode,
                               [Parameter(Mandatory=$False)]
                               [string]$OperatingSystem = "2016",
                               [Parameter(Mandatory=$False)]
                               [string]$Template = "OSDTEMPLATE",
                               [Parameter(Mandatory=$True, ParameterSetName="ComputeClusterAndDomainJoined")]
                               [Parameter(Mandatory=$True, ParameterSetName="ComputeHostAndDomainJoined")]
                               [string]$Domain,
                               [Parameter(Mandatory=$True, ParameterSetName="ComputeClusterAndDomainJoined")]
                               [Parameter(Mandatory=$True, ParameterSetName="ComputeHostAndDomainJoined")]
                               [string]$OrganizationalUnit,
                               [Parameter(Mandatory=$True, ParameterSetName="ComputeClusterAndWorkgroup")]
                               [Parameter(Mandatory=$True, ParameterSetName="ComputeClusterAndDomainJoined")]
                               [string]$ComputeCluster,
                               [Parameter(Mandatory=$True, ParameterSetName="ComputeHostAndDomainJoined")]
                               [Parameter(Mandatory=$True, ParameterSetName="ComputeHostAndWorkgroup")]
                               [string]$ComputeHost,
                               [Parameter(Mandatory=$True, ParameterSetName="ComputeClusterAndWorkgroup")]
                               [Parameter(Mandatory=$True, ParameterSetName="ComputeHostAndWorkgroup")]
                               [switch]$Workgroup
               )
               if ($Gateway) {
                               $GatewayCheckSep = $IPAddress.lastindexof(".")
                               $GatewayExpect = $IPAddress.substring(0,$GatewayCheckSep) + ".1"
                               if ($Gateway -ne $GatewayExpect) {
                                               $ReadHost = Read-Host 'Gateway supplied is' $Gateway 'but' $GatewayExpect 'was expected. Are you sure you wish to continue? (Y/N)'
                                               Switch ($ReadHost) {
                                                               Y { continue }
                                                               N { exit }
                                               }
                               }
               } elseif (!$Gateway) {
                               $IPAddressSep = $IPAddress.lastindexof(".")
                               $Gateway = $IPAddress.substring(0,$IPAddressSep) + ".1"
               }
               if ($NetworkAdapter) {
                               $NetworkAdapterCheckSep = $IPAddress.lastindexof(".")
                               $NetworkAdapterExpect = $IPAddress.substring(0,$NetworkAdapterCheckSep) + ".XX"
                               if ($NetworkAdapter -ne $NetworkAdapterExpect) {
                                               $ReadHost = Read-Host 'NetworkAdapter supplied is' $NetworkAdapter 'but' $NetworkAdapterExpect 'was expected. Are you sure you wish to continue? (Y/N)'
                                               Switch ($ReadHost) {
                                                               Y { continue }
                                                               N { exit }
                                               }
                               }
               } elseif (!$NetworkAdapter) {
                               $NetworkAdapterSep = $IPAddress.lastindexof(".")
                               $NetworkAdapter = $IPAddress.substring(0,$NetworkAdapterSep) + ".XX"
               }
               if ($PSCmdlet.ParameterSetName -eq "ComputeClusterAndDomainJoined") {
                               New-VM -Name $ComputerName -Template $Template -Datastore $Datastore -VMHost (Get-Cluster $ComputeCluster | Get-VMHost | ? {$_.ConnectionState -notlike "Maintenance"} | ? {$_.ConnectionState -notlike "NotResponding"} | Sort MemoryUsageGB | Select -First 1)
                               Set-VM $ComputerName -MemoryGB $RAM -NumCpu $CPU -Confirm:$false
                               Set-NetworkAdapter -NetworkAdapter (Get-NetworkAdapter -VM $ComputerName) -NetworkName $NetworkAdapter -Confirm:$false
                               New-KNDComputer -SiteCode $SiteCode -ComputerName $ComputerName -IPAddress $IPAddress -SubnetMask $SubnetMask -Gateway $Gateway -PatchCollection $PatchCollection -OperatingSystem $OperatingSystem -DomainJoined -Domain $Domain -OrganizationalUnit $OrganizationalUnit
               } elseif ($PSCmdlet.ParameterSetName -eq "ComputeHostAndDomainJoined") {
                               New-VM -Name $ComputerName -Template $Template -Datastore $Datastore -VMHost $ComputeHost
                               Set-VM $ComputerName -MemoryGB $RAM -NumCpu $CPU -Confirm:$false
                               Set-NetworkAdapter -NetworkAdapter (Get-NetworkAdapter -VM $ComputerName) -NetworkName $NetworkAdapter -Confirm:$false
                               New-KNDComputer -SiteCode $SiteCode -ComputerName $ComputerName -IPAddress $IPAddress -SubnetMask $SubnetMask -Gateway $Gateway -PatchCollection $PatchCollection -OperatingSystem $OperatingSystem -DomainJoined -Domain $Domain -OrganizationalUnit $OrganizationalUnit
               } elseif ($PSCmdlet.ParameterSetName -eq "ComputeClusterAndWorkgroup") {
                               New-VM -Name $ComputerName -Template $Template -Datastore $Datastore -VMHost (Get-Cluster $ComputeCluster | Get-VMHost | ? {$_.ConnectionState -notlike "Maintenance"} | ? {$_.ConnectionState -notlike "NotResponding"} | Sort MemoryUsageGB | Select -First 1)
                               Set-VM $ComputerName -MemoryGB $RAM -NumCpu $CPU -Confirm:$false
                               Set-NetworkAdapter -NetworkAdapter (Get-NetworkAdapter -VM $ComputerName) -NetworkName $NetworkAdapter -Confirm:$false
                               New-KNDComputer -SiteCode $SiteCode -ComputerName $ComputerName -IPAddress $IPAddress -SubnetMask $SubnetMask -Gateway $Gateway -PatchCollection $PatchCollection -OperatingSystem $OperatingSystem -NonDomainJoined
               } elseif ($PSCmdlet.ParameterSetName -eq "ComputeHostAndWorkgroup") {
                               New-VM -Name $ComputerName -Template $Template -Datastore $Datastore -VMHost $ComputeHost
                               Set-VM $ComputerName -MemoryGB $RAM -NumCpu $CPU -Confirm:$false
                               Set-NetworkAdapter -NetworkAdapter (Get-NetworkAdapter -VM $ComputerName) -NetworkName $NetworkAdapter -Confirm:$false
                               New-KNDComputer -SiteCode $SiteCode -ComputerName $ComputerName -IPAddress $IPAddress -SubnetMask $SubnetMask -Gateway $Gateway -PatchCollection $PatchCollection -OperatingSystem $OperatingSystem -NonDomainJoined
               }
}

