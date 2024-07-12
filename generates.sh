#!/usr/bin/env bash

# Create directories for gh-pages and report-history if they don't exist
echo "Creating directories: ./${INPUT_GH_PAGES} and ./${INPUT_REPORT_HISTORY}"
mkdir -p ./${INPUT_GH_PAGES}
mkdir -p ./${INPUT_REPORT_HISTORY}

# Copy all contents from gh-pages to report-history
echo "Copying contents from ./${INPUT_GH_PAGES} to ./${INPUT_REPORT_HISTORY}"
cp -r ./${INPUT_GH_PAGES}/. ./${INPUT_REPORT_HISTORY}

# Get repository name from full input (owner/repo)
REPOSITORY_OWNER_SLASH_NAME=${INPUT_GITHUB_REPO}
REPOSITORY_NAME=${REPOSITORY_OWNER_SLASH_NAME##*/}
GITHUB_PAGES_WEBSITE_URL="https://${INPUT_GITHUB_REPO_OWNER}.github.io/${REPOSITORY_NAME}"

# If a subfolder is specified, adjust paths and URL
if [[ ${INPUT_SUBFOLDER} != '' ]]; then
  INPUT_REPORT_HISTORY="${INPUT_REPORT_HISTORY}/${INPUT_SUBFOLDER}"
  INPUT_GH_PAGES="${INPUT_GH_PAGES}/${INPUT_SUBFOLDER}"
  mkdir -p ./${INPUT_REPORT_HISTORY}
  GITHUB_PAGES_WEBSITE_URL="${GITHUB_PAGES_WEBSITE_URL}/${INPUT_SUBFOLDER}"
  echo "Adjusted paths for subfolder: INPUT_REPORT_HISTORY=${INPUT_REPORT_HISTORY}, INPUT_GH_PAGES=${INPUT_GH_PAGES}"
  echo "Updated GITHUB_PAGES_WEBSITE_URL: ${GITHUB_PAGES_WEBSITE_URL}"
fi

# Removing the folder with the smallest number
COUNT=$( (ls ./${INPUT_REPORT_HISTORY} | wc -l))
echo "Count folders in report-history: ${COUNT}"
echo "Keep reports count ${INPUT_KEEP_REPORTS}"
echo "Removing the folder with the smallest number..."
if ((COUNT == INPUT_KEEP_REPORTS)); then
  echo "If ${COUNT} == ${INPUT_KEEP_REPORTS}"
  ls -d ${INPUT_REPORT_HISTORY}/*/ | sort -V | head -n 1 | xargs rm -rv
elif ((COUNT > INPUT_KEEP_REPORTS)); then
  echo "elif ${COUNT} > ${INPUT_KEEP_REPORTS}"
  ls -d ${INPUT_REPORT_HISTORY}/*/ | sort -V | head -n -$((${INPUT_KEEP_REPORTS} - 1)) | xargs rm -rv
fi

# Copy INPUT_REPORT_FOLDER folder to INPUT_SUBFOLDER
if [ -d "${INPUT_REPORT_FOLDER}" ]; then
  echo "Copying ${INPUT_REPORT_FOLDER} to ${INPUT_SUBFOLDER}"
  cp -r "${INPUT_REPORT_FOLDER}" "${INPUT_SUBFOLDER}"
fi

# Copy contents of INPUT_SUBFOLDER to INPUT_REPORT_HISTORY/INPUT_GITHUB_RUN_NUM
if [ -d "${INPUT_SUBFOLDER}" ]; then
  echo "Copying contents of ${INPUT_SUBFOLDER} to ${INPUT_REPORT_HISTORY}/${INPUT_GITHUB_RUN_NUM}"
  cp -r ./${INPUT_SUBFOLDER}/. ./${INPUT_REPORT_HISTORY}/${INPUT_GITHUB_RUN_NUM}
else
  echo "Folder ${INPUT_SUBFOLDER} not found."
fi

# Rename report.html files to index.html
# find "$INPUT_REPORT_HISTORY" -type f -name 'report.html' -execdir mv {} index.html \;

# ls -R