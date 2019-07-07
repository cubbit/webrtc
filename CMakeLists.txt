cmake_minimum_required(VERSION 3.8)

project(webrtc NONE)

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${CMAKE_CURRENT_SOURCE_DIR}/cmake)

include(ExternalProject)
find_package(Git REQUIRED)

include(DepotTools)

set(WEBRTC_REVISION m74)
set(WEBRTC_GIT_REVISION branch-heads/${WEBRTC_REVISION})

set(WEBRTC_FOLDER ${CMAKE_CURRENT_BINARY_DIR}/webrtc)
file(MAKE_DIRECTORY ${WEBRTC_FOLDER})

set(WEBRTC_LIB_FOLDER ${CMAKE_INSTALL_PREFIX}/lib)
file(MAKE_DIRECTORY ${WEBRTC_LIB_FOLDER})

set(WEBRTC_HEADERS_FOLDER ${CMAKE_INSTALL_PREFIX}/include/webrtc)
file(MAKE_DIRECTORY ${WEBRTC_HEADERS_FOLDER})

list(APPEND WEBRTC_GEN_ARGS
    rtc_build_examples=false
    rtc_use_x11=false
    rtc_enable_protobuf=false
    rtc_use_gtk=false
    rtc_include_pulse_audio=false
    rtc_include_tests=false
)

set(WEBRTC_ARCH amd64)
if(ARCH)
    set(WEBRTC_ARCH ${ARCH})
endif()

if(ARCH STREQUAL "arm")
    list(APPEND WEBRTC_GEN_ARGS
        target_os=\"linux\"
        target_cpu=\"arm\"
        rtc_build_tools=true
        treat_warnings_as_errors=false
        fatal_linker_warnings=false
    )
elseif(ARCH STREQUAL "arm64")
    list(APPEND WEBRTC_GEN_ARGS
        target_os=\"linux\"
        target_cpu=\"arm64\"
        rtc_build_tools=true
        treat_warnings_as_errors=false
        fatal_linker_warnings=false
    )
else()
    list(APPEND WEBRTC_GEN_ARGS rtc_build_tools=false)
endif()

if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    set(WEBRTC_BUILD_TYPE debug)
    list(APPEND WEBRTC_GEN_ARGS is_debug=true enable_iterator_debugging=true)
else()
    set(WEBRTC_BUILD_TYPE release)
    list(APPEND WEBRTC_GEN_ARGS is_debug=false)
endif()

if(WIN32)
    list(APPEND WEBRTC_GEN_ARGS is_clang=false)
endif()

string(REPLACE ";" " " WEBRTC_GEN_ARGS "${WEBRTC_GEN_ARGS}")

set(WEBTC_TARGET webrtc libjingle_peerconnection)

include(WebrtcCommand)

include(Download)
include(Configure)
include(Build)
include(Setup)

include(Pack)
