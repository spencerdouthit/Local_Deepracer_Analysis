#!/usr/bin/env bash
set -euo pipefail

# Paths
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RACE_ENV="$DIR/race.env"
RUN_ENV="$DIR/run.env"
MODELS_FILE="$DIR/models_to_race.txt"

# sanity checks
for f in "$RACE_ENV" "$RUN_ENV" "$MODELS_FILE"; do
    if [[ ! -f "$f" ]]; then
        printf "Missing required file: %s\n" "$f" >&2
        exit 2
    fi
done

# helper: update or append a KEY=VALUE line in a file
update_kv_in_file() {
    local file=$1 key=$2 value=$3
    # escape for sed
    local esc
    esc=$(printf '%s' "$value" | sed -e 's/[\/&|]/\\&/g')
    if grep -q -E "^${key}=" "$file"; then
        sed -i -E "s|^${key}=.*|${key}=${esc}|" "$file"
    else
        printf '%s=%s\n' "$key" "$value" >> "$file"
    fi
}

# 1) copy "common" params from race.env into run.env (skip DR_LOCAL_S3_MODEL_PREFIX)
while IFS= read -r raw || [[ -n $raw ]]; do
    line="${raw%%#*}"
    line="${line%"${line##*[![:space:]]}"}"   # rtrim
    line="${line#"${line%%[![:space:]]*}"}"   # ltrim
    [[ -z "$line" ]] && continue
    # strip leading 'export ' if present
    if [[ "$line" == export* ]]; then
        line="${line#export }"
    fi
    # must be KEY=VALUE
    if [[ "$line" != *=* ]]; then
        continue
    fi
    key="${line%%=*}"
    value="${line#*=}"
    # skip model prefix here
    if [[ "$key" == "DR_LOCAL_S3_MODEL_PREFIX" ]]; then
        continue
    fi
    update_kv_in_file "$RUN_ENV" "$key" "$value"
done < "$RACE_ENV"

# 2) iterate models and run start/stop for each
while IFS= read -r raw || [[ -n $raw ]]; do
    model="${raw%%#*}"
    model="${model%"${model##*[![:space:]]}"}"
    model="${model#"${model%%[![:space:]]*}"}"
    [[ -z "$model" ]] && continue

    # set model in run.env
    update_kv_in_file "$RUN_ENV" "DR_LOCAL_S3_MODEL_PREFIX" "$model"

    # export variables from run.env into environment
    set -a
    # shellcheck disable=SC1090
    source "$RUN_ENV"
    set +a

    printf 'Starting evaluation for model: %s\n' "$model"
    if ! dr-start-evaluation; then
        printf 'dr-start-evaluation failed for %s\n' "$model" >&2
        continue
    fi

    # pause briefly between starting and stopping evaluation
    sleep 3

    printf 'Stopping evaluation for model: %s\n' "$model"
    if ! dr-stop-evaluation; then
        printf 'dr-stop-evaluation failed for %s\n' "$model" >&2
        continue
    fi

done < "$MODELS_FILE"