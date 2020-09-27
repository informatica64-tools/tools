#!/bin/bash

# Author Zerxcool

#Colors

#Colours
greenColor="\e[0;32m\033[1m"
endColor="\033[0m\e[0m"
redColor="\e[0;31m\033[1m"
blueColor="\e[0;34m\033[1m"
yellowColor="\e[0;33m\033[1m"
purpleColor="\e[0;35m\033[1m"
turquoiseColor="\e[0;36m\033[1m"
grayColor="\e[0;37m\033[1m"

trap ctrl_c INT

function_ctrl(){
	echo -e "\n${redColor}[!] Existing...\n${endColor}"

	rm ut.t* 2>/dev/null; exit 1
}

# Help Panel
function helpPanel(){
	echo -e "\n${redColor}[!] Usage: ./btcAnalyzer${endColor}"
	for i in $(seq 1 80); do echo -ne "${redColor}-"; done; echo -ne "${endColor}"
	echo -e "\n\n\t${grayColor}[-e]${endColor}${yellowColor} Exploration mode${endColor}"
	echo -e "\t\t${purpleColor}unconfirmed_transactions${endColor}${yellowColor}:\t List unconfirmed transactions${endColor}"
	echo -e "\t\t${purpleColor}inspect${endColor}${yellowColor}:\t\t\t inspect a transaction's hash${endColor}"
	echo -e "\t\t${purpleColor}address${endColor}${yellowColor}:\t\t\t inspect a transaction's address${endColor}"
	echo -e "\n\t${grayColor}[-n]${endColor}${yellowColor} Limit the number of results${endColor}${blueColor} (Example: -n 10)${endColor}"
	echo -e "\n\t${grayColor}[-i]${endColor}${yellowColor} Provide the transaction identifier${endColor}${blueColor} (Example -i ba76ab9876b98ad5b98ad5b9a8db5ad98b5ad98b5a9d${endColor})"
    echo -e "\n\t${grayColour}[-a]${endColour}${yellowColour} Provide a transaction address${endColour}${blueColour} (Example: -a bad876fa876A876f8d6a861b9a8bd9a)${endColour}"
    echo -e "\n\t${grayColor}[-h]${endColor}${yellowColor} Show this help panel${endColor}\n"

	exit 1
}

# Variavles globales
unconfirmed_transactions="https://www.blockchain.com/es/btc/unconfirmed-transactions"
inspect_transactions="https://www.blockchain.com/es/btc/tx/"
inspect_address_url="https://www.blockchain.com/es/btc/address/"

function printTable(){

    local -r delimiter="${1}"
    local -r data="$(removeEmptyLines "${2}")"

    if [[ "${delimiter}" != '' && "$(isEmptyString "${data}")" = 'false' ]]
    then
        local -r numberOfLines="$(wc -l <<< "${data}")"

        if [[ "${numberOfLines}" -gt '0' ]]
        then
            local table=''
            local i=1

            for ((i = 1; i <= "${numberOfLines}"; i = i + 1))
            do
                local line=''
                line="$(sed "${i}q;d" <<< "${data}")"

                local numberOfColumns='0'
                numberOfColumns="$(awk -F "${delimiter}" '{print NF}' <<< "${line}")"

                if [[ "${i}" -eq '1' ]]
                then
                    table="${table}$(printf '%s#+' "$(repeatString '#+' "${numberOfColumns}")")"
                fi

                table="${table}\n"

                local j=1

                for ((j = 1; j <= "${numberOfColumns}"; j = j + 1))
                do
                    table="${table}$(printf '#| %s' "$(cut -d "${delimiter}" -f "${j}" <<< "${line}")")"
                done

                table="${table}#|\n"

                if [[ "${i}" -eq '1' ]] || [[ "${numberOfLines}" -gt '1' && "${i}" -eq "${numberOfLines}" ]]
                then
                    table="${table}$(printf '%s#+' "$(repeatString '#+' "${numberOfColumns}")")"
                fi
            done

            if [[ "$(isEmptyString "${table}")" = 'false' ]]
            then
                echo -e "${table}" | column -s '#' -t | awk '/^\+/{gsub(" ", "-", $0)}1'
            fi
        fi
    fi
}

function removeEmptyLines(){

    local -r content="${1}"
    echo -e "${content}" | sed '/^\s*$/d'
}

function repeatString(){

    local -r string="${1}"
    local -r numberToRepeat="${2}"

    if [[ "${string}" != '' && "${numberToRepeat}" =~ ^[1-9][0-9]*$ ]]
    then
        local -r result="$(printf "%${numberToRepeat}s")"
        echo -e "${result// /${string}}"
    fi
}

function isEmptyString(){

    local -r string="${1}"

    if [[ "$(trimString "${string}")" = '' ]]
    then
        echo 'true' && return 0
    fi

    echo 'false' && return 1
}

function trimString(){

    local -r string="${1}"
    sed 's,^[[:blank:]]*,,' <<< "${string}" | sed 's,[[:blank:]]*$,,'
}


function unconfirmedTransactions(){

	number_output=$1
	echo '' > ut.tmp

	while [ "$(cat ut.tmp | wc -l)" == "1" ]; do
		curl -s "$unconfirmed_transactions" | html2text > ut.tmp
	done

	hashes=$(cat ut.tmp | grep "Hash" -A 1 | grep -v -E "Hash|\--|Tiempo" | head -n $number_output)

	echo "Hash_Quantity_Bitcoin_Time" > ut.table

	for hash in $hashes; do
		echo "${hash}_$(cat ut.tmp | grep "$hash" -A 6 | tail -n 1)_$(cat ut.tmp | grep "$hash" -A 4 | tail -n 1)_$(cat ut.tmp | grep "$hash" -A 2 | tail -n 1)" >> ut.table
	done


    cat ut.table | tr '_' ' ' | awk '{print $2}' | grep -v "Quantity" | tr -d '$' | sed 's/\..*//g' | tr -d ',' > money

    money=0; cat money | while read money_in_line; do
        let money+=$money_in_line
        echo $money > money.tmp
    done;

    echo -n "Total quantity_" > amount.table
    echo "\$$(printf "%'.d\n" $(cat money.tmp))" >> amount.table

    if [ "$(cat ut.table | wc -l)" != "1" ]; then
        echo -ne "${greenColor}"
        printTable '_' "$(cat ut.table)"
        echo -ne "${endColor}"
        echo -ne "${blueColor}"
        printTable '_' "$(cat amount.table)"
        echo -ne "${endColor}"
        rm ut.* money* amount.table 2>/dev/null

        exit 0
    else
        rm ut.* money* amount.table 2>/dev/null
    fi

    rm ut.* money* amount.table 2>/dev/null
}

function inspectTransactions(){
    inspect_transactions=$1
}

parameter_counter=0; while getopts "e:n:i:h:" arg; do
	case $arg in
		e) exploration_mode=$OPTARG; let parameter_counter+=1;;
		n) number_output=$OPTARG; let parameter_counter+=1;;
        i) inspect_transactions=$OPTARG; let parameter_counter+=1;;
		h) helpPanel;;
	esac
done


if [ $parameter_counter -eq 0 ]; then
	helpPanel
else
	if [ "$(echo $exploration_mode)" == "unconfirmed_transactions" ]; then
		if [ ! "$number_output" ]; then
			number_output=100
			unconfirmedTransactions $number_output
		else
			unconfirmedTransactions $number_output
		fi
	elif [ "$(echo $exploration_mode)" == "inspect" ]; then
        inspectTransactions $inspect_transactions
    fi
fi

