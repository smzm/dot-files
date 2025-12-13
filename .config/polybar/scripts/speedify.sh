#!/bin/bash
# speedify_cli headercompression on
# speedify_cli encryption on 
# speedify_cli esni on 
# speedify_cli mode speed 
# speedify_cli streaming domains add youtube.com
# speedify_cli streamingbypass service disable
# speedify_cli streamingbypass domains add downloadly.ir
# speedify_cli jumbo on
# speedify_cli packetaggr on 
# speedify_cli transport udp 
# speedify_cli dns 1.1.1.1

state=$(speedify_cli state | jq -r .state)

speedify_print() {
  if [ "$state" == "CONNECTED" ] ; then
    currentServer=$(speedify_cli show currentserver | jq -r .friendlyName)
    echo "   $currentServer"
  elif [ "$state" == "LOGGED_IN" ] ; then
    echo "   NOT CONNECTED"
  fi
}

speedify_toggle() {
  if [ "$state" == "CONNECTED" ] ; then
    speedify_cli disconnect
  elif [ "$state" == "LOGGED_IN" ] ; then
    echo "CONNECTING..."
    speedify_cli connect "$1"
  fi
}

case "$1" in
    --toggle)
        speedify_toggle "last"
        ;;
    --us)
        speedify_toggle "us-nyc-69"
        ;;
    --no) 
        speedify_toggle "no-oslo-2"
        ;;
    --closest)
        speedify_toggle "closest"
        ;;
    *)
        speedify_print
        ;;
esac

