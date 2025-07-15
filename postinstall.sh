#!/bin/sh

launchdID="io.prometheus.node_exporter_swift"

if launchctl list "$launchdID"; then
	launchctl bootout system/"$launchdID"
fi

launchctl bootstrap system /Library/LaunchDaemons/"$launchdID".plist