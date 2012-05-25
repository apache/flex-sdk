/*

   Copyright 2001,2003  The Apache Software Foundation 

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.

 */
package org.apache.flex.forks.batik.test;

/**
 * Simple GUI tool to run a <tt>Test</tt>. This tool takes
 * a class name parameter as an input and provides a GUI to 
 * run an instance of the test. The generated <tt>TestReport</tt>
 * is printed to the standard output with the 
 * <tt>SimpleTestReportProcessor</tt>
 *
 * @author <a href="mailto:vhardy@apache.org">Vincent Hardy</a>
 * @version $Id: SimpleTestRunner.java,v 1.4 2004/08/18 07:16:57 vhardy Exp $
 */
public class SimpleTestRunner {
    /**
     * Error Messages. 
     */
    public static final String ERROR_CLASS_CAST =
        "Messages.SimpleTestRuner.error.class.cast";

    public static final String ERROR_CLASS_NOT_FOUND =
        "Messages.SimpleTestRuner.error.class.not.found";

    public static final String ERROR_INSTANTIATION =
        "Messages.SimpleTestRunner.error.instantiation";

    public static final String ERROR_ILLEGAL_ACCESS = 
        "Messages.SimpleTestRunner.error.illegal.access";

    /**
     * Usage for this tool
     */
    public static final String USAGE 
        = "Messages.SimpleTestRunner.usage";

    public static void main(String args[]) throws Exception{
        if(args.length < 1){
            System.err.println(Messages.formatMessage(USAGE, null));
            System.exit(0);
        }

        String className = args[0];

        Class cl = null;

        try{
            cl = Class.forName(className);
        }catch(ClassNotFoundException e){
            System.err.println(Messages.formatMessage(ERROR_CLASS_NOT_FOUND,
                                                      new Object[]{className,
                                                      e.getClass().getName(),
                                                      e.getMessage()}));
            System.exit(0);
        }

        Test t = null;

        try{
            t = (Test)cl.newInstance();
        }catch(ClassCastException e){
            System.err.println(Messages.formatMessage(ERROR_CLASS_CAST,
                                                      new Object[]{ className,
                                                                    e.getClass().getName(),
                                                                    e.getMessage()
                                                      }));
            System.exit(0);
        }catch(InstantiationException e){
            System.err.println(Messages.formatMessage(ERROR_INSTANTIATION,
                                                      new Object[]{ className,
                                                                    e.getClass().getName(),
                                                                    e.getMessage() } ));
            System.exit(0);
        }catch(IllegalAccessException e){
            System.err.println(Messages.formatMessage(ERROR_ILLEGAL_ACCESS,
                                                      new Object[] { className,
                                                                     e.getClass().getName(),
                                                                     e.getMessage() }));

            System.exit(0);
        }
                               

        //
        // Run test and process report with simple
        // text output.
        //
        TestReport tr = t.run();

        try{
            TestReportProcessor p 
                = new org.apache.flex.forks.batik.test.xml.XMLTestReportProcessor();
            
            p.processReport(tr);
        }catch(TestException e){
            System.out.println(e.getClass().getName());
            System.out.println(e.getMessage());
            Exception source = e.getSourceError();
            if(source != null) {
                System.out.println(source);
                System.out.println(source.getMessage());
                source.printStackTrace();
            }
        }
        System.exit(1);

    }
}
