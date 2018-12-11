Apache Flex (Flex)
==================

    Apache Flex is an application framework for easily building Flash-based applications 
    for mobile devices, the browser and desktop.

    For detailed information about Apache Flex please visit 
    http://flex.apache.org/

    The Apache Flex Pixel Bender package contains Adobe Pixel Bender shaders used by the 
    Apache Flex SDK.

    To compile the shaders, run:

	ant -f pixelbender.xml

    While Apache Flex runs on a large set of platforms, the Adobe Pixel Bender 
    compiler used to compile the shaders is only supported on:

        Microsoft Windows
        Mac OS X

Getting the convenience packages for the Apache Flex Pixel Bender shaders.
================================================

    You can also get just the binaries from our website.  These binaries do not
    include the dependencies, so additional software may need to be downloaded and
    installed.

      http://flex.apache.org/download-binaries.html


Getting the latest sources via git
==================================

    Getting the source code is the recommended way to get Apache Flex.  We also
    offer an automated installer along with binary distributions on our website
    at http://flex.apache.org/.

    You can always checkout the latest source via git using the following
    command:
	
	 git clone https://git-wip-us.apache.org/repos/asf/flex-sdk.git sdk
	 cd sdk
	 git checkout develop

    The above sequence actually checks out the entire Apache Flex SDK.  The
    Apache Flex Pixel Bender files are a subset of files from this repository.
    
Building Apache Flex Pixel Bender Files
=========================

    Apache Flex Pixel Bender files requires a build tool which must be installed
    prior to building Flex.  The build tools have a proprietary license.
        
Install Prerequisites
---------------------

    Before building the Apache Flex Pixel Bender files you must install the following
    software and set the corresponding environment variables using absolute file paths.
    Relative file paths will result in build errors.
    
    The environment variable PIXELBENDER_HOME can also be set in the property file 
    called env.properties. See the env-template.properties file for instructions.
    
    The Adobe Pixel Bender Toolkit is needed to build these files.  You may also
    need to set the JAVA_HOME and ANT_HOME environment variables as described below.

    ==================================================================================
    SOFTWARE                                    ENVIRONMENT VARIABLE (absolute paths)
    ==================================================================================
    
    Java SDK 1.6 or greater (*1)                JAVA_HOME
        (for Java 1.7 see note at (*2))
        
    Ant 1.7.1 or greater (*1)                   ANT_HOME
        (for Java 1.7 see note at (*2))
    
    Adobe Pixel Bender Toolkit (*5)             PIXELBENDER_HOME
    
    ==================================================================================
        
    *1) The bin directories for ANT_HOME and JAVA_HOME should be added to your PATH.
        
        On Windows, set PATH to
            
            PATH=%PATH%;%ANT_HOME%\bin;%JAVA_HOME%\bin
            
        On the Mac (bash), set PATH to
            
            export PATH="$PATH:$ANT_HOME/bin:$JAVA_HOME/bin"
            
         There is no Adobe Pixel Bender compiler for Linux.

    *2)  If you are using Java SDK 1.7 or greater on a Mac you must use Ant 1.8 or 
         greater. If you use Java 1.7 with Ant 1.7, ant reports the java version as 1.6 
         so the JVM args for the data model (-d32/-d64) will not be set correctly and
         you will get compile errors.
        
            
    *3) The Adobe Pixel Bender Toolkit for Windows can be downloaded from:
            http://www.adobe.com/go/pixelbender_toolkit_zip/
        
         The Adobe Pixel Bender Toolkit for Mac can be downloaded from:
            http://www.adobe.com/go/pixelbender_toolkit_dmg/
                                
         Download the Adobe Pixel Bender Toolkit for your platform and install or unzip
         it.
         On Windows and Mac Set PIXELBENDER_HOME to the absolute path of the Adobe Pixel
         Bender Toolkit directory.

        
Using the Binary Distribution
-----------------------------

    The binary distribution should be usable as-is and not require building.  The
    binary distribution is used in a build of the main Flex SDK build script.  To
    set the Flex SDK build to use a binary distribution, run the main Flex SDK 
    build.xml's main target and set -Dpixelbender.url=<path to folder containing 
    binary distribution> or set pixelbender.url in a local.properties file.


Building the Source in the Source Distribution
----------------------------------------------

    To build the source, run:

        ant -f pixelbender.xml

    To clean the build of the compiled PBJ files use:
    
        ant -f pixelbender.xml clean

    To use the PBJ files in an Flex SDK build run:

        ant -f pixelbender.xml copy-to-flex-sdk

    The above will copy the PBJ files to the appropriate places in the folder
    specified by the environment variable FLEX_HOME which may also be
    specified on the command line or in a local.properties file as:

        ant -f pixelbender.xml -DFLEX_HOME=<path to Flex SDK> copy-to-flex-sdk

    The presence of the PBJ files in the Flex SDK folders will prevent the Flex
    SDK from downloading a binary distribution to access those PBJ files.
    
    Note for Release Managers:  To generate a source distribution package and a 
    binary distribution package use the main Flex SDK build.xml as follows
        
        ant release-pixelbender

    The packages can be found in the "out" subdirectory.
            
    To get a brief listing of all the targets type
    
        ant -projecthelp


Thanks for using Apache Flex.  Enjoy!

                                          The Apache Flex Project
                                          <http://flex.apache.org>
