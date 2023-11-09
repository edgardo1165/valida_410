#!/bin/bash
URLS_FILE="urls.txt"
OUTPUT_FILE="urls_and_status.txt"

count=0

if [ $# -eq 1 ]; then
  URLS_FILE=$1
  OUTPUT_FILE="$1.out"
fi

echo $URLS_FILE $OUTPUT_FILE

if [ -e "$OUTPUT_FILE" ]; then
  rm "$OUTPUT_FILE"
fi

while IFS= read -r url
do
    if [[ $url != "https"* ]]; then
       url=https://"$url"
    fi
    status_code=$(curl -s -o /dev/null -w "%{http_code}" -I "$url")

    ((count++))

    #if [ "$status_code" -ne 410 -a "$status_code" -ne 404 -a "$status_code" -ne 301 ]; then
    #    echo "$url" >> "$OUTPUT_FILE"
    #fi
    if [ "$status_code" -eq 301 ]; then
        echo "$url" >> "301_$OUTPUT_FILE"
    fi
    if [ "$status_code" -eq 410 ]; then
        echo "$url" >> "410_$OUTPUT_FILE"
    fi
    if [ "$status_code" -eq 404 ]; then
        echo "$url" >> "404_$OUTPUT_FILE"
    fi

    if [ $count -eq 500 ]; then
        echo "Rastreadas 500 URLs. Esperando 30 segundos para evitar saturar la api."
        sleep 30
        count=0
    fi
done < "$URLS_FILE"

echo "Proceso completado. Las URLs y sus códigos de estado se han guardado en $OUTPUT_FILE."
