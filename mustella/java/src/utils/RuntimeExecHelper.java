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

import java.io.*;
import java.net.InetAddress;
import java.net.Socket;

/**
 * User: dschaffer
 * Date: Mar 7, 2005
 * Time: 11:17:42 AM
 */
public class RuntimeExecHelper {
    boolean running = false;
    boolean output = false;
    int timeout = 300; // timeout in seconds
    int exitValue = -1;

    String inputText = null;
    String outputText;
    String errorText;
    String command[];
    String environment[];
    String dir;
    protected Process browserProcess;
    protected long startTime;
    protected ThreadReader outThreadReader;
    protected ThreadReader errThreadReader;

    private boolean printOutput = false;
    private boolean stop = false;

    public int browserServerID;

    public RuntimeExecHelper(String command[],String environment[],String dir) {
        setCommand(command);
        setEnvironment(environment);
        setDir(dir);
    }
    public RuntimeExecHelper(String command[],String dir) {
        this(command,null,dir);
    }

    public void setOutput(boolean output) {
    	this.output=output;
    }

    public void setTimeout(int timeout) {
        this.timeout=timeout;
    }

    public void setInputText(String inputText) {
        this.inputText=inputText;
    }

    public void setDir(String dir) {
        this.dir=dir;
    }
    public void setCommand(String command[]) {
        this.command=command;
    }

    public void setEnvironment(String environment[]) {
        this.environment=environment;
    }

    public void setPrintOutput(boolean printOutput) {
        this.printOutput=printOutput;
    }

    public boolean getRunning() {
        return running;
    }

    public String getOutputText() {
        refreshStreams();
        return outputText;
    }

    public String getErrorText() {
        refreshStreams();
        return errorText;
    }

    public int getExitValue() {
        return exitValue;
    }


    public void refreshStreams() {
        outputText = outThreadReader.getOutput();
        errorText = errThreadReader.getOutput();
        try {
            exitValue = browserProcess.exitValue();

        } catch (Exception e) {
        }

        if (exitValue != -1)
            running=false;
    }


    public void stop() {
        stop = true;
    }


    public void kill() throws Exception {
        if (browserProcess != null && exitValue == -1)
            browserProcess.destroy();

        outputText = outThreadReader.getOutput();
        errorText = errThreadReader.getOutput();
    }


    public void runInBackground() throws Exception {
        browserProcess = Runtime.getRuntime().exec(command,environment,new File(dir));
        running=true;
        if (inputText != null) {
            Thread.sleep(1000);
            OutputStreamWriter osw = new OutputStreamWriter(browserProcess.getOutputStream());
            osw.write(inputText);
            osw.flush();
            osw.close();
        }

        InputStreamReader outReader = new InputStreamReader(browserProcess.getInputStream());
        outThreadReader = new ThreadReader(outReader);
        Thread outTR = new Thread(outThreadReader);
        outTR.setName("Out-" + command[command.length - 1]);
        outTR.start();
        InputStreamReader errReader = new InputStreamReader(browserProcess.getErrorStream());
        errThreadReader = new ThreadReader(errReader);
        Thread errTR = new Thread(errThreadReader);
        errTR.setName("Err-" + command[command.length - 1]);
        errTR.start();
        startTime = System.currentTimeMillis();
        exitValue = -1;
    }


    public void run() throws Exception {
        runInBackground();
        waitFor();
    }


    public void waitFor() throws Exception {
    	int outputCounter=0;

        while (!stop && System.currentTimeMillis() - startTime < timeout * 1000L) {
            try {
                exitValue = browserProcess.exitValue();
            } catch (Exception e) {
            }

            if (exitValue > -1)
                break;

            if (output) {
            	String out = outThreadReader.getOutput();
            	System.out.print(out.substring(outputCounter));
            	outputCounter = out.length();
            }

            Thread.sleep(300);
        }

        if (exitValue==-1) {
            kill();
        }

        Thread.sleep(1000);
        outputText = outThreadReader.getOutput();
        errorText = errThreadReader.getOutput();

    }


    public void runBrowserServerTest(String test, String browserType, String browserServer, int browserServerPort) {

        String id="";
        try {
                if (test.indexOf("localhost")>-1) {
                    try {
                        String ipaddress = InetAddress.getLocalHost().getHostAddress();
                        test = test.substring(0,test.indexOf("localhost")) + ipaddress + test.substring(test.indexOf("localhost") + 9);

                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }

                System.out.println("starting test "+test);
                Socket s = new Socket(browserServer,browserServerPort);

                BufferedWriter bw = new BufferedWriter(new OutputStreamWriter(s.getOutputStream()));
                bw.write("cmd=start browser=" + browserType + " url=" + test + " timeout=300 pingTimeout=300 ;");
                bw.newLine();
                bw.flush();
                BufferedReader br=new BufferedReader(new InputStreamReader(s.getInputStream()));
                String line;

                while ((line = br.readLine()) != null) {

                    if (line.indexOf("id=")>-1) {
                        line = line.substring(line.indexOf("id") + 3);
                        line = line.substring(0, line.indexOf(" "));
                        id=line;
                        break;
                    }
                }

                s.close();
/*
                Thread.sleep(2000);

                while (true) {
                    s=new Socket(browserServer,browserServerPort);
                    bw=new BufferedWriter(new OutputStreamWriter(s.getOutputStream()));
                    bw.write("cmd=status id="+id+";");
                    bw.newLine();
                    bw.flush();

                    br=new BufferedReader(new InputStreamReader(s.getInputStream()));
                    done=false;
                    while ((line=br.readLine())!=null) {
                        if (line.indexOf(": true :")>-1) {
                            System.out.println("test is still running...");
                            break;
                        } else if (line.indexOf(": false :")>-1) {
                            System.out.println("test finished...");
                            done=true;
                            break;
                        }
                    }
                    s.close();
                    if (done) break;
                    Thread.sleep(5000);
                }

*/
            } catch (Exception e) {
                e.printStackTrace();
            }

        browserServerID = Integer.parseInt(id);
    }


    public class ThreadReader implements Runnable {
        Reader reader;
        String output = "";
        boolean running = true;

        public ThreadReader(Reader reader) {
            this.reader = reader;
        }

        public String getOutput() {
            return output;
        }

        public void run() {
            int len;
            char ch[] = new char[8192];

            while (true) {
                try {
                    len = reader.read(ch, 0, 8192);
                    if (len == -1)
                        break;

                    String newOut=new String(ch, 0, len);

                    if (printOutput)
                        System.out.print(newOut);

                    output = output + newOut;

                    if (!running)
                        break;

                    if (len==0)
                        Thread.sleep(100);

                } catch (Exception e) {
                	String errorString = "===============================\n" + Thread.currentThread().toString() +
                						 "\n======Error Marker Start=======" + 
                						 "\n" + output +
                						 "\n=======Error Marker End========";
                	System.out.println(errorString);
                    e.printStackTrace();
                    break;
                }
            }
        }
    }
}