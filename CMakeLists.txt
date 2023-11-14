#note: experimental
#      currently only used for generating `compile_commands.json` for clangd.
#      to build this project, it's suggested to use `makefile` instead

cmake_minimum_required(VERSION 3.7)
project(udp2raw)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

set(CMAKE_CXX_STANDARD 11)

#Where to find local cmake scripts
# set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${PROJECT_SOURCE_DIR}/cmake/modules")
set(CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake/modules")
set(CMAKE_DEBUG_OUTPUT ON)

# https://github.com/iovisor/bcc/blob/master/CMakeLists.txt
include(cmake/GetGitRevisionDescription.cmake)
include(cmake/version.cmake)

# configuare a header file for settings
INCLUDE_DIRECTORIES(${CMAKE_BINARY_DIR})
string(TIMESTAMP COMPILE_TIME %Y%m%d-%H%M%S)
configure_file(src/version.h.in ${CMAKE_BINARY_DIR}/version.h)

set(SOURCE_FILES
        src/main.cpp
        src/encrypt.cpp
        src/log.cpp
        src/network.cpp
        src/common.cpp
        src/connection.cpp
        src/misc.cpp
        src/fd_manager.cpp
        src/client.cpp
        src/server.cpp
        src/my_ev.cpp
        lib/aes_faster_c/aes.cpp
        lib/aes_faster_c/wrapper.cpp
        lib/md5.cpp
        lib/pbkdf2-sha1.cpp
        lib/pbkdf2-sha256.cpp
)
set(CMAKE_CXX_FLAGS "-Wall -Wextra -Wno-unused-variable -Wno-unused-parameter -Wno-missing-field-initializers")
set(CMAKE_CXX_FLAGS_RELEASE "-Os")
set(CMAKE_CXX_FLAGS_DEBUG "-O2 -g -fsanitize=address,undefined")

#targets for multi-platform version (native compile)
# cygwin:git_version
#   ${cc_local}   -o ${NAME}_$@          -I. ${SOURCES} pcap_wrapper.cpp ${FLAGS} -lrt -ggdb -static -O2 -D_GNU_SOURCE ${MP}
MESSAGE("CMAKE_SYSTEM_NAME: ${CMAKE_SYSTEM_NAME}")
if(CMAKE_SYSTEM_NAME MATCHES "Cygwin"
    OR CMAKE_SYSTEM_NAME MATCHES "MSYS")
  MESSAGE("Configure System: ${CMAKE_SYSTEM_NAME}")
  add_definitions(-DUDP2RAW_MP)
  add_definitions(-D_GNU_SOURCE)

  # set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -ggdb -static")
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -ggdb")

  list(APPEND SOURCE_FILES src/pcap_wrapper.cpp)

  # target_link_libraries(udp2raw rt)
  set(LINK_EXTRA_LIBS rt)
endif()

# mingw:git_version
# 	${cc_local}   -o ${NAME}_$@         -I. ${SOURCES} pcap_wrapper.cpp ${FLAGS} -ggdb -static -O2 -lws2_32 ${MP}
if(CMAKE_SYSTEM_NAME MATCHES "MINGW")
  add_definitions(-DUDP2RAW_MP)
  add_definitions(-D_GNU_SOURCE)

  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -lrt -ggdb -static")

  list(APPEND SOURCE_FILES src/pcap_wrapper.cpp)

  # target_link_libraries(udp2raw rt ws2_32)
  set(LINK_EXTRA_LIBS rt ws2_32)
endif()

# mingw_wepoll:git_version
# 	${cc_local}   -o ${NAME}_$@        -I. ${SOURCES0} pcap_wrapper.cpp ${FLAGS} -ggdb -static -O2 -DNO_LIBEV_EMBED -D_WIN32 -lev -lws2_32 ${MP}

# linux:git_version
# 	${cc_local}   -o ${NAME}_$@          -I. ${SOURCES} ${PCAP} ${FLAGS} -lrt -ggdb -static -O2 ${MP}
if(CMAKE_SYSTEM_NAME MATCHES "Linux")
  add_definitions(-DUDP2RAW_MP)

  # set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -ggdb -static")
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -ggdb")

  # target_link_libraries(udp2raw rt)
  find_package(PCAP REQUIRED)
  if(PCAP_FOUND)
    include_directories(${PCAP_INCLUDE_DIRS})
    message("PCAP libs: ${PCAP_LIBRARIES}")
    set(LINK_EXTRA_LIBS rt ${PCAP_LIBRARIES})
    # target_link_libraries(udp2raw ${PCAP_LIBRARIES})
    # target_link_libraries(udp2raw pcap dubs-1 systemd)
    # target_link_libraries(udp2raw libpcap.a libdbus-1.a libsystemd.a)
  endif()
endif()

# freebsd:git_version
# 	${cc_local}   -o ${NAME}_$@        -I. ${SOURCES} ${PCAP} ${FLAGS} -lrt -ggdb -static -libverbs -O2 ${MP}
if(CMAKE_SYSTEM_NAME MATCHES "FreeBSD"
    OR CMAKE_SYSTEM_NAME MATCHES "OpenBSD"
    OR CMAKE_SYSTEM_NAME MATCHES "NetBSD"
    OR CMAKE_SYSTEM_NAME MATCHES "DragonFlyBSD")
  add_definitions(-DUDP2RAW_MP)

  # target_link_libraries(udp2raw rt pcap ibverbs)
  set(LINK_EXTRA_LIBS rt pcap ibverbs)
endif()

# Check if the OS is either macOS or MinGW
# mac:git_version
# 	${cc_local}   -o ${NAME}_$@        -I. ${SOURCES} ${PCAP} ${FLAGS} -ggdb -O2 ${MP}
if(CMAKE_SYSTEM_NAME MATCHES "Darwin"
    OR CMAKE_SYSTEM_NAME MATCHES "MINGW")
  add_definitions(-DUDP2RAW_MP)

  # target_link_libraries(udp2raw pcap)
  set(LINK_EXTRA_LIBS pcap)
endif()

#targets for multi-platform version (cross compile)
# mingw_cross:git_version
# 	${cc_mingw_cross}   -o ${NAME}_mp.exe          -I. ${SOURCES} pcap_wrapper.cpp ${FLAGS} -ggdb -static -O2 -lws2_32 ${MP}

add_executable(udp2raw ${SOURCE_FILES})
# target_link_libraries(udp2raw rt)
target_link_libraries(udp2raw pthread)
target_link_libraries(udp2raw ${LINK_EXTRA_LIBS})
include_directories(SYSTEM "libev")
include_directories("." "src")

set(CPACK_SOURCE_GENERATOR "TGZ")
set(CPACK_SOURCE_IGNORE_FILES
  \\.git/
  build/
  ".*~$"
  )
set(CPACK_VERBATIM_VARIABLES YES)
set(CPACK_SYSTEM_NAME "${CMAKE_SYSTEM_NAME}-${CMAKE_SYSTEM_PROCESSOR}")
set(CPACK_GENERATOR "TGZ")

install(TARGETS udp2raw RUNTIME DESTINATION bin)

include(CPack)
