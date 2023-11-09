#note: experimental
#      currently only used for generating `compile_commands.json` for clangd.
#      to build this project, it's suggested to use `makefile` instead

cmake_minimum_required(VERSION 3.7)
project(udp2raw)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

set(CMAKE_CXX_STANDARD 11)

set(SOURCE_FILES
        main.cpp
        lib/md5.cpp
        lib/pbkdf2-sha1.cpp
        lib/pbkdf2-sha256.cpp
        encrypt.cpp
        log.cpp
        network.cpp
        common.cpp
        connection.cpp
        misc.cpp
        fd_manager.cpp
        client.cpp
        server.cpp
        lib/aes_faster_c/aes.cpp
        lib/aes_faster_c/wrapper.cpp
        my_ev.cpp
)
set(CMAKE_CXX_FLAGS "-Wall -Wextra -Wno-unused-variable -Wno-unused-parameter -Wno-missing-field-initializers")
set(CMAKE_CXX_FLAGS_RELEASE "-Os")
set(CMAKE_CXX_FLAGS_DEBUG "-O2 -g -fsanitize=address,undefined")

add_executable(udp2raw ${SOURCE_FILES})
target_link_libraries(udp2raw rt)
target_link_libraries(udp2raw pthread)
include_directories(SYSTEM "libev")
include_directories(".")

set(CPACK_SOURCE_GENERATOR "TGZ")
set(CPACK_SOURCE_IGNORE_FILES
  \\.git/
  build/
  ".*~$"
)
set(CPACK_VERBATIM_VARIABLES YES)

set(CPACK_GENERATOR "TGZ")
install(TARGETS udp2raw RUNTIME DESTINATION bin)

include(CPack)
