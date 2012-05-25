/*

   Copyright 2003  The Apache Software Foundation 

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

import org.apache.flex.forks.batik.test.TestReport;

/**
 * One line Class Desc
 *
 * Complete Class Desc
 *
 * @author <a href="mailto:deweese@apache.org">l449433</a>
 * @version $Id: MemoryLeakTestValidator.java,v 1.5 2005/03/27 08:58:37 cam Exp $
 */
public class MemoryLeakTestValidator extends MemoryLeakTest {
    public MemoryLeakTestValidator() {
    }

    Link start;
    public TestReport doSomething() throws Exception {
        for (int i=0; i<20; i++) 
            registerObjectDesc(new Object(), "Obj#"+i);
        for (int i=0; i<10; i++) {
            Pair p1 = new Pair();
            Pair p2 = new Pair();
            p1.mate(p2);
            registerObjectDesc(p2, "Pair#"+i);
        }
        Link p = null;
        for (int i=0; i<10; i++) {
            p = new Link(p);
            registerObjectDesc(p, "Link#"+i);
        }
        // Uncomment this to make the test fail with all the links.
        // start = p;
        return null;
    }
    
    public static class Pair {
        Pair myMate;
        public Pair() { }
        public void mate(Pair p) {
            this.myMate = p;
            p.myMate    = this;
        }
    }

    public static class Link {
        public Link prev;
        public Link(Link prev) {
            this.prev = prev;
        }
    }

}
