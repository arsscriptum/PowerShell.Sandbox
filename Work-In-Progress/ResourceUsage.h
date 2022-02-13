/*!
* \warning     Copyright (c) 2016 Laboratoires Bodycad inc., All rights reserved
* 
* \date        2016-07-06
* \author      Jerome Godbout
*              
* \file        ResourceUsage.h
* \brief       This file contains the declaration of the ResourceUsage class.
*/

#pragma once

#include <string>

class ResourceUsage
{
public:
	static size_t get_current_heap_size();
	static size_t get_max_heap_size();
	static size_t get_virtual_memory_usage();
};

