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
dadorkBs_A=$(sar -d 1 1 | awk 'NR==4 {print$5}')
dadowkBs_A=$(sar -d 1 1 | awk 'NR==4 {print$6}')
dadoutil_A=$(sar -d 1 1 | awk 'NR==4 {print$11}')

# dados do tps para o diskB
dadotps_B=$(sar -d 1 1 | awk 'NR==5 {print$4}')
dadorkBs_B=$(sar -d 1 1 | awk 'NR==5 {print$5}')
dadowkBs_B=$(sar -d 1 1 | awk 'NR==5 {print$6}')
dadoutil_B=$(sar -d 1 1 | awk 'NR==5 {print$11}')

# dados do tps para o diskC
dadotps_C=$(sar -d 1 1 | awk 'NR==6 {print$4}')
dadorkBs_C=$(sar -d 1 1 | awk 'NR==6 {print$5}')
dadowkBs_C=$(sar -d 1 1 | awk 'NR==6 {print$6}')
dadoutil_C=$(sar -d 1 1 | awk 'NR==6 {print$11}')

#  distribuição do linux
distLinux=$(cat /etc/redhat-release)

# versão do kernel
Vkernel=$(uname -r)

#arquitetura do processador
ArqProc=$(uname -m)

# tempo que a maquina está no ar
uptime=$(uptime | awk '{print $2, $3}')

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
mem=$(free | awk 'NR==2 {print $1}')

total=$(free | awk 'NR==1 {print $1}')
dadototal=$(free | awk 'NR==2 {print $2}')

# used
used=$(free | awk 'NR==1 {print $2}')
dadoused=$(free | awk 'NR==2 {print $3}')

#free 
free=$(free | awk 'NR==1 {print $3}')
dadofree=$(free | awk 'NR==2 {print $4}')
#shared

shared=$(free | awk 'NR==1 {print $4}')
dadoshared=$(free | awk 'NR==2 {print $5}')

# buff/cache
buff_cache=$(free | awk 'NR==1 {print $5}')
dadobuff_cache=$(free | awk 'NR==2 {print $6}')

# available
available=$(free | awk 'NR==1 {print $6}')
dadoavailable=$(free | awk 'NR==2 {print $7}')

# memória (Swap): swap-total, swap-used, swap-free
swap=$(free | awk 'NR==3 {print $1}')

swap_total=$(free | awk 'NR==3 {print $2}')
swap_used=$(free | awk 'NR==3 {print $3}')
swap_free=$(free | awk 'NR==3 {print $4}')

#estrutura do JSON para passar os dados de cada disco referente a 
#disco: tps, rKb/s, wkB/s, svctm, %util
json_data=$(cat <<EOF

   {
 "Json $tpsdisk": {
	"$diskA": "$dadotps_A"
	"$diskB": "$dadotps_B"
	"$diskC": "$dadotps_C"
	},
  "$rkBsdisk": {
	"$diskA": "$dadorkBs_A"
 	"$diskB": "$dadorkBs_B"
  	"$diskC": "$dadorkBs_C"
  	},
  "$wkBsdisk": {
  	"$diskA": "$dadowkBs_A"
   	"$diskB": "$dadowkBs_B"
    	"$diskC": "$dadowkBs_C"
     	},
  "$utildisk": {
  	"$diskA": "$dadoutil_A"
   	"$diskB": "$dadoutil_B"
    	"$diskC": "$dadoutil_C"
     	},
      	{
  "Distribuicao_Linux": "$distLinux"
  	},
   	{
  "Vercao_Linux": "$Vkernel"
  	},
   	{
  "arquitetura_processador": "$ArqProc"
  	},
   	{
  "maquina_no_ar": "$uptime"
    	},
"memoria": {
	"$pgpgins": "$dadopgpgins"
	"$pgpgouts": "$dadopgpgouts"
	"$falts": "$dadofalts"
	"$majflts": "$dadomajflts"
	},
"$mem": {
	"$total": "$dadototal"
	"$used": "$dadoused"
 	"$free": "$dadofree"
	"$shared": "$dadoshared"
	"$buff_cache": "$dadobuff_cache"
	"$available": "$dadoavailable"
	},
"$swap": {
	"$total": "$swap_total"
	"$used": "$swap_used"
	"$free": "$swap_free"
	},
  
}
EOF
)

echo "$json_data"
