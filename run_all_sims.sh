#!/bin/bash

export running_sims=$(
  xcrun simctl list devices | \
  grep "(Booted)"           | \
  grep -E -o -i "([0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12})"
)

export most_recently_built_app=$(
  find "$HOME/Library/Developer/Xcode/DerivedData" -type d -name '*.app' -print0 | \
  xargs -0 stat -f "%m %N"                                                       | \
  sort -rn                                                                       | \
  head -1                                                                        | \
  cut -f2- -d" "
)

export most_recently_built_app_bundle_id=$(/usr/libexec/PlistBuddy -c "Print :CFBundleIdentifier" "${most_recently_built_app}/Info.plist")

install_app_and_launch () {
    xcrun simctl install "$1" $most_recently_built_app
    xcrun simctl launch "$1" $most_recently_built_app_bundle_id
}
export -f install_app_and_launch

echo "$running_sims" | xargs -n 1 -P 8 -I {} bash -c 'install_app_and_launch "$@"' _ {}

