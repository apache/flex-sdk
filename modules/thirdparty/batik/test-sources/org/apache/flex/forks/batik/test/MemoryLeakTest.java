/*

   Copyright 2003-2004  The Apache Software Foundation 

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

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.HashMap;
import java.util.Iterator;

import org.apache.flex.forks.batik.test.AbstractTest;
import org.apache.flex.forks.batik.test.DefaultTestReport;
import org.apache.flex.forks.batik.test.TestReport;

import org.apache.flex.forks.batik.util.CleanerThread;

/**
 * One line Class Desc
 *
 * Complete Class Desc
 *
 * @author <a href="mailto:deweese@apache.org">l449433</a>
 * @version $Id: MemoryLeakTest.java,v 1.9 2005/03/27 08:58:37 cam Exp $
 */
public abstract class MemoryLeakTest  extends AbstractTest {

    // I know that 120 seems _really_ high but it turns out
    // That the "GraphicsNodeTree" was not being cleared when I
    // tested with as high as 60.  So I would leave it at 120
    // (why so large I don't know) - it will bail if the all
    // the objects of interest are collected sooner so the runtime
    // is really only a concern for failures.
    final static int NUM_GC=60;

    final static String ERROR_OBJS_NOT_CLEARED = 
        "MemoryLeakTest.message.error.objs.not.cleared";

    final static String ERROR_DESCRIPTION = 
        "TestReport.entry.key.error.description";
        
    public static String fmt(String key, Object []args) {
        return Messages.formatMessage(key, args);
    }

    public MemoryLeakTest() {
    }
    
    Map objs = new HashMap();
    List entries = new ArrayList();

    public void registerObject(Object o) {
        synchronized (objs) {
            String desc = o.toString();
            objs.put(desc, new WeakRef(o, desc));
        }
    }
    public void registerObjectDesc(Object o, String desc) {
        synchronized (objs) {
            objs.put(desc, new WeakRef(o, desc));
        }
    }
    
    public boolean checkObject(String desc) {
        String [] strs = new String[1];
        strs[0] = desc;
        return checkObjects(strs);
    }

    public boolean checkObjects(String [] descs) {
        for (int i=0; i<NUM_GC; i++) {
            System.gc();
            boolean passed = true;
            for (int j=0; j< descs.length; j++) {
                String desc = descs[j];
                WeakRef wr = (WeakRef)objs.get(desc);
                if ((wr != null) && (wr.get() != null)) {
                    passed = false;
                    break;
                }
            }
            if (passed) return true;
            Thread.yield();
        }

        StringBuffer sb = new StringBuffer();
        synchronized (objs) {
            boolean passed = true;
            for (int j=0; j< descs.length; j++) {
                String desc = descs[j];
                WeakRef wr = (WeakRef)objs.get(desc);
                if ((wr == null) || (wr.get() == null)) continue;
                if (!passed)
                    sb.append(","); // Already put one obj out
                passed = false;
                sb.append("'");
                sb.append(wr.getDesc());
                sb.append("'");
            }
        }
        
        String objStr = sb.toString();
        TestReport.Entry entry = new TestReport.Entry
            (fmt(ERROR_DESCRIPTION, null),
             fmt(ERROR_OBJS_NOT_CLEARED, new Object[]{objStr}));
        entries.add(entry);

        if (objStr.length() > 40) 
            objStr = objStr.substring(0,40) + "..." ;
        System.err.println(">>>>> Objects not cleared: " + objStr);
        // System.err.println("Waiting for heap dump...");
        // try { Thread.sleep(60000); } catch (InterruptedException ie) { }
        return false;
    }

    public boolean checkObjectsList(List descs) {
        String [] strs = new String[descs.size()];
        descs.toArray(strs);
        return checkObjects(strs);
    }

    public boolean checkAllObjects() {
        for (int i=0; i<NUM_GC; i++) {
            System.gc();
            synchronized (objs) {
                boolean passed = true;
                Iterator iter = objs.values().iterator();
                while (iter.hasNext()) {
                    WeakRef wr = (WeakRef)iter.next();
                    Object o = wr.get();
                    if (o != null) {
                        passed = false;
                        break;
                    }
                }
                if (passed) return true;
            }
        }
        
        StringBuffer sb = new StringBuffer();
        synchronized (objs) {
            boolean passed = true;
            Iterator iter = objs.values().iterator();
            while (iter.hasNext()) {
                WeakRef wr = (WeakRef)iter.next();
                Object o = wr.get();
                if (o == null) continue;
                if (!passed)
                    sb.append(",");
                passed = false;
                sb.append("'");
                sb.append(wr.getDesc());
                sb.append("'");
            }
            if (passed) return true;
        }
        
        String objStr = sb.toString();

        TestReport.Entry entry = new TestReport.Entry
            (fmt(ERROR_DESCRIPTION, null),
             fmt(ERROR_OBJS_NOT_CLEARED, new Object[]{objStr}));
        entries.add(entry);

        if (objStr.length() > 40) 
            objStr = objStr.substring(0,40) + "..." ;
        System.err.println(">>>>> Objects not cleared: " + objStr);
        // System.err.println("Waiting for heap dump...");
        // try { Thread.sleep(60000); } catch (InterruptedException ie) { }
        return false;
    }

    public TestReport runImpl() throws Exception {
        TestReport ret = doSomething();
        if ((ret != null) && !ret.hasPassed())
            return ret;

        checkAllObjects();

        DefaultTestReport report = new DefaultTestReport(this);
        if (entries.size() == 0) {
            report.setPassed(true);
            return report;
        }
        report.setErrorCode(ERROR_OBJS_NOT_CLEARED);
        report.setDescription
            ((TestReport.Entry[])entries.toArray
             (new TestReport.Entry[entries.size()]));
        report.setPassed(false);
        return report;
    }

    public abstract TestReport doSomething() throws Exception;

    public class WeakRef extends CleanerThread.WeakReferenceCleared {
        String desc;
        public WeakRef(Object o) {
            super(o);
            this.desc = o.toString();
        }
        public WeakRef(Object o, String desc) {
            super(o);
            this.desc = desc;
        }

        public String getDesc() { return desc; }

        public void cleared() {
            synchronized (objs) {
                objs.remove(desc);
            }
        }
        
    }
    
}
