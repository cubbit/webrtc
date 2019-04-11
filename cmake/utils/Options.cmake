option(BUILD_TESTS "Build test binaries" OFF)
option(BUILD_SAMPLE "Build sample" OFF)
set(DEPOT_TOOLS_PATH "" CACHE STRING "Path to your own depot_tools directory")
set(WEBRTC_REVISION "" CACHE STRING "WebRTC commit hash to checkout")
set(WEBRTC_TARGET "" CACHE STRING "WebRTC build target")

if(APPLE)
    add_definitions(-DWEBRTC_MAC -DWEBRTC_POSIX)
endif(APPLE)

if(DEPOT_TOOLS_PATH)
    set(HAS_OWN_DEPOT_TOOLS 1)
endif (DEPOT_TOOLS_PATH)
