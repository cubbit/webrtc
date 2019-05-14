set(WEBRTC_BUILD_COMMAND "ninja ${WEBRTC_TARGET} -C out/${WEBRTC_BUILD_TYPE}")
webrtc_command(
    NAME ninja
    COMMAND ${WEBRTC_BUILD_COMMAND}
    WORKING_DIRECTORY ${WEBRTC_FOLDER}/src
    DEPENDS configure
)

webrtc_command(
    NAME build
    COMMAND ""
    DEPENDS ninja
)
