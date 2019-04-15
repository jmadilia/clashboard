#!/usr/bin/env bash

retrieval_date=$(date +%Y%m%d)
retrieval_day=$(date +%d)

url="https://aact.ctti-clinicaltrials.org/static/static_db_copies/daily/${retrieval_date}_clinical_trials.zip"
response=$(curl -sL -w "%{http_code}" -I ${url} -o /dev/null)

echo "Searching for most recent data..."
while true; do
    if [[ ${response} != '200' ]]; then
        if !(( ${retrieval_day} >= 10 )); then
            retrieval_day="$((0${retrieval_day:1:1} - 1))"
        fi
        retrieval_day=$((${retrieval_day} - 1))
        retrieval_date=$(date +%Y%m${retrieval_day})
        url="https://aact.ctti-clinicaltrials.org/static/static_db_copies/daily/${retrieval_date}_clinical_trials.zip"
        response=$(curl -sL -w "%{http_code}" -I ${url} -o /dev/null)
        continue
    else
        echo "Most recent data found for ${retrieval_date}."
        results=$(wget ${url})
        break
    fi
done

unzip -p ${retrieval_date}_clinical_trials >postgres_data.dmp
