#!/bin/sh

wait_for_service() {
  while ! timeout 1 bash -c "echo > /dev/tcp/vote/80"; do sleep 1; done
}

get_vote_count() {
  PGPASSWORD=postgres psql -h db -U postgres -d postgres -At -c "SELECT COALESCE(COUNT(id),0) FROM votes"
}

wait_for_service vote 80
wait_for_service result 4000
wait_for_service db 5432

VAR_A=$(get_vote_count)
[ -z "$VAR_A" ] && VAR_A=0
echo "Initial DB vote count: $VAR_A"

echo "Casting vote..."
curl -sS -X POST --data "vote=b" http://vote > /dev/null
sleep 10

VAR_B=$(get_vote_count)
[ -z "$VAR_B" ] && VAR_B=0
echo "New DB vote count: $VAR_B"

if [ "$VAR_B" -gt "$VAR_A" ]; then
  echo -e "\\e[42m--------------------------------"
  echo -e "\\e[92mTests passed! ($VAR_A -> $VAR_B)"
  echo -e "\\e[42m--------------------------------"
  exit 0
else
  echo -e "\\e[41m--------------------------------"
  echo -e "\\e[91mTests failed: Vote count did not increase"
  echo -e "\\e[41m--------------------------------"
  exit 1
fi



#while ! timeout 1 bash -c "echo > /dev/tcp/vote/80"; do
#    sleep 1
#done

#curl -sS -X POST --data "vote=b" http://vote > /dev/null
#sleep 10

#if node render.js http://result:4000 | grep -q '1 vote'; then

#  echo -e "\\e[42m------------"
#  echo -e "\\e[92mTests passed"
#  echo -e "\\e[42m------------"
#  exit 0
#else
#  echo -e "\\e[41m------------"
#  echo -e "\\e[91mTests failed"
#  echo -e "\\e[41m------------"
#  exit 1
#fi
