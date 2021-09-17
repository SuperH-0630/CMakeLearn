#[[
文件名: hello2\CMakeLists.txt
自动生成hello2.c和hello2.h文件
]]

set(name "Huan")
set(who "\"sys\"")

set(def1 10)
set(def2 20)
set(def3 1)
set(def5 1)

# 生成文件
configure_file(${CMAKE_CURRENT_SOURCE_DIR}/hello2.c.in ${CMAKE_BINARY_DIR}/hello2/hello2.c @ONLY)
configure_file(${CMAKE_CURRENT_SOURCE_DIR}/hello2.h.in ${CMAKE_BINARY_DIR}/hello2/hello2.h)

add_executable(hello2 ${CMAKE_BINARY_DIR}/hello2/hello2.c ${CMAKE_BINARY_DIR}/hello2/hello2.h)
target_include_directories(hello2 PRIVATE ${CMAKE_BINARY_DIR}/hello2)