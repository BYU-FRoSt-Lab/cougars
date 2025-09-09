# !/bin/bash

# Usage: ./copy_templates.sh source_dir dest_dir
src="templates"
dst="config"

# 1. Sync everything except the special files
rsync -av --ignore-existing \
    --exclude "fast_discovery_config_base_station.xml" \
    --exclude "fast_discovery_config_vehicle.xml" \
    "$src/" "$dst/"

# 2. Handle the special discovery config
base="$src/fast_discovery_config_base_station.xml"
veh="$src/fast_discovery_config_vehicle.xml"
special="$dst/fast_discovery_config.xml"

if [[ -f "$base" && -f "$veh" ]]; then
    if [[ ! -e "$special" ]]; then
        echo "Special case: fast_discovery_config.xml"
        echo "1) Use base_station version"
        echo "2) Use vehicle version"
        echo "3) Skip"
        read -rp "Choose [1-3]: " choice
        case "$choice" in
            1) cp "$base" "$special"; echo "Copied base_station → $special";;
            2) cp "$veh" "$special"; echo "Copied vehicle → $special";;
            3) echo "Skipped special file." ;;
            *) echo "Invalid choice, skipped." ;;
        esac
    else
        echo "Conflict detected for: fast_discovery_config.xml"
        echo "1) Keep destination version"
        echo "2) Overwrite with base_station"
        echo "3) Overwrite with vehicle"
        echo "4) Save both (append _copy)"
        echo "5) Skip"
        read -rp "Choose [1-5]: " choice
        case "$choice" in
            1) echo "Keeping destination version." ;;
            2) cp "$base" "$special"; echo "Overwritten with base_station." ;;
            3) cp "$veh" "$special"; echo "Overwritten with vehicle." ;;
            4) cp "$base" "${special%.*}_base_copy.${special##*.}"
               cp "$veh" "${special%.*}_vehicle_copy.${special##*.}"
               echo "Saved both (base_station & vehicle copies).";;
            5) echo "Skipped special file." ;;
            *) echo "Invalid choice, skipping." ;;
        esac
    fi
fi