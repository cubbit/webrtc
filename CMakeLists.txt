cmake_minimum_required(VERSION 3.8)

project(webrtc NONE)

find_package(Git REQUIRED)

include(ExternalProject)

option(ARCH "Target architecture" "")
option(NOLOG "Disable debug log" ON)
option(CUBBIT "Build cubbit version" ON)

if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    set(WEBRTC_BUILD_TYPE debug)
else()
    set(WEBRTC_BUILD_TYPE release)
endif()

set(PROJECT_ARGS
    -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}
    -DWEBRTC_BUILD_TYPE=${WEBRTC_BUILD_TYPE}
    -DBINARY_ROOT=${CMAKE_BINARY_DIR}
    -DARCH=${ARCH}
    -DNOLOG=${NOLOG}
    -DCUBBIT=${CUBBIT}
)

ExternalProject_Add(webrtc
    PREFIX ${CMAKE_BINARY_DIR}/webrtc
    SOURCE_DIR ${CMAKE_SOURCE_DIR}/webrtc

    CMAKE_ARGS ${PROJECT_ARGS}

    INSTALL_COMMAND ""
)

ExternalProject_Get_Property(webrtc BINARY_DIR)
set(WEBRTC_SRC_ROOT ${BINARY_DIR}/webrtc/src)

ExternalProject_Add(libwebrtc
    PREFIX ${CMAKE_BINARY_DIR}/libwebrtc
    SOURCE_DIR ${CMAKE_SOURCE_DIR}/libwebrtc

    DEPENDS webrtc

    CMAKE_ARGS ${PROJECT_ARGS}
        -DWEBRTC_SRC_ROOT=${WEBRTC_SRC_ROOT}

    INSTALL_COMMAND ""
)
