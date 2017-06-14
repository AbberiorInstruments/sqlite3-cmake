# Settings for original CMakeLists.txt as not change stuff
if( BPC_PACKAGE_FOUND )

set( VERSION "3.19.3" )

else()
# Platforms for which to build
set( BPC_PACKAGE_PLATFORMS "MSVC-32-14.0;MSVC-64-14.0;GNU-64-Linux-4.7.4;NISOM" )

endif()