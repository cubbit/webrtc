cmake_minimum_required(VERSION 3.8)

project(libwebrtc)

set(WEBRTC_OUTPUT_DIR ${WEBRTC_SRC_ROOT}/out/${WEBRTC_BUILD_TYPE})

file(GLOB_RECURSE OBJ_FILES
    ${WEBRTC_OUTPUT_DIR}/obj/*.o
    ${WEBRTC_OUTPUT_DIR}/obj/*.obj
)

file(GLOB_RECURSE OBJ_EXCLUDED
    ${WEBRTC_OUTPUT_DIR}/obj/third_party/yasm/gen*/*.o*
    ${WEBRTC_OUTPUT_DIR}/obj/third_party/yasm/re2c/*.o*
    ${WEBRTC_OUTPUT_DIR}/obj/third_party/yasm/yasm/*.o*
    ${WEBRTC_OUTPUT_DIR}/obj/examples/*.o*
    ${WEBRTC_OUTPUT_DIR}/obj/tools/*.o*
    ${WEBRTC_OUTPUT_DIR}/obj/modules/video_capture/video_capture/video_capture_external.o*
    ${WEBRTC_OUTPUT_DIR}/obj/modules/video_capture/video_capture/device_info_external.o*
)

list(LENGTH OBJ_EXCLUDED OBJ_EXCLUDED_LENGTH)
if(${OBJ_EXCLUDED_LENGTH} GREATER "0")
    list(REMOVE_ITEM OBJ_FILES ${OBJ_EXCLUDED})
endif()

add_library(webrtc STATIC ${OBJ_FILES})

set_source_files_properties(${OBJ_FILES} PROPERTIES EXTERNAL_OBJECT true GENERATED true)
set_target_properties(webrtc PROPERTIES LINKER_LANGUAGE C LIBRARY_OUTPUT_DIRECTORY ${WEBRTC_OUTPUT_DIR})

# #
# # Install headers
# install(DIRECTORY ${WEBRTC_SOURCE_DIR} DESTINATION "include" FILES_MATCHING PATTERN "*.h")

# #
# # Install library
# install(TARGETS webrtc
#         EXPORT LibWebRTCTargets
#         ARCHIVE DESTINATION lib
#         RUNTIME DESTINATION bin
#         LIBRARY DESTINATION lib
#         INCLUDES DESTINATION include)

# install(EXPORT LibWebRTCTargets
#         FILE LibWebRTCTargets.cmake
#         DESTINATION ${INSTALL_CMAKE_DIR})

# install(FILES ${CMAKE_MODULE_PATH}/Templates/UseLibWebRTC.cmake
#         DESTINATION ${INSTALL_CMAKE_DIR})
