#!/usr/bin/env sh
useradd -s /bin/false -M -G systemd-journal promtail || echo "Couldn't add promtail user"
usermod -g systemd-journal promtail
