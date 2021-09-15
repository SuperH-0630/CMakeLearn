#[[==============================================================
文件名: CMakeLists.txt

2021/9/25
cmake_minimum_required不仅可以设定一个版本最小值, 还可以设定版本的一个范围, 具体可以参见文档
project是顶级CMakeLists.txt所必须的, Languages表示该项目需要使用的语言, c++语言用CXX表示
add_executable的第一个参数表示可执行程序的名字, 不需要包含后缀, cmake会根据不同的平台设定正确的后缀

add_librar与add_executable类型, 用于生成一个函数库(默认情况下是静态库)
target_sources会追加源文件到目标中
目标: 即通过add_librar与add_executable构建的对象, 例如此例子中的msg和hello
为什么.h要写入头文件中: 其实我也没有很确切的理由, 实际上尽管不添加大多数情况也可以运行, 我想应该是文件依赖管理吧
PUBLIC是什么意思: 例如hello依赖msg库, 则hello的源文件中也会自动添加msg的PUBLIC源文件
INTERFACE和PRIVATE: 除了PUBLIC, 还有这两种类型.
    PRIVATE表示只添加到msg中
    INTERFACE表示只添加到依赖msg的目标中(例如hello)
    PUBLIC = PRIVATE + INTERFACE
target_link_libraries用于添加一个库链接

if() ... elseif() ... else() ... endif() 表示一个条件语句
option 表示添加一个CMake参数
    注意: 在cmake-gui只有当该option被运算时, 才会将option显示出来
    例如, 将option(BUILD_LIBRARY "Build msg library" ON)修改为option(BUILD_LIBRARY "Build msg library" OFF)
        初次配置CMake时便将不会显示BUILD_SHARED_LIBRARY选项, 因为BUILD_LIBRARY为OFF
        option(BUILD_SHARED_LIBRARY "Build shared library" ON)没有执行
    在命令行则可以直接通过-Dxxx=yyy来使用参数
add_library添加的源码默认为PRIVATE

message 用于在CMake终端输出信息
CMAKE_C_COMPILER等变量记录的是编译器等的信息, 修改这些变量可以对编译产生影响
也可以通过-DCMAKE_C_COMPILER=xxx的方式在命令行修改这些选项

foreach(var item1 item2 item3...) ... endforeach() 表示一个遍历语句
foreach 还有range的迭代方式, 可以参见文档 foreach(var strat [end] [step])
=================================================================]]

cmake_minimum_required(VERSION 3.20)  # 设定cmake的版本, 当运行该CMakeLists.txt的CMake解释器低于该版本是将会报错
project(cmake-learn LANGUAGES C)  # 设置项目的名称

option(BUILD_LIBRARY "Build msg library" ON)  # 添加一个选项, 寻味是否构建库

add_executable(hello main.c)  # 编译一个可执行程序, 使用main.c为源代码, 可执行程序的名字为hello

if (BUILD_LIBRARY)
    option(BUILD_SHARED_LIBRARY "Build shared library" ON)  # 添加一个选项, 寻味是否构建库
    if (BUILD_SHARED_LIBRARY)
        add_library(msg SHARED "")  # 生成一个动态库
    else()
        add_library(msg STATIC "")  # 生成一个静态库
    endif()
    target_sources(msg  # 追加源文件到msg中, 源文件被定义为PUBLIC类型
        PRIVATE  # 何为PRIVATE和PUBLIC可以参见上文注释
            msg.c msgBeautiful.c _msg.h
        PUBLIC
            msg.h
    )
    target_link_libraries(hello msg)  # hello链接msg
else()  # 不构建库, 库的代码被直接写到hello中
    target_sources(hello
        PRIVATE
            msg.c msgBeautiful.c _msg.h
        PUBLIC
            msg.h
    )
endif()

message(STATUS "Hello, CMake!")  # 显示一条STATUS信息
# message(WARNING "I am warning.")  # 显示一条WARNING信息
# message(FATAL_ERROR "I am error!")  # 显示一条错误信息, CMake停止运行
# message(SEND_ERROR "I am send_error!")  # 显示一条错误信息, CMake不会停止运行, 但不生成内容(无法构建项目)

if(NOT CMAKE_BUILD_TYPE)  # 若CMAKE_BUILD_TYPE为空(未定义)
    set(CMAKE_BUILD_TYPE "Debug" CACHE STRING "Build type" FORCE)  # 设置CACHE变量CMAKE_BUILD_TYPE
endif()

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

# 关于find_package还有Module模式Config模式等之分
find_package(Python3 COMPONENTS Interpreter Development)  # 通过FindPython3.cmake文件(CMake内置的文件)寻找Python3的可执行程序

if(Python3_FOUND)
    message("Python3_EXECUTABLE = ${Python3_EXECUTABLE}")  # Python3的可执行程序
    message("Python3_LIBRARIES = ${Python3_LIBRARIES}")  # Python3的库(Windows上为导入库)
    message("Python3_RUNTIME_LIBRARY_DIRS = ${Python3_RUNTIME_LIBRARY_DIRS}")  # Python3的运行时库(Windows上为.dll)
else()
    message(WARNING "Python3 Not Found")
endif()
