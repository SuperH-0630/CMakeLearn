#[[
文件名: print_info.cmake
目标: 输出系统信息
]]

message(STATUS "include print_info")

include_guard(GLOBAL)  # 检测该文件是否重复导入, 若是非第一次导入则不再允许下面的代码

# 显示编译器信息(1)
message(STATUS "CMAKE_C_COMPILER = ${CMAKE_C_COMPILER}")  # 显示C编译器的路径
message(STATUS "CMAKE_C_FLAGS = ${CMAKE_C_FLAGS}")  # 显示C编译器的选项
message(STATUS "CMAKE_BUILD_TYPE = ${CMAKE_BUILD_TYPE}")  # 当前的构建类型(若为设置则为空)

# 显示构建类型的信息
#[[
构建类型: Debug, Release, RelWithDebInfo, MinSizeRel
解释:
Debug：用于在没有优化的情况下，使用带有调试符号构建库或可执行文件。
Release：用于构建的优化的库或可执行文件，不包含调试符号。
RelWithDebInfo：用于构建较少的优化库或可执行文件，包含调试符号。
MinSizeRel：用于不增加目标代码大小的优化方式，来构建库或可执行文件。

CMAKE_C_FLAGS变量记录的是当前编译器的参数, 不同的构建类型也有不同的默认参数
]]
message(STATUS "C flags, Debug configuration: ${CMAKE_C_FLAGS_DEBUG}")
message(STATUS "C flags, Release configuration: ${CMAKE_C_FLAGS_RELEASE}")
message(STATUS "C flags, Release configuration with Debug info: ${CMAKE_C_FLAGS_RELWITHDEBINFO}")
message(STATUS "C flags, minimal Release configuration: ${CMAKE_C_FLAGS_MINSIZEREL}")

# 显示CMake信息
message(STATUS "CMAKE_CURRENT_SOURCE_DIR = ${CMAKE_CURRENT_SOURCE_DIR}")  # 显示当前CMake文件的所在目录
message(STATUS "CMAKE_BINARY_DIR = ${CMAKE_BINARY_DIR}")  # 显示CMake的构建目录

# 显示操作系统信息
message(STATUS "CMAKE_SYSTEM_NAME = ${CMAKE_SYSTEM_NAME}")
if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
    message(STATUS "On Linux")
elseif(CMAKE_SYSTEM_NAME STREQUAL "Darwin")
    message(STATUS "On MacOS")
elseif(CMAKE_SYSTEM_NAME STREQUAL "Windows")
    message(STATUS "On Windows")
else()
    message(STATUS "On ${CMAKE_SYSTEM_NAME}")
endif()

# 显示编译器信息(2)
message(STATUS "CMAKE_C_COMPILER_ID = ${CMAKE_C_COMPILER_ID}")
if(CMAKE_C_COMPILER_ID MATCHES Intel)
    message(STATUS "Intel COMPILER")
elseif(CMAKE_C_COMPILER_ID MATCHES GNU)
    message(STATUS "GNU COMPILER")
elseif(CMAKE_C_COMPILER_ID MATCHES PGI)
    message(STATUS "PGI COMPILER")
elseif(CMAKE_C_COMPILER_ID MATCHES XL)
    message(STATUS "XL COMPILER")
endif()

# 显示处理器信息
# 使用CMAKE_SIZEOF_VOID_P是检查当前CPU是否具有32位或64位架构的唯一"真正"可移植的方法
if(CMAKE_SIZEOF_VOID_P EQUAL 8)
    message(STATUS "Target is 64 bits")
else()
    message(STATUS "Target is 32 bits")
endif()

message(STATUS "CMAKE_HOST_SYSTEM_PROCESSOR = ${CMAKE_HOST_SYSTEM_PROCESSOR}")
if(CMAKE_HOST_SYSTEM_PROCESSOR MATCHES "i386")
    message(STATUS "i386 architecture detected")
elseif(CMAKE_HOST_SYSTEM_PROCESSOR MATCHES "i686")
    message(STATUS "i686 architecture detected")
elseif(CMAKE_HOST_SYSTEM_PROCESSOR MATCHES "x86_64")
    message(STATUS "x86_64 architecture detected")
else()
    message(STATUS "host processor architecture is unknown")
endif()

#[[
CMAKE_SYSTEM_NAME, CMAKE_C_COMPILER_ID, CMAKE_HOST_SYSTEM_PROCESSOR并不总是对所有的系统或编译器有效
当然, 大部分常见系统, 编译器确实可以使用这种方法来判断
]]


# 查询主机信息
# 使用cmake_host_system_information, RESULT参数是结果存储的位置, QUERY参数表示需要获取的信息
option(PRINT_SYS_INFO "Print system information" OFF)
if(PRINT_SYS_INFO)
    foreach(key
        IN ITEMS
        NUMBER_OF_LOGICAL_CORES
        NUMBER_OF_PHYSICAL_CORES
        TOTAL_VIRTUAL_MEMORY
        AVAILABLE_VIRTUAL_MEMORY
        TOTAL_PHYSICAL_MEMORY
        AVAILABLE_PHYSICAL_MEMORY
        IS_64BIT
        HAS_FPU
        HAS_MMX
        HAS_MMX_PLUS
        HAS_SSE
        HAS_SSE2
        HAS_SSE_FP
        HAS_SSE_MMX
        HAS_AMD_3DNOW
        HAS_AMD_3DNOW_PLUS
        HAS_IA64
        OS_NAME
        OS_RELEASE
        OS_VERSION
        OS_PLATFORM
        )
        cmake_host_system_information(RESULT re QUERY ${key})
        message(STATUS "cmake_host_system_information ${key} = ${re}")
    endforeach()
endif()

set(PRINT_INFO TRUE)  # 设置一个变量