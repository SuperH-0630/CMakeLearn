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
=================================================================]]

cmake_minimum_required(VERSION 3.20)  # 设定cmake的版本, 当运行该CMakeLists.txt的CMake解释器低于该版本是将会报错
project(cmake-learn LANGUAGES C)  # 设置项目的名称

add_executable(hello main.c)  # 编译一个可执行程序, 使用main.c为源代码, 可执行程序的名字为hello

add_library(msg msg.c msgBeautiful.c _msg.h)  # 生成一个库文件
target_sources(msg  # 追加源文件到msg中, 源文件被定义为PUBLIC类型
    PUBLIC
        msg.h
)

target_link_libraries(hello msg)  # hello链接msg