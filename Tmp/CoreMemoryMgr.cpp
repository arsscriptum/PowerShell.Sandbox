/*!
* \warning     Copyright (c) 2020 Laboratoires Bodycad inc., All rights reserved
*
* \date        2020-09-24
* \author      Guillaume Plante
*
* \file        CoreMemoryMgr.cpp
* \brief       Implementation details of the custom memory manager.
*
*/

#include "CoreMemoryConfig.h"
#include "rmem.h"
#include "rmem_entry.h"
#include "Trace.h"
#include <stdlib.h>
#include <string>
#include <list>


unsigned long GUniqueAllocId = 0;
unsigned int TotalAllocations = 0;
unsigned int TotalFree = 0;



typedef struct {
	unsigned long	address;
	unsigned long	size;
	char file[64];
	unsigned long	line;
	unsigned long	uid;
} ALLOC_INFO;

typedef std::list<ALLOC_INFO*> AllocList;

AllocList *allocList;

bool NoTrack = false;


#pragma warning( push )
#pragma warning( disable : 4267 4717)


/******************************************************************************
*
*  Below are internal tracking functions used to have a record of allocations
*  so we can list the ones that are not freed.
*  We are not support DEBUG currently so the debug allocator with
*  filename/line number may not be available. For this situation, I also use
*  a unique identifier for allocations.
*
*    DumpUnfreedAllocations   - dump memory allocation that were not freed yet
* 	 AddTrack           - keeps a record of a memory allocation
*    RemoveTrack        - delete a record of a memory allocation
*
******************************************************************************/


/**
* AddTrack: keeps a record of a memory allocation with the file and line number (used in debug)
*   @see RemoveTrack()
*   @param addr the memory address (returned by malloc or new)
*   @param size the size of memory block
*   @param fname the file name where allocation occured
*   @param lnum line number
*/
void AddTrack(unsigned long addr, unsigned long asize, const char *fname, unsigned long lnum)
{
#ifdef ENABLE_MEMORY_TRACKING
	if (NoTrack) { return;  }
	ALLOC_INFO *info;

	NoTrack = true;
	if (!allocList) {
		allocList = new(AllocList);
	}

	info = new(ALLOC_INFO);
	
	info->address = addr;
	strncpy(info->file, fname?fname:"", 63);
	info->line = lnum;
	info->size = asize; 
	info->uid = GUniqueAllocId++;;

	allocList->insert(allocList->begin(), info);
	NoTrack = false;
#endif
};

/**
* AddTrack: keeps a record of a memory allocation with the file and line number (used in debug)
*   @see RemoveTrack()
*   @param addr the memory address (returned by malloc or new)
*   @param size the size of memory block
*   @param fname the file name where allocation occured
*   @param lnum line number
*/
void AddTrack(unsigned long addr, unsigned long asize, const wchar_t *fname, unsigned long lnum)
{
#ifdef ENABLE_MEMORY_TRACKING
	if (NoTrack) { return; }

	std::wstring ws(fname);
	std::string str(ws.begin(), ws.end());
	const char* cfname = str.c_str();
	AddTrack(addr, asize, (const char*) cfname, lnum);
#endif
}

/**
* RemoveTrack: delete a record of a memory allocation
*   @see AddTrack()
*   @param addr the memory address (returned by malloc or new)
*/
void RemoveTrack(int addr)
{
#ifdef ENABLE_MEMORY_TRACKING
	if (NoTrack) { return; }

	AllocList::iterator i;

	if (!allocList)
		return;
	for (i = allocList->begin(); i != allocList->end(); i++)
	{
		if ((*i)->address == addr)
		{
			allocList->remove((*i));
			break;
		}
	}
#endif
};

/**
* DumpUnfreedAllocations: dump memory allocation that were not freed yet
*   @see AddTrack()
*/
void DumpUnfreedAllocations()
{
#ifdef ENABLE_MEMORY_TRACKING
	AllocList::iterator i;
	unsigned long totalSize = 0;

	if (!allocList)
		return;

	for (i = allocList->begin(); i != allocList->end(); i++) 
	{
		if ((*i)->file != nullptr)
		{
			DEJA_WARNING("CoreMemory", "%s:%d, %d bytes unfreed at 0x%08x", (*i)->file, (*i)->line, (*i)->size, (*i)->address);
		}
		else
		{
			DEJA_WARNING("CoreMemory", "uid:%d, %d bytes unfreed at 0x%08x", (*i)->uid, (*i)->size, (*i)->address);
		}
		
		totalSize += (*i)->size;
	}

	DEJA_WARNING("CoreMemory", "-----------------------------------------------------------");
	DEJA_WARNING("CoreMemory", "Total Unfreed: %d bytes", totalSize);
#endif
};

void ClearAllocationRecords()
{
	if (allocList) 
	{
		allocList->clear();
	}
}

/******************************************************************************
 *  First, the functions which actually perform the heap operations.  These just 
 *  wrap the standard C library heap functions.
 *
 *  Both the standard C library heap function replacements (CoreMalloc, 
 *  CoreRealloc, and MyFree) and the C++ global operators new and delete are routed 
 *  through here.
 *
 *  Note that is is possible to use the Microsoft debug heap functions. For
 *  example, HeapMalloc could be:
 *      void* HeapMalloc( size_t Size, const char* pFileName, int Line )
 *      {
 *          void* pResult = _malloc_dbg( Size, _NORMAL_BLOCK, pFileName, Line );
 *          return( pResult );
 *      }
 *
 *  And then, HeapRealloc and HeapFree would use:
 *      _realloc_dbg( pMemory, Size, _NORMAL_BLOCK, pFileName, Line );
 *      _free_dbg( pMemory, _NORMAL_BLOCK );
 *
 ******************************************************************************/
#include "rmem.h"
void* HeapMalloc( size_t Size )
{
	TotalAllocations++;
    void* pResult = malloc( Size );
	rmemAlloc(0, pResult, Size, 8);
    return( pResult );
}


void* HeapRealloc( void* pMemory, size_t Size )
{
	void *pPrev = pMemory;
    void* pResult = realloc( pMemory, Size );
	rmemRealloc(0, pResult, Size, 8, pPrev);
    return( pResult );
}

void HeapFree( void* pMemory )
{
	TotalFree++;
    free( pMemory );
	rmemFree(0, pMemory);
}

/******************************************************************************
*  Standard allocators / Minimum informations
******************************************************************************/
void* StdMalloc( size_t Size )
{
    void* pResult = HeapMalloc( Size );	
	AddTrack((unsigned long)pResult, (unsigned long)Size, (const char*)nullptr, 0);
    DEJA_LOG_MALLOC( pResult, Size );
    return( pResult );
}


void* StdRealloc(void* pMemory, size_t Size)
{
	void* pResult = HeapRealloc(pMemory, Size);
	DEJA_LOG_REALLOC(pResult, pMemory, Size);
	return(pResult);
}

void StdFree(void* pMemory)
{
	if (pMemory)
	{
		DEJA_LOG_FREE(pMemory);
	}

	HeapFree(pMemory);
}

/******************************************************************************
*  Debug allocators / free
******************************************************************************/

void* DbgMalloc(size_t Size, const char* pFileName, int Line)
{
	void* pResult = HeapMalloc(Size);
	AddTrack((unsigned long)pResult, Size, pFileName, Line);
	DEJA_LOG_MALLOC(pResult, Size, pFileName, Line);
	return(pResult);
}


void DbgFree( void* pMemory, const char* pFileName, int Line )
{
    if( pMemory ) 
    { 
		RemoveTrack((unsigned long)pMemory);
        DEJA_LOG_FREE( pMemory, pFileName, Line );
    }

    HeapFree( pMemory );
}

void DbgFree( void* pMemory, const wchar_t* pFileName, int Line )
{
    if( pMemory ) 
    { 
		RemoveTrack((unsigned long)pFileName);
        DEJA_LOG_FREE( pMemory, pFileName, Line );
    }
	 
    HeapFree( pMemory );
}

/******************************************************************************
 *  Finally, the new versions of global operators new and delete.
 ******************************************************************************/

void* operator new ( size_t Size )
{
    void* pResult = StdMalloc( Size );
    DEJA_LOG_NEW( pResult, Size );
    return( pResult );
}

void* operator new ( size_t Size, const char* pFileName, int Line )
{
    void* pResult = DbgMalloc( Size, pFileName, Line );
    DEJA_LOG_NEW( pResult, Size, pFileName, Line );
    return( pResult );
}


void* operator new ( size_t Size, const wchar_t* pFileName, int Line )
{
	std::wstring ws(pFileName);
	std::string str(ws.begin(), ws.end());
	const char* cfname = str.c_str();
    void* pResult = DbgMalloc(Size, cfname, Line);
    DEJA_LOG_NEW( pResult, Size, pFileName, Line );
    return( pResult );
}

void* operator new [] ( size_t Size )
{
    void* pResult = StdMalloc( Size );
    DEJA_LOG_NEW_ARRAY( pResult, Size );
    return( pResult );
}

void* operator new [] ( size_t Size, const char* pFileName, int Line )
{
    void* pResult = DbgMalloc(Size, pFileName, Line);
    DEJA_LOG_NEW_ARRAY( pResult, Size, pFileName, Line );
    return( pResult );
}


void* operator new [] ( size_t Size, const wchar_t* pFileName, int Line )
{
	std::wstring ws(pFileName);
	std::string str(ws.begin(), ws.end());
	const char* cfname = str.c_str();
    void* pResult = DbgMalloc(Size, cfname, Line);
    DEJA_LOG_NEW_ARRAY( pResult, Size, pFileName, Line );
    return( pResult );
}


void operator delete ( void* pMemory )
{
    if( pMemory )
    {
		RemoveTrack((unsigned long)pMemory);
        DEJA_LOG_DELETE( pMemory );
    }

    HeapFree( pMemory );
}

void operator delete ( void* pMemory, const char* pFileName, int Line )
{
    if( pMemory )
    {
		RemoveTrack((unsigned long)pMemory);
        DEJA_LOG_DELETE( pMemory, pFileName, Line );
    }

    HeapFree( pMemory );
}

void operator delete ( void* pMemory, const wchar_t* pFileName, int Line )
{
    if( pMemory )
    {
		RemoveTrack((unsigned long)pMemory);
        DEJA_LOG_DELETE( pMemory, pFileName, Line );
    }

    HeapFree( pMemory );
}


void operator delete [] ( void* pMemory )
{
    if( pMemory )
    {
		RemoveTrack((unsigned long)pMemory);
        DEJA_LOG_DELETE_ARRAY( pMemory );
    }

    HeapFree( pMemory );
}

void operator delete [] ( void* pMemory, const char* pFileName, int Line )
{
    if( pMemory )
    {
		RemoveTrack((unsigned long)pMemory);
        DEJA_LOG_DELETE_ARRAY( pMemory, pFileName, Line );
    }

    HeapFree( pMemory );
}

void operator delete [] ( void* pMemory, const wchar_t* pFileName, int Line )
{
    if( pMemory )
    {
		RemoveTrack((unsigned long)pMemory);
        DEJA_LOG_DELETE_ARRAY( pMemory, pFileName, Line );
    }

    HeapFree( pMemory );
}


#pragma warning( pop )