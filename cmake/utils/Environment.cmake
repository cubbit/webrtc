# Include guard
if (ENVIRONMENT_INCLUDED)
    return()
endif (ENVIRONMENT_INCLUDED)
set(ENVIRONMENT_INCLUDED true)

# Add Depot tools and $PATH to webrtc PATH
list(APPEND _WEBRTC_PATH ${DEPOT_TOOLS_PATH} $ENV{PATH})
string(REGEX REPLACE ";" ":" _WEBRTC_PATH "${_WEBRTC_PATH}")

# Set custom env variable 
set(_ENV PATH="${_WEBRTC_PATH}")

# Set prefix execute
set(PREFIX_EXECUTE ${CMAKE_COMMAND} -E env "${_ENV}")
