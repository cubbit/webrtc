set(LIBCPP_OBJECTS
    algorithm.o
    any.o
    bind.o
    chrono.o
    condition_variable.o
    debug.o
    exception.o
    functional.o
    future.o
    hash.o
    ios.o
    iostream.o
    locale.o
    memory.o
    mutex.o
    new.o
    optional.o
    random.o
    regex.o
    shared_mutex.o
    stdexcept.o
    string.o
    strstream.o
    system_error.o
    thread.o
    typeinfo.o
    utility.o
    valarray.o
    variant.o
    vector.o
)
list(TRANSFORM LIBCPP_OBJECTS PREPEND ${WEBRTC_LIB_SOURCE}/buildtools/third_party/libc++/libc++/)

set(LIBCPPABI_OBJECTS
    abort_message.o
    cxa_aux_runtime.o
    cxa_default_handlers.o
    cxa_demangle.o
    cxa_exception.o
    cxa_exception_storage.o
    cxa_guard.o
    cxa_handlers.o
    cxa_personality.o
    cxa_unexpected.o
    cxa_vector.o
    cxa_virtual.o
    fallback_malloc.o
    private_typeinfo.o
    stdlib_exception.o
    stdlib_stdexcept.o
    stdlib_typeinfo.o
)
list(TRANSFORM LIBCPPABI_OBJECTS PREPEND ${WEBRTC_LIB_SOURCE}/buildtools/third_party/libc++abi/libc++abi/)

set(LIBCXX_NAME libcxx.a)

webrtc_command(
    NAME libcxx
    COMMAND ${CMAKE_AR}
    ARGS -r ${LIBCXX_NAME} ${LIBCPP_OBJECT} ${LIBCPPABI_OBJECTS}
    WORKING_DIRECTORY ${WEBRTC_LIB_SOURCE}
    DEPENDS build
)
