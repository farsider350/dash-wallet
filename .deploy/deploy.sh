#!/bin/bash

if [ "${TRAVIS_TAG:0:4}" = "NMA-" ] || [ "${TRAVIS_TAG:0:4}" = "dpl-" ]; then

  cd "$TRAVIS_BUILD_DIR" || exit

  eval "$(ssh-agent -s)" # Start ssh-agent cache
  chmod 600 .deploy/id_rsa # Allow read access to the private key
  ssh-add .deploy/id_rsa # Add the private key to SSH

  echo -e "Let's deploy it!"
  echo "TRAVIS_TAG: $TRAVIS_TAG"
#  ls -l wallet/build/outputs/apk/_testNet3/debug/
  git clone git@github.com:dash-mobile-team/dash-wallet-staging.git
  DEPLOY_DIR=dash-wallet-staging/"$TRAVIS_TAG"
  mkdir -p "$DEPLOY_DIR"
  cp wallet/build/outputs/apk/_testNet3/debug/dash-wallet-_testNet3-debug.apk "$DEPLOY_DIR"/dash-wallet-_testNet3-debug.apk
  cp wallet/build/outputs/apk/prod/debug/dash-wallet-prod-debug.apk "$DEPLOY_DIR"/dash-wallet-prod-debug.apk
#  cp wallet/build/outputs/apk/_testNet3/debug/dash-wallet-_testNet3-debug.apk dash-wallet-staging/"$TRAVIS_TAG"/dash-wallet-_testNet3-debug.apk
  README="$DEPLOY_DIR"/README.md
  if [ "${TRAVIS_TAG:0:4}" = "NMA-" ]; then
    printf 'https://dashpay.atlassian.net/browse/%s\n\n' "$TRAVIS_TAG" > "$README"
  fi
  git show "$TRAVIS_TAG" | grep -B20 "diff" >> "$README"
  head -n -1 "$README" > temp.txt ; mv temp.txt "$README"

  cd dash-wallet-staging || exit
  git add .
  git commit -m "Travis CI deploy $TRAVIS_TAG"
  git push origin master

  # clean up the mess
  cd "$TRAVIS_BUILD_DIR" || exit
  rm -rf dash-wallet-staging
  rm -rf "$TRAVIS_BUILD_DIR"/app/build/outputs
  echo "deleting tag $TRAVIS_TAG"
#  git tag -d "$TRAVIS_TAG"
  git push -q https://"$PERSONAL_ACCESS_TOKEN"@github.com/dashevo/dash-wallet --delete "refs/tags/$TRAVIS_TAG"
else
  echo "Only tags "
fi
echo "Deploy done"