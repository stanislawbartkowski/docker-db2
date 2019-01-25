#!/bin/bash

modifydb2nodes() {
  local -r HOST=`hostname -f`
  echo "0 $HOST 0" >/home/$DB2USER/sqllib/db2nodes.cfg
}

startdb2() {
  su - $DB2USER -c db2start
}

main() {
   modifydb2nodes
   startdb2
   sleep infinity
}

main
