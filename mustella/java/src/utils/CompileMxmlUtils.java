/*
 *
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */
package utils;

import java.io.File;
import java.util.ArrayList;
import java.util.Vector;
import java.util.List;
import java.util.StringTokenizer;

/**
 * User: dschaffer
 * Date: Mar 22, 2005
 * Time: 3:28:38 PM
 */
public class CompileMxmlUtils {
    private String swf;
	private String linkReport;
    private String fileBasedArgs;
    private String mxmlc;
    private String dir;
    private long lastRunTime;
    private RuntimeExecHelper reh;
    private String execArgs[];
    boolean printOut=false;
    
    public void compile(String mxml) throws Exception {
    	compile(mxml,new ArrayList());
    }

    public void compile(String mxml,ArrayList optionalArgs) throws Exception {
        boolean debug=false;
        debug=System.getProperty("debug")!=null && System.getProperty("debug").equals("true");
        String mxmlcdir=System.getProperty("mxmlcdir");
        String mxmlcexe=System.getProperty("mxmlcexe");
        mxmlc=FileUtils.normalizeDirOS(mxmlcdir+"/"+mxmlcexe);
        if (debug) {
            System.out.println("mxmlcdir="+mxmlcdir);
            System.out.println("mxmlcexe="+mxmlcexe);
            System.out.println("mxmlc="+mxmlc);                                                                       
        }
        if (mxmlc==null || new File(mxmlc).isFile()==false) {
            throw new Exception("mxml compiler not set correctly, mxmlc="+mxmlc);
        }
        String frameworks=System.getProperty("frameworks");
        if (frameworks==null || new File(frameworks).isDirectory()==false) {
            throw new Exception("frameworks not set correctly, frameworks="+frameworks);
        }
        if (debug) {
            System.out.println("frameworks="+frameworks);
        }
        if (dir==null || new File(dir).isDirectory()==false) {
            throw new Exception("working dir not set correctly, dir="+dir);
        }

        swf=mxml.substring(0,mxml.length()-4)+"swf";
		linkReport=mxml.substring(0,mxml.length()-4)+"lnk.xml";
		
        String newArgs=null;

        //if cmdLineArgs property exists used it for mxmlc args
        String sysPropArgs=System.getProperty("cmdLineArgs");
        if (sysPropArgs!=null && !sysPropArgs.equals("") ){
            newArgs=sysPropArgs;
            if (debug) {
                System.out.println("sysPropArgs="+newArgs + " exists.  Reading args.");
                System.out.println("sysPropArgs="+newArgs);
            }
        }

        //see if there is a .args file in the folder with the same name as the folder
        String folderpath= new File(mxml).getParent();
        String foldername=new File(folderpath).getName();
        String folderBasedArgs=folderpath + File.separator + foldername + ".args";
        //if file with same name as mxml, but extension=args exists used it for mxmlc args
        fileBasedArgs=mxml.substring(0,mxml.length()-4)+"args";

        if (new File(fileBasedArgs).exists()==true) {
            if (debug) {
                System.out.println("fileBasedArgs="+fileBasedArgs + " exists.  Reading args.");
            }
            //read file and create string[] of args
            String tmp=FileUtils.readFile(fileBasedArgs);

            if (tmp !=null && !tmp.equals("") ){
                newArgs=tmp;
            }
            if (debug) {
                System.out.println("fileBasedArgs="+newArgs);
            }

        } else if (new File(folderBasedArgs).exists()==true)   {
             if (debug) {
                System.out.println("folderBasedArgs="+folderBasedArgs + " exists.  Reading args.");
            }
            //read file and create string[] of args
            String tmp=FileUtils.readFile(folderBasedArgs);

            if (tmp !=null && !tmp.equals("") ){
                newArgs=tmp;
            }
            if (debug) {
                System.out.println("folderBasedArgs="+newArgs);
            }
        }

        if( newArgs != null ) {
        	ArgumentParser parser = new ArgumentParser(newArgs);
        	optionalArgs = parser.parseArguments();
        }

        //String mxmldir=FileUtils.getDirectory(mxml);
        // mxunit setup?
        String mxunit=System.getProperty("mxunit");
        if (mxunit!=null) {
            if (new File(mxunit).isDirectory()==false) {
                throw new Exception("mxunit directory not set correctly, mxunit="+mxunit);
            }
            if (debug) {
                System.out.println("mxunit="+mxunit);
            }
            mxunit=FileUtils.normalizeDir(mxunit);
        }

        String basedir=System.getProperty("basedir");
        if (basedir!=null) {
            if (new File(basedir).isDirectory()==false) {
                throw new Exception("basedir directory not set correctly, basedir="+basedir);
            }
            if (debug) {
                System.out.println("basedir="+basedir);
            }
            basedir=FileUtils.normalizeDir(basedir);
        }

		boolean hasLinkReport = false;
        optionalArgs.add(0, mxmlc);
        for (int i=0; i < optionalArgs.size(); i++) {
        	String a = (String)optionalArgs.get(i);
        	if( a.indexOf("-link-report") != -1 ) hasLinkReport = true;
        }
        if( !hasLinkReport ) {
        	optionalArgs.add("-link-report=" + linkReport);
        }
        optionalArgs.add(mxml);
        execArgs = ArgumentParser.toArray(optionalArgs);

        if (debug) {
        	System.out.println("cd "+dir);
            System.out.println("CompileMxmlUtils.compile: "+StringUtils.arrayToString(execArgs));
        }

        int timeout=300;
        try { timeout=Integer.parseInt(System.getProperty("mxunit.compiler.timeout")); } catch (Exception e) {}
		
		//String java_home = System.getProperty("JAVA_HOME");
		//String [] env = new String[]{"JAVA_HOME=" + java_home};
        reh=new RuntimeExecHelper(execArgs,dir);
        reh.setPrintOutput(printOut);
        reh.setTimeout(timeout);
        long startTime=System.currentTimeMillis();
        reh.run();
        lastRunTime=System.currentTimeMillis()-startTime;
    }
    
    public String getSwf() { return swf; }
    public long getLastRunTime() { return lastRunTime; }
    public RuntimeExecHelper getRuntimeExecHelper() { return reh; }
    public String[] getExecArgs() { return execArgs; }
    public void setDir(String dir) { this.dir=dir; }
    public String getDir() { return dir; }
    public void setPrintOut(boolean b)  { printOut=b; }
}
