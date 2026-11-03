# Mario Party Win Probability Tool
<img width="772" height="635" alt="Screenshot 2026-11-01 161123" src="https://github.com/user-attachments/assets/1ec64e30-5768-47e3-90ef-3fb3dc8fa97a" />

Given a player's star and coin counts relative to other players along with the turns remaining in the game, attempt to track a player's probability of winning.

## About
A Mario Party player makes a multitude of choices of the course of a game. The Win Probability tool attempts to help a player by making data-driven decisions. These insights can be instrumental in boosting a player's chances of winning.

This repository contains a Lua script used during data acquisition to track player and game stats and another Lua script used for the live overlay of the turn number and each player's star count, coin count, and win probability. These scripts contain all the addresses for player star and coins counts, final star counts, and the turn number. [Dolphin Lua Core](https://github.com/SwareJonge/Dolphin-Lua-Core) is a custom Dolphin Emulator build that allows Lua scripts to create on-screen info displays. The csv files containing 100 games worth of statistics and the final star and coin counts with the winning player number can be found in the Data folder.

## How to Run
NOTE: You will need an iso file of Mario Party 7 on the Gamecube to run on Dolphin. Piracy is lame. Obtain a copy of the game and [rip it](https://dolphin-emu.org/docs/guides/ripping-games/). 

1) Download Dolphin Lua Core
2) Import iso file of game to Dolphin
3) Start a Party Cruise with 15 turns
4) Load the liveWP.lua script. This script should be in Sys>Scripts in the Dolphin folder saved on your computer
5) (Optional) Run the [Dolphin Memory Engine](https://github.com/aldelaro5/dolphin-memory-engine) 
