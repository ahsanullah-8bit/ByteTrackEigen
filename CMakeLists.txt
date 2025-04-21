cmake_minimum_required(VERSION 3.20)
project(ByteTrackEigen VERSION 1.0.1)

# Specify the C++ standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED True)

# Set default build type to Release if not specified
if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Release)
endif()

# If     Eigen3_DIR is set, use that
# elseIf CMAKE_TOOLCHAIN_FILE is set to a vcpkg dir or VCPKG_ROOT env is set, use vcpkg.
# else   download, extract and set Eigen3_DIR manually.
if (DEFINED Eigen3_DIR)
    message("Using custom ${Eigen3_DIR} for eigen3.4.0.")
    find_package(Eigen3 3.4.0 REQUIRED)

elseif (DEFINED CMAKE_TOOLCHAIN_FILE
        OR CMAKE_TOOLCHAIN_FILE MATCHES "vcpkg"
        OR DEFINED ENV{VCPKG_ROOT}
    )
    message("Using vcpkg for eigen3.4.0 dependencies.")
    find_package(Eigen3 3.4.0 CONFIG REQUIRED)

else()
    message("Setting up eigen3.4.0 manually.")
    set(BASE_DEPS_DIR "${CMAKE_BINARY_DIR}/_deps")
    set(Eigen3_DIR "${BASE_DEPS_DIR}/Eigen3")
    set(Eigen3_URL "https://gitlab.com/libeigen/eigen/-/archive/3.4.0/eigen-3.4.0.zip")
    set(Eigen3_ZIP "${BASE_DEPS_DIR}/eigen-3.4.0.zip")
    set(Eigen3_EXTRACT "${BASE_DEPS_DIR}/eigen-3.4.0")
    set(Eigen3_BUILD "${BASE_DEPS_DIR}/eigen-3.4.0-build")

    # Create the external directory if it does not exist
    if(NOT EXISTS "${CMAKE_SOURCE_DIR}/ext/")
        file(MAKE_DIRECTORY "${CMAKE_SOURCE_DIR}/ext/")
    endif()

    # Check if Eigen directory exists
    if(NOT EXISTS ${Eigen3_DIR})
        # Eigen URL and expected ZIP file path

        # Download Eigen
        message(STATUS "Downloading Eigen to ${Eigen3_ZIP}")
        file(DOWNLOAD ${Eigen3_URL} ${Eigen3_ZIP}
            STATUS EIGEN3_DOWNLOAD_STATUS
            TIMEOUT 60) # Timeout in seconds

        # Check download status
        list(GET EIGEN3_DOWNLOAD_STATUS 0 EIGEN3_DOWNLOAD_RESULT)
        if(EIGEN3_DOWNLOAD_RESULT EQUAL 0)
            # Extract Eigen
            message(STATUS "Extracting Eigen")
            execute_process(COMMAND ${CMAKE_COMMAND} -E tar xzf ${Eigen3_ZIP}
                WORKING_DIRECTORY "${BASE_DEPS_DIR}"    # <bin-dir>/_deps/
                RESULT_VARIABLE EIGEN3_EXTRACT_RESULT)

            # Check extraction status and rename directory
            if(EIGEN3_EXTRACT_RESULT EQUAL 0)
                # Configure into ext-build
                execute_process(
                  COMMAND ${CMAKE_COMMAND} -S ${Eigen3_EXTRACT} -B ${Eigen3_BUILD}
                          -DCMAKE_INSTALL_PREFIX=${Eigen3_DIR}
                  RESULT_VARIABLE EIGEN3_CFG_RES
                )

                # 2) Build from ext-build
                execute_process(
                  COMMAND ${CMAKE_COMMAND} --build ${Eigen3_BUILD}
                  RESULT_VARIABLE EIGEN3_BUILD_RES
                )

                # 3) Install from ext-build
                execute_process(
                  COMMAND ${CMAKE_COMMAND} --install ${Eigen3_BUILD} --prefix ${Eigen3_DIR}
                  RESULT_VARIABLE EIGEN3_INS_RES
                )

            else()
                message(FATAL_ERROR "Failed to extract Eigen")
            endif()
        else()
            message(FATAL_ERROR "Failed to download Eigen")
        endif()
    endif()

    # Include Eigen and project headers
    list(APPEND CMAKE_PREFIX_PATH ${Eigen3_DIR})
    find_package(Eigen3 3.4.0 REQUIRED)
endif()

# Add library
add_library(bytetrackeigen SHARED
    src/BaseTrack.cpp
    src/BoundingBoxTrackUtils.cpp
    src/BYTETracker.cpp
    src/HungarianAlgorithmEigen.cpp
    src/KalmanBBoxTrack.cpp
    src/KalmanFilter.cpp
    src/LinearAssignment.cpp
    src/BoundingBoxIoUMatching.cpp
)
add_library(ByteTrackEigen::ByteTrack ALIAS bytetrackeigen)

# Compiler options for different build types
if (MSVC)
    target_compile_options(bytetrackeigen PRIVATE
        $<$<CONFIG:Debug>:/Zi /DDEBUG>
        $<$<CONFIG:Release>:/O2>
    )
else()
    target_compile_options(bytetrackeigen PRIVATE
        $<$<CONFIG:Debug>:-g -DDEBUG>
        $<$<CONFIG:Release>:-O3>
    )
endif()

# Set runtime output directories for Debug and Release
# This should output the binaries to the main directory, even if it's a sub-project
set_target_properties(bytetrackeigen PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY_DEBUG ${CMAKE_BINARY_DIR}
    RUNTIME_OUTPUT_DIRECTORY_RELEASE ${CMAKE_BINARY_DIR}
)

target_include_directories(bytetrackeigen PRIVATE include)
# Definitions for DLL export, if needed
target_compile_definitions(bytetrackeigen PRIVATE BUILDING_BYTE_TRACK_EIGEN)
target_link_libraries(bytetrackeigen PRIVATE Eigen3::Eigen)
