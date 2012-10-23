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
import java.io.IOException;
import java.util.StringTokenizer;
import java.util.List;
import java.util.Vector;
import java.util.Iterator;
import java.util.ArrayList;

import utils.FileUtils;
import org.xml.sax.SAXException;
import org.w3c.dom.Document;
import org.w3c.dom.NodeList;

public class CompcUtils {
    private String compc;
    private String dir;
    private long lastRunTime;
    private RuntimeExecHelper reh;
    private String execArgs[];
    boolean printOut = false;
    private String configfileIndicator1 = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>";
    private String configfileIndicator2 = "<flex-config xmlns=\"http://www.adobe.com/2006/flex-config\">";
    private Vector swcs;
    private boolean bConfigFileArgs = false;

    private void debug(String msg) {
        if (System.getProperty("debug") != null && System.getProperty("debug").equals("true")) {
            System.out.println(msg);
        }
    }

    //read args from system property = compc.args
    public void compile() throws Exception {
        String strArgs = System.getProperty("compc.args");
        if (strArgs != null && !strArgs.equals("")) {
            debug("got compc args from System property - compc.args = " + strArgs);
            compile(strArgs);
        } else {
            throw new Exception("compc args from System property - compc.args are empty!");
        }
    }


    public void compile(String args) throws Exception {
    	if( !args.equals("")) {
    		ArgumentParser parser = new ArgumentParser(args);
    		ArrayList result = parser.parseArguments();
    		String a[] = new String[result.size()];
        	for(int i=0; i < result.size(); i++) a[i] = (String)result.get(i);
        	compc(a);
    	} else {
    		throw new Exception("compc args are empty!");
    	}
    }

    //read args from file
    public void compile(File argFile) throws Exception {
        if (argFile.exists()) {
            debug("reading compc args from file: " + argFile.getAbsolutePath());
            // determine if arg file is a config file or lists of commandline args
            List args = FileUtils.readLines(argFile.getAbsolutePath());
            if (args.size() == 0) {
                throw new Exception("compc args file " + argFile.getAbsolutePath() + " is empty!");
            }

            String frameworks = FileUtils.normalizeDir(System.getProperty("frameworks", "."));
            String basedir=FileUtils.normalizeDir(System.getProperty("basedir"));
            String mxunitdir=basedir+"/sdk/testsuites/mxunit";

            try {
                // if 1st 2 lines of argFile indicate that it is an xml config file, make compc args use the -config=argFile
                if (((String) args.get(0)).trim().equalsIgnoreCase(configfileIndicator1) && ((String) args.get(1)).trim().equalsIgnoreCase((configfileIndicator2))) {
                    args = new Vector();
                    args.add("--load-config " + argFile.getAbsolutePath());
                    bConfigFileArgs = true;
                }
            } catch (Exception e) {
                //must only have 1 line so do nothing
            }
            Iterator it = args.iterator();
            while (it.hasNext()) {
                compile((String) it.next() + " +frameworks-dir " + frameworks + " +mxunit-dir " + mxunitdir);
            }
        } else {
            throw new Exception("compc args file " + argFile.getAbsolutePath() + " does not exisit!");
        }

    }

    //given an mxml Testfile,
    //  if file with same name, but extension=compc exists, return that file
    //  if file with same name as parent folder and extension=compc exists, return that file
    public File getCompcArgFile(String mxmlTest) throws Exception {

        return getArgFile(mxmlTest, "compc");
    }

    public File getRSLArgFile(String mxmlTest) throws Exception {
        return getArgFile(mxmlTest, "rsl");
    }

    private File getArgFile(String mxmlTest, String extension) throws Exception {
        //see if there is a .extension file in the folder with the same name as the folder
        String folderpath = new File(mxmlTest).getParent();
        String foldername = new File(folderpath).getName();
        String folderBasedArgs = folderpath + File.separator + foldername + "." + extension;
        //if file with same name as mxml, but extension=extension exists use it for args
        String fileBasedArgs = mxmlTest.substring(0, mxmlTest.length() - 4) + extension;
        File argFile = null;

        if (new File(fileBasedArgs).exists()) {
            debug("fileBasedArgs=" + fileBasedArgs + " exists.  Reading args.");
            argFile = new File(fileBasedArgs);
        } else if (new File(folderBasedArgs).exists()) {
            debug("folderBasedArgs=" + folderBasedArgs + " exists.  Reading args.");
            argFile = new File(folderBasedArgs);
        } else {
            throw new Exception(extension + " argFile does not exist");
        }
        return argFile;
    }


    public void compile(String[] args) throws Exception {
        compc(args);
    }

    private void compc(String[] args) throws Exception {
        //compcdir and compcexe must be specified as system properties!
        String compcdir = System.getProperty("compcdir");
        String compcexe = System.getProperty("compcexe");
        compc = FileUtils.normalizeDirOS(compcdir + File.separator + compcexe);
        debug("compcdir=" + compcdir);
        debug("compcexe=" + compcexe);
        debug("compc=" + compc);

        if (compc == null || new File(compc).isFile() == false) {
            throw new Exception("compc compiler not set correctly, compc=" + compc);
        }

        // frameworks must be specified as system property.
        // This will be used later on as the working directory for compilation
        String frameworks = FileUtils.normalizeDir(System.getProperty("frameworks"));
        if (frameworks == null || new File(frameworks).isDirectory() == false) {
            throw new Exception("frameworks not set correctly, frameworks=" + frameworks);
        }
        debug("frameworks=" + frameworks);
        if (dir == null)
        	dir = frameworks;

        execArgs = new String[args.length + 1];
        execArgs[0] = compc;
        for (int i = 0; i < args.length; i++) {
            execArgs[i + 1] = args[i];
        }

        debug("cd " + dir);
        System.out.println(StringUtils.arrayToString(execArgs));

        int timeout = 300;
        try {
            timeout = Integer.parseInt(System.getProperty("compc.timeout"));
        } catch (Exception e) {
        }

        swcs = new Vector();

        //delete output swc if it already exists and add swc to list of swcs generated
        // uh...this doesn't really work if swc is relative..
        String swcname=getSwc(execArgs);
        /*
        debug(">>>>> deleting old swc if it exists: " + swcname);
        if (!swcname.endsWith(".swc")){
            debug(">>>>> swc is dir so emptying dir");
            File f = new File(swcname);
            if (f.isDirectory()){
                File[] fa=f.listFiles();
                for (int x=0;x<fa.length;x++){
                    debug(">>>>> deleting: " + fa[x].getAbsolutePath());
                    fa[x].delete();
                }
             }
        }
        */
        utils.FileUtils.deleteFile(swcname);

        reh = new RuntimeExecHelper(execArgs, dir);
        reh.setPrintOutput(printOut);
        reh.setTimeout(timeout);
        long startTime = System.currentTimeMillis();
        reh.run();
        lastRunTime = System.currentTimeMillis() - startTime;

    }

    private String getSwc(String[] execArgs) {
        // add swc that results from compile to private array of swcs
        //parse execArgs to find -output value
        //todo:this will need to be refactored when compc really works
        String swc = "";
        if (!bConfigFileArgs) {
            for (int i = 0; i < execArgs.length; i++) {
                if (execArgs[i].equals("--o") || execArgs[i].equals("-o") || execArgs[i].equals("--output") || execArgs[i].equals("-output")) {
                    swc = execArgs[i + 1];
                    swcs.add(swc);
                    break;
                }
            }
        } else {
            String configFile = "";
            for (int i = 0; i < execArgs.length; i++) {
                if (execArgs[i].equals("--load-config") || execArgs[i].equals("-load-config")) {
                    configFile = execArgs[i + 1];
                    break;
                }
            }

            try {
                debug("configFile=" + configFile);
                Document doc = DocumentUtils.parseDocument(configFile);
                doc.getDocumentElement().normalize();
                NodeList nd = doc.getElementsByTagName("output");
                swc = nd.item(0).getFirstChild().getNodeValue();
                debug(">>>>>>>>>>>swc=" + swc);
                swcs.add(swc);
            } catch (SAXException e) {
                e.printStackTrace();
            } catch (IOException e) {
                e.printStackTrace();
            }

        }
        return swc;
    }

    public List getSwcs() {
        return swcs;
    }

    public long getLastRunTime() {
        return lastRunTime;
    }

    public RuntimeExecHelper getRuntimeExecHelper() {
        return reh;
    }

    public String[] getExecArgs() {
        return execArgs;
    }

    public String getDir() {
        return dir;
    }
    
    public void setDir(String newDir) {
        dir = newDir;
    }

    public void setPrintOut(boolean b) {
        printOut = b;
    }

    //use the internal swc returned via compc and validate it
    public void validateSwcs() {
        validateSwcs(getSwcs());

    }

    private boolean validateSwc(String swc) {
        //todo: this will need to be refactored to improve validation criteria
        if (new File(swc).exists() && new File(swc).length() > 0) {
            return true;
        } else {
            return false;
        }
    }

    private void validateSwcs(List swcs) {
        Iterator it = swcs.iterator();
        while (it.hasNext()) {
            String swc = (String) it.next();
            if (validateSwc(swc)) {
                junit.framework.Assert.fail("compc failed to compile swc using these args: \n" + swc);
            }
        }
    }


//    todo: I think this is the correct thing do to when compc will really be working?? - kq
    public ArrayList addSwcToClassPath(ArrayList mxmlArgs) {
        //tack the swc onto the end of the --library-path

        //debug(">>>>>> original mxmlArgs >>> " + StringUtils.arrayToString(mxmlArgs));

        validateSwcs();

        boolean bFound = false;
        String sep = " ";
        int insertPos = 0;
        ArrayList l = new ArrayList();
        for (int i = 0; i < mxmlArgs.size(); i++) {
        	String anArg = (String)mxmlArgs.get(i);
            if (anArg.trim().toLowerCase().indexOf("--library-path") > 0 || anArg.trim().toLowerCase().indexOf("-library-path") > 0) {
                bFound = true;
                insertPos = i;
                debug("found library-path");
            }
            if (bFound) {
                if ((anArg.startsWith("-") || anArg.startsWith("+")) && insertPos != i) {
                    insertPos = i;
                    bFound = false;
                }
                if (anArg.indexOf("=") > 0) {
                    sep = ",";
                    debug(">>> sepaprator is ',' ");
                }
            }
            l.add(anArg);

        }
        if (insertPos != 0) {
            debug("found library-path at pos = " + insertPos);
            Iterator it = getSwcs().iterator();
            if (sep.equals(",")) {
                String ins = (String) l.get(insertPos - 1);
                while (it.hasNext()) {
                    ins += sep + it.next();
                }
                l.set(insertPos - 1, ins);
            } else {
                while (it.hasNext()) {
                    l.add(insertPos, (String) it.next());
                    insertPos++;
                }

                //l.add(insertPos, "--");
            }
        } else {
            //hack to make skinning.as last
            boolean skinning = false;
            if (((String) l.get(l.size() - 1)).trim().equalsIgnoreCase("skinning.as")) {
                skinning = true;
                l.remove(l.size() - 1);
            }

            //l.add("--library-path=");
            String swcNames = "";
            Iterator it = getSwcs().iterator();
            while (it.hasNext()) {
                //l.add((String) it.next());
                swcNames += (String) it.next();
            }
			l.add("--library-path+=" + swcNames);
			
            if (skinning) {
                if (!((String) l.get(l.size())).startsWith("-")) {
                    l.add("--");
                }
                l.add("skinning.as");
            }
        }

        return l;

    }


}
