#!/bin/bash
echo "=== Checking DNS resolution ==="
flyctl ssh console -a go-game --machine d8d1630be10d18 -C "nslookup go-game.internal"

echo ""
echo "=== Checking node connectivity ==="
flyctl ssh console -a go-game --machine d8d1630be10d18 -C "/app/bin/go_game rpc ':net_adm.names()'"
