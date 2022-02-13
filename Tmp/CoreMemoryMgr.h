/*!
* \warning     Copyright (c) 2020 Laboratoires Bodycad inc., All rights reserved
*
* \date        2020-09-24
* \author      Guillaume Plante
*
* \file        CoreMemoryMgr.h
* \brief       This memory manager is a super thin wrapper around the standard library heap functions.  
*
*              It has the following features:
*               - Provides replacement functions for malloc, realloc, and free.
*               - Overrides global operators new and delete.
*               - Via a macro definition, allows you to enable or disable source code
*                 information availability to the functions.
*
*              Note that this is a very simple memory manager wrapper.  It is intended
*              only to be used for debugging memory leaks, analyse usage and add heap tracking instrumentation.
*
*              Although in 'Core', it it used wherever possible but not everywhere. A proper centralized memory manager in C++ 
*              is made more complicated by the presence of things like:
*                - Third party libraries which call standard library heap functions
*                  directly without providing callback hooks for heap requests.  (Shame on
*                  such libraries!). Eigen is a problem here.
*                - Certain Windows header files which also redefine new.
*/

#ifndef CORE_MEMORY_MGR
#define CORE_MEMORY_MGR

#include "rmem.h"
#include "CoreMemoryConfig.h"

//! Make sure these macros are not defined at this point.
#undef CoreMalloc
#undef CoreRealloc
#undef CoreFree
#undef new

/******************************************************************************
 *
 *  The useable interface is as follows:
 *
 *    CoreMalloc            - Replacement for malloc.
 * 	  CoreRealloc           - Replacement for realloc.
 *    CoreFree              - Replacement for free.

 *    operator new        - Replaces default global operator new.
 *    operator new []     - Replaces default global operator new [].
 *    operator delete     - Replaces default global operator delete.
 *    operator delete []  - Replaces default global operator delete [].
 *
 ******************************************************************************/

void* CoreMalloc  (                 size_t Size );
void* CoreRealloc ( void*  pMemory, size_t Size );
void  CoreFree    ( void*  pMemory              );


/**
* GLOBAL NEW / DELETE
*/

#ifdef ENABLE_CORE_MEMORY_MGR

	void* operator new       (size_t Size);
	void* operator new[]     (size_t Size);

	void  operator delete    (void* p);
	void  operator delete[]  (void* p);

#endif // ENABLE_CORE_MEMORY_MGR


/******************************************************************************
 * Global vs class-specific overloading
 * 
 * The new and delete operators can also be overloaded like other operators in 
 * C++. New and Delete operators can be overloaded globally or they can be 
 * overloaded for specific classes.
 * If these operators are overloaded using member function for a class, it means
 * that these operators are overloaded ***only for that specific class.***
 * If overloading is done outside a class (i.e. it is not a member function 
 * of a class), the overloaded ‘new’ and ‘delete’ will be called anytime you 
 * make use of these operators (within classes or outside classes). 
 * This is global overloading.
*******************************************************************************/



/******************************************************************************
 *  Internal functions - declarations - CoreMemoryMgrInternal.h
 * 
 *  I have put the internal function dclarations in a separate file because
 *  it was just complicating things for the untrained-eye. A dev not well-versed
 *  in allocator overloading would be puzzled by StdMalloc, DbgMallow, 
 *  HeapMalloc abd CoreMalloc. Now, just look ath declarations in this file.
 *******************************************************************************/

#include "rmem.h"
#include "rmem_entry.h"
#include "CoreMemoryMgrInternal.h"


 /**
 * CLASS-SPECIFIC NEW / DELETE
 * macro to provide header file interface
 */
#define CORE_MEMORY_ALLOCATOR_DECL \
    public: \
        void* operator new(size_t size) { \
			void* pResult = HeapMalloc( size ); \
			AddTrack((unsigned long)pResult, Size, (const char*)nullptr, 0);  \
			DEJA_LOG_NEW(pResult, size); \
			return(pResult); \
        } \
        void operator delete(void* pMemory) { \
			if (pMemory) { \
				RemoveTrack((unsigned long)pMemory); \
				DEJA_LOG_DELETE(pMemory); \
			} \
			HeapFree(pMemory);  \
        };



/**
* DumpUnfreedAllocations: dump memory allocation that were not freed yet
*/
void DumpUnfreedAllocations();
/**
* ClearUnfreedAllocations: clear all allocation records
*/
void ClearAllocationRecords();

#endif // ifdef CORE_MEMORY_MGR

