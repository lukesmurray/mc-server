#!/bin/sh

# function to determine the number of players
number_of_players() {
python - << END
from mcstatus import MinecraftServer
import sys

server = MinecraftServer("localhost")

try:
    print(server.status().players.online)
except Exception:
    print(-1)
END
}

PLAYER_COUNT=$(number_of_players)

if [ "$PLAYER_COUNT" -ne -1 ]; then
    if [ "$PLAYER_COUNT" -eq 0 ]; then
        echo "Waiting for players to come back in 12m, otherwise shutdown"
        sleep 12m
        PLAYER_COUNT=$(number_of_players)
        if [ "$PLAYER_COUNT" -eq 0 ]
        then
            echo "Will shutdown"
            sudo /sbin/shutdown -P +1
        fi
    fi
else
    echo "Server has crashed, briefly waiting before trying again"
    sleep 5m
    PLAYER_COUNT=$(number_of_players)
    if [ "$PLAYER_COUNT" -eq -1 ]; then
        echo "Server has crashed shutting down"
        sudo /sbin/shutdown -P +1
    fi
fi
