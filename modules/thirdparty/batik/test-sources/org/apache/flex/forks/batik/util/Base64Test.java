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
package org.apache.flex.forks.batik.util;

import org.apache.flex.forks.batik.test.AbstractTest;
import org.apache.flex.forks.batik.test.DefaultTestReport;
import org.apache.flex.forks.batik.test.TestReport;

import java.io.PipedOutputStream;
import java.io.PipedInputStream;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.IOException;
import java.io.StringWriter;
import java.io.PrintWriter;

import java.net.URL;

/**
 * This test validates that the Base65 encoder/decoders work properly.
 *
 * @author <a href="mailto:deweese@apache.org">Thomas DeWeese</a>
 * @version $Id: Base64Test.java,v 1.6 2004/08/18 07:17:15 vhardy Exp $
 */
public class Base64Test extends AbstractTest {
    /**
     * Error when bad action string given.
     * {0} = Bad action string
     */
    public static final String ERROR_BAD_ACTION_STRING
        = "Base64Test.error.bad.action.string";

    /**
     * Error when unable to read/open in URL
     * {0} = URL
     * {1} = exception stack trace.
     */
    public static final String ERROR_CANNOT_READ_IN_URL
        = "Base64Test.error.cannot.read.in.url";

    /**
     * Error when unable to read/open ref URL
     * {0} = URL
     * {1} = exception stack trace.
     */
    public static final String ERROR_CANNOT_READ_REF_URL
        = "Base64Test.error.cannot.read.ref.url";

    /**
     * Result didn't match reference result.
     * {0} = first byte of mismatch
     */
    public static final String ERROR_WRONG_RESULT
        = "Base64Test.error.wrong.result";

    public static final String ENTRY_KEY_ERROR_DESCRIPTION
        = "Base64Test.entry.key.error.description";

    protected String action = null;
    protected URL    in     = null;
    protected URL    ref    = null;

    /**
     * Constructor. ref is ignored if action == ROUND.
     * @param action The action to perform, one of:
     *               ROUND  : base64 encode then base64 decode.
     *               ENCODE : encode in to base 64 and compare result to ref.
     *               DECODE : decode in (must be base 64) and compare to ref.
     * @param in     The source file to apply 'action' to.
     * @param ref    The reference file.
     */
    public Base64Test(String action, URL in, URL ref) {
        this.action = action;
        this.in     = in;
        this.ref    = ref;
    }

    /**
     * Constructor, for round trip testing (only one file required).
     * @param in     The source file to round trip.
     */
    public Base64Test(URL in) {
        this.action = "ROUND";
        this.in     = in;
    }

    /**
     * Returns this Test's name
     */
    public String getName() {
        return action + " -- " + in + " -- " + super.getName();
    }

    /**
     * This method will only throw exceptions if some aspect
     * of the test's internal operation fails.
     */
    public TestReport runImpl() throws Exception {
        DefaultTestReport report
            = new DefaultTestReport(this);

        InputStream inIS;

        try {
            inIS = in.openStream();
        } catch(Exception e) {
            StringWriter trace = new StringWriter();
            e.printStackTrace(new PrintWriter(trace));
            report.setErrorCode(ERROR_CANNOT_READ_IN_URL);
            report.setDescription(new TestReport.Entry[] {
                new TestReport.Entry
                    (TestMessages.formatMessage
                     (ENTRY_KEY_ERROR_DESCRIPTION, null),
                     TestMessages.formatMessage
                     (ERROR_CANNOT_READ_IN_URL,
                      new String[]{in.toString(), trace.toString()}))
                    });
            report.setPassed(false);
            return report;
        }

        if (action.equals("ROUND"))
            this.ref = in;
        else if (!action.equals("ENCODE") && 
                 !action.equals("DECODE")) {
            report.setErrorCode(ERROR_BAD_ACTION_STRING);
            report.setDescription(new TestReport.Entry[] {
                new TestReport.Entry
                    (TestMessages.formatMessage
                     (ENTRY_KEY_ERROR_DESCRIPTION, null),
                     TestMessages.formatMessage(ERROR_BAD_ACTION_STRING, 
                                            new String[]{action}))
                    });
            report.setPassed(false);
            return report;
        }

        InputStream refIS;
        try {
            refIS = ref.openStream();
        } catch(Exception e) {
            StringWriter trace = new StringWriter();
            e.printStackTrace(new PrintWriter(trace));
            report.setErrorCode(ERROR_CANNOT_READ_REF_URL);
            report.setDescription(new TestReport.Entry[] {
                new TestReport.Entry
                    (TestMessages.formatMessage
                     (ENTRY_KEY_ERROR_DESCRIPTION, null),
                     TestMessages.formatMessage
                     (ERROR_CANNOT_READ_REF_URL,
                      new String[]{ref.toString(), trace.toString()}))
                    });
            report.setPassed(false);
            return report;
        }

        if (action.equals("ENCODE") ||
            action.equals("ROUND")) {
          // We need to encode the incomming data
          PipedOutputStream pos = new PipedOutputStream();
          OutputStream os = new Base64EncoderStream(pos);

          // Copy the input to the Base64 Encoder (in a seperate thread).
          Thread t = new StreamCopier(inIS, os);
          
          // Read that from the piped output stream.
          inIS = new PipedInputStream(pos);
          t.start();
        }

        if (action.equals("DECODE")||
            action.equals("ROUND")) {
            inIS = new Base64DecodeStream(inIS);
        } 


        int mismatch = compareStreams(inIS, refIS, action.equals("ENCODE"));
        
        if (mismatch == -1) {
          report.setPassed(true);
          return report;
        }

        report.setErrorCode(ERROR_WRONG_RESULT);
        report.setDescription(new TestReport.Entry[] {
          new TestReport.Entry
            (TestMessages.formatMessage(ENTRY_KEY_ERROR_DESCRIPTION, null),
             TestMessages.formatMessage(ERROR_WRONG_RESULT, 
                                    new String[]{""+mismatch}))
            });
        report.setPassed(false);
        return report;
    }

    /**
     * Returns true if the contents of <tt>is1</tt> match the
     * contents of <tt>is2</tt>
     */
    public static int compareStreams(InputStream is1, InputStream is2, 
                              boolean skipws) {
        byte [] data1 = new byte[100];
        byte [] data2 = new byte[100];
        int off1=0;
        int off2=0;
        int idx=0;

        try {
            while(true) {
                int len1 = is1.read(data1, off1, data1.length-off1);
                int len2 = is2.read(data2, off2, data2.length-off2);

                if (off1 != 0) {
                    if (len1 == -1)
                        len1 = off1;
                    else
                        len1 += off1;
                }

                if (off2 != 0) {
                    if (len2 == -1)
                        len2 = off2;
                    else
                        len2 += off2;
                }

                if (len1 == -1) {
                    if (len2 == -1)
                        break; // Both done...

                    // Only is1 is done...
                    if (!skipws)
                        return idx;

                    // check if the rest of is2 is whitespace...
                    for (int i2=0; i2<len2; i2++)
                        if ((data2[i2] != '\n') &&
                            (data2[i2] != '\r') && 
                            (data2[i2] != ' '))
                            return idx+i2;
                    off1 = off2 = 0;
                    continue;
                }

                if (len2 == -1) {
                    // Only is2 is done...
                    if (!skipws)
                        return idx;

                    // Check if rest of is1 is whitespace...
                    for (int i1=0; i1<len1; i1++)
                        if ((data1[i1] != '\n') &&
                            (data1[i1] != '\r') && 
                            (data1[i1] != ' '))
                            return idx+i1;
                    off1 = off2 = 0;
                    continue;
                }

                int i1=0;
                int i2=0;
                while((i1<len1) && (i2<len2)) {
                    if (skipws) {
                        if ((data1[i1] == '\n') || 
                            (data1[i1] == '\r') || 
                            (data1[i1] == ' ')) {
                            i1++;
                            continue;
                        }
                        if ((data2[i2] == '\n') || 
                            (data2[i2] == '\r') || 
                            (data2[i2] == ' ')) {
                            i2++;
                            continue;
                        }
                    }
                    if (data1[i1] != data2[i2])
                        return idx+i2;

                    i1++;
                    i2++;
                }

                if (i1 != len1)
                    System.arraycopy(data1, i1, data1, 0, len1-i1);
                if (i2 != len2)
                    System.arraycopy(data2, i2, data2, 0, len2-i2);
                off1 = len1-i1;
                off2 = len2-i2;
                idx+=i2;
            }
        } catch(IOException ioe) {
            ioe.printStackTrace();
            return idx;
        }

        return -1;
    }


    static class StreamCopier extends Thread {
        InputStream src;
        OutputStream dst;

        public StreamCopier(InputStream src,
                            OutputStream dst) {
            this.src = src;
            this.dst = dst;
        }

        public void run() {
            try {
                byte [] data = new byte[1000];
                while(true) {
                    int len = src.read(data, 0, data.length);
                    if (len == -1) break;

                    dst.write(data, 0, len);
                }
            } catch (IOException ioe) {
                // Nothing
            }
            try {
                dst.close();
            } catch (IOException ioe) {
                // Nothing
            }
        }
    }
}
