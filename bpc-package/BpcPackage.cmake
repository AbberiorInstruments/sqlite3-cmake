include( CMakePackageConfigHelpers )
include( CMakeParseArguments )

set( BPC_PACKAGE_FOUND True )
	
include( "${CMAKE_CURRENT_LIST_DIR}/BpcHelpers.cmake" )
include( "${CMAKE_CURRENT_LIST_DIR}/BpcTargetPaths.cmake" )
include( "${CMAKE_CURRENT_LIST_DIR}/BpcCompiler.cmake" )

set( DEFAULTS_FILE "${CMAKE_SOURCE_DIR}/BpcPackageDefaults.cmake" )

if( EXISTS "${DEFAULTS_FILE}" )
	message( STATUS "Reading package defaults from: ${DEFAULTS_FILE}" )
	include( "${DEFAULTS_FILE}" )
endif()

if (CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT OR NOT CMAKE_INSTALL_PREFIX)
    set (CMAKE_INSTALL_PREFIX "${CMAKE_SOURCE_DIR}-install/" CACHE PATH "CMake install Directory" FORCE )
endif()

function( BpcInstallPackage )
	if( NOT CMAKE_CONFIGURATION_TYPES )
		set( CMAKE_CONFIGURATION_TYPES "${CMAKE_BUILD_TYPE}" )
	endif()
	
	cmake_parse_arguments( "PACKAGE"
		"ALL_COMPILERS;USE_HEADER_SUBFOLDER" "COMPATIBILITY;NAMESPACE;NAME;VERSION" "TARGETS" ${ARGN}
	)

	if( NOT PACKAGE_COMPATIBILITY )
		set( PACKAGE_COMPATIBILITY AnyNewerVersion )
	endif()
	
	if( NOT PACKAGE_NAME )
		set( PACKAGE_NAME ${CMAKE_PROJECT_NAME} )
	endif()
		
	message( STATUS "Creating \"${PACKAGE_NAME}\" installation for targets: ${PACKAGE_TARGETS}" )
	
	set( ns )
	if( PACKAGE_NAMESPACE )
		set( ns "NAMESPACE;${PACKAGE_NAMESPACE}" )
	endif()
	
	string( TOLOWER ${PACKAGE_NAME} package )
	string( TOUPPER ${PACKAGE_NAME} PACKAGE )

	if( NOT PACKAGE_VERSION )
		message( FATAL_ERROR "Missing version argument!" )
	endif()

	if( PACKAGE_ALL_COMPILERS )
		set( CONF_ROOT "cmake/ALL_COMPILERS" )
		set( INST_ROOT "ALL_COMPILERS" )
	else()
		set( CONF_ROOT "cmake/${BPC_COMPILER}" )
		set( INST_ROOT ${BPC_COMPILER} )
	endif()

	set( CONF_DESTINATION "${CONF_ROOT}/${package}-${PACKAGE_VERSION}" )
	set( INST_DESTINATION "${INST_ROOT}/${package}/${package}-${PACKAGE_VERSION}" )

	if( WIN32 )
		foreach( config ${CMAKE_CONFIGURATION_TYPES} )
			string( TOUPPER ${config} CONFIG )
			set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_${CONFIG} "${CMAKE_BINARY_DIR}/bin/${config}")
			set(CMAKE_LIBRARY_OUTPUT_DIRECTORY_${CONFIG} "${CMAKE_BINARY_DIR}/bin/${config}")
			set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY_${CONFIG} "${CMAKE_BINARY_DIR}/lib/${config}")
		endforeach()
	endif()

	write_basic_package_version_file(
		"${CMAKE_CURRENT_BINARY_DIR}/${package}-config-version.cmake"
		VERSION ${PACKAGE_VERSION}
		COMPATIBILITY ${PACKAGE_COMPATIBILITY}
	)
			
	install(FILES "${CMAKE_CURRENT_BINARY_DIR}/${package}-config-version.cmake" 
		DESTINATION ${CONF_DESTINATION} )

	if( PACKAGE_USE_HEADER_SUBFOLDER )
		set( INC_DESTINATION ${INST_DESTINATION}/include/${package} )
	else()
		set( INC_DESTINATION ${INST_DESTINATION}/include )
	endif()
	
	foreach( config ${CMAKE_CONFIGURATION_TYPES} )
		string( TOUPPER ${config} CONFIG )

		if( WIN32 )
			foreach( target ${PACKAGE_TARGETS} )
				get_target_property( type ${target} TYPE )
				
				if( type STREQUAL EXECUTABLE OR type STREQUAL SHARED_LIBRARY OR type STREQUAL MODULE_LIBRARY )
					set( IS_RUNTIME_TARGET TRUE )
				else()
					set( IS_RUNTIME_TARGET FALSE )
				endif()
			
				# message( "TARGET: ${target} is RTT?: ${IS_RUNTIME_TARGET}" )
				
				if ( IS_RUNTIME_TARGET AND MSVC )
					bpc_get_symbol_dir( ${target}  ${config} sydir )
					bpc_get_symbol_name( ${target} ${config} syname )

					install( PROGRAMS "${sydir}/${syname}"
						DESTINATION "${INST_DESTINATION}/bin/${config}"
						CONFIGURATIONS ${config} )
				endif()
			endforeach()
		endif()
		
		install( TARGETS ${PACKAGE_TARGETS} EXPORT "${package}.${config}" CONFIGURATIONS ${config} 
			RUNTIME DESTINATION ${INST_DESTINATION}/bin/${config}
			LIBRARY DESTINATION ${INST_DESTINATION}/bin/${config}
			ARCHIVE DESTINATION ${INST_DESTINATION}/lib/${config}
			PUBLIC_HEADER DESTINATION ${INC_DESTINATION}
			INCLUDES DESTINATION ${INST_DESTINATION}/include
		)
		install(EXPORT "${package}.${config}" ${ns} DESTINATION ${CONF_DESTINATION} CONFIGURATIONS ${config} FILE ${package}-config.cmake)
	endforeach()
endfunction()
