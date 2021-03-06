# Module manifest for module 'Benchmark.psm1'
#
# Created by: Joakim Svendsen
#
# Created on: 2012-07-21
#
# 2017-12-01: v1.2.1. Make numbers returned a numeric type for easier use with comparison
#             operators like -gt, -ge, -le and -lt. Use [Math]::Round() instead of
#             the string formatting operator -f.
# 2017-12-02: v1.2.2. Minor doc fixes (e.g. s/comma (separator)/decimal $1/). Make $Precision a Byte.
#             Use [CmdletBinding()] and add scaffolding.

@{

# Script module or binary module file associated with this manifest
ModuleToProcess = 'Benchmark.psm1'

# Version number of this module.
ModuleVersion = '1.2.2'

# ID used to uniquely identify this module
GUID = 'c09f899c-7cd1-4c2a-b5f1-fb3481e1e022'

# Author of this module
Author = 'Joakim Borger Svendsen'

# Company or vendor of this module
CompanyName = 'Svendsen Tech'

# Copyright statement for this module
Copyright = 'Copyright (c) 2012-2017, Joakim Borger Svendsen, Svendsen Tech. All rights reserved.'

# Description of the functionality provided by this module
Description = 'Svendsen Tech''s Benchmark module provides a convenient interface to benchmarking and comparing execution speed of code blocks containing arbitrary PowerShell code. Online documentation here: http://www.powershelladmin.com/wiki/PowerShell_benchmarking_module_built_around_Measure-Command'

# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '2.0'

# Name of the Windows PowerShell host required by this module
PowerShellHostName = ''

# Minimum version of the Windows PowerShell host required by this module
PowerShellHostVersion = ''

# Minimum version of the .NET Framework required by this module
DotNetFrameworkVersion = '3.5'

# Minimum version of the common language runtime (CLR) required by this module
CLRVersion = ''

# Processor architecture (None, X86, Amd64, IA64) required by this module
ProcessorArchitecture = ''

# Modules that must be imported into the global environment prior to importing this module
RequiredModules = @()

# Assemblies that must be loaded prior to importing this module
RequiredAssemblies = @()

# Script files (.ps1) that are run in the caller's environment prior to importing this module
ScriptsToProcess = @()

# Type files (.ps1xml) to be loaded when importing this module
TypesToProcess = @()

# Format files (.ps1xml) to be loaded when importing this module
FormatsToProcess = @()

# Modules to import as nested modules of the module specified in ModuleToProcess
NestedModules = @()

# Functions to export from this module
FunctionsToExport = 'Measure-These'

# Cmdlets to export from this module
CmdletsToExport = '*'

# Variables to export from this module
VariablesToExport = '*'

# Aliases to export from this module
AliasesToExport = '*'

# List of all modules packaged with this module
ModuleList = @()

# List of all files packaged with this module
FileList = @('Benchmark.psm1', 'Benchmark.psd1')

# Private data to pass to the module specified in ModuleToProcess
PrivateData = ''

}