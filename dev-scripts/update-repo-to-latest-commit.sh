SCRIPT_DIR=$(dirname "$0")
REPO_NAME="fitness-tracker-web-backend"

LATEST_COMMIT="$(./$SCRIPT_DIR/get-latest-commit-for-repo.sh $REPO_NAME)"

./$SCRIPT_DIR/update-commit-for-repo.sh $REPO_NAME $LATEST_COMMIT
