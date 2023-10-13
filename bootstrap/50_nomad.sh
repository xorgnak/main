#!/bin/bash

sudo su -c "echo '(screen -Dr || screen)' > /usr/bin/nomad";

echo "[NOMAD] installed."
