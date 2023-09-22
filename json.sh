#!/bin/bash

namedisk=$(sar -d 1 1 | grep DEV | awk 'NR >1 {print $2}')
diskA=$(sar -d 1 1 | awk '$2=="sda" {print $2}')
diskB=$(sar -d 1 1 | awk '$2=="dm-0" {print $2}')
diskC=$(sar -d 1 1 | awk '$2=="dm-1" {print $2}')




#estrutura do JSON
json_data=(cat <<EOF

   {
 	"Json $namedisk": {
	"$diskA": "dato"
	"$diskB": "dato"
	"$diskC": "dato"
	},
}
EOF
)

echo "$json_data"
