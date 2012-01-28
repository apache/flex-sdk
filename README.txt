January 20, 2012

Adobe will be dropping subsets of the Adobe Flex code into the Apache Flex subversion directory at The Apache Software Foundation after each subset is approved for donation by the Adobe legal team.  The first subset will be the frameworks directory, minus the automation libraries, and the javascript and flash-integration directories. We expect the second subset to be the modules directory which contains the compiler.

Until the modules directory is donated you should follow these steps to build the framework directory.

1.  Download the Adobe Flex 4.6 Open Source Flex SDK from http://opensource.adobe.com/wiki/display/flexsdk/Download+Flex+4.6 and expand it.

2.  Make sure you have your build environment configured.

    It requires the following software that is not under source control:

    J2SDK 1.5.0_13 (http://java.sun.com/products/archive/j2se/5.0_13/index.html) (see Notes below)
    
    Ant 1.7.0 (http://archive.apache.org/dist/ant/binaries/) (see Notes below)
    
    The following environment variables must be set:

        JAVA_HOME
        ANT_HOME
        ANT_OPTS - set max heap size to at least 256m (-Xmx256m)

    The PATH must include

        bin directory of Flex SDK
        bin directory of Ant
        bin directory of Java

    Per the instructions in {FLEX_HOME}/ant/README.txt, copy flexTasks.jar to the lib directory of your ant installation.

    For testing, the Flash Player's mm.cfg file must have the following entries

        ErrorReportingEnable=1
        TraceOutputFileEnable=1

    and a FlashPlayerTrust file must allow local SWFs to access local files.

3.  Delete the frameworks directory from the files you just expanded and replace it with the contents of the frameworks directory from the ASF svn repository.  
    The SVN-location is https://svn.apache.org/repos/asf/incubator/flex/trunk/frameworks

4.  To build the frameworks directory, from the frameworks directory, type:

	ant -f build_framework.xml

    This will download the thirdparty code that the build needs and then build the project directories.

5.  Other useful targets in frameworks/build_framework.xml:

	ant -f build_framework.xml thirdparty-downloads - to download the thirdparty code
		The default target, main, does this only if the files aren't already in place.

	ant -f build_framework.xml thirdparty-clean
		Removes the thirdparty code that was downloaded.

	ant -f build_framework.xml clean - to clean the results of the build
		This does not remove the thirdparty downloads since they take some time and they don't change often.

Notes:

- The Open Source kit was certified with J2SDK 1.5.0_13 and Ant 1.7.0.
  It is quite possible that later versions of these work as well.
  We've successfully used Java Version 1.6.0_29 from Apple Inc. on the Mac and Java 1.7 and both Ant 1.7 and Ant 1.8 on Windows 7.

- The frameworks directory contains a build_framework.xml file and a build.xml file.  
  The build_framework.xml directory builds frameworks in the context of a downloaded kit so it uses the compiler in the bin directory.  
  The build.xml file builds frameworks in the context of the source tree which means it uses the compiler in the modules directory.  
  If you would prefer you can copy build_framework.xml to build.xml so you just have to type ant to build frameworks.

- The following framework files have not yet been approved by legal for donation to the ASF:
  flash-integration, javascript, and tests directories and the automation libraries

- The build files for the asdoc and doc directories will be added shortly.
