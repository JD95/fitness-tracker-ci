SCRIPT_DIR=$(dirname "$0")
TARGET_FILE="$1"
REPO_NAME="$2"

LATEST_COMMIT="$(./$SCRIPT_DIR/get-latest-commit-for-repo.sh $REPO_NAME)"

echo "Updating $REPO_NAME to commit '$LATEST_COMMIT'"

./$SCRIPT_DIR/update-commit-for-repo.sh $REPO_NAME $LATEST_COMMIT $TARGET_FILE 
