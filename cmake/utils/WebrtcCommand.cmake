include(CMakeParseArguments) 

# Include guard
if(LIBWEBRTC_COMMAND_INCLUDED)
    return()
endif(LIBWEBRTC_COMMAND_INCLUDED)
set(LIBWEBRTC_COMMAND_INCLUDED true)

# Set environment for script calls
include(Environment)

# Function declaration
function(webrtc_command)
    set(ONE_VALUE_ARGS NAME COMMENT WORKING_DIRECTORY)
    set(LIST_ARGS COMMAND DEPENDS)
    cmake_parse_arguments(COMMAND "" "${ONE_VALUE_ARGS}" "${LIST_ARGS}" ${ARGN})

    set(STAMP_DIR ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY})
    set(STAMP_FILE "${STAMP_DIR}/${COMMAND_NAME}-complete")

    if(WIN32)
        set(COMMAND_COMMAND cmd /c ${COMMAND_COMMAND})
    endif()

    add_custom_command(
        OUTPUT ${STAMP_FILE}
        COMMENT ${COMMAND_COMMENT}
        COMMAND ${PREFIX_EXECUTE} ${COMMAND_COMMAND}
        COMMAND ${CMAKE_COMMAND} -E touch ${STAMP_FILE}
        WORKING_DIRECTORY ${COMMAND_WORKING_DIRECTORY}
    )

    add_custom_target(${COMMAND_NAME} ALL DEPENDS ${STAMP_FILE})
    
    if (COMMAND_DEPENDS)
        add_dependencies(${COMMAND_NAME} ${COMMAND_DEPENDS})
    endif (COMMAND_DEPENDS)
endfunction()
