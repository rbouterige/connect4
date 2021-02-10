# 
#
# Downloads GTest and provides a helper macro to add tests. Add make check, as well, which
# gives output on failed tests without having to set an environment variable.
#
#
set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)

if(CMAKE_VERSION VERSION_LESS 3.11)
    set(UPDATE_DISCONNECTED_IF_AVAILABLE "UPDATE_DISCONNECTED 1")

    include(DownloadProject)
    download_project(PROJ                googletest
		     GIT_REPOSITORY      https://github.com/google/googletest.git
		     GIT_TAG             release-1.10.0
		     UPDATE_DISCONNECTED 1
		     QUIET
    )

    # CMake warning suppression will not be needed in version 1.9
    set(CMAKE_SUPPRESS_DEVELOPER_WARNINGS 1 CACHE BOOL "")
    add_subdirectory(${googletest_SOURCE_DIR} ${googletest_SOURCE_DIR} EXCLUDE_FROM_ALL)
    unset(CMAKE_SUPPRESS_DEVELOPER_WARNINGS)
else()
    include(FetchContent)
    FetchContent_Declare(googletest
        GIT_REPOSITORY      https://github.com/google/googletest.git
        GIT_TAG             release-1.10.0)
    FetchContent_GetProperties(googletest)
    if(NOT googletest_POPULATED)
        FetchContent_Populate(googletest)
        set(CMAKE_SUPPRESS_DEVELOPER_WARNINGS 1 CACHE BOOL "")
        add_subdirectory(${googletest_SOURCE_DIR} ${googletest_BINARY_DIR} EXCLUDE_FROM_ALL)
        unset(CMAKE_SUPPRESS_DEVELOPER_WARNINGS)
    endif()
endif()


if(CMAKE_CONFIGURATION_TYPES)
    add_custom_target(check COMMAND ${CMAKE_CTEST_COMMAND} 
        --force-new-ctest-process --output-on-failure 
        --build-config "$<CONFIGURATION>")
else()
    add_custom_target(check COMMAND ${CMAKE_CTEST_COMMAND} 
        --force-new-ctest-process --output-on-failure)
endif()
set_target_properties(check PROPERTIES FOLDER "Scripts")


# Target must already exist
macro(add_gtest TESTNAME)
    target_link_libraries(${TESTNAME} PUBLIC gtest gmock gtest_main)
    
    add_test(NAME ${TESTNAME} COMMAND $<TARGET_FILE:${TESTNAME}>)

    set_target_properties(${TESTNAME} PROPERTIES 
        RUNTIME_OUTPUT_DIRECTORY "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/tests")
    install(TARGETS ${TESTNAME} DESTINATION bin/tests)
endmacro()

mark_as_advanced(
gmock_build_tests
gtest_build_samples
gtest_build_tests
gtest_disable_pthreads
gtest_force_shared_crt
gtest_hide_internal_symbols
BUILD_GMOCK
BUILD_GTEST
)

set_target_properties(gtest gtest_main gmock gmock_main
    PROPERTIES FOLDER "Extern")