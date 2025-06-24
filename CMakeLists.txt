cmake_minimum_required(VERSION 3.20)
project(ByteTrackEigen VERSION 1.0.2)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED True)

if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Release)
endif()

include(cmake/helpers.cmake)

# Packages
bte_init_dependencies()

find_package(Eigen3 3.4.0 REQUIRED)

# Add library
add_library(bytetrackeigen
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

# Definitions for DLL export, if needed
target_compile_definitions(bytetrackeigen PRIVATE BUILDING_BYTE_TRACK_EIGEN)
target_include_directories(bytetrackeigen PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}/include")
target_link_libraries(bytetrackeigen PRIVATE Eigen3::Eigen)
