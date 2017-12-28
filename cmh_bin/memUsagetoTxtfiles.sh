#!/bin/bash
cd /home/homeseer/logs
grep HSConsole MemUsage.log > memHSConsole.txt
grep HSBuddy   MemUsage.log > memHSbuddy.txt
grep ZWave     MemUsage.log > memZwave.txt
