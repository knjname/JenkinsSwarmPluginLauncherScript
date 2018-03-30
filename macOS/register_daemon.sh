#!/bin/bash

set -x

export dirpath="$( cd $(dirname "$0"); cd ../; pwd -P )"
export mustBeExisting="${dirpath}/build.gradle"
export plistDest="$(echo ~/Library/LaunchAgents/jenkins-slave.plist)"
export label="jenkins-slave"

if ! [ -f "${mustBeExisting}" ] ; then
    echo "${mustBeExisting} is not found." >&2
    exit 1
fi

echo "Put launchd file to ${plistDest}"
cat <<EOF > "${plistDest}"
<?xml version="1.0" ?>

<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">

<plist version="1.0">
<dict>

    <key>Label</key>
    <string>${label}</string>

    <key>ProgramArguments</key>
    <array>
        <string>bash</string>
        <string>-l</string>
        <string>-c</string>
        <string>./gradlew</string>
    </array>

    <key>KeepAlive</key>
    <true/>

    <key>Debug</key>
    <true/>
    <key>StandardOutPath</key>
    <string>${dirpath}/${label}.out.log</string>
    <key>StandardErrorPath</key>
    <string>${dirpath}/${label}.err.log</string>

    <key>WorkingDirectory</key>
    <string>${dirpath}</string>

</dict>
</plist>
EOF

echo "Activate it."
launchctl stop "${label}"
launchctl unload "${plistDest}"
launchctl load "${plistDest}"
launchctl start "${label}"
