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

package flex2.tools.oem.internal;

import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.io.PrintWriter;
import java.net.URISyntaxException;

import flex2.compiler.common.DefaultsConfigurator;
import flex2.compiler.config.ConfigurationBuffer;
import flex2.compiler.config.ConfigurationException;
import flex2.compiler.swc.SwcException;
import flex2.compiler.util.ThreadLocalToolkit;
import flex2.tools.CommandLineConfiguration;
import flex2.tools.Mxmlc;
import flex2.tools.oem.Application;
import flex2.tools.oem.Report;

/**
 * Command line utility for compiling applications using the OEM API.
 *
 * @version 2.0.1
 * @author Clement Wong
 */
public class ApplicationCompiler
{
	static class FBApp extends Application
	{
		public FBApp(File file) throws FileNotFoundException
		{
			super(file);
		}
		
		public void build(OutputStream releaseOut, OutputStream debugOut, boolean incremental) throws IOException
		{
			int result = compile(incremental);
			if (result == OK || result == LINK)
			{
				long size = 0;
				
				size = link(debugOut);
				System.out.println("(" + size + " bytes)");
				this.getConfiguration().enableDebugging(false, "password");
				this.getConfiguration().keepLinkReport(true);
				this.getConfiguration().keepSizeReport(true);
				size = link(releaseOut);
				System.out.println("(" + size + " bytes)");
			}
		}
	}
	
	public static void main(String[] args) throws IOException
	{
        final OEMConsole console = new OEMConsole();
        
        try
        {
            LibraryCompiler.init();
    		run(console, args);
        }
        catch (ConfigurationException ex)
        {
            Mxmlc.processConfigurationException(ex, "mxmlc");
        }
        catch (SwcException ex)
        {
            assert ThreadLocalToolkit.errorCount() > 0;
        }
        catch (Throwable t) // IOException, Throwable
        {
            ThreadLocalToolkit.logError(t.getMessage());
            t.printStackTrace();
        }
        finally
        {
            LibraryCompiler.clean();
        }

        System.exit(console.errorCount());
	}
    
    public static void run(OEMConsole console, String[] args)
        throws ConfigurationException, IOException, URISyntaxException
    {
        ThreadLocalToolkit.setLogger(console);
        
        /*
        BuilderApplication a = new BuilderApplication(new File(args[0]));
        BuilderConfiguration c = (BuilderConfiguration) a.getDefaultConfiguration();
        c.setConfiguration(new String[] { "-dump-config", "c:\\foo.xml", "-verbose-stacktraces=true", "--debug=false", "-warnings=true" });
        a.setConfiguration(c);
        System.out.println(a.build(new java.io.ByteArrayOutputStream(), true));
         */
        
        FBApp app = new FBApp(new File(args[args.length - 1]));     
        CommandLineConfiguration c2 = getCommandLineConfiguration(args);
        app.setLogger(new OEMConsole());
        OEMConfiguration c1 = (OEMConfiguration) app.getDefaultConfiguration();
        OEMConfiguration c3 = new OEMConfiguration(null, c2);
        c1.importDefaults(c3);
        c1.keepConfigurationReport(true);
        app.setConfiguration(c1);
        // app.setProgressMeter(new OEMProgressMeter());

        // app.build(new BufferedOutputStream(new FileOutputStream(new File(c2.getOutput()))), true);
        app.build(new BufferedOutputStream(new FileOutputStream(new File(c2.getOutput()))),
                  new BufferedOutputStream(new FileOutputStream(new File(c2.getOutput() + ".swf"))), true);
        Report r = app.getReport();
        r.writeLinkReport(new PrintWriter(new FileOutputStream(new File(c2.getOutput() + ".link.xml"))));
        r.writeConfigurationReport(new PrintWriter(new FileOutputStream(new File(c2.getOutput() + ".config.xml"))));
        /*
        Message[] messages = r.getMessages();
        for (int i = 0, size = messages == null ? 0 : messages.length; i < size; i++)
        {
            System.out.println(messages[i].toString());
        }
        */
    }
	
	private static CommandLineConfiguration getCommandLineConfiguration(String[] args)
        throws ConfigurationException, IOException
	{
        ConfigurationBuffer cfgbuf = new ConfigurationBuffer(CommandLineConfiguration.class,
        													 CommandLineConfiguration.getAliases());
        cfgbuf.setDefaultVar("file-specs");
        DefaultsConfigurator.loadDefaults( cfgbuf );
        Object obj = Mxmlc.processConfiguration(ThreadLocalToolkit.getLocalizationManager(),
        										   "mxmlc",
        										   args,
        										   cfgbuf,
        										   CommandLineConfiguration.class,
        										   "file-specs");
        
        return (CommandLineConfiguration) obj;
	}
}
