PROJECT(sqlite3)
cmake_minimum_required(VERSION 2.8)

# Switch on BpcPackage
if( EXISTS "${CMAKE_CURRENT_LIST_DIR}/bpc-package/BpcPackage.cmake" )
  include( "bpc-package/BpcPackage.cmake" )
endif()

include_directories(${CMAKE_SOURCE_DIR}/src)
add_library(sqlite3 SHARED src/sqlite3.c src/sqlite3.h src/sqlite3ext.h src/sqlite3.def)
add_executable(sqlite src/sqlite3.c src/shell.c src/sqlite3.h src/sqlite3ext.h)
set_target_properties(sqlite PROPERTIES OUTPUT_NAME sqlite3)

add_definitions(-DSQLITE_ENABLE_RTREE)
add_definitions(-DSQLITE_ENABLE_FTS4)
add_definitions(-DSQLITE_ENABLE_FTS5)
add_definitions(-DSQLITE_ENABLE_JSON1)
add_definitions(-DSQLITE_ENABLE_RBU)
add_definitions(-DSQLITE_ENABLE_STAT4)

set_target_properties(sqlite3 PROPERTIES PUBLIC_HEADER "src/sqlite3.h;src/sqlite3ext.h")

# Uncomment this for single-threaded variant (faster)
#add_definitions(-DSQLITE_THREADSAFE=0)

if(NOT WIN32)
  include(FindThreads)
  target_link_libraries(sqlite m ${CMAKE_THREAD_LIBS_INIT} ${CMAKE_DL_LIBS})
endif()

if ( BPC_PACKAGE_FOUND )
  BpcInstallPackage( NAME SQLite3 VERSION ${VERSION} TARGETS sqlite3 )
else()
	install(FILES src/sqlite3.h src/sqlite3ext.h DESTINATION include)
	install(TARGETS sqlite3 LIBRARY DESTINATION lib ARCHIVE DESTINATION lib)
	install(TARGETS sqlite RUNTIME DESTINATION bin)
endif()
