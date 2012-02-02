January 15, 2012

Adobe will be dropping subsets of the Adobe Flex code into the Apache Flex subversion directory at The Apache Software Foundation after each subset is approved for donation by the Adobe legal team.  The first subset will be the frameworks directory, minus the automation and flash-integration directories, and we expect the second subset to be the modules directory which contains the compiler.

Until the modules directory is donated you should follow these steps to build the framework directory.

1.  Make sure you have your build environment configured.

    It requires the following software that is not under source control:

    J2SDK 1.5.0_13 (http://java.sun.com/products/archive/j2se/5.0_13/index.html) (see Note below)
    
    Ant 1.7.0 (http://archive.apache.org/dist/ant/binaries/)
    
    The following environment variables must be set:

        JAVA_HOME
        ANT_HOME

    The PATH must include

        bin directory of Flex SDK
        bin directory of Ant
        bin directory of Java

    For testing, the Flash Player's mm.cfg file must have the following entries

        ErrorReportingEnable=1
        TraceOutputFileEnable=1

    and a FlashPlayerTrust file must allow local SWFs to access local files.

2.  Download the Adobe Flex 4.6 Open Source Flex SDK from http://opensource.adobe.com/wiki/display/flexsdk/Download+Flex+4.6 and expand it.

3.  Delete the frameworks directory from the files you just expanded and replace it with the contents of the frameworks directory from the ASF svn repository.  
    The SVN-location is https://svn.apache.org/repos/asf/incubator/flex/trunk/frameworks

4.  From the frameworks directory, type ant -f build_framework.xml to build the frameworks directories.

Notes:

- The following frameworks directories have not yet been approved by legal for donation to the ASF: flash-intergration, 
  automation, automation_air, automation_airspark, automation_dmv, automation_flashflexkit and automation_spark.
- The asdoc and doc directories will be contributed in a later drop.
- The frameworks directory contains a build_framework.xml file and a build.xml file.  The build_framework.xml directory builds frameworks in the context of 
  a downloaded kit so it uses the compiler in the bin directory.  The build.xml file builds frameworks in the context of the source tree which means it 
  uses the compiler in the modules directory.  If you would prefer you can copy build_framework.xml to build.xml so you just have to type ant to build
  frameworks.
- While the official documentation says that J2SDK 1.5.0_13 is required, I use Java Version 1.6.0_29 from Apple Inc. without any issues.