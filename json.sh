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
     	}   
}
EOF
)

echo "$json_data"
