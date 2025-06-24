# Helpers

function(bte_init_dependencies)
	cmake_policy(SET CMP0135 NEW)

	include(FetchContent)
	set(FETCHCONTENT_QUIET OFF)

	#######################################
	##		Eigen 3.4.0
	#######################################

	if (Eigen3_DIR STREQUAL "" AND Eigen3_ROOT STREQUAL "")
		FetchContent_Declare(Eigen3
			URL "https://gitlab.com/libeigen/eigen/-/archive/3.4.0/eigen-3.4.0.zip"
			# FIND_PACKAGE_ARGS CONFIG REQUIRED # Use find_package to look if Eigen3_DIR is already set
		)
	    FetchContent_MakeAvailable(Eigen3)

		if (Eigen3_POPULATED)
			set(Eigen3_ROOT	"${CMAKE_BINARY_DIR}/Eigen3" PARENT_SCOPE)

			# 1. Configure
			execute_process(
				COMMAND ${CMAKE_COMMAND} -S ${Eigen3_SOURCE_DIR} -B ${Eigen3_BINARY_DIR}
				    -DCMAKE_INSTALL_PREFIX=${Eigen3_ROOT}
					-DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
					RESULT_VARIABLE EIGEN3_CFG_RES	# TODO: Must check for a fail
			)

		    # 2) Build
			execute_process(
				COMMAND ${CMAKE_COMMAND} --build ${Eigen3_BINARY_DIR}
				RESULT_VARIABLE EIGEN3_BUILD_RES # TODO: Must check for a fail
			)

		    # 3) Install
			execute_process(
				COMMAND ${CMAKE_COMMAND} --install ${Eigen3_BINARY_DIR} --prefix ${Eigen3_ROOT}
				RESULT_VARIABLE EIGEN3_INS_RES # TODO: Must check for a fail
			)

		    # Eigen3_ROOT should work just fine with find_package. But I'm setting Eigen3_DIR just in case...
			set(Eigen3_DIR "${Eigen3_ROOT}/lib/cmake/Eigen3" PARENT_SCOPE)	# Now find_package can look for Eigen3.

		endif() # Eigen3_POPULATED
	endif() # NOT Eigen3_DIR STREQUAL "" AND NOT Eigen3_ROOT STREQUAL ""

	#######################################

endfunction()
