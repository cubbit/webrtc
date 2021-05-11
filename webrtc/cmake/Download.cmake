set(DEPOT_TOOLS_CONFIG_COMMAND git config core.autocrlf false)
webrtc_command(
    NAME depot-tools-config
    COMMAND ${DEPOT_TOOLS_CONFIG_COMMAND}
    WORKING_DIRECTORY ${DEPOT_TOOLS_PATH}
    DEPENDS depot-tools
)

set(WEBRTC_FETCH_COMMAND gclient config --unmanaged --name src https://webrtc.googlesource.com/src)
webrtc_command(
    NAME config
    COMMAND ${WEBRTC_FETCH_COMMAND}
    WORKING_DIRECTORY ${WEBRTC_FOLDER}
    DEPENDS depot-tools-config
)

set(WEBRTC_SYNC_COMMAND gclient sync --revision ${WEBRTC_GIT_REVISION} --nohooks --reset --no-history --shallow)
webrtc_command(
    NAME sync
    COMMAND ${WEBRTC_SYNC_COMMAND}
    WORKING_DIRECTORY ${WEBRTC_FOLDER}
    DEPENDS config
)

set(WEBRTC_HOOKS_COMMAND gclient runhooks)
webrtc_command(
    NAME hooks
    COMMAND ${WEBRTC_HOOKS_COMMAND}
    WORKING_DIRECTORY ${WEBRTC_FOLDER}
    DEPENDS sync
)

if(DEFINED ENV{GYP_DEFINES})
    message(WARNING GYP_DEFINES is already set to $ENV{GYP_DEFINES})
else()
    if(APPLE)
        set(ENV{GYP_DEFINES} "target_arch=x64")
    else()
        set(ENV{GYP_DEFINES} "target_arch=ia32")
    endif()
endif()

set(WEBRTC_DOWNLOAD_DEPENDS config sync hooks)

if(NOLOG)
    set(WEBRTC_NOLOG_COMMAND git apply --3way --ignore-space-change --ignore-whitespace ${CMAKE_CURRENT_SOURCE_DIR}/patch/Disable-debug-build-log.patch)
    webrtc_command(
        NAME nolog
        COMMAND ${WEBRTC_NOLOG_COMMAND}
        WORKING_DIRECTORY ${WEBRTC_FOLDER}/src
        DEPENDS sync
    )
    list(APPEND WEBRTC_DOWNLOAD_DEPENDS nolog)
endif()

if(CUBBIT)
    if(UNIX)
        if(APPLE)
            set(WEBRTC_SDK_PATCH_COMMAND git apply --3way --ignore-space-change --ignore-whitespace ${CMAKE_CURRENT_SOURCE_DIR}/patch/sdk/mac-sdk-find-updated.patch)
            webrtc_command(
                NAME sdk-patch
                COMMAND ${WEBRTC_SDK_PATCH_COMMAND}
                WORKING_DIRECTORY ${WEBRTC_FOLDER}/src/build/mac
                DEPENDS sync
            )
            list(APPEND WEBRTC_DOWNLOAD_DEPENDS sdk-patch)
        else()
            set(WEBRTC_LIBCXXABI_PATCH_COMMAND git apply --3way --ignore-space-change --ignore-whitespace ${CMAKE_CURRENT_SOURCE_DIR}/patch/libc++abi/Enable-cxa_thread_atexit-for-linux.patch)
            webrtc_command(
                NAME libcxxabi-patch
                COMMAND ${WEBRTC_LIBCXXABI_PATCH_COMMAND}
                WORKING_DIRECTORY ${WEBRTC_FOLDER}/src/buildtools/third_party/libc++abi
                DEPENDS sync
            )
            list(APPEND WEBRTC_DOWNLOAD_DEPENDS libcxxabi-patch)
        endif()
    endif()
endif()

if(WIN32)
    set(DEPOT_TOOLS_PIP_COMMAND python -m pip install pywin32)
    webrtc_command(
        NAME depot-tools-pip
        COMMAND ${DEPOT_TOOLS_PIP_COMMAND}
        WORKING_DIRECTORY ${DEPOT_TOOLS_PATH}
        DEPENDS sync
    )
    list(APPEND WEBRTC_DOWNLOAD_DEPENDS depot-tools-pip)
endif()

webrtc_command(
    NAME download
    COMMAND echo download completed
    DEPENDS ${WEBRTC_DOWNLOAD_DEPENDS}
)
