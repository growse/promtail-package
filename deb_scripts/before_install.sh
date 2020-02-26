#!/usr/bin/env sh
useradd -s /bin/false -M -G systemd-journal promtail || echo "Promtail user already exists"
usermod -g systemd-journal promtail
