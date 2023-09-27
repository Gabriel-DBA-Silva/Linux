#!/bin/bash

#nome dos discos 
diskA=$(sar -d 1 1 | awk '$2=="sda" {print $2}')
diskB=$(sar -d 1 1 | awk '$2=="dm-0" {print $2}')
diskC=$(sar -d 1 1 | awk '$2=="dm-1" {print $2}')

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

#  distribuição do linux
distLinux=$(cat /etc/redhat-release)

# versão do kernel
Vkernel=$(uname -r)

#arquitetura do processador
ArqProc=$(uname -m)

# tempo que a maquina está no ar
#uptime=$(uptime | awk '{print $2, $3}')
uptime_seconds=$(($(date +%s) - $(date -d "$(uptime -s)" +%s)))


# memória: pgpgin/s)
pgpgins=$(sar -B 1 1 | awk 'NR==3 {print $3}')
dadopgpgins=$(sar -B 1 1 | awk 'NR==4 {print $3}')

# pgpgout/s 
pgpgouts=$(sar -B 1 1 | awk 'NR==3 {print $4}')
dadopgpgouts=$(sar -B 1 1 | awk 'NR==4 {print $4}')

# falt/s 
falts=$(sar -B 1 1 | awk 'NR==3 {print $5}')
dadofalts=$(sar -B 1 1 | awk 'NR==4 {print $5}')

#majflt/s
majflts=$(sar -B 1 1 | awk 'NR==3 {print $6}')
dadomajflts=$(sar -B 1 1 | awk 'NR==4 {print $6}')

# memória (Men): total, used,free shared, buff/cache, available
mem=$(free | awk 'NR==2 {gsub(/:/, "", $1); print $1}')

total=$(free | awk 'NR==1 {print $1}')
dadototal=$(free | awk 'NR==2 {print $2 * 1024}')

# used
used=$(free | awk 'NR==1 {print $2}')
dadoused=$(free | awk 'NR==2 {print $3 * 1024}')

#free 
free=$(free | awk 'NR==1 {print $3}')
dadofree=$(free | awk 'NR==2 {print $4 * 1024}')
#shared

shared=$(free | awk 'NR==1 {print $4}')
dadoshared=$(free | awk 'NR==2 {print $5 * 1024}')

# buff/cache
buff_cache=$(free | awk 'NR==1 {print $5}')
dadobuff_cache=$(free | awk 'NR==2 {print $6 * 1024}')

# available
available=$(free | awk 'NR==1 {print $6}')
dadoavailable=$(free | awk 'NR==2 {print $7 * 1024}')

# memória (Swap): swap-total, swap-used, swap-free
swap=$(free | awk 'NR==3 {gsub(/:/, "", $1); print $1}')

swap_total=$(free | awk 'NR==3 {print $2 * 1024}')
swap_used=$(free | awk 'NR==3 {print $3 * 1024}')
swap_free=$(free | awk 'NR==3 {print $4 * 1024}')

# filesystem: Consumo em % de inodes
#filesystem=$(df -i | awk 'NR==1 {print $1}')
filesystem=$(df -i | grep -v "tmpfs" | awk 'NR>1 {gsub(/%/, "", $5); print $NF ": " $5}')
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
## lo
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

#estrutura do JSON para passar os dados de cada disco referente a 
#disco: tps, rKb/s, wkB/s, svctm, %util
json_data=$(cat <<EOF

[{"#DISKNAME":"$diskA"},{"#DISKNAME":"$diskB"},{"#DISKNAME":"$diskC"}]

 $tpsdisk  = $diskA: $dadotps_A
 $rkBsdisk = $diskA: $dadorkBs_A
 $wkBsdisk = $diskA: $dadowkBs_A
 $utildisk = $diskA: $dadoutil_A

 $tpsdisk  = $diskB: $dadotps_B
 $rkBsdisk = $diskB: $dadorkBs_B
 $wkBsdisk = $diskB: $dadowkBs_B
 $utildisk = $diskB: $dadoutil_B

  $tpsdisk = $diskC: $dadotps_C
 $rkBsdisk = $diskC: $dadorkBs_C
 $wkBsdisk = $diskC: $dadowkBs_C
 $utildisk = $diskC: $dadoutil_C


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


$filesystem

[{"#IFACENAME":"$lo"},{"#IFACENAME":"$enp0s3"}]

$rxpcks   = $lo: $dadorxpcks 
$txpcks   = $lo: $dadotxpcks
$rxKbs    = $lo: $dadorxKbs 
$txKbs    = $lo: $dadotxKbs 
$ifutil   = $lo: $dadoifutil

$rxpcks = $enp0s3: $endadorxpcks
$txpcks = $enp0s3: $endadotxpcks
$rxKbs  = $enp0s3: $endadorxKbs 
$txKbs  = $enp0s3: $endadotxKbs 
$ifutil = $enp0s3: $endadoifutil

distribuição_linux: $distLinux

versão_kernel: $Vkernel

arquitetura_processador: $ArqProc

tempo_maquina_ar: $uptime_seconds

  
EOF
)

echo "$json_data"
