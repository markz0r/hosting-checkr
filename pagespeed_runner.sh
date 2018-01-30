#!/bin/bash
#########################################################################################
#########################################################################################
CHECK_LOG="/var/www/speed/speed_check.log"
INDEX_FILE="/var/www/speed/index.html"
SOURCE_FILE="/root/hosting_checkr/20150813_domain_list.txt"
touch ${CHECK_LOG}

# args $1 - string to add
# args $2 - file to add to
add_line() {
  head --lines=-1 $2 > temp
  echo $1 >> temp
  tail --lines=1 $2 >> temp
  mv temp $2
}

initialise_index() {
  cols=6
  DATEN=$(date +%Y-%m-%d)
  echo "<head><title>SPEED_CHECKR</title></head>" > $INDEX_FILE
  echo "<html><head>
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.12.0/jquery.min.js"></script>
        <script src="theme.js"></script>
    <link rel="stylesheet" type="text/css" href="basic.css">
  </head><body><div class=\"results_box\"><div class=\"top_row\">$DATEN</div>" >> $INDEX_FILE
  echo "<div class=\"top_row\"># CREATE DATE: $DATEN</div>" >> $INDEX_FILE
  echo "<div class=\"top_row\"># LIST OF DOMAINS CHECKED: <a href="https://speed.mwclearning.com/speed_check.log">speed_check.log</a></div>" >> $INDEX_FILE
  echo "<div class=\"row_head\"><div class=\"th\">URL</div><div class=\"th\">CHECK DATE</div><div class=\"th\">TYPE</div><div class=\"th\">RESULTFILE</div><div class=\"th\">OVERALL SCORE</div></div>" >> $INDEX_FILE
  echo "</div></body></html>" >> $INDEX_FILE
}

if [ ! -f ${INDEX_FILE} ]; then
    initialise_index
fi

while true; do
  URL=$(head -$((${RANDOM} % `wc -l < ${SOURCE_FILE}` + 1)) ${SOURCE_FILE} | tail -1)
  if ! $(grep --quiet "$URL" $CHECK_LOG) && $(nslookup $URL > /dev/null) ; then
    if ! nslookup $URL > /dev/null; then
      echo "${iDate} - ${URL} - INVALID DNS" >> ${CHECK_LOG}
    else
      iDate=$(date +%Y-%m-%d)
      mob_result="/var/www/speed/results/${URL}.mob.${iDate}.txt"
      desk_result="/var/www/speed/results/${URL}.desk.${iDate}.txt"
      echo "${iDate} - ${URL}" >> ${CHECK_LOG}
      psi ${URL} --strategy desktop > ${desk_result}
      psi ${URL} --strategy mobile > ${mob_result}
      add_line "<div class=\"row\"><div class=\"td\"><a href="http://$URL" target="_blank">$URL</a></div><div class=\"td\">${iDate}</div><div class=\"td\">Desktop</div><div class=\"td\"><a href="results/${URL}.desk.${iDate}.txt">${URL}.desktop.out</a></div><div class=\"td\">$(awk '/Speed/ {print $2}' ${desk_result})</div></div>" $INDEX_FILE
      add_line "<div class=\"row\"><div class=\"td\"><a href="http://$URL" target="_blank">$URL</a></div><div class=\"td\">${iDate}</div><div class=\"td\">Mobile</div><div class=\"td\"><a href="results/${URL}.mob.${iDate}.txt">${URL}.mob.out</a></div><div class=\"td\">$(awk '/Speed/ {print $2}' ${mob_result})</div></div>" $INDEX_FILE
    fi
  fi
done
