set(WEBRTC_LAST_CHANGE_COMMAND python src/build/util/lastchange.py -o src/build/util/LASTCHANGE)
webrtc_command(
    NAME last-change
    COMMAND ${WEBRTC_LAST_CHANGE_COMMAND}
    WORKING_DIRECTORY ${WEBRTC_FOLDER}
    DEPENDS download
)

set(WEBRTC_CONFIGURE_COMMAND gn gen out/${WEBRTC_BUILD_TYPE} --args=${WEBRTC_GEN_ARGS})
webrtc_command(
    NAME gen
    COMMAND ${WEBRTC_CONFIGURE_COMMAND}
    WORKING_DIRECTORY ${WEBRTC_FOLDER}/src
    DEPENDS download
)

webrtc_command(
    NAME configure
    COMMAND echo configure complete
    DEPENDS gen last-change
)
