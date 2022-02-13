/*!
* \warning     Copyright (c) 2016 Laboratoires Bodycad inc., All rights reserved
* 
* \date        2016-07-06
* \author      Jerome Godbout
*              
* \file        ResourceUsage.cpp
* \brief       see .h
*/

#include "ResourceUsage.h"

// Taken from http://stackoverflow.com/questions/669438/how-to-get-memory-usage-at-run-time-in-c
#if defined(_WIN32)

#include <windows.h>
#include <psapi.h>

size_t ResourceUsage::get_current_heap_size()
{
	PROCESS_MEMORY_COUNTERS info;
	GetProcessMemoryInfo(GetCurrentProcess(), &info, sizeof(info));
	return (size_t)info.WorkingSetSize;
}

size_t ResourceUsage::get_max_heap_size()
{
	PROCESS_MEMORY_COUNTERS info;
	GetProcessMemoryInfo(GetCurrentProcess(), &info, sizeof(info));
	return (size_t)info.PeakWorkingSetSize;
}


int64_t get_virtual_memory_usage()
{
	DWORD process_id = GetCurrentProcessId();

	DWORD  desired_access = PROCESS_QUERY_INFORMATION | PROCESS_VM_READ;
	BOOL inherit_handle = FALSE;
	HANDLE process_handle = OpenProcess(desired_access, inherit_handle, process_id);

	PROCESS_MEMORY_COUNTERS pmc;
	BOOL success = GetProcessMemoryInfo(process_handle, &pmc, sizeof(pmc));

	int64_t current_virtual_memory_usage = 0;
	if (success)
	{
		// The Commit Charge value in bytes for this process.
		// Commit Charge is the total amount of private memory that the memory manager has committed for a running process.
		current_virtual_memory_usage = pmc.PagefileUsage;
	}

	return current_virtual_memory_usage;
}


#endif // defined(_WIN32)