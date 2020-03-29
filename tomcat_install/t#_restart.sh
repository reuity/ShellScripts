#!/bin/bash
sh ~/shell/tomkill.sh $appName
echo tail -200f $logDir/catalina.out
