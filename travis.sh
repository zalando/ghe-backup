set +e
# http://stackoverflow.com/questions/13400445/jenkins-build-script-exits-after-google-test-execution/13404608#13404608
# http://stackoverflow.com/questions/22814559/how-when-does-execute-shell-mark-a-build-as-failure-in-jenkins

#virtualenv --no-site-packages --distribute -p /usr/bin/python3 ~/.ghebackup_venv
#. ~/.ghebackup_venv/bin/activate
#pip install boto3 --upgrade
#pip install pyyaml --upgrade
#pip install requests --upgrade

cd bashtest
sudo ./prepare-tests.sh
sudo chmod 0755 /kms/parseyaml.py
../convert-kms-private-ssh-key.sh

if [ $? -eq 1 ]
then
  echo "^^^^^^^^^^^^ This is expected. Test succesfully passed." # ../convert-kms-private-ssh-key.sh executed w/ error.
  exit 0
else
  echo "^^^^^^^^^^^^ This is NOT expected." # ../convert-kms-private-ssh-key.sh executed w/o error.
  exit 1
fi
