#!/bin/bash

#nome dos discos 
diskA=$(sar -d 1 1 | awk '$2=="sda" {print $2}')
diskB=$(sar -d 1 1 | awk '$2=="dm-0" {print $2}')
diskC=$(sar -d 1 1 | awk '$2=="dm-1" {print $2}')

# nome das métricas de desempenho de disco  
# tps, rKb/s, wkB/s, svctm, %util 
tpsdisk=$(sar -d 1 1 | grep tps | awk 'NR >1 {print $3}')
rkBsdisk=$(sar -d 1 1 | grep rkB/s | awk 'NR >1 {print $4}')
wkBsdisk=$(sar -d 1 1 | grep wkB/s | awk 'NR >1 {print $5}')
%utildisk=$(sar -d 1 1 | grep %util | awk 'NR >1 {print $10}')




#estrutura do JSON para passar os dados de cada disco referente a 
#disco: tps, rKb/s, wkB/s, svctm, %util
json_data=$(cat <<EOF

   {
 	"Json $tpsdisk": {
	"$diskA": "dato"
	"$diskB": "dato"
	"$diskC": "dato"
	}
}
EOF
)

echo "$json_data"
