set +e
# http://stackoverflow.com/questions/13400445/jenkins-build-script-exits-after-google-test-execution/13404608#13404608
# http://stackoverflow.com/questions/22814559/how-when-does-execute-shell-mark-a-build-as-failure-in-jenkins

cd bashtest
sudo ./prepare-tests.sh
SSHKEY="aws:kms:myAWSregion:123456789:key/myrandomstringwithnumbers123456567890"

if [ $SSHKEY = "aws:kms:"* ]; then
  SSHKEY=${SSHKEY##aws:kms:}
  SSHKEY=`python3 /kms/decryptkms.py $SSHKEY`
  if [[ $SSHKEY == "Invalid KMS key." ]]
  then
    echo "KMS key or KMS string is invalid."
    echo "KMS string must be formate: aws:kms:<BASE64STRING>"
    echo "KMS key must be usable via Host-IAM-Profile"
    exit 1
  fi

  if [ -f ~/.ssh/id_rsa ]
  then
    echo "The file ~/.ssh/id_rsa exists already. Won't be overridden." >&2
    exit 0
  else
    # assumption: file does not exists on new created docker container
    echo "The file ~/.ssh/id_rsa does not exists. Start writing private ssh key.".
    mkdir -p ~/.ssh
    printf "%s" "$SSHKEY" >> ~/.ssh/id_rsa
    chmod 0600 ~/.ssh/id_rsa
    echo "Private ssh key file written.".
    exit 0
  fi
fi
exit 1


if [ $? -eq 1 ]
then
  echo "^^^^^^^^^^^^ This is expected. Test succesfully passed." # ../convert-kms-private-ssh-key.sh executed w/ error.
  exit 0
else
  echo "^^^^^^^^^^^^ This is NOT expected." # ../convert-kms-private-ssh-key.sh executed w/o error.
  exit 1
fi
