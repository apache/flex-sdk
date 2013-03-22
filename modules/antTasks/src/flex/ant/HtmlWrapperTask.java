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

package flex.ant;

import java.io.BufferedReader;
import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.FileOutputStream;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.DynamicAttribute;
import org.apache.tools.ant.Task;

/**
 * Implements the &lt;html-wrapper&gt; Ant task.  For example:
 * <pre>
 * &lt;html-wrapper title="foo"
 *             height="100"
 *             width="100"
 *             bgcolor="red"
 *             application="bar"
 *             swf="bar"
 *             version-major="9"
 *             version-minor="0"
 *             version-revision="0"
 *             history="true"
 *             template="client-side-detection"
 *             output="client-side-detection-with-history"/&gt;
 * </pre>
 */
public final class HtmlWrapperTask extends Task implements DynamicAttribute
{
    private static final String TEMPLATE_DIR = "/templates/swfobject/";
    private static final String INDEX_TEMPLATE_HTML = "index.template.html";
    private static final String SWFOBJECT_JS = "swfobject.js";
    private static final String HISTORY_CSS = "history/history.css";
    private static final String HISTORY_JS = "history/history.js";
    private static final String HISTORY_FRAME_HTML = "history/historyFrame.html";
    private static final String EXPRESSINSTALL_SWF = "expressInstall.swf";
    private static final String HTML_COMMENT_DELIMITER = "--";
    
    private String application;
    private String bgcolor = "white";
    private String fileName = "index.html";
    private String height = "400";
    private String output;
    private String swf;
    private String title = "Flex Application";
    private String width = "400";
    private boolean history = false;
    private boolean expressInstall = false;
    private boolean versionDetection = true;
    
    // The various settings of version, browser history and express install
    // determine how the generated template behaves - maps to the 6 template 
    // flavors that existed for Flex 3 and earlier.
    private String versionMajor = "10";
    private String versionMinor = "0";
    private String versionRevision = "0";
    private String useBrowserHistory;  
    private String expressInstallSwf = "";
    
    public HtmlWrapperTask()
    {
        setTaskName("html-wrapper");
    }

    public void execute() throws BuildException
    {
        // Check for requirements.
        if (swf == null)
        {
            throw new BuildException("The <html-wrapper> task requires the 'swf' attribute.", getLocation());
        }

        InputStream inputStream = getInputStream();

        if (inputStream != null)
        {
            BufferedReader bufferedReader = null;
            PrintWriter printWriter = null;
            String path = null;

            try
            {
                bufferedReader = new BufferedReader(new InputStreamReader(inputStream));

                if (output != null)
                {
                    File outputDir = new File(output);
                    if (outputDir.exists() && outputDir.isDirectory())
                    {
                        path = output + File.separatorChar + fileName;
                    }
                    else
                    {
                        String base = getProject().getBaseDir().getAbsolutePath();
                        outputDir = new File(base + File.separatorChar + output);
                        if (outputDir.exists() && outputDir.isDirectory())
                        {
                            path = base + File.separatorChar + output + File.separatorChar + fileName;
                        }
                        else
                        {
                            throw new BuildException("output directory does not exist: " + output);
                        }
                    }
                }
                else
                {
                    path = fileName;
                }

                printWriter = new PrintWriter(new FileWriter(path));

                String line;

                while ((line = bufferedReader.readLine()) != null)
                {
                    printWriter.println(substitute(line));
                }
            }
            catch (IOException ioException)
            {
                System.err.println("Error outputting resource: " + path);
                ioException.printStackTrace();
            }
            finally
            {
                try
                {
                    bufferedReader.close();
                    printWriter.close();
                }
                catch (Exception exception)
                {
                }
            }
        }
        else
        {
            throw new BuildException("Missing resources", getLocation());
        }
    }

    private InputStream getInputStream()
    {
        InputStream inputStream;
        String[] resources;
        
        if (history)
        {
        	if(expressInstall)
        	{
        		expressInstallSwf = EXPRESSINSTALL_SWF;
        		resources = new String[] {SWFOBJECT_JS, HISTORY_FRAME_HTML, HISTORY_JS, HISTORY_CSS, EXPRESSINSTALL_SWF};
        		versionDetection = true;
        	}
        	else 
        	{
        		resources = new String[] {SWFOBJECT_JS, HISTORY_FRAME_HTML, HISTORY_JS, HISTORY_CSS};        		
        	}
            
            useBrowserHistory = HTML_COMMENT_DELIMITER;
        }
        else
        {
        	if(expressInstall)
        	{
        		expressInstallSwf = EXPRESSINSTALL_SWF;
        		resources = new String[] {SWFOBJECT_JS, EXPRESSINSTALL_SWF};
        		versionDetection = true;
        	}
        	else 
        	{
        		resources = new String[] {SWFOBJECT_JS};        		
        	}        	
            
            useBrowserHistory = "";
        }
        
        if(!versionDetection)
        {
            // no version checking
            versionMajor = "0";
            versionMinor = "0";
            versionRevision = "0";
            // don't install flash.
            expressInstallSwf = "";        	
        }
        
        inputStream = getClass().getResourceAsStream(TEMPLATE_DIR + INDEX_TEMPLATE_HTML);
        outputResources(TEMPLATE_DIR, resources);

        return inputStream;
    }

    private void outputResources(String resourceDir, String[] resources)
    {
        BufferedInputStream bufferedInputStream = null;
        BufferedOutputStream bufferedOutputStream = null;

        for (int i = 0; i < resources.length; i++)
        {
            try
            {
                InputStream inputStream = getClass().getResourceAsStream(resourceDir + resources[i]);
                bufferedInputStream = new BufferedInputStream(inputStream);
                String path = null;

                if (output != null)
                {
                    File outputDir = new File(output);
                    if (outputDir.exists() && outputDir.isDirectory())
                    {
                        path = output + File.separatorChar + resources[i];
                    }
                    else
                    {
                        String base = getProject().getBaseDir().getAbsolutePath();
                        outputDir = new File(base + File.separatorChar + output);
                        if (outputDir.exists() && outputDir.isDirectory())
                        {
                            path = base + File.separatorChar + output + File.separatorChar + resources[i];
                        }
                        else
                        {
                            throw new BuildException("output directory does not exist: " + output);
                        }
                    }
                }
                else
                {
                    path = resources[i];
                }
                
                File file = new File(path);
                file.getParentFile().mkdirs();

                bufferedOutputStream = new BufferedOutputStream(new FileOutputStream(file));

                byte byteArr[]=new byte[8192];

                int len;
                while ((len=bufferedInputStream.read(byteArr, 0, 8192))!=-1) 
                {
                    bufferedOutputStream.write(byteArr, 0, len);
                }
            }
            catch (IOException ioException)
            {
                System.err.println("Error outputting resource: " + resources[i]);
                ioException.printStackTrace();
            }
            finally
            {
                try
                {
                    bufferedOutputStream.close();
                    bufferedInputStream.close();
                }
                catch (Exception exception)
                {
                }
            }
        }
    }

    public void setApplication(String application)
    {
        this.application = application;
    }

    public void setBgcolor(String bgcolor)
    {
        this.bgcolor = bgcolor;
    }

    public void setDynamicAttribute(String name, String value)
    {
        if (name.equals("version-major"))
        {
            versionMajor = value;
        }
        else if (name.equals("version-minor"))
        {
            versionMinor = value;
        }
        else if (name.equals("version-revision"))
        {
            versionRevision = value;
        }
        else if (name.equals("express-install"))
        {
            expressInstall = Boolean.parseBoolean(value);
        }
        else if (name.equals("version-detection"))
        {
        	versionDetection = Boolean.parseBoolean(value);
        }
        else
        {
            throw new BuildException("The <html-wrapper> task doesn't support the \""
                                     + name + "\" attribute.", getLocation());
        }
    }

    public void setFile(String fileName)
    {
        this.fileName = fileName;
    }

    public void setHeight(String height)
    {
        this.height = height;
    }

    public void setHistory(boolean history)
    {
        this.history = history;
    }
    
    public void setOutput(String output)
    {
        this.output = output;
    }

    public void setSwf(String swf)
    {
        // Doctor up backslashes to fix bug 193739.
        this.swf = swf.replace('\\', '/');
        if (application == null)
        {
            application = this.swf;
        }
    }

    public void setTitle(String title)
    {
        this.title = title;
    }

    public void setWidth(String width)
    {
        this.width = width;
    }

    private String substitute(String input)
    {
        String result = input.replaceAll("\\$\\{application\\}", application);
        result = result.replaceAll("\\$\\{bgcolor\\}", bgcolor);
        result = result.replaceAll("\\$\\{expressInstallSwf\\}", expressInstallSwf);
        result = result.replaceAll("\\$\\{height\\}", height);
        result = result.replaceAll("\\$\\{swf\\}", swf);
        result = result.replaceAll("\\$\\{title\\}", title);
        result = result.replaceAll("\\$\\{version_major\\}", versionMajor);
        result = result.replaceAll("\\$\\{version_minor\\}", versionMinor);
        result = result.replaceAll("\\$\\{version_revision\\}", versionRevision);
        result = result.replaceAll("\\$\\{width\\}", width);
        result = result.replaceAll("\\$\\{useBrowserHistory\\}", useBrowserHistory);
        return result;
    }
}
