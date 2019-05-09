cmake_minimum_required(VERSION 3.14)

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${CMAKE_CURRENT_SOURCE_DIR}/cmake)

include(ExternalProject)
find_package(Git REQUIRED)

if(NOT WIN32)
    find_package(PythonInterp 2.7 REQUIRED)
endif()

ExternalProject_Add(depot-tools
  GIT_REPOSITORY    https://chromium.googlesource.com/chromium/tools/depot_tools.git
  PREFIX            ${CMAKE_BINARY_DIR}/depot_tools

  UPDATE_COMMAND    ""
  CONFIGURE_COMMAND ""
  BUILD_COMMAND     ""
  INSTALL_COMMAND   ""
)

ExternalProject_Get_Property(depot-tools SOURCE_DIR)
set(DEPOT_TOOLS_PATH ${SOURCE_DIR})

set(WEBRTC_REVISION branch-heads/m74)

include(WebrtcCommand)

set(WEBRTC_FOLDER ${CMAKE_CURRENT_BINARY_DIR}/webrtc)
file(MAKE_DIRECTORY ${WEBRTC_FOLDER})

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

# download_from_google_storage --no_resume --platform=win32 --no_auth --bucket chromium-gn -s src/buildtools/win/gn.exe.sha1
# download_from_google_storage --no_resume --platform=darwin --no_auth --bucket chromium-gn -s src/buildtools/mac/gn.sha1
# download_from_google_storage --no_resume --platform=linux --no_auth --bucket chromium-gn -s src/buildtools/linux64/gn.sha1
