/*!
* \warning     Copyright (c) 2020 Laboratoires Bodycad inc., All rights reserved
*
* \date        2020-09-24
* \author      Guillaume Plante
*
* \file        CoreMemoryConfig.h
* \brief       Contains defines that configure the memory manager usage and behavior
*/

#ifndef CORE_MEMORY_CONFIG
#define CORE_MEMORY_CONFIG

/******************************************************************************
 *  Configurable options:
 *    - ENABLE_CORE_MEMORY_MGR - If defined, enables CoreMemoryMgr.  If not
 *          defined then all CoreMemory manager funtions compile directly 
 *          into their standard library heap function analogs.
 *    - ENABLE_SOURCE_CODE_INFO - If defined, allows CoreMemoryMgr to track source
 *          code file name and line number. 
 *
 *  Comment/uncomment these two macros as needed.
 *  Alternately define them based on the project configuration.
 *******************************************************************************/

#define ENABLE_CORE_MEMORY_MGR
#define ENABLE_SOURCE_CODE_INFO
//#define ENABLE_MEMORY_TRACKING

#endif // ifdef CORE_MEMORY_CONFIG

