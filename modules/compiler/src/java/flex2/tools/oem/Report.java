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

import java.io.IOException;
import java.io.Writer;

/**
 * The <code>Report</code> interface provides information about the composition
 * of an <code>Application</code> or a <code>Library</code>.
 * 
 * @see flex2.tools.oem.Builder#getReport()
 * @version 2.0.1
 * @author Clement Wong
 */
public interface Report
{
    /**
     * Use this constant when querying information from the compiler.
     */
    Object COMPILER = "COMPILER";
    
    /**
     * Use this constant when querying information from the linker.
     */
    Object LINKER = "LINKER";
    
    /**
     * Gets the name of all the sources that are involved in the <code>Application</code> or <code>Library</code>.
     * The <code>getSourceNames(Report.COMPILER)</code> method returns the name of all the source files
     * that are involved in the compilation.
     * 
     * <p>
     * The <code>getSourceNames(Report.LINKER)</code> method returns the name of all the source files
     * that are eventually output by the linker. 
     * 
     * <p>
     * The <code>getSourceNames(Report.COMPILER)</code> 
     * and <code>getSourceNames(Report.LINKER)</code> methods can yield different results if the linker is
     * instructed to exclude certain definitions from the final output.
     * 
     * @see #COMPILER
     * @see #LINKER
     * 
     * @param report The <code>COMPILER</code> or <code>LINKER</code>.
     * 
     * @return A list of source names.
     */
    String[] getSourceNames(Object report);
    
    /**
     * Gets the names of all the assets that are involved in the <code>Application</code> or <code>Library</code>.
     * The <code>getAssetNames(Report.COMPILER)</code> method returns the names of all the asset files
     * that are involved in the compilation.
     * 
     * <p>
     * The <code>getAssetNames(Report.LINKER)</code> method returns the names of all the asset files
     * that are eventually output by the linker. 
     * 
     * <p>
     * The <code>getAssetNames(Report.COMPILER)</code> 
     * and <code>getAssetNames(Report.LINKER)</code> methods can yield different results if the linker is
     * instructed to exclude certain definitions from the final output.
     * 
     * @see #COMPILER
     * @see #LINKER
     * 
     * @param report The <code>COMPILER</code> or <code>LINKER</code>.
     * 
     * @return A list of asset names.
     */
    String[] getAssetNames(Object report);
    
    /**
     * Gets the names of all the assets that are in the specified frame.
     * The number of frames in the movie can be obtained by invoking <code>getFrameCount()</code>.
     * 
     * <p>
     * If the compilation did not generate a movie, this method returns <code>null</code>.
     * 
     * @see #getFrameCount()
     * @param frame frame number. The number is 1-based.
     * @return an array of asset file names
     */
    String[] getAssetNames(int frame);

    /**
     * Gets the name of all the libraries that are involved in the <code>Application</code> or <code>Library</code>.
     * The <code>getLibraryNames(Report.COMPILER)</code> method returns the name of all the library files
     * that are involved in the compilation.
     * 
     * <p>
     * The <code>getLibraryNames(Report.LINKER)</code> method returns the name of all the library files
     * that are eventually output by the linker. 
     * 
     * <p>
     * The <code>getLibraryNames(Report.COMPILER)</code>
     * and <code>getLibraryNames(Report.LINKER)</code> methods can yield different results if the linker is
     * instructed to exclude certain definitions from the final output.
     * 
     * @see #COMPILER
     * @see #LINKER
     * 
     * @param report The <code>COMPILER</code> or <code>LINKER</code>.
     * 
     * @return A list of library names.
     */
    String[] getLibraryNames(Object report);
    
    /**
     * Gets the name of all the resource bundles that are involved in the Application/Library.
     * The <code>getResourceBundleNames()</code> method returns a list of names that
     * can be passed to the <code>Library.addResourceBundle()</code> method.
     * 
     * <p>
     * The returned value should match the output from the <code>resource-bundle-list</code> compiler option.
     * 
     * @return A list of resource bundle names.
     */
    String[] getResourceBundleNames();

    /**
     * Gets the list of all the top-level, externally-visible definitions in the specified
     * source file. You can get the specified source file from the <code>getSourceNames()</code> method.
     * 
     * <p>
     * The output definition names are in the QName format; for example: <code>mx.controls:Button</code>.
     * 
     * @param sourceName Source file name.
     * @return An array of definition names; <code>null</code> if there is no definition in the source file.
     */
    String[] getDefinitionNames(String sourceName);
    
    /**
     * Gets the list of all the top-level, externally-visible definitions in the specified frame.
     * The sequence represents the order in which the definitions are exported to the frame.
     * The number of frames in the movie can be obtained by invoking <code>getFrameCount()</code>.
     * 
     * <p>
     * If the compilation did not generate a movie, this method returns <code>null</code>.
     * 
     * @see #getFrameCount()
     * @param frame frame number. The number is 1-based.
     * @return an array of definition names
     */
    String[] getDefinitionNames(int frame);
    
    /**
     * Gets the location of the specified definition.
     * 
     * <p>
     * The specified definition name must be in the QName format; for example: <code>mx.controls:Button</code>.
     * 
     * @param definition A definition is a class, function, variable, or namespace.
     * @return The location of the specified definition; <code>null</code> if the definition is not found.
     */
    String getLocation(String definition);
    
    /**
     * Gets the list of definitions that the specified definition depends on during initialization.
     *  
     * <p>
     * The specified definition name must be in the QName format; for example: <code>mx.controls:Button</code>.
     * 
     * @param definition A class.
     * 
     * @return An array of definition names; <code>null</code> if there is no dependency.
     */
    String[] getPrerequisites(String definition);
    
    /**
     * Gets the list of definitions that the specified definition depends on during run time.
     *  
     * <p>
     * The specified definition name must be in the QName format; for example: <code>mx.controls:Button</code>.
     * 
     * @param definition A definition is a class, function, variable, or namespace.
     * 
     * @return An array of definition names; <code>null</code> if there is no dependency.
     */
    String[] getDependencies(String definition);

    /**
     * Writes the linker report to the specified output. If this <code>Report</code> was generated before linking,
     * this method returns <code>0</code>. You should provide a <code>BufferedWriter</code>, if possible. 
     * You should be sure to close the specified <code>Writer</code>.
     * 
     * <p>
     * To use this method, you must call the <code>Configuration.keepLinkReport()</code> method 
     * before the compilation.
     * 
     * @param out An instance of <code>Writer</code>.
     * 
     * @return The number of characters written out.
     * 
     * @throws IOException Thrown when an I/O error occurs while the link report is being written.
     * 
     * @see flex2.tools.oem.Configuration#keepLinkReport(boolean)
     */
    long writeLinkReport(Writer out) throws IOException;
    
    /**
     * Writes the linker size report to the specified output. If this <code>Report</code> was generated before linking,
     * this method returns <code>0</code>. You should provide a <code>BufferedWriter</code>, if possible. 
     * You should be sure to close the specified <code>Writer</code>.
     * 
     * <p>
     * To use this method, you must call the <code>Configuration.keepSizeReport()</code> method 
     * before the compilation.
     * 
     * @param out An instance of <code>Writer</code>.
     * 
     * @return The number of characters written out.
     * 
     * @throws IOException Thrown when an I/O error occurs while the link report is being written.
     * 
     * @see flex2.tools.oem.Configuration#keepSizeReport(boolean)
     */
    long writeSizeReport(Writer out) throws IOException;
    
    /**
     * Writes the configuration report to the specified output.
     * You should provide a <code>BufferedWriter</code>, if possible. 
     * Be sure to close the specified <code>Writer</code>.
     * 
     * <p>
     * To use this method, you must call the <code>Configuration.keepConfigurationReport()</code> method 
     * before the compilation.
     * 
     * @param out An instance of <code>Writer</code>.
     * 
     * @return The number of characters written out.
     * 
     * @throws IOException Thrown when an I/O error occurs during writing the configuration report.
     * 
     * @see flex2.tools.oem.Configuration#keepConfigurationReport(boolean)
     */
    long writeConfigurationReport(Writer out) throws IOException;
    
    /**
     * Gets the background color. The default value is <code>0x869CA7</code>.
     * If the <code>Report</code> was generated before linking, this method returns <code>0</code>.
     * 
     * @return An RGB value.
     */
    int getBackgroundColor();
    
    /**
     * Gets the page title.
     * If the <code>Report</code> was generated before linking, this method returns <code>null</code>.
     * 
     * @return Page title; <code>null</code> if it was not specified.
     */
    String getPageTitle();
    
    /**
     * Gets the default width of the application. The default value is <code>500</code>.
     * 
     * @return The default width, in pixels.
     */
    int getDefaultWidth();
    
    /**
     * Gets the default height of the application. The default value is <code>375</code>.
     * 
     * @return The default height, in pixels.
     */
    int getDefaultHeight();
    
    /**
     * Gets the user-defined width.
     * If the <code>Report</code> was generated before linking, this method returns <code>0</code>.
     * 
     * @return Width of the application, in pixels; <code>0</code> if it was not specified.
     */
    int getWidth();
    
    /**
     * Gets the user-defined height.
     * If the <code>Report</code> was generated before linking, this method returns <code>0</code>.
     * 
     * @return Height, in pixels; <code>0</code> if it was not specified.
     */
    int getHeight();
    
    /**
     * Gets the user-defined width percentage.
     * If the <code>Report</code> was generated before linking, this method returns <code>0.0</code>.
     * 
     * @return Width percentage; <code>0.0</code> if it was not specified.
     */
    double getWidthPercent();
    
    /**
     * Gets the user-defined height percentage.
     * If the <code>Report</code> was generated before linking, this method returns <code>0.0</code>.
     * 
     * @return Height percentage; <code>0.0</code> if it was not specified.
     */
    double getHeightPercent();
    
    /**
     * Outputs the compiler version.
     * 
     * @return A string representing the compiler version.
     */
    String getCompilerVersion();
    
    /**
     * Reports the errors and warnings that were generated during the compilation. The returned
     * <code>Message</code> objects are errors and warnings.
     * 
     * @return An array of error and warning Message objects; <code>null</code> if there were no errors or warnings.
     */
    Message[] getMessages();

    /**
     * Gets the number of frames in the movie. For <code>Application</code>, the returned
     * value is the number of frames in the movie. For <code>Library</code>, the returned
     * value is the number of frames in library.swf.
     * 
     * <p>
     * If the compilation did not generate a movie, the returned value will be <code>0</code>.
     * 
     * @return number of frames
     */
    int getFrameCount();
    
    /**
     * Checks whether the sources, assets and libraries have been updated since the report was created.
     * 
     * @since 3.0
     * @return
     */
    boolean contentUpdated();
}
