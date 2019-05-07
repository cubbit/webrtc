# Project settings
cmake_minimum_required(VERSION 3.9.2)
project(webrtc)

# Urls
set(WEBRTC_URL https://chromium.googlesource.com/external/webrtc.git)

# Set include path
set(CMAKE_MODULE_PATH
    ${CMAKE_MODULE_PATH}
    ${CMAKE_CURRENT_SOURCE_DIR}/cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/cmake/utils
)

# Prerequisites
find_package(Git REQUIRED)
include(ExternalProject)

if(HAS_OWN_DEPOT_TOOLS)
    # If user provide his own depot_tools
    find_package(DepotTools REQUIRED)
endif(HAS_OWN_DEPOT_TOOLS)

if(NOT WIN32)
    find_package(PythonInterp 2.7 REQUIRED)
endif(NOT WIN32)

if(NOT HAS_OWN_DEPOT_TOOLS)
    set(DEPOT_TOOLS_REPO https://chromium.googlesource.com/chromium/tools/depot_tools.git)
    set(DEPOT_TOOLS_PATH ${CMAKE_BINARY_DIR}/depot_tools/src/depot-tools)

    if(WIN32)
        set(GCLIENT_EXECUTABLE ${DEPOT_TOOLS_PATH}/gclient.bat)
        set(GN_EXECUTABLE ${DEPOT_TOOLS_PATH}/gn.bat)
        set(NINJA_EXECUTABLE ${DEPOT_TOOLS_PATH}/ninja.bat)
    else(WIN32)
        set(GCLIENT_EXECUTABLE ${DEPOT_TOOLS_PATH}/gclient)
        set(GN_EXECUTABLE ${DEPOT_TOOLS_PATH}/gn)
        set(NINJA_EXECUTABLE ${DEPOT_TOOLS_PATH}/ninja)
    endif(WIN32)

    ExternalProject_Add(depot-tools
        GIT_REPOSITORY ${DEPOT_TOOLS_REPO}
        PREFIX ${CMAKE_BINARY_DIR}/depot_tools

        CONFIGURE_COMMAND ""
        UPDATE_COMMAND ""
        PATCH_COMMAND ""
        BUILD_COMMAND ""
        INSTALL_COMMAND ""
    )
    file(REMOVE_RECURSE ${CMAKE_BINARY_DIR}/depot_tools/.git)
endif(NOT HAS_OWN_DEPOT_TOOLS)

# Includes
include(Options)
include(FindLibraries)
include(WebrtcCommand)

set(WEBRTC_FOLDER ${CMAKE_CURRENT_BINARY_DIR}/webrtc)
if(WIN32)
    string(REGEX REPLACE "/" "\\\\" WEBRTC_FOLDER ${WEBRTC_FOLDER})
    set(CREATE_FOLDER_COMMAND if not exist ${WEBRTC_FOLDER} md ${WEBRTC_FOLDER})
else()
    set(CREATE_FOLDER_COMMAND mkdir -p ${WEBRTC_FOLDER})
endif()

# Create Webrtc folder
webrtc_command(
    NAME webrtc-create-folder
    COMMAND ${CREATE_FOLDER_COMMAND}
    COMMENT "Creating folder webrtc"
    ERROR "Unable to create folder webrtc"
    DEPENDS depot-tools
)

# GClient configuration
set(WEBRTC_CONFIG ${GCLIENT_EXECUTABLE} config
    --name src
    --verbose
    ${WEBRTC_URL}
)

webrtc_command(
    NAME webrtc-configuration
    COMMAND ${WEBRTC_CONFIG} || exit 0
    DEPENDS webrtc-create-folder
    WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/webrtc"
    COMMENT "Configuring webrtc"
    ERROR "Unable to configure webrtc"
)

# GClient sync
if(NOT WEBRTC_REVISION)
    set(WEBRTC_REVISION branch-heads/m74)
endif(NOT WEBRTC_REVISION)

set(WEBRTC_SYNC ${GCLIENT_EXECUTABLE} sync
    --verbose
    --nohooks
    --no-history
    --with_branch_heads
    --delete_unversioned_trees
    --revision ${WEBRTC_REVISION}
)

webrtc_command(
    NAME webrtc-sync
    COMMAND ${WEBRTC_SYNC}
    DEPENDS webrtc-configuration
    WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/webrtc"
    COMMENT "Syncing webrtc"
    ERROR "Unable to sync webrtc"
)

# GClient runhooks
if(APPLE)
    set(ENV{GYP_DEFINES} “target_arch=x64”)
else()
    set(ENV{GYP_DEFINES} “target_arch=ia32”)
endif()

set(WEBRTC_HOOKS ${GCLIENT_EXECUTABLE} runhooks)

webrtc_command(
    NAME webrtc-hooks
    COMMAND ${WEBRTC_HOOKS}
    DEPENDS webrtc-sync
    WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/webrtc"
    COMMENT "Running webrtc hooks"
    ERROR "Unable to run webrtc hooks"
)

# Build generation
if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Debug)
endif()

set(WEBRTC_PREPARE ${GN_EXECUTABLE} gen out/${CMAKE_BUILD_TYPE}
    --verbose
    --args="is_debug=false"
)

webrtc_command(
    NAME webrtc-prepare
    COMMAND ${WEBRTC_PREPARE}
    DEPENDS webrtc-hooks
    WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/webrtc/src"
    COMMENT "Generating webrtc build"
    ERROR "Unable to generate webrtc build"
)

# Build
if(NOT WEBRTC_TARGET)
    set(WEBRTC_TARGET webrtc)
endif(NOT WEBRTC_TARGET)

set(WEBRTC_BUILD ${NINJA_EXECUTABLE} -v -C out/${CMAKE_BUILD_TYPE} ${WEBRTC_TARGET})

webrtc_command(
    NAME webrtc-build
    COMMAND ${WEBRTC_BUILD}
    DEPENDS webrtc-prepare
    WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/webrtc/src"
    COMMENT "Building webrtc"
    ERROR "Unable to build webrtc"
)

if(NOT CMAKE_INSTALL_PREFIX)
    set(CMAKE_INSTALL_PREFIX ${CMAKE_CURRENT_BINARY_DIR}/webrtc)
endif()

# Create lib folder
set(WEBRTC_LIB_CREATE mkdir -p ${CMAKE_INSTALL_PREFIX}/lib)

webrtc_command(
    NAME webrtc-lib-create
    COMMAND ${WEBRTC_LIB_CREATE}
    DEPENDS webrtc-build
    COMMENT "Creating webrtc lib folder"
    ERROR "Unable to create webrtc lib folder"
)

# Copy lib
set(WEBRTC_LIB_COPY cp ${CMAKE_CURRENT_BINARY_DIR}/webrtc/src/out/${CMAKE_BUILD_TYPE}/obj/libwebrtc.a $${CMAKE_INSTALL_PREFIX}/lib/)

webrtc_command(
    NAME webrtc-lib-copy
    COMMAND ${WEBRTC_LIB_COPY}
    DEPENDS webrtc-lib-create
    COMMENT "Copying webrtc lib"
    ERROR "Unable to copy webrtc lib"
)

# Create header folder
set(WEBRTC_HEADER_CREATE mkdir -p ${CMAKE_INSTALL_PREFIX}/include/webrtc)

webrtc_command(
    NAME webrtc-header-create
    COMMAND ${WEBRTC_HEADER_CREATE}
    DEPENDS webrtc-lib-copy
    COMMENT "Creating webrtc header folder"
    ERROR "Unable to create webrtc header folder"
)

# Copy header folder
set(WEBRTC_HEADER_COPY cd ${CMAKE_CURRENT_BINARY_DIR}/webrtc/src &&
    find . -name '*.h' | cpio -pdm ${CMAKE_INSTALL_PREFIX}/include/webrtc/
)

webrtc_command(
    NAME webrtc
    COMMAND ${WEBRTC_HEADER_COPY}
    DEPENDS webrtc-header-create
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/webrtc/src
    COMMENT "Copying webrtc headers"
    ERROR "Unable to copy webrtc headers"
)

# set(WEBRTC_INCLUDES ${CMAKE_CURRENT_BINARY_DIR}/webrtc/include ${CMAKE_CURRENT_BINARY_DIR}/webrtc/include/webrtc ${CMAKE_CURRENT_BINARY_DIR}/webrtc/include/webrtc/third_party/abseil-cpp)
# set(WEBRTC_LIBRARIES ${WEBRTC_LIBRARIES} ${CMAKE_CURRENT_BINARY_DIR}/webrtc/lib/libwebrtc.a)
