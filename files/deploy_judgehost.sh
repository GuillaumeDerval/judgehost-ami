#!/bin/bash

if [ ${JUDGEHOST_COMMON_DEB} == 'latest-common' ]; then
  aws s3 cp --region=${JUDGEHOST_S3_REGION} s3://${JUDGEHOST_S3_BUCKET}/${JUDGEHOST_COMMON_DEB} /tmp/judgehost-latest-common
  JUDGEHOST_COMMON_DEB=$(cat /tmp/judgehost-latest-common)
fi
if [ ${JUDGEHOST_JUDGEHOST_DEB} == 'latest-judgehost' ]; then
  aws s3 cp --region=${JUDGEHOST_S3_REGION} s3://${JUDGEHOST_S3_BUCKET}/${JUDGEHOST_JUDGEHOST_DEB} /tmp/judgehost-latest-judgehost
  JUDGEHOST_JUDGEHOST_DEB=$(cat /tmp/judgehost-latest-judgehost)
fi

aws s3 cp --region=${JUDGEHOST_S3_REGION} s3://${JUDGEHOST_S3_BUCKET}/${JUDGEHOST_COMMON_DEB} "/tmp/${JUDGEHOST_COMMON_DEB}"
aws s3 cp --region=${JUDGEHOST_S3_REGION} s3://${JUDGEHOST_S3_BUCKET}/${JUDGEHOST_JUDGEHOST_DEB} "/tmp/${JUDGEHOST_JUDGEHOST_DEB}"

dpkg --force -i /tmp/${JUDGEHOST_COMMON_DEB}
dpkg --force -i /tmp/${JUDGEHOST_JUDGEHOST_DEB}

rm -f /tmp/${JUDGEHOST_COMMON_DEB}
rm -f /tmp/${JUDGEHOST_JUDGEHOST_DEB}

# Remove old init scripts
/etc/init.d/domjudge-judgehost stop
update-rc.d -f domjudge-judgehost remove
rm -f /etc/init.d/domjudge-judgehost

cat >/etc/domjudge/restapi.secret <<EOF
default $JUDGEHOST_ENDPOINT judgehost $JUDGEHOSTPASS
EOF

# enable/start the new service
systemctl enable judgedaemons
systemctl start judgedaemons
