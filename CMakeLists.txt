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

ExternalProject_Add(webrtc
    PREFIX ${CMAKE_BINARY_DIR}/webrtc
    SOURCE_DIR ${CMAKE_SOURCE_DIR}/webrtc

    CMAKE_ARGS
        -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}
        -DWEBRTC_BUILD_TYPE=${WEBRTC_BUILD_TYPE}
        -DBINARY_ROOT=${CMAKE_BINARY_DIR}
        -DARCH=${ARCH}
        -DNOLOG=${NOLOG}
        -DCUBBIT=${CUBBIT}

    INSTALL_COMMAND ""
)

ExternalProject_Get_Property(webrtc BINARY_DIR)
set(WEBRTC_SRC_ROOT ${BINARY_DIR}/webrtc/src)

ExternalProject_Add(libwebrtc
    PREFIX ${CMAKE_BINARY_DIR}/libwebrtc
    SOURCE_DIR ${CMAKE_SOURCE_DIR}/libwebrtc

    DEPENDS webrtc

    CMAKE_ARGS
        -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}
        -DWEBRTC_BUILD_TYPE=${WEBRTC_BUILD_TYPE}
        -DWEBRTC_SRC_ROOT=${WEBRTC_SRC_ROOT}
)

# Pack
set(CMAKE_SKIP_INSTALL_ALL_DEPENDENCY ON)

if(WIN32)
    set(WEBRTC_PACK_PLATFORM win)
elseif(APPLE)
    set(WEBRTC_PACK_PLATFORM darwin)
else()
    set(WEBRTC_PACK_PLATFORM linux)
endif()

string(TOLOWER ${CMAKE_HOST_SYSTEM_PROCESSOR} WEBRTC_PACK_ARCHITECTURE)
if(ARCH)
    set(WEBRTC_PACK_ARCHITECTURE ${ARCH})
endif()

set(WEBRTC_PACK_NAME webrtc-${WEBRTC_PACK_PLATFORM}-${WEBRTC_PACK_ARCHITECTURE}-${WEBRTC_BUILD_TYPE})
if(CUBBIT)
    set(WEBRTC_PACK_NAME ${WEBRTC_PACK_NAME}-cubbit)
endif()
if(WEBRTC_BUILD_TYPE STREQUAL debug AND NOLOG)
    set(WEBRTC_PACK_NAME ${WEBRTC_PACK_NAME}-nolog)
endif()
set(WEBRTC_PACK_NAME ${WEBRTC_PACK_NAME}.zip)
set(WEBRTC_PACK ${CMAKE_INSTALL_PREFIX}/${WEBRTC_PACK_NAME})

set(WEBRTC_CONFIG ${CMAKE_INSTALL_PREFIX}/CMakeLists.txt)

add_custom_command(
    OUTPUT ${WEBRTC_PACK}
    COMMAND ${CMAKE_COMMAND} -E tar cf ${WEBRTC_PACK} --format=zip ${CMAKE_INSTALL_PREFIX}/lib ${CMAKE_INSTALL_PREFIX}/include ${CMAKE_INSTALL_PREFIX}/CMakeLists.txt
    WORKING_DIRECTORY ${CMAKE_INSTALL_PREFIX}
    DEPENDS libwebrtc
)
add_custom_target(pack DEPENDS ${WEBRTC_PACK})
