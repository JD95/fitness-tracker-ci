SCRIPT_DIR=$(dirname "$0")
IMAGE_PATH="$(pwd)/result"
TAG="$1"
VAULT="$2"

nix build .#packages."x86_64-linux".docker

$SCRIPT_DIR/push-image-to-dockerhub.sh $IMAGE_PATH $TAG $VAULT
