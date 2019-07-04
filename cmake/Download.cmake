set(WEBRTC_FETCH_COMMAND gclient config --unmanaged --name src https://webrtc.googlesource.com/src)
webrtc_command(
    NAME config
    COMMAND ${WEBRTC_FETCH_COMMAND}
    WORKING_DIRECTORY ${WEBRTC_FOLDER}
    DEPENDS depot-tools
)

set(WEBRTC_SYNC_COMMAND gclient sync --revision ${WEBRTC_GIT_REVISION} --nohooks --reset --no-history --shallow)
webrtc_command(
    NAME sync
    COMMAND ${WEBRTC_SYNC_COMMAND}
    WORKING_DIRECTORY ${WEBRTC_FOLDER}
    DEPENDS config
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

if(WIN32)
    set(WEBRTC_PLATFORM win32)
    set(WEBRTC_GN_SHA_PATH src/buildtools/win/gn.exe.sha1)
elseif(APPLE)
    set(WEBRTC_PLATFORM darwin)
    set(WEBRTC_GN_SHA_PATH src/buildtools/mac/gn.sha1)
else()
    set(WEBRTC_PLATFORM linux)
    set(WEBRTC_GN_SHA_PATH src/buildtools/linux64/gn.sha1)
endif()

set(WEBRTC_DOWNLOAD_GN_COMMAND download_from_google_storage --no_resume --platform=${WEBRTC_PLATFORM} --no_auth --bucket chromium-gn -s ${WEBRTC_GN_SHA_PATH})
webrtc_command(
    NAME download-gn
    COMMAND ${WEBRTC_DOWNLOAD_GN_COMMAND}
    WORKING_DIRECTORY ${WEBRTC_FOLDER}
    DEPENDS sync
)

set(WEBRTC_DOWNLOAD_CIOPFS_COMMAND download_from_google_storage --no_resume --no_auth --bucket chromium-browser-clang/ciopfs -s src/build/ciopfs.sha1)
webrtc_command(
    NAME download-ciopfs
    COMMAND ${WEBRTC_DOWNLOAD_CIOPFS_COMMAND}
    WORKING_DIRECTORY ${WEBRTC_FOLDER}
    DEPENDS download-gn
)

set(WEBRTC_UPDATE_CLANG_COMMAND python src/tools/clang/scripts/update.py)
webrtc_command(
    NAME update-clang
    COMMAND ${WEBRTC_UPDATE_CLANG_COMMAND}
    WORKING_DIRECTORY ${WEBRTC_FOLDER}
    DEPENDS sync
)

set(WEBRTC_DOWNLOAD_DEPENDS config sync download-gn download-ciopfs update-clang)

if(WIN32)
    set(WEBRTC_UPDATE_VS_COMMAND python src/build/vs_toolchain.py update --force)
    webrtc_command(
        NAME update-vs
        COMMAND ${WEBRTC_UPDATE_VS_COMMAND}
        WORKING_DIRECTORY ${WEBRTC_FOLDER}
        DEPENDS sync
    )
    list(APPEND WEBRTC_DOWNLOAD_DEPENDS update-vs)
endif()


webrtc_command(
    NAME download
    COMMAND echo download completed
    DEPENDS ${WEBRTC_DOWNLOAD_DEPENDS}
)
