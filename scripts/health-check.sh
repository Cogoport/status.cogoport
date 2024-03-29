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

  for i in 1 2 3; 
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
  mention1="Rudraprasad Das"
  email1="rudra@cogoport.com"
  mention2="Prashant Paddune"
  email2="prashant.paddune@cogoport.com"
  mention3="Harshit Soni"
  email3="harshit.soni@cogoport.com"
  mention4="Riyaz Khan"
  email4="riyaz.khan@cogoport.com"
  mention5="Shivanshi Gupta"
  email5="shivanshi.gupta@cogoport.com"

  mention6="Aman Kumar Jha"
  email6="aman.jha@cogoport.com"
  mention7="Sanmit vartak"
  email7="sanmit.vartak@cogoport.com"

  service="Admin Frontend"
  emoji="😨"
  get_post_data()
  {
      if [ "$key" = "frontend_admin" ]
      then
          service="Admin Frontend"
          emoji="😨"
      elif [ "$key" = "frontend_partner" ]
      then
          service="Partner Frontend"
          emoji="😱"
      elif [ "$key" = "frontend_app" ]
      then
          service="App Frontend"
          emoji="😭"
      elif [ "$key" = "backend_service" ]
      then
          service="Backend Service"
          emoji="🤦‍♂️"
      elif [ "$key" = "frontend_public" ]
      then
          service="Frontend Public"
          emoji="😕"
      elif [ "$key" = "frontend_cms" ]
      then
          service="Frontend CMS"
          emoji="🙊"
      fi

      if [ "$key" = "frontend_admin" ] || [ "$key" = "frontend_partner" ] || [ "$key" = "frontend_app" ] || [ "$key" = "frontend_cms" ] || [ "$key" = "frontend_public" ]; then
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
                                "text": "Status"
                            },
                            {
                                "type": "TextBlock",
                                "text": "Hi, <at>'$mention1'</at>, <at>'$mention2'</at>, <at>'$mention3'</at>, <at>'$mention4'</at>, <at>'$mention5'</at>."
                            },
                            {
                                "type": "TextBlock",
                                "text": "'$service' is down '$emoji'!!"
                            }
                        ],
                        "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
                        "version": "1.0",
                        "msteams": {
                            "width": "Full",
                            "entities": [
                                {
                                    "type": "mention",
                                    "text": "<at>'$mention1'</at>",
                                    "mentioned": {
                                        "id": "'$email1'",
                                        "name": "'$mention1'"
                                    }
                                },
                                {
                                    "type": "mention",
                                    "text": "<at>'$mention2'</at>",
                                    "mentioned": {
                                        "id": "'$email2'",
                                        "name": "'$mention2'"
                                    }
                                },
                                {
                                    "type": "mention",
                                    "text": "<at>'$mention3'</at>",
                                    "mentioned": {
                                        "id": "'$email3'",
                                        "name": "'$mention3'"
                                    }
                                },
                                {
                                    "type": "mention",
                                    "text": "<at>'$mention4'</at>",
                                    "mentioned": {
                                        "id": "'$email4'",
                                        "name": "'$mention4'"
                                    }
                                },
                                {
                                    "type": "mention",
                                    "text": "<at>'$mention5'</at>",
                                    "mentioned": {
                                        "id": "'$email5'",
                                        "name": "'$mention5'"
                                    }
                                }
                            ]
                        }
                    }
                }
            ]
        }'
      else 
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
                                "text": "Status"
                            },
                            {
                                "type": "TextBlock",
                                "text": "Hi, <at>'$mention6'</at>, <at>'$mention7'</at>."
                            },
                            {
                                "type": "TextBlock",
                                "text": "'$service' is down '$emoji'!!"
                            }
                        ],
                        "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
                        "version": "1.0",
                        "msteams": {
                            "width": "Full",
                            "entities": [
                                {
                                    "type": "mention",
                                    "text": "<at>'$mention6'</at>",
                                    "mentioned": {
                                        "id": "'$email6'",
                                        "name": "'$mention6'"
                                    }
                                },
                                {
                                    "type": "mention",
                                    "text": "<at>'$mention7'</at>",
                                    "mentioned": {
                                        "id": "'$email7'",
                                        "name": "'$mention7'"
                                    }
                                },
                            ]
                        }
                    }
                }
            ]
        }'
        fi
  }
  if [ "$result" = "failed" ]
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