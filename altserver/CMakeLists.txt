 Copyright (c) (2018-2022) Apple Inc. All rights reserved.
#
# corecrypto is licensed under Apple Inc.’s Internal Use License Agreement
# (which is contained in the License.txt file distributed with corecrypto) and
# only to people who accept that license. IMPORTANT:  Any license rights granted
# to you by Apple Inc. (if any) are limited to internal use within your
# organization only on devices and computers you own or control, for the sole
# purpose of verifying the security characteristics and correct functioning of
# the Apple Software.  You may not, directly or indirectly, redistribute the
# Apple Software or any portions thereof.

#
# CMake corecrypto build for Linux and Darwin.
#

cmake_minimum_required(VERSION 3.4.3)
set(CMAKE_OSX_SYSROOT "macosx.internal") # NOTE: This must be set before the
                                         # call to project

option(CC_LINUX_ASM "Enable assembler support on Linux platform" OFF)
option(CC_SMALL_CODE "Enable small code" OFF)
option(BUILD_FOR_ARMV7 "Cross-compile for ARMv7" OFF)
option(BUILD_FOR_ARMV6 "Cross-compile for ARMv6" OFF)

if(BUILD_FOR_ARMV6)
  set(CMAKE_C_COMPILER "arm-none-eabi-gcc")
  set(CMAKE_C_FLAGS "-mcpu=cortex-m0 -mfloat-abi=soft")
  set(CMAKE_EXE_LINKER_FLAGS "--specs=rdimon.specs")

  enable_language(ASM)
  set(CMAKE_ASM_COMPILER "arm-none-eabi-gcc")
  set(CMAKE_ASM_FLAGS "-x assembler-with-cpp ${CMAKE_C_FLAGS}")
endif()

if(BUILD_FOR_ARMV7)
  set(CMAKE_SYSTEM_NAME Linux)
  set(CMAKE_SYSTEM_PROCESSOR arm)

  set(triple armv7-linux-gnueabihf)

  set(CMAKE_C_COMPILER clang)
  set(CMAKE_C_COMPILER_TARGET ${triple})
  set(CMAKE_CXX_COMPILER clang++)
  set(CMAKE_CXX_COMPILER_TARGET ${triple})
  set(CMAKE_ASM_COMPILER clang)
  set(CMAKE_ASM_COMPILER_TARGET ${triple})

  set(CMAKE_C_FLAGS "-I/usr/arm-linux-gnueabihf/include")
  set(LINKER_FLAGS "-fuse-ld=/usr/arm-linux-gnueabihf/bin/ld")
  set(CMAKE_EXE_LINKER_FLAGS "${LINKER_FLAGS}")
  set(CMAKE_SHARED_LINKER_FLAGS "${LINKER_FLAGS}")
  set(CMAKE_LIBRARY_PATH "/usr/arm-linux-gnueabihf/lib/")
endif()

project(corecrypto C)

include(CoreCryptoSources.cmake)

#
# For code coverage, we use the code-coverage.cmake script from
# https://github.com/StableCoder/.
#
include(scripts/code-coverage.cmake)

#
# Build Macros and Targets
#

# get_include_dirs: extract include directories from list of headers
macro(get_include_dirs out in)
  foreach(file ${in})

    # Add directory including the header
    get_filename_component(dir ${file} DIRECTORY)
    list(APPEND ${out} ${dir})

    # If the directory is corecrypto, we should also add its parent to the
    # include dir.
    get_filename_component(dirname ${dir} NAME)
    if(${dirname} STREQUAL "corecrypto")
      get_filename_component(parent ${dir} DIRECTORY)
      list(APPEND ${out} ${parent})
    endif()

  endforeach()
endmacro()

# Project-level settings

# Build all objects with -fPIC
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

# CMake spelling of -std=gnu99
set(CMAKE_C_STANDARD 99)
set(CMAKE_C_EXTENSIONS ON)

# Project-globals
set_property(
  DIRECTORY
  APPEND
  PROPERTY COMPILE_DEFINITIONS
           $<$<CONFIG:Debug>:DEBUG=1> $<$<CONFIG:Release>:NDEBUG>)
set(CC_C_OPTIONS -DBUILDKERNEL=0 -Wundef -Wcast-qual
                 -Wno-error=deprecated-declarations $<$<CONFIG:Debug>:-Werror>)
add_compile_options("$<$<COMPILE_LANGUAGE:C>:${CC_C_OPTIONS}>")
if(CODE_COVERAGE)
  add_code_coverage() # Adds instrumentation to all targets
endif()

# System dependencies
find_package(UnixCommands REQUIRED) # For ${BASH}

# Threads
find_package(Threads)
if(Threads_FOUND)
  set(THREADS_PKG "Threads::Threads")
else()
  message(WARNING "Threads not found.")
endif()

# libm
find_library(MATH_LIBRARY m DOC "libm")
if(NOT MATH_LIBRARY)
  message(WARNING "libm not found.")
  unset(MATH_LIBRARY CACHE)
endif()

# Platform-specific dependencies
if(CMAKE_SYSTEM_NAME STREQUAL "Darwin")

  find_library(SYSTEM_FRAMEWORK NAMES System)
  mark_as_advanced(SYSTEM_FRAMEWORK)
  find_path(SYSTEM_CPU_CAPABILITIES_PATH i386/cpu_capabilities.h
            HINTS "${SYSTEM_FRAMEWORK}/PrivateHeaders")
  mark_as_advanced(SYSTEM_CPU_CAPABILITIES_PATH)
  if(NOT SYSTEM_FRAMEWORK OR NOT SYSTEM_CPU_CAPABILITIES_PATH)
    unset(SYSTEM_FRAMEWORK CACHE)
    message(
      SEND_ERROR
        "Could not find internal System.framework\n"
        "HINT: Run cmake with xcrun to point it at the right SDK, or try:\n"
        "  ${CMAKE_COMMAND} -DCMAKE_OSX_SYSROOT=macosx.internal .")
  else()
    message("-- Found internal System.framework")
  endif()

  find_library(
    KPERF_FRAMEWORK
    NAMES kperf
    PATHS ${CMAKE_OSX_SYSROOT}/System/Library/PrivateFrameworks)
  mark_as_advanced(KPERF_FRAMEWORK)
  find_path(KPERF_KPC_PATH kpc.h HINTS "${KPERF_FRAMEWORK}/PrivateHeaders")
  mark_as_advanced(KPERF_KPC_PATH)
  if(NOT KPERF_FRAMEWORK OR NOT KPERF_KPC_PATH)
    unset(KPERF_FRAMEWORK CACHE)
    message(
      SEND_ERROR
        "Could not find internal kperf.framework\n"
        "HINT: Run cmake with xcrun to point it at the right SDK, or try:\n"
        "  ${CMAKE_COMMAND} -DCMAKE_OSX_SYSROOT=macosx.internal .")
  else()
    message("-- Found internal kperf.framework")
  endif()

  # Compile assembler sources in OSX
  enable_language(ASM)

  # avoid `ranlib` (which `ar` runs automatically) warnings about
  # objects with "no symbols" by modifying the archive commands

  # Add the `S` argument to `ar` so it will not run `randlib`
  set(CMAKE_C_ARCHIVE_CREATE "<CMAKE_AR> Sqc <TARGET> <LINK_FLAGS> <OBJECTS>")

  # Run `ranlib` directly with the additional argument to avoid the
  # warnings
  set(CMAKE_C_ARCHIVE_FINISH "<CMAKE_RANLIB> -no_warning_for_no_symbols -c <TARGET>")

elseif(CMAKE_SYSTEM_NAME STREQUAL "Linux")

  # Exclude sources that don't apply to Linux (or haven't yet been ported)
  set(CORECRYPTO_EXCLUDE_SRCS
      # exclude files that are OSX dependent
      cc_fips/src/fipspost_get_hmac.c
      cc_fips/src/fipspost_indicator.c
      cc_fips/src/fipspost_post.c
      cc_fips/src/fipspost_post_indicator.c
      cc_fips/src/fipspost_post_integrity.c
      cc_fips/src/fipspost_trace.c
      cc_fips/src/module_id.c
      cckprng/src/cckprng_diag.c
      cckprng/src/cckprng_diaggens.c
      cckprng/src/cckprng_generate.c
      cckprng/src/cckprng_init.c
      cckprng/src/cckprng_initgen.c
      cckprng/src/cckprng_loadseed.c
      cckprng/src/cckprng_printdiag.c
      cckprng/src/cckprng_ratchetseed.c
      cckprng/src/cckprng_refresh.c
      cckprng/src/cckprng_rekeygen.c
      cckprng/src/cckprng_rekeygens.c
      cckprng/src/cckprng_reseed.c
      cckprng/src/cckprng_storeseed.c
      cckprng/src/prng.c)

  if(CC_LINUX_ASM)
    enable_language(ASM)

    # Add assembler specific clang flags
    set(CC_ASM_OPTIONS -integrated-as # Always use clang internal assembler
                       -x assembler-with-cpp # Run preprocessor despite .s name
    )
    add_compile_options("$<$<COMPILE_LANGUAGE:ASM>:${CC_ASM_OPTIONS}>")

    # Enable Linux assembler in corecrypto
    add_compile_options("-DCC_LINUX_ASM=1")
  endif()
endif()

include(GNUInstallDirs)

#
# corecrypto_static library target
#

# A few include dirs cannot be automatically generated by the above headers
# list. Manually fix it up.
set(CORECRYPTO_FIXED_INCLUDE_DIRS
    ccaes/src/vng
    cckprng
    cckprng/corecrypto
    acceleratecrypto/Include
    acceleratecrypto/Header
    ccec25519/src)

# Find include dirs for corecrypto_static headers.
set(cc_include_dir ${CORECRYPTO_FIXED_INCLUDE_DIRS})
get_include_dirs(cc_include_dir "${CORECRYPTO_PROJECT_HDRS}")
get_include_dirs(cc_include_dir "${CORECRYPTO_PUBLIC_HDRS}")
get_include_dirs(cc_include_dir "${CORECRYPTO_PRIVATE_HDRS}")
list(REMOVE_DUPLICATES cc_include_dir)

# Filter out excluded sources
if(CORECRYPTO_EXCLUDE_SRCS)
  list(REMOVE_ITEM CORECRYPTO_SRCS ${CORECRYPTO_EXCLUDE_SRCS})
endif()

# Create target for corecrypto_static
add_library(corecrypto_static STATIC ${CORECRYPTO_SRCS})
target_link_libraries(
  corecrypto_static PRIVATE $<$<PLATFORM_ID:Darwin>:${SYSTEM_FRAMEWORK}>
                            ${MATH_LIBRARY})
target_include_directories(corecrypto_static PRIVATE ${cc_include_dir})
set_property(TARGET corecrypto_static PROPERTY POSITION_INDEPENDENT_CODE ON)

# Generate pkgconfig for corecrypto_static
configure_file("corecrypto.pc.in" "corecrypto.pc" @ONLY)

# Add defines
target_compile_definitions(corecrypto_static PRIVATE ENABLE_CRYPTOKIT_PRIVATE_DEFINITIONS)
if(CC_SMALL_CODE)
  target_compile_definitions(corecrypto_static PRIVATE CC_SMALL_CODE=1)
endif()

# Install corecrypto_static
if(CMAKE_SYSTEM_NAME STREQUAL "Darwin")
  # install the archive like a regular file, `ranlib` has already been
  # applied above.
  install(FILES $<TARGET_FILE:corecrypto_static> DESTINATION "${CMAKE_INSTALL_LIBDIR}")
else()
  install(TARGETS corecrypto_static ARCHIVE DESTINATION "${CMAKE_INSTALL_LIBDIR}")
endif()

install(FILES ${CORECRYPTO_PUBLIC_HDRS} ${CORECRYPTO_PRIVATE_HDRS}
        DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}/corecrypto")
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/corecrypto.pc
        DESTINATION "${CMAKE_INSTALL_LIBDIR}/pkgconfig")

# Add defines
if(CC_SMALL_CODE)
  target_compile_definitions(corecrypto_perf PRIVATE CC_SMALL_CODE=1)
endif()

