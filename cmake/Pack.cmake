set(WEBRTC_PACK_NAME webrtc.zip)
set(WEBRTC_PACK ${CMAKE_INSTALL_PREFIX}/${WEBRTC_PACK_NAME})

add_custom_command(
    OUTPUT ${WEBRTC_PACK}
    COMMAND ${CMAKE_COMMAND} -E tar cf ${WEBRTC_PACK} --format=zip ${WEBRTC_LIB_FOLDER} ${WEBRTC_HEADERS_FOLDER}
    WORKING_DIRECTORY ${CMAKE_INSTALL_PREFIX}
)

add_custom_target(pack DEPENDS ${WEBRTC_PACK})
add_dependencies(pack setup)
