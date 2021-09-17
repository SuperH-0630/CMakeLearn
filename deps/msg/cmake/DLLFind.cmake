#[[
文件名: DllFind.cmake
定位windows的dll文件用的
]]

function(dll_find re path)
    file(GLOB_RECURSE _dll  # 遍历所有的.dll
         LIST_DIRECTORIES FALSE  #
         CONFIGURE_DEPENDS
         "${path}/*.dll"
         )
    set(${re} ${_dll} PARENT_SCOPE)
endfunction()