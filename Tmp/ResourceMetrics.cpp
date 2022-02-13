/*!
* \warning     Copyright (c) 2020 Laboratoires Bodycad inc., All rights reserved
*
* \date        2020-10-09
* \author      Guillaume Plante
*
* \file        ResourceMetrics.cpp
* \brief       Implementation details of the ResourceMetrics class.

*/


#include "stdafx.h"
#include "ResourceMetrics.h"

#include <windows.h>
#include <psapi.h>


// System pagesize. This value remains constant on x86/64 architectures.
const int PAGESIZE_KB = 4;
bool ResourceMetrics::workingSetMonitoringEnabled = false;

size_t ResourceMetrics::GetAvailableVirtualMemory()
{
	MEMORYSTATUSEX memInfo;
	ZeroMemory(&memInfo, sizeof(PROCESS_MEMORY_COUNTERS));
	memInfo.dwLength = sizeof(MEMORYSTATUSEX);
	GlobalMemoryStatusEx(&memInfo);
    // Note: The name "TotalPageFile" is a bit misleading here.In reality this parameter 
	// gives the "Virtual Memory Size", which is size of swap file plus installed RAM.
	return (size_t)memInfo.ullTotalPageFile / 1024 ;
}


size_t ResourceMetrics::GetVirtualMemoryUsage()
{
	MEMORYSTATUSEX memInfo;
	ZeroMemory(&memInfo, sizeof(PROCESS_MEMORY_COUNTERS));
	memInfo.dwLength = sizeof(MEMORYSTATUSEX);
	GlobalMemoryStatusEx(&memInfo);
	size_t totalVirtualMem = (size_t)memInfo.ullTotalPageFile;
	size_t virtualMemUsed = (size_t)(memInfo.ullTotalPageFile - memInfo.ullAvailPageFile);
	return virtualMemUsed / 1024 ;
}

size_t ResourceMetrics::GetVirtualMemoryUsageByCurrentProcess()
{
	PROCESS_MEMORY_COUNTERS_EX memcounter;
	ZeroMemory(&memcounter, sizeof(PROCESS_MEMORY_COUNTERS));
	GetProcessMemoryInfo(GetCurrentProcess(), (PROCESS_MEMORY_COUNTERS*)&memcounter, sizeof(memcounter));
	return memcounter.PrivateUsage / 1024 ;
}

size_t ResourceMetrics::GetAvailablePhysicalMemory()
{
	MEMORYSTATUSEX memInfo;
	ZeroMemory(&memInfo, sizeof(PROCESS_MEMORY_COUNTERS));
	memInfo.dwLength = sizeof(MEMORYSTATUSEX);
	GlobalMemoryStatusEx(&memInfo);
	return (size_t)memInfo.ullTotalPhys / 1024 ;
}

size_t ResourceMetrics::GetPhysicalMemoryUsage()
{
	MEMORYSTATUSEX memInfo;
	ZeroMemory(&memInfo, sizeof(PROCESS_MEMORY_COUNTERS));

	memInfo.dwLength = sizeof(MEMORYSTATUSEX);
	GlobalMemoryStatusEx(&memInfo);
	size_t physMemUsed = (size_t)(memInfo.ullTotalPhys - memInfo.ullAvailPhys);
	return physMemUsed / 1024 ;
}
size_t ResourceMetrics::GetWorkingSetSize()
{
	PROCESS_MEMORY_COUNTERS pmc;
	if (GetProcessMemoryInfo(GetCurrentProcess(), &pmc, sizeof(pmc))) {
		return pmc.WorkingSetSize / 1024 ;
	}
	return 0;
}

size_t ResourceMetrics::GetPeakWorkingSetSize()
{
	PROCESS_MEMORY_COUNTERS pmc;
	if (GetProcessMemoryInfo(GetCurrentProcess(), &pmc, sizeof(pmc))) {
		return pmc.PeakWorkingSetSize / 1024 ;
	}
	return 0;
}

size_t ResourceMetrics::GetPagefileUsage()
{
	PROCESS_MEMORY_COUNTERS pmc;
	if (GetProcessMemoryInfo(GetCurrentProcess(), &pmc, sizeof(pmc))) {
		return pmc.PagefileUsage / 1024 ;
	}
	return 0;
}

bool ResourceMetrics::InitializeMemoryContext(std::string identifier)
{	
	if (InitializeProcessForWsWatch(GetCurrentProcess())) {
		workingSetMonitoringEnabled = true;
		return true;
	}
	return false;
}


std::string GetCurrentMemoryContextIdentifier()
{

}

size_t ResourceMetrics::GetCurrentMemoryContextSize()
{
}

size_t ResourceMetrics::MemoryContextSize(std::string identifer)
{
	return 0;
}

size_t ResourceMetrics::CloseMemoryContext()
{
	/*if (workingSetMonitoringEnabled)
	{
		workingSetMonitoringEnabled = false;
	    DWORD watchInfoSize = 3; //! Allocate a reasonable number of page values, if the buffer is too small
		//  ERROR_INSUFFICIENT_BUFFER will be returned.
		PSAPI_WS_WATCH_INFORMATION_EX *watchInfo = (PSAPI_WS_WATCH_INFORMATION_EX*) malloc(watchInfoSize  * sizeof(PSAPI_WS_WATCH_INFORMATION_EX));
		DWORD ret = GetWsChangesEx(GetCurrentProcess(), watchInfo, &watchInfoSize);
		
		if (ret == 0  && GetLastError() == ERROR_INSUFFICIENT_BUFFER)
		{
			DWORD newBufferSize = watchInfoSize * sizeof(PSAPI_WS_WATCH_INFORMATION_EX);
			watchInfo = (PSAPI_WS_WATCH_INFORMATION_EX*)realloc(watchInfo, newBufferSize);
			ret = GetWsChangesEx(GetCurrentProcess(), watchInfo, &watchInfoSize);
			if (ret != 0)
			{
				for (DWORD n = 0; n < watchInfoSize; n++)
				{
					//todo Guillaume: QueryWorkingSet iInformation...
					watchInfo[n].BasicInfo
				}
			}
		}
		
	}*/
	workingSetMonitoringEnabled = false;
	return 0;

}

size_t ResourceMetrics::GetPeakPagefileUsage()
{
	PROCESS_MEMORY_COUNTERS pmc;
	if (GetProcessMemoryInfo(GetCurrentProcess(), &pmc, sizeof(pmc))) {
		return pmc.PeakPagefileUsage / 1024 ;
	}
	return 0;
}

bool ResourceMetrics::GetMemoryBytes(size_t* private_bytes, size_t* shared_bytes)
{
	// PROCESS_MEMORY_COUNTERS_EX is not supported until XP SP2.
	// GetProcessMemoryInfo() will simply fail on prior OS. So the requested
	// information is simply not available. Hence, we will return 0 on unsupported
	// OSes. Unlike most Win32 API, we don't need to initialize the "cb" member.
	PROCESS_MEMORY_COUNTERS_EX pmcx;
	if (private_bytes &&
		GetProcessMemoryInfo(GetCurrentProcess(),
			reinterpret_cast<PROCESS_MEMORY_COUNTERS*>(&pmcx),
			sizeof(pmcx))) {
		*private_bytes = pmcx.PrivateUsage;
	}
	if (shared_bytes) {
		WorkingSetKBytes ws_usage;
		if (!GetWorkingSetKBytes(&ws_usage))
			return false;
		*shared_bytes = ws_usage.shared * 1024;
	}
	return true;
}



void ResourceMetrics::GetCommittedKBytes(CommittedKBytes* usage)
{
	MEMORY_BASIC_INFORMATION mbi = { 0 };
	size_t committed_private = 0;
	size_t committed_mapped = 0;
	size_t committed_image = 0;
	void* base_address = NULL;
	while (VirtualQueryEx(GetCurrentProcess(), base_address, &mbi, sizeof(mbi)) == sizeof(mbi)) 
	{
		if (mbi.State == MEM_COMMIT) 
		{
			if (mbi.Type == MEM_PRIVATE) 
			{
				committed_private += mbi.RegionSize;
			}
			else if (mbi.Type == MEM_MAPPED) 
			{
				committed_mapped += mbi.RegionSize;
			}
			else if (mbi.Type == MEM_IMAGE) 
			{
				committed_image += mbi.RegionSize;
			}
			else {
				
			}
		}
		void* new_base = (static_cast<BYTE*>(mbi.BaseAddress)) + mbi.RegionSize;
		// Avoid infinite loop by weird MEMORY_BASIC_INFORMATION.
		// If we query 64bit processes in a 32bit process, VirtualQueryEx()
		// returns such data.
		if (new_base <= base_address) {
			usage->image = 0;
			usage->mapped = 0;
			usage->priv = 0;
			return;
		}
		base_address = new_base;
	}
	usage->image = committed_image / 1024;
	usage->mapped = committed_mapped / 1024;
	usage->priv = committed_private / 1024;
}

#define MIN(a,b) ((a) < (b) ? (a) : (b))

bool ResourceMetrics::GetWorkingSetKBytes(WorkingSetKBytes* ws_usage)
{
	size_t ws_private = 0;
	size_t ws_shareable = 0;
	size_t ws_shared = 0;

	memset(ws_usage, 0, sizeof(*ws_usage));
	DWORD number_of_entries = 4096;  // Just a guess.
	PSAPI_WORKING_SET_INFORMATION* buffer = NULL;
	int retries = 5;
	for (;;) {
		DWORD buffer_size = sizeof(PSAPI_WORKING_SET_INFORMATION) +
			(number_of_entries * sizeof(PSAPI_WORKING_SET_BLOCK));
		// if we can't expand the buffer, don't leak the previous
		// contents or pass a NULL pointer to QueryWorkingSet
		PSAPI_WORKING_SET_INFORMATION* new_buffer =
			reinterpret_cast<PSAPI_WORKING_SET_INFORMATION*>(
				realloc(buffer, buffer_size));
		if (!new_buffer) {
			free(buffer);
			return false;
		}
		buffer = new_buffer;
		// Call the function once to get number of items
		if (QueryWorkingSet(GetCurrentProcess(), buffer, buffer_size))
			break;  // Success
		if (GetLastError() != ERROR_BAD_LENGTH) {
			free(buffer);
			return false;
		}
		number_of_entries = static_cast<DWORD>(buffer->NumberOfEntries);
		// Maybe some entries are being added right now. Increase the buffer to
		// take that into account.
		number_of_entries = static_cast<DWORD>(number_of_entries * 1.25);
		if (--retries == 0) {
			free(buffer);  // If we're looping, eventually fail.
			return false;
		}
	}
	// On windows 2000 the function returns 1 even when the buffer is too small.
	// The number of entries that we are going to parse is the minimum between the
	// size we allocated and the real number of entries.
	number_of_entries =
		MIN(number_of_entries, static_cast<DWORD>(buffer->NumberOfEntries));
	for (unsigned int i = 0; i < number_of_entries; i++) {
		if (buffer->WorkingSetInfo[i].Shared) {
			ws_shareable++;
			if (buffer->WorkingSetInfo[i].ShareCount > 1)
				ws_shared++;
		}
		else {
			ws_private++;
		}
	}
	ws_usage->priv = ws_private * PAGESIZE_KB;
	ws_usage->shareable = ws_shareable * PAGESIZE_KB;
	ws_usage->shared = ws_shared * PAGESIZE_KB;
	free(buffer);
	return true;
}


double ResourceMetrics::GetCPUUsage()
{
	return 0;
}
