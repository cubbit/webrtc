set(WEBRTC_FETCH_COMMAND "gclient config --unmanaged --name src https://webrtc.googlesource.com/src")
webrtc_command(
    NAME config
    COMMAND ${WEBRTC_FETCH_COMMAND}
    WORKING_DIRECTORY ${WEBRTC_FOLDER}
    DEPENDS depot-tools
)

set(WEBRTC_SYNC_COMMAND "gclient sync --revision ${WEBRTC_REVISION} --nohooks --reset --no-history --shallow")
webrtc_command(
    NAME sync
    COMMAND ${WEBRTC_SYNC_COMMAND}
    WORKING_DIRECTORY ${WEBRTC_FOLDER}
    DEPENDS config
)

if(WIN32)
    set(PLATFORM win32)
    set(GN_SHA_PATH src/buildtools/win/gn.exe.sha1)
elseif(APPLE)
    set(PLATFORM darwin)
    set(GN_SHA_PATH src/buildtools/mac/gn.sha1)
else()
    set(PLATFORM linux)
    set(GN_SHA_PATH src/buildtools/linux64/gn.sha1)
endif()
set(WEBRTC_DOWNLOAD_GN_COMMAND "download_from_google_storage --no_resume --platform=${PLATFORM} --no_auth --bucket chromium-gn -s ${GN_SHA_PATH}")
webrtc_command(
    NAME download-gn
    COMMAND ${WEBRTC_DOWNLOAD_GN_COMMAND}
    WORKING_DIRECTORY ${WEBRTC_FOLDER}
    DEPENDS sync
)

set(WEBRTC_DOWNLOAD_CIOPFS_COMMAND "download_from_google_storage --no_resume --no_auth --bucket chromium-browser-clang/ciopfs -s src/build/ciopfs.sha1")
webrtc_command(
    NAME download-ciopfs
    COMMAND ${WEBRTC_DOWNLOAD_CIOPFS_COMMAND}
    WORKING_DIRECTORY ${WEBRTC_FOLDER}
    DEPENDS sync
)

set(WEBRTC_UPDATE_CLANG_COMMAND "python src/tools/clang/scripts/update.py")
webrtc_command(
    NAME update-clang
    COMMAND ${WEBRTC_UPDATE_CLANG_COMMAND}
    WORKING_DIRECTORY ${WEBRTC_FOLDER}
    DEPENDS sync
)

webrtc_command(
    NAME download
    COMMAND ""
    DEPENDS config sync download-gn download-ciopfs update-clang
)
