# # Copyright (c) PLUMgrid, Inc.
# # Licensed under the Apache License, Version 2.0 (the "License")
# if(NOT REVISION)
#   get_git_head_revision(GIT_REFSPEC GIT_SHA1)
#   string(SUBSTRING "${GIT_SHA1}" 0 8 GIT_SHA1_SHORT)
#   git_describe(GIT_DESCRIPTION)
#   git_describe(GIT_TAG_LAST "--abbrev=0" "--tags")
#   git_get_exact_tag(GIT_TAG_EXACT)
#   string(SUBSTRING "${GIT_TAG_LAST}+${GIT_SHA1_SHORT}" 1 -1 REVISION)
#   if(GIT_TAG_EXACT)
#     string(SUBSTRING "${GIT_TAG_EXACT}" 1 -1 REVISION)
#     message(STATUS "Currently on Git tag ${GIT_TAG_EXACT}")
#   else ()
#     message(STATUS "Latest recognized Git tag is ${GIT_TAG_LAST}")
#     set(GIT_TAG_EXACT "")
#   endif()
#   message(STATUS "Git HEAD is ${GIT_SHA1}")
#   # rpm/deb packaging uses this, only works on whole tag numbers
#   if(NOT REVISION_LAST)
#     string(SUBSTRING "${GIT_TAG_LAST}" 1 -1 REVISION_LAST)
#   endif()
# else()
#   set(REVISION_LAST "${REVISION}")
# endif()
#
# if (REVISION MATCHES "^([0-9]+)\\.([0-9]+)\\.([0-9]+)")
#     set(REVISION_MAJOR ${CMAKE_MATCH_1})
#     set(REVISION_MINOR ${CMAKE_MATCH_2})
#     set(REVISION_PATCH ${CMAKE_MATCH_3})
# else()
#   message(WARNING "Could not extract major/minor/patch from revision ${REVISION}" )
# endif()
# # strip leading 'v', and make unique for the tag
# message(STATUS "Revision is ${REVISION} (major ${REVISION_MAJOR}, minor ${REVISION_MINOR}, patch ${REVISION_PATCH})")

find_package(Git)
if(GIT_FOUND AND EXISTS "${CMAKE_SOURCE_DIR}/.git")
    # INCLUDE(GetGitRevisionDescription.cmake)
    EXECUTE_PROCESS(COMMAND ${GIT_EXECUTABLE} rev-parse --short HEAD OUTPUT_VARIABLE SHORT_SHA OUTPUT_STRIP_TRAILING_WHITESPACE)

    SET(REVISION ${SHORT_SHA} CACHE STRING "git short sha" FORCE)

    # only use the plugin to tie the configure state to the sha to force rebuilds
    # of files that depend on version.h
    # include(GetGitRevisionDescription.cmake)
    get_git_head_revision(REFSPEC COMMITHASH)
else()
    message(WARNING "Git not found, cannot set version info")

    SET(REVISION "unknown")
endif()
