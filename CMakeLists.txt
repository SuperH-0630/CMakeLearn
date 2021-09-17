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
    注意: if的条件访问变量时不需要${}符号, 例如 if(var1)实际上就是条件时var1的值而不是var1字符串本身 (if已经自动解引用变量, 不需要再显式使用${})
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

execute_process 在CMake配置时运行程序
add_custom_command 添加自定义命令
add_custom_target 添加自定义目标

file 指令主要处理文件IO相关的操作
list 指令主要处理列表相关的操作
=================================================================]]

cmake_minimum_required(VERSION 3.20)
project(cmake-learn LANGUAGES C)
set(CMAKE_C_STANDARD 11)
set(C_EXTENSIONS OFF)
set(C_STANDARD_REQUIRED OFF)

include(cmake/CMakeFindExternalProject/init.cmake)
wi_set_install_dir()  # 设置安装的目录

cfep_find_dir(msgTargets
              SOURCE_DIR "${CMAKE_SOURCE_DIR}/deps/msg"
              EXTERNAL TIMEOUT 60)

add_executable(learn main.c)
target_link_libraries(learn message::msg)

wi_copy_import(TARGETS message::msg)
if (msgTargets_CFEP_FOUND)  # 拷贝内容
    file(TOUCH ${msgTargets_CFEP_INSTALL}/bin/test_a.dll)  # 为检验wi_copy_dll_bin创建而创建
    file(TOUCH ${msgTargets_CFEP_INSTALL}/test_a2.dll)  # 为检验wi_copy_dll_dir创建而创建
    file(TOUCH ${msgTargets_CFEP_INSTALL}/test_a2.exe)  # 为检验wi_copy_dll_dir创建而创建

    wi_copy_dll_bin(DIRS ${msgTargets_CFEP_INSTALL}/bin)
    wi_copy_dll_dir(DIRS ${msgTargets_CFEP_INSTALL})
endif()

file(TOUCH ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/test.dll)  # 为检验wi_install_dll_bin创建而创建
file(TOUCH ${CMAKE_BINARY_DIR}/test2.dll)  # 为检验wi_install_dll_dir创建而创建
file(TOUCH ${CMAKE_BINARY_DIR}/test2.exe)  # 为检验wi_install_dll_dir创建而创建

wi_install(INSTALL TARGETS learn)
wi_install_import(TARGETS message::msg)
wi_install_dll_bin(DIRS ${CMAKE_RUNTIME_OUTPUT_DIRECTORY})
wi_install_dll_dir(DIRS ${CMAKE_BINARY_DIR})