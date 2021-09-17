/*
 * 文件名: msg.h
 *
 * msg动态库的导出头文件
 */

#ifndef CMAKE_LEARN_MSG_H
#define CMAKE_LEARN_MSG_H
#include "msgExport.h"  // 由CMake自动生成

MSG_EXPORT size_t printMSG(char *msg);
MSG_EXPORT size_t printMSGBeautiful(char *msg);

#endif //CMAKE_LEARN_MSG_H
