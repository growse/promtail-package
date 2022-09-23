#!/usr/bin/env sh

userdel promtail || echo "Promtail user already removed"
groupdel promtail || echo "Promtail group already removed"