#/bin/bash
VERIFY_TLS="${TLS_VERIFY:-true}"

# login to push image registry
podman login --log-level=debug --tls-verify=$VERIFY_TLS -u ${PUSH_IMAGE_REGISTRY_UNAME} -p ${PUSH_IMAGE_REGISTRY_PWD} ${PUSH_IMAGE_REGISTRY}
if [ $? -ne 0 ]; then
   echo "Failed to login to docker registry ${PUSH_IMAGE_REGISTRY}"
   exit 1
fi
echo "logged into the registry ${PUSH_IMAGE_REGISTRY}"
# check if application img is already available in the registry
podman inspect docker://${PUSH_IMAGE_REGISTRY}/${PUSH_IMAGE_REPO}/${PUSH_IMAGE_NAME}:${PUSH_IMAGE_VERSION} > inspect.log 2>&1
error_count=$(grep -E "error|Error" -c inspect.log)
if [ $error_count -gt 0 ]; then
   touch app-deploy-flag.txt
fi
echo "inspection of image completed ${PUSH_IMAGE_REGISTRY}/${PUSH_IMAGE_REPO}/${PUSH_IMAGE_NAME}:${PUSH_IMAGE_VERSION}"

#build image
podman build --tls-verify=$VERIFY_TLS -t ${PUSH_IMAGE_REGISTRY}/${PUSH_IMAGE_REPO}/${PUSH_IMAGE_NAME}:${PUSH_IMAGE_VERSION} .
if [ $? -ne 0 ]; then
   echo "Failed to build application image ${PUSH_IMAGE_REGISTRY}/${PUSH_IMAGE_REPO}/${PUSH_IMAGE_NAME}:${PUSH_IMAGE_VERSION}"
   exit 1
fi
echo "image ${PUSH_IMAGE_REGISTRY}/${PUSH_IMAGE_REPO}/${PUSH_IMAGE_NAME}:${PUSH_IMAGE_VERSION} build completed" 
#push image
podman push --tls-verify=$VERIFY_TLS ${PUSH_IMAGE_REGISTRY}/${PUSH_IMAGE_REPO}/${PUSH_IMAGE_NAME}:${PUSH_IMAGE_VERSION}
if [ $? -ne 0 ]; then
   echo "Failed to push application image ${PUSH_IMAGE_REGISTRY}/${PUSH_IMAGE_REPO}/${PUSH_IMAGE_NAME}:${PUSH_IMAGE_VERSION}"
   exit 1
fi

echo "image ${PUSH_IMAGE_REGISTRY}/${PUSH_IMAGE_REPO}/${PUSH_IMAGE_NAME}:${PUSH_IMAGE_VERSION} push completed" 
