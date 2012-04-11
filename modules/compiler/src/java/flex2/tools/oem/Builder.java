/*
 *
 *  Licensed to the Apache Software Foundation (ASF) under one or more
 *  contributor license agreements.  See the NOTICE file distributed with
 *  this work for additional information regarding copyright ownership.
 *  The ASF licenses this file to You under the Apache License, Version 2.0
 *  (the "License"); you may not use this file except in compliance with
 *  the License.  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 */

package flex2.tools.oem;

import flex2.compiler.util.Benchmark;
import flex2.compiler.util.PerformanceData;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.Map;

/**
 * The <code>Builder</code> interface lists the common configuration and build-cycle methods.
 * The <code>Application</code> and <code>Library</code> classes both implement this interface.
 *  
 * @see flex2.tools.oem.Application
 * @see flex2.tools.oem.Library
 * @version 2.0.1
 * @author Clement Wong
 */
public interface Builder
{
    /**
     * Sets the compiler options for this object. You use the 
     * <code>getDefaultConfiguration()</code> method to get a <code>Configuration</code> object.
     * 
     * @see flex2.tools.oem.Configuration
     * 
     * @param configuration An instance of an object that implements the <code>Configuration</code> interface.
     */
    void setConfiguration(Configuration configuration);
    
    /**
     * Gets the default compiler options. The default values are specified in the <code>flex-config.xml</code>
     * file. You can override the default values by using methods of the <code>Configuration</code> interface.
     * 
     * <p>
     * This method returns the default compiler options in new <code>Configuration</code> objects.
     * 
     * @see flex2.tools.oem.Configuration
     * 
     * @return An instance of an object that implements the <code>Configuration</code> interface.
     */
    Configuration getDefaultConfiguration();
    
    /**
     * Gets the compiler options for this object. Unlike the <code>getDefaultConfiguration()</code> method,
     * this method returns <code>null</code> if the <code>setConfiguration()</code> method was not called.
     * 
     * @see flex2.tools.oem.Configuration
     * 
     * @return An instance of an object that implements the <code>Configuration</code> interface.
     */
    Configuration getConfiguration();


    /**
     * Gets the performance data for each compiler phase for the last build.
     *
     * @return A map of compiler phase to PerformanceData.
     */
    Map<String, PerformanceData[]> getCompilerBenchmarks();

    /**
     * Gets the overall performance data for the last build.
     *
     * @return a Benchmark object.
     */
    Benchmark getBenchmark();
    
    /**
     * Sets the logger for this object. The compiler uses the logger 
     * to notify clients of events that occurred during the compilation.
     * 
     * @see flex2.tools.oem.Logger
     * 
     * @param logger An object that implements the <code>Logger</code> interface.
     */
    void setLogger(Logger logger);
    
    /**
     * Gets the logger for this object. This method returns <code>null</code> if the <code>setLogger()</code>
     * method was not called.
     *  
     * @see flex2.tools.oem.Logger
     * 
     * @return An object that implements the <code>Logger</code> interface.
     */
    Logger getLogger();
    
    /**
     * Sets the custom file extensions for this object. For example:
     * 
     * <pre>
     * setSupportedFileExtensions(flex2.compiler.util.MimeMappings.MXML, new String[] {".foo"});
     * </pre>
     * 
     * This example instructs the compiler to treat files with the <code>*.foo</code> extension as MXML documents. 
     * The supported MIME types are specified in the <code>flex2.compiler.util.MimeMappings</code> class as constants.
     * 
     * @param mimeType MIME type.
     * @param extensions An array of file extensions.
     */
    void setSupportedFileExtensions(String mimeType, String[] extensions);

    /**
     * Sets the progress meter for this object. This method is optional.
     * You can set a progress meter so that it receives periodic updates
     * during the compilation. 
     * 
     * @see flex2.tools.oem.ProgressMeter
     * 
     * @param meter An object that implements the <code>ProgressMeter</code> interface.
     */
    void setProgressMeter(ProgressMeter meter);
    
    /**
     * Sets the path resolver for this object. This method is optional.
     *
     * @see flex2.tools.oem.PathResolver
     * 
     * @param resolver A path resolver
     */
    void setPathResolver(PathResolver resolver);

    /**
     * Sets the application cache to be shared by all the applications
     * and libraries in the current workspace.
     *
     * @param applicationCache The cache.
     */
    void setApplicationCache(ApplicationCache applicationCache);

    /**
     * Sets the library cache to be shared by all the applications and
     * libraries in the current project.
     *
     * @param libraryCache The cache.
     */
    void setSwcCache(LibraryCache libraryCache);
    
    /**
     * Builds the object. If the <code>incremental</code> input argument is <code>false</code>, 
     * this method recompiles all parts of the object. If the <code>incremental</code> 
     * input argument is <code>true</code>, 
     * this method compiles only the parts of the object that have changed since the last compilation.
     * 
     * <p>
     * You must call the <code>setOutput()</code> method before calling this method. The result is saved to the location
     * specified by the <code>getOutput()</code> method. If there is no output destination specified, this method 
     * does nothing and returns <code>0</code>.
     * 
     * @see flex2.tools.oem.Application
     * @see flex2.tools.oem.Library
     * 
     * @param incremental If <code>true</code>, build incrementally; if <code>false</code>, rebuild.
     * @return The number of bytes written out.
     * @throws IOException Thrown when an I/O error occurs during compilation.
     */
    long build(boolean incremental) throws IOException;

    /**
     * Builds the object. If the <code>incremental</code> input argument is <code>false</code>, 
     * this method recompiles all parts of the object. 
     * If the <code>incremental</code> input argument is <code>true</code>, 
     * this method compiles only the parts of the object that have changed since the last compilation.
     * 
     * <p>
     * This method only outputs to the specified <code>OutputStream</code>. For better performance, the OutputStream
     * should be buffered. This method does not output
     * to the destination specified by the <code>setOutput()</code> method.
     * 
     * @param out The <code>OutputStream</code>.
     * @param incremental If <code>true</code>, build incrementally; if <code>false</code>, rebuild.
     * @return The number of bytes written out. This method returns <code>0</code> if the object fails to compile.
     * @throws IOException Thrown when an I/O error occurs during compilation.
     */
    long build(OutputStream out, boolean incremental) throws IOException;

    /**
     * Stops the compilation. If the client runs the compiler in a background thread,
     * it can use this method to stop the compilation. The compiler does not
     * stop immediately, but stops the compilation when it reaches a
     * stable state.
     */
    void stop();

    /**
     * If you called the <code>setOutput()</code> method, this method
     * deletes the <code>Application</code> or <code>Library</code>
     * file. Calls to the <code>build()</code> method trigger a full
     * recompilation.
     * 
     * <p>
     * The <code>clean()</code> method does not remove compiler options or reset the output location.
     */
    void clean();

    /**
     * Loads compilation data from a previous compilation. This method is usually called before the <code>build()</code> method.
     * 
     * @param in The <code>InputStream</code>.
     * @throws IOException Thrown when an I/O error occurs while loading the compilation data.
     */
    void load(InputStream in) throws IOException;
    
    /**
     * Saves the current compilation data. This method is usually called after the <code>build()</code> method.
     * 
     * <p>
     * Do not use this to create a SWF or SWC file. Use the <code>build()</code> method instead.
     * 
     * @param out The <code>OutputStream</code>.
     * @return The number of bytes written out.
     * @throws IOException Thrown when an I/O error occurs while saving the compilation data.
     */
    long save(OutputStream out) throws IOException;
    
    /**
     * Reports information about the current compilation. This method returns <code>null</code>
     * if you have not yet called the <code>build(boolean)</code>, <code>build(OutputStream, boolean)</code>, or 
     * <code>compile(boolean)</code> methods.
     * 
     * <p>
     * The <code>Report</code> object includes the following information:
     * <ol>
     * <li>Number of source files used in the compilation.</li>
     * <li>The location of the source files.</li>
     * <li>Number of asset files that are embedded in the <code>Application</code> or <code>Library</code>.</li>
     * <li>The location of the asset files.</li>
     * <li>The dependencies of the source files.</li>
     * </ol>
     * <p>
     * You must call the <code>getReport()</code> method to get a new report after each 
     * call to the <code>build()</code> method.
     * 
     * @return An object that implements the <code>Report</code> interface.
     */
    Report getReport();

    File getOutput();
    
    /**
     * <code>Application.compile()</code> or <code>Library.compile()</code> did not compile anything.
     */
    int SKIP	= 0;
    
    /**
     * <code>Application.compile()</code> or <code>Library.compile()</code> did not compile but advise
     * the caller to link again.
     */
    int LINK	= Integer.MAX_VALUE;
    
    /**
     * <code>Application.compile()</code> or <code>Library.compile()</code> compiled successfully.
     */
    int OK		= 1;
    
    /**
     * <code>Application.compile()</code> or <code>Library.compile()</code> failed to compile.
     */
    int FAIL	= -1;
}
