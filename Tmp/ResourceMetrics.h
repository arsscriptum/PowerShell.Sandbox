/*!
* \warning     Copyright (c) 2020 Laboratoires Bodycad inc., All rights reserved
*
* \date        2020-10-09
* \author      Guillaume Plante
*
* \file        ResourceMetrics.h
* \brief       This class contains routines for gathering resource statistics used by the current process.
*              Most of the provided data is extracted using the 'process status application programming 
*              interface' (PSAPI), a helper library to obtain information about processes and device drivers.
*              Metric values are not stored by this class, so it's not possible, for example, to get the 
*              amount of resources used by a given node 10 minutes ago.
*
*              Process Memory Usage Information
*               - Memory is reported as the current and peak value, in bytes, at the instant the metric was collected
*                 for the following categories:
*                  + working set
*                  + paged pool
*                  + nonpaged pool
*                  + pagefile
*                 The working set is the amount of memory physically mapped to the process context at a given time. 
*                 Memory in the paged pool is system memory that can be transferred to the paging file on disk (paged) when it is not being used. 
*                 Memory in the nonpaged pool is system memory that cannot be paged to disk as long as the corresponding objects are allocated. 
*                 The pagefile usage represents how much memory is set aside for the process in the system paging file. When memory usage is too high, 
*                 the virtual memory manager pages selected memory to disk. When a thread needs a page that is not in memory, the memory manager 
*                 reloads it from the paging file.
*              CPU
*               - CPU is reported as the average usage, in CPU cores, over a period of time. 
*                 This value is derived by taking a rate over a cumulative CPU counter provided by the Windows OS.
*/

#pragma once

#include <string>


/*!
 * Working Set (resident) memory usage broken down by
 *  priv (private): These pages (kbytes) cannot be shared with any other process.
 *  shareable:      These pages (kbytes) can be shared with other processes under
 *                  the right circumstances.
 *  shared :        These pages (kbytes) are currently shared with at least one
 *                  other process.
 */

struct WorkingSetKBytes 
{
	WorkingSetKBytes() : priv(0), shareable(0), shared(0) {}
	size_t priv;
	size_t shareable;
	size_t shared;
};

/*!
 * Committed (resident + paged) memory usage broken down by
 * private: These pages cannot be shared with any other process.
 * mapped:  These pages are mapped into the view of a section (backed by
 *          pagefile.sys)
 * image:   These pages are mapped into the view of an image section (backed by
 *          file system)
 */
struct CommittedKBytes 
{
	CommittedKBytes() : priv(0), mapped(0), image(0) {}
	size_t priv;
	size_t mapped;
	size_t image;
};

/*!
 * Free memory (Megabytes marked as free) in the 2G process address space.
 * total : total amount in megabytes marked as free. Maximum value is 2048.
 * largest : size of the largest contiguous amount of memory found. It is
 *   always smaller or equal to FreeMBytes::total.
 * largest_ptr: starting address of the largest memory block.
*/
struct FreeMBytes 
{
	size_t total;
	size_t largest;
	void* largest_ptr;
};


class ResourceMetrics
{
public:

	/*! Total virtual memory available  */
	static size_t GetAvailableVirtualMemory();

	/*! Total virtual memory available  */
	static size_t GetVirtualMemoryUsage();

	/*! Total physical memory available  */
	static size_t GetAvailablePhysicalMemory();

	/*! Total physical memory available  */
	static size_t GetPhysicalMemoryUsage();

	/*! Total virtual memory available  */
	static size_t GetVirtualMemoryUsageByCurrentProcess();

	/*! Returns the current working set size, in bytes. Physical Memory currently used by current process  */
	static size_t GetWorkingSetSize();

	/* Returns the peak working set size, in bytes. Physical Memory peak by current process */
	static size_t GetPeakWorkingSetSize();

	/* Returns the current space allocated for the pagefile, in bytes (these pages
	 * may or may not be in memory).  On Linux, this returns the total virtual
	 * memory size.
	*/
	static size_t GetPagefileUsage();

	/*! Returns the peak space allocated for the pagefile, in bytes. */
	static size_t GetPeakPagefileUsage();

	/*! Returns private and sharedusage, in bytes. Private bytes is the amount of
	*   memory currently allocated to a process that cannot be shared. 
	*  \tparam private_bytes  
	*  \tparam shared_bytes
	*/
	static bool GetMemoryBytes(size_t* private_bytes, size_t* shared_bytes);


	/*! Fills a CommittedKBytes with both resident and paged
	*   memory usage as per definition of CommittedBytes.
	*  \tparam ws_usage  The commited memory values set in kilobytes.
	*/
	static void GetCommittedKBytes(CommittedKBytes* usage);

	/*! Fills a WorkingSetKBytes containing resident private and shared memory
	*   usage in bytes, as per definition of WorkingSetBytes.
	*  \tparam ws_usage  The working set in kilobytes.
	*/
	static bool GetWorkingSetKBytes(WorkingSetKBytes* ws_usage);


	/*! Returns the CPU usage in percent since the last time this method was called
     *  The CPU usage value is for all CPUs. So if you have 2 CPUs and your process 
	 *  is using all the cycles of 1 CPU and not the other CPU, this method returns 50.
	*/
	static double GetCPUUsage();

	static bool InitializeMemoryContext(std::string identifier);
	static std::string GetCurrentMemoryContextIdentifier();
	static size_t GetCurrentMemoryContextSize();
	static size_t MemoryContextSize(std::string identifer);
	static size_t CloseMemoryContext();


	static bool workingSetMonitoringEnabled;
};

