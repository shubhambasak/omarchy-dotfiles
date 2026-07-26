#!/bin/bash

# Find coretemp dynamically
BASE=$(for hwmon in /sys/class/hwmon/hwmon*; do
  if grep -q "coretemp" "$hwmon/name" 2>/dev/null; then
    echo "$hwmon"
    break
  fi
done)

# If not found, fail safely
if [ -z "$BASE" ]; then
  echo '{"text":"","tooltip":"Temp sensor not found"}'
  exit 0
fi

# Read temps
temps=()
for i in 2 3 4 5; do
  file="$BASE/temp${i}_input"
  if [ -f "$file" ]; then
    temps+=($(cat "$file"))
  fi
done

# Avoid division by zero
if [ ${#temps[@]} -eq 0 ]; then
  echo '{"text":"","tooltip":"No core temps"}'
  exit 0
fi

# Calculate average
sum=0
for t in "${temps[@]}"; do
  sum=$((sum + t))
done

avg=$((sum / ${#temps[@]} / 1000))

echo "   $avg°C "
