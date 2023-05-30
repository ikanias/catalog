#!/bin/sh

# Create config file for CRDA CLI
mkdir -p $HOME/.crda
touch $HOME/.crda/config.yaml

# Add params to CRDA CLI config
echo auth_token: ${AUTH_TOKEN} >> $HOME/.crda/config.yaml
echo crda_key: ${CRDA_KEY} >> $HOME/.crda/config.yaml
echo host: ${HOST} >> $HOME/.crda/config.yaml

if [ "$TELEMETRY" == "true" ]
then
crda config set consent_telemetry true
else
crda config set consent_telemetry false
fi

manifest_file_path="$1"
output_file_path="$2"
consumer="$3"

printf "Analysing the stack. Please wait..\n\n"

# Getting stack analysis report using CRDA CLI.
if [ -z "$consumer" ]
then
  result=$(crda analyse $manifest_file_path -j)
else
  result=$(crda analyse $manifest_file_path -j --client $consumer)
fi

exit_code=$?

if [ $exit_code == 1 ]
then
  # In case of failure save only exit code into output file.
  jq -n {} | \
  jq --arg exit_code "$exit_code" '. + {exit_code: $exit_code}' > \
  $output_file_path
else
  # In case of success print details from report into console
  printf "RedHat CodeReady Dependency Analysis task is being executed.\n"
  printf "=%.0s" {1..50}
  printf "\nRedHat CodeReady Dependency Analysis Report\n"
  printf "=%.0s" {1..50}
  printf "\n"
  printf "Total Scanned Dependencies            :  %s \n" $(jq -r .total_scanned_dependencies <<< $result)
  printf "Total Scanned Transitive Dependencies :  %s \n" $(jq -r .total_scanned_transitives <<< $result)
  printf "Total Vulnerabilities                 :  %s \n" $(jq -r .total_vulnerabilities <<< $result)
  printf "Direct Vulnerable Dependencies        :  %s \n" $(jq -r .direct_vulnerable_dependencies <<< $result)
  printf "Publicly Available Vulnerabilities    :  %s \n" $(jq -r .publicly_available_vulnerabilities <<< $result)
  printf "Vulnerabilities Unique to Snyk        :  %s \n" $(jq -r .vulnerabilities_unique_to_synk <<< $result)
  printf "Critical Vulnerabilities              :  %s \n" $(jq -r .critical_vulnerabilities <<< $result)
  printf "High Vulnerabilities                  :  %s \n" $(jq -r .high_vulnerabilities <<< $result)
  printf "Medium Vulnerabilities                :  %s \n" $(jq -r .medium_vulnerabilities <<< $result)
  printf "Low Vulnerabilities                   :  %s \n" $(jq -r .low_vulnerabilities <<< $result)
  printf "=%.0s" {1..50}
  printf "\n\nOpen this link to see detailed report:\n%s \n\n" $(jq -r .report_link <<< $result)

  # Save report along with exit code into output file.
  jq -n {} | \
  jq --argjson result "$result" '. + {report: $result}' | \
  jq --arg exit_code "$exit_code" '. + {exit_code: $exit_code}' > \
  $output_file_path
fi

printf "\nReport is saved into file: $output_file_path"
printf "\nTask is completed."
