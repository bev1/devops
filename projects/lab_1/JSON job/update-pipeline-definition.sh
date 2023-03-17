#!/bin/bash

# Validate if JQ is installed
if ! [ -x "$(command -v jq)" ]; then
  echo "JQ is not installed. Please install it before running this script."
  echo "For example, on Debian-based systems, run: sudo apt-get install jq"
  exit 1
fi

# Parse command line arguments
if [ "$#" -lt 2 ]; then
  echo "Usage: $0 <pipeline-definition-file> [--configuration <value>] [--owner <value>] [--branch <value>] [--poll-for-source-changes <value>]"
  exit 1
fi

pipeline_definition_file=$1
shift
while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    --configuration)
      configuration="$2"
      shift
      shift
      ;;
    --owner)
      owner="$2"
      shift
      shift
      ;;
    --branch)
      branch="$2"
      shift
      shift
      ;;
    --poll-for-source-changes)
      poll_for_source_changes="$2"
      shift
      shift
      ;;
    *)
      echo "Unknown option: $key"
      exit 1
      ;;
  esac
done

# Validate required properties in pipeline definition
if ! jq -e '.pipeline.name and .pipeline.stages and .pipeline.version' "$pipeline_definition_file" >/dev/null; then
  echo "Invalid pipeline definition. The name, stages, and version properties are required."
  exit 1
fi

# Increment pipeline version
jq '.pipeline.version += 1' "$pipeline_definition_file" >tmp.json

# Set Source action properties
jq --arg branch "${branch:-main}" \
   --arg owner "$owner" \
   --argjson poll_for_source_changes "${poll_for_source_changes:-false}" \
   '.pipeline.stages[0].actions[0].configuration.Branch = $branch |
    .pipeline.stages[0].actions[0].configuration.Owner = $owner |
    .pipeline.stages[0].actions[0].configuration.PollForSourceChanges = $poll_for_source_changes' tmp.json >"$pipeline_definition_file"

# Set EnvironmentVariables property in all actions
jq --argjson build_configuration "{\"name\":\"BUILD_CONFIGURATION\",\"value\":\"$configuration\",\"type\":\"PLAINTEXT\"}" \
   '.pipeline.stages[].actions[].configuration.EnvironmentVariables = [$build_configuration]' "$pipeline_definition_file" >tmp.json

# Remove metadata property
jq 'del(.metadata)' tmp.json >"$pipeline_definition_file"

# Generate new filename with date
filename="pipeline-$(date +%Y-%m-%d).json"
cp "$pipeline_definition_file" "$filename"

# Clean up temporary file
rm tmp.json

echo "Pipeline definition updated and saved to $filename"
