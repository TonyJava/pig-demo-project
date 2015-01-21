#!/bin/bash

OS=centos7
PROJECTNAME=pig-demo-project
CONTAINER_NAME=${PROJECTNAME}-${USER}-$$

docker build -t ${PROJECTNAME} docker

if [ "$(uname -s)" == "Linux" ]; then
  USER_NAME=${SUDO_USER:=$USER}
  USER_ID=$(id -u $USER_NAME)
  GROUP_ID=$(id -g $USER_NAME)
else # boot2docker uid and gid
  USER_NAME=$USER
  USER_ID=1000
  GROUP_ID=50
fi

docker build -t ${PROJECTNAME}-${USER_NAME} - <<UserSpecificDocker
FROM ${PROJECTNAME}
RUN groupadd -g ${GROUP_ID} ${USER_NAME} || true
RUN useradd -g ${GROUP_ID} -u ${USER_ID} -k /root -m ${USER_NAME}
ENV HOME /home/${USER_NAME}
UserSpecificDocker

# Do NOT Map the real ~/.m2 directory !!!
[ -d ${PWD}/docker/_m2    ] || mkdir ${PWD}/docker/_m2
[ -d ${PWD}/docker/_gnupg ] || mkdir ${PWD}/docker/_gnupg

docker run --rm=true -t -i                                    \
           -u ${USER_NAME}                                    \
           -v ${PWD}:/home/${USER_NAME}/${PROJECTNAME}        \
           -v ${PWD}/docker/_m2:/home/${USER_NAME}/.m2        \
           -v ${PWD}/docker/_gnupg:/home/${USER_NAME}/.gnupg  \
           -w /home/${USER_NAME}/${PROJECTNAME}               \
           --name "${CONTAINER_NAME}"                         \
           ${PROJECTNAME}-${USER_NAME}                        \
           bash

exit 0
