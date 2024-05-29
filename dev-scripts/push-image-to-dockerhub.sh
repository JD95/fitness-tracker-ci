IMAGE_PATH="$1"
TAG="$2"
VAULT="$3"
DEST="docker.io/jdwyer95/fitness-server:$TAG"
SECRETS="$(sops --decrypt $VAULT)"
PASS="$(echo "$SECRETS" | yq ".passwords.dockerhub")"

echo "logging into docker..."
skopeo login docker.io --username jdwyer95 --password $(eval echo $PASS)
echo "copying images..."
skopeo copy docker-archive://$IMAGE_PATH docker://$DEST
echo "done"
