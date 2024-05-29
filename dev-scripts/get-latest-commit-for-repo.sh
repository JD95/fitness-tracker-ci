REMOTE="github.com"
USER="JD95"
REPO_NAME="$1"

TMP_DIR=$(mktemp -d)

git clone git@$REMOTE:$USER/$REPO_NAME.git "$TMP_DIR/$REPO_NAME" > /dev/null 2>&1

git -C "$TMP_DIR/$REPO_NAME" rev-parse HEAD 

rm -rf $TMP_DIR > /dev/null 2>&1
