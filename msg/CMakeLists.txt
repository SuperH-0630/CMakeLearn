#[[
文件名: msg\CMakeLists.txt
生成msg库, 并链接到hello
]]

option(BUILD_SHARED_LIBRARY "Build shared library" ON)  # 添加一个选项, 寻味是否构建库

if (BUILD_SHARED_LIBRARY)
    add_library(msg SHARED "")  # 生成一个动态库
else()
    add_library(msg STATIC "")  # 生成一个静态库
endif()

target_include_directories(msg PUBLIC include)
target_sources(msg  # 追加源文件到msg中, 源文件被定义为PUBLIC类型
    PRIVATE  # 何为PRIVATE和PUBLIC可以参见上文注释
        msg.c msgBeautiful.c _msg.h
    PUBLIC
        ${PROJECT_SOURCE_DIR}/include/msg.h
    )
