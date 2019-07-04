set(WEBRTC_LAST_CHANGE_COMMAND python src/build/util/lastchange.py -o src/build/util/LASTCHANGE)
webrtc_command(
    NAME last-change
    COMMAND ${WEBRTC_LAST_CHANGE_COMMAND}
    WORKING_DIRECTORY ${WEBRTC_FOLDER}
    DEPENDS download
)

set(WEBRTC_ARCH amd64)

if(APPLE)
    set(CMAKE_OSX_DEPLOYMENT_TARGET 10.14)
    set(CMAKE_OSX_SYSROOT macosx10.14)
endif(APPLE)

set(WEBRTC_SYSROOT_COMMAND python build/linux/sysroot_scripts/install-sysroot.py --arch=${WEBRTC_ARCH})
webrtc_command(
    NAME sysroot
    COMMAND ${WEBRTC_SYSROOT_COMMAND}
    WORKING_DIRECTORY ${WEBRTC_FOLDER}/src
    DEPENDS download
)

set(WEBRTC_CONFIGURE_COMMAND gn gen out/${WEBRTC_BUILD_TYPE} --args=${WEBRTC_GEN_ARGS})
webrtc_command(
    NAME gen
    COMMAND ${WEBRTC_CONFIGURE_COMMAND}
    WORKING_DIRECTORY ${WEBRTC_FOLDER}/src
    DEPENDS sysroot
)

webrtc_command(
    NAME configure
    COMMAND echo configure complete
    DEPENDS gen last-change
)
