SCRIPT_DIR=$(dirname "$0")
VAULT="$1"

$SCRIPT_DIR/update-repo-to-latest-commit.sh flake.nix fitness-tracker-web-backend
$SCRIPT_DIR/update-repo-to-latest-commit.sh flake.nix fitness-tracker-web-frontend

if git diff --quiet -- flake.nix; then
  echo "Changes detected"
  git add flake.nix
  git commit -m "Updates repo commits to latest (automated)"
  NEW_TAG="$(git log -1 --format="%H")"
  echo "New tag: $NEW_TAG"
  $SCRIPT_DIR/manual-push-image-to-dockerhub.sh $NEW_TAG $VAULT
  DEPLOYMENT_FILE="kubernetes/fitness-tracker/deployment.dhall"
  $SCRIPT_DIR/update-image-tag.sh fitness-server $NEW_TAG $DEPLOYMENT_FILE
  git add $DEPLOYMENT_FILE
  git commit -m "Updates tag for fitness-server (automated)" 
  git push
else
  echo "No changes detected"
fi  
