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

add_subdirectory添加一个子目录 注意: 是添加子目录而不是子程序 (子程序需要使用超级构建)

include 可以导入文件来执行(一般是.cmake文件), 并且不会生成新的变量空间

可以设置CMAKE_ARCHIVE_OUTPUT_DIRECTORY, CMAKE_RUNTIME_OUTPUT_DIRECTORY等变量来控制add_library, add_executable对目标的输出位置

execute_process  在CMake配置时运行程序
=================================================================]]

cmake_minimum_required(VERSION 3.20)  # 设定cmake的版本, 当运行该CMakeLists.txt的CMake解释器低于该版本是将会报错
project(cmake-learn LANGUAGES C)  # 设置项目的名称

#[[
定义输出目录
GNUInstallDirs中定义了GNU标准的输出文件夹名字, 例如:
CMAKE_INSTALL_LIBDIR lib
CMAKE_INSTALL_BINDIR bin
]]
include(GNUInstallDirs)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY  # 静态库的输出路径
        ${PROJECT_BINARY_DIR}/${CMAKE_INSTALL_LIBDIR})
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY  # 动态库(或者动态库的导入文件)的输出路径
        ${PROJECT_BINARY_DIR}/${CMAKE_INSTALL_LIBDIR})
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY
        ${PROJECT_BINARY_DIR}/${CMAKE_INSTALL_BINDIR})  # 可执行文件(以及.dll)的输出路径

add_executable(hello main.c)  # 编译一个可执行程序, 使用main.c为源代码, 可执行程序的名字为hello

option(BUILD_LIBRARY "Build msg library" ON)  # 添加一个选项, 寻味是否构建库
if (BUILD_LIBRARY)
    add_subdirectory(msg)
    target_link_libraries(hello msg)  # hello链接msg
else()  # 不构建库, 库的代码被直接写到hello中
    target_sources(hello
        PRIVATE
            msg/msg.c msg/msgBeautiful.c msg/_msg.h
        PUBLIC
            include/msg.h
        )
    target_include_directories(hello PUBLIC include)
endif()

message(STATUS "Hello, CMake!")  # 显示一条STATUS信息
# message(WARNING "I am warning.")  # 显示一条WARNING信息
# message(FATAL_ERROR "I am error!")  # 显示一条错误信息, CMake停止运行
# message(SEND_ERROR "I am send_error!")  # 显示一条错误信息, CMake不会停止运行, 但不生成内容(无法构建项目)

if(NOT CMAKE_BUILD_TYPE)  # 若CMAKE_BUILD_TYPE为空(未定义)
    set(CMAKE_BUILD_TYPE "Debug" CACHE STRING "Build type" FORCE)  # 设置CACHE变量CMAKE_BUILD_TYPE
endif()

include(cmake/print_info.cmake)
include(cmake/print_info.cmake)  # 第二次导入将不会再输出文件信息, 但是会输出"include print_info"
message(STATUS "PRINT_INFO = ${PRINT_INFO}")  # PRINT_INFO在cmake/print_info.cmake中定义

# 关于find_package还有Module模式Config模式等之分
find_package(Python3 COMPONENTS Interpreter Development)  # 通过FindPython3.cmake文件(CMake内置的文件)寻找Python3的可执行程序
if(Python3_FOUND)
    message(STATUS "Python3_EXECUTABLE = ${Python3_EXECUTABLE}")  # Python3的可执行程序
    message(STATUS "Python3_LIBRARIES = ${Python3_LIBRARIES}")  # Python3的库(Windows上为导入库)
    message(STATUS "Python3_RUNTIME_LIBRARY_DIRS = ${Python3_RUNTIME_LIBRARY_DIRS}")  # Python3的运行时库(Windows上为.dll)
else()
    message(WARNING "Python3 Not Found")
endif()

# 启用测试
# 一般情况下, 在顶层的CMakeLists.txt执行enable_testing
enable_testing()
add_subdirectory(test)  # 添加测试

if(Python3_FOUND)
    execute_process(  # 在CMake配置时运行程序
            COMMAND  # 代码会按顺序执行
                ${Python3_EXECUTABLE} "-c" "print(\"I am execute_process\");a"  # 打印内容后, 访问不存在的变量a
            RESULT_VARIABLE re  # 存储结果
            OUTPUT_VARIABLE _stdout  # stdout的输出内容
            ERROR_VARIABLE _stderr  # stderr的输出内容
            OUTPUT_STRIP_TRAILING_WHITESPACE
            ERROR_STRIP_TRAILING_WHITESPACE
    )

    message(STATUS "result = ${re}")  # 因为访问不存在的变量a, 故会诱发python错误, result = 1
    message(STATUS "stdout = ${_stdout}")
endif()

include(cmake/custom_target_test.cmake)  # 添加custom_target_test测试程序