#[[==============================================================
文件名: CMakeLists.txt

2021/9/25 (1)
cmake_minimum_required不仅可以设定一个版本最小值, 还可以设定版本的一个范围, 具体可以参见文档
project是顶级CMakeLists.txt所必须的, Languages表示该项目需要使用的语言, c++语言用CXX表示
add_executable的第一个参数表示可执行程序的名字, 不需要包含后缀, cmake会根据不同的平台设定正确的后缀

=================================================================]]

cmake_minimum_required(VERSION 3.20)  # 设定cmake的版本, 当运行该CMakeLists.txt的CMake解释器低于该版本是将会报错
project(cmake-learn LANGUAGES C)  # 设置项目的名称

add_executable(hello main.c)  # 编译一个可执行程序, 使用main.c为源代码, 可执行程序的名字为hello
