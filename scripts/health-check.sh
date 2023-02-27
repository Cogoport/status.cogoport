commit=true
origin=$(git remote get-url origin)
if [[ $origin == *statsig-io/statuspage* ]]
then
  commit=false
fi

KEYSARRAY=()
URLSARRAY=()

urlsConfig="public/urls.cfg"
echo "Reading $urlsConfig"
while read -r line
do
  echo "  $line"
  IFS='=' read -ra TOKENS <<< "$line"
  KEYSARRAY+=(${TOKENS[0]})
  URLSARRAY+=(${TOKENS[1]})
done < "$urlsConfig"

echo "***********************"
echo "Starting health checks with ${#KEYSARRAY[@]} configs:"

mkdir -p logs

for (( index=0; index < ${#KEYSARRAY[@]}; index++))
do
  key="${KEYSARRAY[index]}"
  url="${URLSARRAY[index]}"
  echo "  $key=$url"

  for i in 1 2 3 4; 
  do
    response=$(curl -o /dev/null -s -w '%{http_code} %{time_total}' --silent --output /dev/null $url)
    http_code=$(echo $response | cut -d ' ' -f 1)
    time_total=$(echo $response | cut -d ' ' -f 2)
    echo "    $http_code $time_total"
    if [ "$http_code" -eq 200 ] || [ "$http_code" -eq 202 ] || [ "$http_code" -eq 301 ] || [ "$http_code" -eq 302 ] || [ "$http_code" -eq 307 ]; then
      result="success"    
    else
      result="failed"
    fi
    if [ "$result" = "success" ]; then
      break
    fi
    sleep 5
  done
  dateTime=$(date +'%Y-%m-%d %H:%M')
  
  # Notify on teams channel
  mention="Prashant Paddune"
  email="prashant.paddune@cogoport.com"
  service="Admin"
  emoji="😨"
  get_post_data()
  {
      if [ "$key" = "frontend_admin" ]
      then
          # mention="Sanagapati Sai Tarun"
          # email="sanagapati.tarun@cogoport.com"
          service="Admin"
          emoji="😨"
      elif [ "$key" = "frontend_partner" ]
      then
          # mention="Shivom Mahar"
          # email="shivom.mahar@cogoport.com"
          service="Partner"
          emoji="😱"
      elif [ "$key" = "frontend_app" ]
      then
          # mention="Vikram Gudda"
          # email="vikram.gudda@cogoport.com"
          service="App"
          emoji="😭"
      elif [ "$key" = "backend_service" ]
      then
          # mention="Kanduri Jayanth Sri Ram"
          # email="kanduri.ram@cogoport.com"
          service="Backend"
          emoji="🤦‍♂️"
      fi
      echo '{
          "type": "message",
          "attachments": [
              {
                  "contentType": "application/vnd.microsoft.card.adaptive",
                  "content": {
                      "type": "AdaptiveCard",
                      "body": [
                          {
                              "type": "TextBlock",
                              "size": "Medium",
                              "weight": "Bolder",
                              "text": "Issue Message"
                          },
                          {
                              "type": "TextBlock",
                              "text": "Hi, <at>'$mention'</at>. '$service' service is Down 😨"
                          }
                      ],
                      "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
                      "version": "1.0",
                      "msteams": {
                          "width": "Full",
                          "entities": [
                              {
                                  "type": "mention",
                                  "text": "<at>'$mention'</at>",
                                  "mentioned": {
                                      "id": "'$email'",
                                      "name": "'$mention'"
                                  }
                              }
                          ]
                      }
                  }
              }
          ]
      }'
  }
  if [ "$result" = "success" ]
  then
    curl -H 'Content-Type: application/json' -d "$(get_post_data)" $TEAMS_WEBHOOK_URL &> /dev/null
  fi

 # Commit to repository
  if [[ $commit == true ]]
  then
    echo $dateTime, $result, $time_total >> "public/status/${key}_report.log"
    echo "$(tail -9000 public/status/${key}_report.log)" > "public/status/${key}_report.log"
  else
    echo "    $dateTime, $result, $time_total"
  fi
done

if [[ $commit == true ]]
then
  git config --global user.name 'sai-tarun'
  git config --global user.email 'sanagapati.tarun@cogoport.com'
  git add -A --force public/status/
  git commit -am '[Automated] Update Health Check Logs'
  git push
fi