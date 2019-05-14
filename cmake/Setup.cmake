set(WEBRTC_LIB_SOURCE "${CMAKE_CURRENT_BINARY_DIR}/webrtc/src/out/${WEBRTC_BUILD_TYPE}/obj")
if(WIN32)
    string(REGEX REPLACE "/" "\\\\" WEBRTC_LIB_SOURCE ${WEBRTC_LIB_SOURCE})
    set(WEBRTC_LIB_COPY_COMMAND robocopy ${WEBRTC_LIB_SOURCE} ${WEBRTC_LIB_FOLDER} *.lib /mir /lev:1 || exit 0)
else()
    set(WEBRTC_LIB_COPY_COMMAND cp ${WEBRTC_LIB_SOURCE}/*.a ${WEBRTC_LIB_FOLDER})
endif()

webrtc_command(
    NAME lib-copy
    COMMAND ${WEBRTC_LIB_COPY_COMMAND}
    WORKING_DIRECTORY ${WEBRTC_FOLDER}
    DEPENDS build
)

set(WEBRTC_HEADER_SOURCE "${CMAKE_CURRENT_BINARY_DIR}/webrtc/src/")
if(WIN32)
    string(REGEX REPLACE "/" "\\\\" WEBRTC_HEADER_SOURCE ${WEBRTC_HEADER_SOURCE})
    set(WEBRTC_HEADERS_COPY_COMMAND robocopy ${WEBRTC_HEADER_SOURCE} ${WEBRTC_HEADERS_FOLDER} *.h /mir || exit 0)
else()
    set(WEBRTC_HEADERS_COPY_COMMAND cd ${WEBRTC_HEADER_SOURCE} && find . -name '*.h' | cpio -pdm ${WEBRTC_HEADERS_FOLDER}/)
endif()

webrtc_command(
    NAME headers-copy
    COMMAND ${WEBRTC_HEADERS_COPY_COMMAND}
    WORKING_DIRECTORY ${WEBRTC_FOLDER}
    DEPENDS build
)

webrtc_command(
    NAME setup
    COMMAND ""
    WORKING_DIRECTORY ${WEBRTC_FOLDER}
    DEPENDS lib-copy headers-copy
)
