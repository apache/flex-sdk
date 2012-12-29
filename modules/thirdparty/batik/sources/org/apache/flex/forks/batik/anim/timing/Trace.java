/*

   Licensed to the Apache Software Foundation (ASF) under one or more
   contributor license agreements.  See the NOTICE file distributed with
   this work for additional information regarding copyright ownership.
   The ASF licenses this file to You under the Apache License, Version 2.0
   (the "License"); you may not use this file except in compliance with
   the License.  You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.

 */
package org.apache.flex.forks.batik.anim.timing;

/**
 * Animation debugging support.  To be removed.
 *
 * @author <a href="mailto:cam%40mcc%2eid%2eau">Cameron McCormack</a>
 * @version $Id: Trace.java 475477 2006-11-15 22:44:28Z cam $
 */
public class Trace {

    private static int level;

    private static boolean enabled = false;

    public static void enter(Object o, String fn, Object[] args) {
        if (enabled) {
            System.err.print("LOG\t");
            for (int i = 0; i < level; i++) {
                System.err.print("  ");
            }
            if (fn == null) {
                System.err.print("new " + o.getClass().getName() + "(");
            } else {
                System.err.print(o + "." + fn + "(");
            }
            if (args != null) {
                System.err.print(args[0]);
                for (int i = 1; i < args.length; i++) {
                    System.err.print(", " + args[i]);
                }
            }
            System.err.println(")");
        }
            level++;
    }
    
    public static void exit() {
        level--;
    }

    public static void print(String s) {
        if (enabled) {
            System.err.print("LOG\t");
            for (int i = 0; i < level; i++) {
                System.err.print("  ");
            }
            System.err.println(s);
        }
    }
}
