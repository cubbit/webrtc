cmake_minimum_required(VERSION 3.14)

project(webrtc NONE)

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${CMAKE_CURRENT_SOURCE_DIR}/cmake)

include(ExternalProject)
find_package(Git REQUIRED)

include(DepotTools)

set(WEBRTC_REVISION branch-heads/m74)

set(WEBRTC_FOLDER ${CMAKE_CURRENT_BINARY_DIR}/webrtc)
file(MAKE_DIRECTORY ${WEBRTC_FOLDER})

set(WEBRTC_LIB_FOLDER ${CMAKE_INSTALL_PREFIX}/lib)
file(MAKE_DIRECTORY ${WEBRTC_LIB_FOLDER})

set(WEBRTC_HEADERS_FOLDER ${CMAKE_INSTALL_PREFIX}/include)
file(MAKE_DIRECTORY ${WEBRTC_HEADERS_FOLDER})

list(APPEND WEBRTC_GEN_ARGS
    rtc_build_examples=false
    rtc_use_x11=false
    rtc_enable_protobuf=false
    rtc_use_gtk=false
    rtc_include_pulse_audio=false
    rtc_include_tests=false
    rtc_build_tools=false
)

if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    list(APPEND WEBRTC_GEN_ARGS is_debug=true)
else()
    list(APPEND WEBRTC_GEN_ARGS is_debug=false)
endif()

if (WIN32)
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
