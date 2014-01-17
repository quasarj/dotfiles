#!/usr/bin/bash


echo SET LINESIZE 20000 TRIM ON TRIMSPOOL ON > /tmp/sqltemp.in
echo SPOOL output.txt >> /tmp/sqltemp.in

cat $1 >> /tmp/sqltemp.in

echo SPOOL OFF >> /tmp/sqltemp.in
echo EXIT >> /tmp/sqltemp.in

sqlplus convmgr/u_pick_it@convtest < /tmp/sqltemp.in > /tmp/sqltemp.out
cat /tmp/sqltemp.out
