#!/bin/bash
set -e
set -o pipefail
export AWS_DEFAULT_REGION=eu-west-2

# Terraform caching
mkdir -p "${HOME}/.terraform.d/plugin-cache"

COMMANDS=("init" "get" "validate" "fmt")

# List modules based on presence of *.tf file
MODULES=$(find . -maxdepth 2 -type f -name '*.tf' | sed -r 's|/[^/]+$||' | sort | uniq)

for module in ${MODULES}
do
	(
		set -e
		set -o pipefail
		echo -e " \e[33m\u29C1\e[39m  Module: ${module}"
		cd "${module}"

		for command in "${COMMANDS[@]}"
		do
			echo -e "    \e[33m\u25B6\e[39m terraform ${command}"
			if [ "${command}" = "init" ]; then
				TF_PLUGIN_CACHE_DIR="${HOME}/.terraform.d/plugin-cache" terraform init -backend=false 2>&1 | sed 's/^/      |  /'
			elif [ "${command}" = "get" ]; then
				TF_PLUGIN_CACHE_DIR="${HOME}/.terraform.d/plugin-cache" terraform get -update 2>&1 | sed 's/^/      |  /'
			else
				TF_PLUGIN_CACHE_DIR="${HOME}/.terraform.d/plugin-cache" terraform "${command}" 2>&1 | sed 's/^/      |  /'
			fi

			echo -e "    \e[32m\xE2\x9C\x94\e[39m terraform ${command}"
		done
	)
done

echo -e " \e[32m\xE2\x9C\x94  Build Complete!\e[39m"
