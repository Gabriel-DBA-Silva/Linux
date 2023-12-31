#!/bin/bash

Serverhost="127.0.0.1"
monitoredhost="Gabriel Linux"
porta="10051"


#nome dos discos 
diskA=$(sar -d 1 1 | awk '$2=="sda" {print $2}')
diskB=$(sar -d 1 1 | awk '$2=="dm-0" {print $2}')
diskC=$(sar -d 1 1 | awk '$2=="dm-1" {print $2}')

# pega o nome dos discos dinâmicos e transforma em json
diskname=$(sar -d 1 1 | grep Average | awk 'NR>1 {print "{\"#DISKNAME\":\"" $2 "\"},"}' | sed -e '1s/^/[/' -e '$s/,$/]/')
zabbix_sender -z "$Serverhost" -p "$porta" -s "$monitoredhost"  -k custom.discovery.disco -o "$diskname"


# nome das métricas de desempenho de disco  
# tps, rKb/s, wkB/s, %util 
tpsdisk=$(sar -d 1 1 | grep tps | awk 'NR >1 {print $3}')
rkBsdisk=$(sar -d 1 1 | grep rkB/s | awk 'NR >1 {print $4}')
wkBsdisk=$(sar -d 1 1 | grep wkB/s | awk 'NR >1 {print $5}')
utildisk=$(sar -d 1 1 | grep %util | awk 'NR >1 {print $10}')
 
# dados do tps para o diskA
dadotps_A=$(sar -d 1 1 | awk 'NR==4 {print$4}')
dadorkBs_A=$(sar -d 1 1 | awk 'NR==4 {print$5 * 1024 * 8}')
dadowkBs_A=$(sar -d 1 1 | awk 'NR==4 {print$6 * 1024 * 8}')
dadoutil_A=$(sar -d 1 1 | awk 'NR==4 {print$11}')

# dados do tps para o diskB
dadotps_B=$(sar -d 1 1 | awk 'NR==5 {print$4}')
dadorkBs_B=$(sar -d 1 1 | awk 'NR==5 {print$5 * 1024 * 8}')
dadowkBs_B=$(sar -d 1 1 | awk 'NR==5 {print$6 * 1024 * 8}')
dadoutil_B=$(sar -d 1 1 | awk 'NR==5 {print$11}')

# dados do tps para o diskC
dadotps_C=$(sar -d 1 1 | awk 'NR==6 {print$4}')
dadorkBs_C=$(sar -d 1 1 | awk 'NR==6 {print$5 * 1024 * 8}')
dadowkBs_C=$(sar -d 1 1 | awk 'NR==6 {print$6 * 1024 * 8}')
dadoutil_C=$(sar -d 1 1 | awk 'NR==6 {print$11}')


tps=$(cat <<EOF

 $tpsdisk  = $diskA: $dadotps_A
 $tpsdisk  = $diskB: $dadotps_B
 $tpsdisk = $diskC: $dadotps_C

EOF
)
zabbix_sender -z "$Serverhost" -p "$porta" -s "$monitoredhost"  -k custom.dynamic[{#DISKNAME},tps] -o "$tps"

rkBs=$(cat <<EOF

 $rkBsdisk = $diskA: $dadorkBs_A
 $rkBsdisk = $diskB: $dadorkBs_B
 $rkBsdisk = $diskC: $dadorkBs_C

EOF
)
zabbix_sender -z "$Serverhost" -p "$porta" -s "$monitoredhost"  -k custom.dynamic[{#DISKNAME},rkBs] -o "$rkBs"

wkBs=$(cat <<EOF

 $wkBsdisk = $diskA: $dadowkBs_A
 $wkBsdisk = $diskB: $dadowkBs_B
 $wkBsdisk = $diskC: $dadowkBs_C

EOF
)
zabbix_sender -z "$Serverhost" -p "$porta" -s "$monitoredhost"  -k custom.dynamic[{#DISKNAME},wkBs] -o "$wkBs"

util=$(cat <<EOF

 $utildisk = $diskA: $dadoutil_A
 $utildisk = $diskB: $dadoutil_B
 $utildisk = $diskC: $dadoutil_C

EOF
)

zabbix_sender -z "$Serverhost" -p "$porta" -s "$monitoredhost"  -k custom.dynamic[{#DISKNAME},util] -o "$util"

#  distribuição do linux
distLinux=$(cat /etc/redhat-release)

zabbix_sender -z "$Serverhost" -p "$porta" -s "$monitoredhost"  -k custom.static[linuxDistribution] -o "$distLinux" 

# versão do kernel
Vkernel=$(uname -r)

zabbix_sender -z "$Serverhost" -p "$porta" -s "$monitoredhost"  -k custom.static[kernelVersion] -o "$Vkernel" 

#arquitetura do processador
ArqProc=$(uname -m)

zabbix_sender -z "$Serverhost" -p "$porta" -s "$monitoredhost"  -k custom.static[processorArchitecture] -o "$ArqProc" 

# tempo que a maquina está no ar
#uptime=$(uptime | awk '{print $2, $3}')
uptime_seconds=$(($(date +%s) - $(date -d "$(uptime -s)" +%s)))

zabbix_sender -z "$Serverhost" -p "$porta" -s "$monitoredhost"  -k custom.static[uptime] -o "$uptime_seconds" 

# memória: pgpgin/s)
pgpgins=$(sar -B 1 1 | awk 'NR==3 {print $3}')
dadopgpgins=$(sar -B 1 1 | awk 'NR==4 {print $3}')
zabbix_sender -z "$Serverhost" -p "$porta" -s "$monitoredhost"  -k custom.static[pgpgins] -o "$dadopgpgins" 

# pgpgout/s 
pgpgouts=$(sar -B 1 1 | awk 'NR==3 {print $4}')
dadopgpgouts=$(sar -B 1 1 | awk 'NR==4 {print $4}')
zabbix_sender -z "$Serverhost" -p "$porta" -s "$monitoredhost"  -k custom.static[pgpgouts] -o "$dadopgpgouts" 

# falt/s 
falts=$(sar -B 1 1 | awk 'NR==3 {print $5}')
dadofalts=$(sar -B 1 1 | awk 'NR==4 {print $5}')
zabbix_sender -z "$Serverhost" -p "$porta" -s "$monitoredhost"  -k custom.static[faults] -o "$dadofalts" 

#majflt/s
majflts=$(sar -B 1 1 | awk 'NR==3 {print $6}')
dadomajflts=$(sar -B 1 1 | awk 'NR==4 {print $6}')
zabbix_sender -z "$Serverhost" -p "$porta" -s "$monitoredhost"  -k custom.static[majflts] -o "$dadomajflts" 

# memória (Men): total, used,free shared, buff/cache, available
mem=$(free | awk 'NR==2 {gsub(/:/, "", $1); print $1}')

total=$(free | awk 'NR==1 {print $1}')
dadototal=$(free | awk 'NR==2 {print $2 * 1024}')
zabbix_sender -z "$Serverhost" -p "$porta" -s "$monitoredhost"  -k custom.static[memoryTotal] -o "$dadototal" 

# used
used=$(free | awk 'NR==1 {print $2}')
dadoused=$(free | awk 'NR==2 {print $3 * 1024}')
zabbix_sender -z "$Serverhost" -p "$porta" -s "$monitoredhost"  -k custom.static[memoryUsed] -o "$dadoused" 

#free 
free=$(free | awk 'NR==1 {print $3}')
dadofree=$(free | awk 'NR==2 {print $4 * 1024}')
zabbix_sender -z "$Serverhost" -p "$porta" -s "$monitoredhost"  -k custom.static[memoryFree] -o "$dadofree" 

#shared
shared=$(free | awk 'NR==1 {print $4}')
dadoshared=$(free | awk 'NR==2 {print $5 * 1024}')
zabbix_sender -z "$Serverhost" -p "$porta" -s "$monitoredhost"  -k custom.static[memoryShared] -o "$dadoshared" 

# buff/cache
buff_cache=$(free | awk 'NR==1 {print $5}')
dadobuff_cache=$(free | awk 'NR==2 {print $6 * 1024}')
zabbix_sender -z "$Serverhost" -p "$porta" -s "$monitoredhost"  -k custom.static[memoryCache] -o "$dadobuff_cache" 
# available
available=$(free | awk 'NR==1 {print $6}')
dadoavailable=$(free | awk 'NR==2 {print $7 * 1024}')
zabbix_sender -z "$Serverhost" -p "$porta" -s "$monitoredhost"  -k custom.static[memoryAvailable] -o "$dadoavailable" 

# memória (Swap): swap-total, swap-used, swap-free
swap=$(free | awk 'NR==3 {gsub(/:/, "", $1); print $1}')

swap_total=$(free | awk 'NR==3 {print $2 * 1024}')
zabbix_sender -z "$Serverhost" -p "$porta" -s "$monitoredhost"  -k custom.static[SwapTotal] -o "$swap_total" 

swap_used=$(free | awk 'NR==3 {print $3 * 1024}')
zabbix_sender -z "$Serverhost" -p "$porta" -s "$monitoredhost"  -k custom.static[usedSwap] -o "$swap_used" 

swap_free=$(free | awk 'NR==3 {print $4 * 1024}')
zabbix_sender -z "$Serverhost" -p "$porta" -s "$monitoredhost"  -k custom.static[freeSwap] -o "$swap_free" 
# filesystem: Consumo em % de inodes
#filesystem=$(df -i | awk 'NR==1 {print $1}')
################filesystem=$(df -i | grep -v "tmpfs" | awk 'NR>1 {gsub(/%/, "", $5); print $NF ": " $5}')
# Obtém a saída original
filesystem_original=$(df -i | grep -v "tmpfs" | awk 'NR>1 {gsub(/%/, "", $5); print $NF ": " $5}')

# Formata a saída como JSON
filesystem_json=$(echo "$filesystem_original" | awk -F ': ' '{printf "{\"#FILESY\":\"%s\"},",$1}' | sed 's/,$//')
filesystem_json="[$filesystem_json]"

zabbix_sender -z "$Serverhost" -p "$porta" -s "$monitoredhost"  -k custom.discovery.filesystem -o "$filesystem_json" 
zabbix_sender -z "$Serverhost" -p "$porta" -s "$monitoredhost"  -k custom.dynamic[{#FSNAME},/] -o "$filesystem_original" 


#devtmpfs=$(df -i | awk 'NR==2 {print $1}')             
#tmpfs=$(df -i | awk 'NR==3 {print $1}')                
#tmpfs=$(df -i | awk 'NR==4 {print $1}')                
#rl_root=$(df -i | awk 'NR==5 {print $1}')  
#sda1=$(df -i | awk 'NR==6 {print $1}')            
#tmpfs=$(df -i | awk 'NR==7 {print $1}')               
#tmpfs=$(df -i | awk 'NR==8 {print $1}')                

# % de inodes
#Iiuse=$(df -i | awk 'NR==2 {print $5}')
#IIiuse=$(df -i | awk 'NR==3 {print $5}')
#IIIiuse=$(df -i | awk 'NR==4 {print $5}')
#IViuse=$(df -i | awk 'NR==5 {print $5}')
#Viuse=$(df -i | awk 'NR==6 {print $5}')
#VIiuse=$(df -i | awk 'NR==7 {print $5}')
#VIIiuse=$(df -i | awk 'NR==8 {print $5}')

#  rede: rxpck/s, txpck/s, rxKb/s, txKb/s, %ifutil
## lo e enp0s3 dinânimico e transformando em json
rede=$(sar -n DEV 1 1 | grep -v Average | awk 'NR>3 && $2 != "" {print "{\"#IFACENAME\":\"" $3 "\"},"}' | sed -e '1s/^/[/' -e '$s/,$/]/')


lo=$(sar -n DEV 1 1 | awk 'NR==4 {print $3}')

rxpcks=$(sar -n DEV 1 1 | awk 'NR==3 {print $4}') 
txpcks=$(sar -n DEV 1 1 | awk 'NR==3 {print $5}') 
rxKbs=$(sar -n DEV 1 1 | awk 'NR==3 {print $6}') 
txKbs=$(sar -n DEV 1 1 | awk 'NR==3 {print $7}') 
ifutil=$(sar -n DEV 1 1 | awk 'NR==3 {print $11}')

dadorxpcks=$(sar -n DEV 1 1 | awk 'NR==4 {print $4}') 
dadotxpcks=$(sar -n DEV 1 1 | awk 'NR==4 {print $5}') 
dadorxKbs=$(sar -n DEV 1 1 | awk 'NR==4 {print $6 * 1024 * 8}') 
dadotxKbs=$(sar -n DEV 1 1 | awk 'NR==4 {print $7 * 1024 * 8}') 
dadoifutil=$(sar -n DEV 1 1 | awk 'NR==4 {print $11}')

## enp0s3
enp0s3=$(sar -n DEV 1 1 | awk 'NR==5 {print $3}') 

endadorxpcks=$(sar -n DEV 1 1 | awk 'NR==5 {print $4}') 
endadotxpcks=$(sar -n DEV 1 1 | awk 'NR==5 {print $5}') 
endadorxKbs=$(sar -n DEV 1 1 | awk 'NR==5 {print $6 * 1024 * 8}') 
endadotxKbs=$(sar -n DEV 1 1 | awk 'NR==5 {print $7 * 1024 * 8}') 
endadoifutil=$(sar -n DEV 1 1 | awk 'NR==5 {print $11}')

drxpcks=$(cat <<EOF
$rxpcks = $lo: $dadorxpcks
$rxpcks = $enp0s3: $endadorxpcks
EOF
)
zabbix_sender -z "$Serverhost" -p "$porta" -s "$monitoredhost"  -k custom.dynamic[{#IFACENAME},rxpcks] -o "$drxpcks"

dtxpcks=$(cat <<EOF
$txpcks = $lo: $dadotxpcks
$txpcks = $endadotxpcks
EOF
)
zabbix_sender -z "$Serverhost" -p "$porta" -s "$monitoredhost"  -k custom.dynamic[{#IFACENAME},txpcks] -o "$dtxpcks"


drxKbs=$(cat <<EOF
$rxKbs = $lo: $dadorxKbs 
$rxKbs = $endadorxKbs
EOF
)
zabbix_sender -z "$Serverhost" -p "$porta" -s "$monitoredhost"  -k custom.dynamic[{#IFACENAME},rxpcks] -o "$drxKbs"

dtxKbs=$(cat <<EOF
$txKbs = $lo: $dadotxKbs
$txKbs = $endadotxKbs
EOF
)
zabbix_sender -z "$Serverhost" -p "$porta" -s "$monitoredhost"  -k custom.dynamic[{#IFACENAME},txkBs] -o "$dtxKbs"

dfutil=$(cat <<EOF
$ifutil = $lo: $dadoifutil
$ifutil = $endadoifutil
EOF
)
zabbix_sender -z "$Serverhost" -p "$porta" -s "$monitoredhost"  -k custom.dynamic[{#IFACENAME},ifutil] -o "$dfutil"

#estrutura do JSON para passar os dados de cada disco referente a 
#disco: tps, rKb/s, wkB/s, svctm, %util
json_data=$(cat <<EOF

$diskname

$tps
$rkBs
$wkBs
$util


 $pgpgins: $dadopgpgins
$pgpgouts: $dadopgpgouts
$falts: $dadofalts
$majflts: $dadomajflts

$total = $mem: $dadototal
$used = $mem: $dadoused
$free = $mem: $dadofree
$shared = $mem: $dadoshared
$buff_cache = $mem: $dadobuff_cache
$available = $mem: $dadoavailable

$total = $swap: $swap_total
$used = $swap: $swap_used 
$free = $swap: $swap_free 

$filesystem_json
$filesystem_original


$rede

$drxpcks
$dtxpcks
$drxKbs
$dtxKbs
$dfutil

distribuição_linux: $distLinux

versão_kernel: $Vkernel

arquitetura_processador: $ArqProc

tempo_maquina_ar: $uptime_seconds

  
EOF
)

echo "$json_data"
