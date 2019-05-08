# Include guard
if (ENVIRONMENT_INCLUDED)
    return()
endif (ENVIRONMENT_INCLUDED)
set(ENVIRONMENT_INCLUDED true)

# Add Depot tools and $PATH to webrtc PATH
list(APPEND _WEBRTC_PATH ${DEPOT_TOOLS_PATH} $ENV{PATH})

if(WIN32)
    string(REGEX REPLACE ";" $<SEMICOLON> _WEBRTC_PATH "${_WEBRTC_PATH}")
else()
    string(REGEX REPLACE ";" ":" _WEBRTC_PATH "${_WEBRTC_PATH}")
endif()

# Set custom env variable
set(_ENV DEPOT_TOOLS_WIN_TOOLCHAIN=0 PATH="${_WEBRTC_PATH}")

# Set prefix execute
set(PREFIX_EXECUTE ${CMAKE_COMMAND} -E env "${_ENV}")
