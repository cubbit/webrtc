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

if(WIN32)
    target_compile_definitions(webrtc PUBLIC WEBRTC_WIN=1)
    target_link_libraries(webrtc PUBLIC Winmm.lib Secur32.lib Msdmo.lib Wmcodecdspuuid.lib Dmoguids.lib)
elseif(APPLE)
    target_compile_definitions(webrtc PUBLIC WEBRTC_MAC=1 WEBRTC_POSIX=1)

    find_library(FOUNDATION_LIBRARY Foundation)
    find_library(COREFOUNDATION_LIBRARY CoreFoundation)
    target_link_libraries(webrtc PUBLIC ${COREFOUNDATION_LIBRARY} ${FOUNDATION_LIBRARY})
    if(NOT CUBBIT)
        find_library(AUDIOTOOLBOX_LIBRARY AudioToolbox)
        find_library(COREAUDIO_LIBRARY CoreAudio)
        find_library(COREGRAPHICS_LIBRARY CoreGraphics)
        target_link_libraries(webrtc PUBLIC ${AUDIOTOOLBOX_LIBRARY} ${COREAUDIO_LIBRARY} ${COREGRAPHICS_LIBRARY})
    endif()
else()
    target_compile_definitions(webrtc PUBLIC WEBRTC_LINUX=1 WEBRTC_POSIX=1)
    if(NOT CUBBIT)
        target_link_libraries(webrtc PUBLIC dl)
    endif()
endif()

install(DIRECTORY ${WEBRTC_SRC_ROOT}/ DESTINATION include/webrtc FILES_MATCHING PATTERN "*.h")
install(TARGETS webrtc EXPORT webrtc-config DESTINATION lib)
install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/template/CMakeLists.txt.in DESTINATION ${CMAKE_INSTALL_PREFIX} RENAME CMakeLists.txt)
install(EXPORT webrtc-config DESTINATION ${CMAKE_INSTALL_PREFIX}/cmake)
