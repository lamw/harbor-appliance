#!/bin/bash

OUTPUT_PATH="../output-vmware-iso"
OVF_PATH=$(find ${OUTPUT_PATH} -type f -iname ${PHOTON_APPLIANCE_NAME}.ovf -exec dirname "{}" \;)

# Move ovf files in to a subdirectory of OUTPUT_PATH if not already
if [ "${OUTPUT_PATH}" = "${OVF_PATH}" ]; then
    mkdir ${OUTPUT_PATH}/${PHOTON_APPLIANCE_NAME}
    mv ${OUTPUT_PATH}/*.* ${OUTPUT_PATH}/${PHOTON_APPLIANCE_NAME}
    OVF_PATH=${OUTPUT_PATH}/${PHOTON_APPLIANCE_NAME}
fi

rm -f ${OVF_PATH}/${PHOTON_APPLIANCE_NAME}.mf

sed "s/{{VERSION}}/${PHOTON_VERSION}/g" ${PHOTON_OVF_TEMPLATE} > photon.xml

if [ "$(uname)" == "Darwin" ]; then
    sed -i .bak1 's/<VirtualHardwareSection>/<VirtualHardwareSection ovf:transport="com.vmware.guestInfo">/g' ${OVF_PATH}/${PHOTON_APPLIANCE_NAME}.ovf
    sed -i .bak2 "/    <\/vmw:BootOrderSection>/ r photon.xml" ${OVF_PATH}/${PHOTON_APPLIANCE_NAME}.ovf
    sed -i .bak3 '/^      <vmw:ExtraConfig ovf:required="false" vmw:key="nvram".*$/d' ${OVF_PATH}/${PHOTON_APPLIANCE_NAME}.ovf
    sed -i .bak4 "/^    <File ovf:href=\"${PHOTON_APPLIANCE_NAME}-file1.nvram\".*$/d" ${OVF_PATH}/${PHOTON_APPLIANCE_NAME}.ovf
    sed -i .bak5 '/vmw:ExtraConfig.*/d' ${OVF_PATH}/${PHOTON_APPLIANCE_NAME}.ovf
else
    sed -i 's/<VirtualHardwareSection>/<VirtualHardwareSection ovf:transport="com.vmware.guestInfo">/g' ${OVF_PATH}/${PHOTON_APPLIANCE_NAME}.ovf
    sed -i "/    <\/vmw:BootOrderSection>/ r photon.xml" ${OVF_PATH}/${PHOTON_APPLIANCE_NAME}.ovf
    sed -i '/^      <vmw:ExtraConfig ovf:required="false" vmw:key="nvram".*$/d' ${OVF_PATH}/${PHOTON_APPLIANCE_NAME}.ovf
    sed -i "/^    <File ovf:href=\"${PHOTON_APPLIANCE_NAME}-file1.nvram\".*$/d" ${OVF_PATH}/${PHOTON_APPLIANCE_NAME}.ovf
    sed -i '/vmw:ExtraConfig.*/d' ${OVF_PATH}/${PHOTON_APPLIANCE_NAME}.ovf
fi

ovftool ${OVF_PATH}/${PHOTON_APPLIANCE_NAME}.ovf ${OUTPUT_PATH}/${FINAL_PHOTON_APPLIANCE_NAME}.ova
rm -rf ${OVF_PATH}
rm -f photon.xml