/*

   Copyright 2002  The Apache Software Foundation 

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

import org.apache.flex.forks.batik.test.*;

/**
 * Validates the operation of the security enforcer class.
 *
 * @author <a mailto="vincent.hardy@sun.com">Vincent Hardy</a>
 * @version $Id: ApplicationSecurityEnforcerTest.java,v 1.5 2004/08/18 07:17:15 vhardy Exp $
 */
public class ApplicationSecurityEnforcerTest extends DefaultTestSuite {
    final static Class APP_MAIN_CLASS = org.apache.flex.forks.batik.apps.svgbrowser.Main.class;
    final static String APP_SECURITY_POLICY = "org/apache/batik/apps/svgbrowser/resources/svgbrowser.policy";

    /**
     * In the constructor, append atomic tests
     */
    public ApplicationSecurityEnforcerTest(){
        addTest(new CheckNoSecurityManagerOverride());
        addTest(new CheckSecurityEnforcement());
        addTest(new CheckSecurityRemoval());
        addTest(new CheckNoPolicyFile());
    }

    static ApplicationSecurityEnforcer buildTestTarget(){
        return new ApplicationSecurityEnforcer(APP_MAIN_CLASS,
                                               APP_SECURITY_POLICY);
    }

    static class CheckNoSecurityManagerOverride extends AbstractTest {
        public boolean runImplBasic(){
            ApplicationSecurityEnforcer aseA
                = buildTestTarget();

            aseA.enforceSecurity(true);

            ApplicationSecurityEnforcer aseB
                = buildTestTarget();

            boolean passed = false;
            try {
                // This should throw a SecurityException
                aseB.enforceSecurity(true);
            } catch (SecurityException se){
                System.out.println(">>>>>>>>>>>>> got expected SecurityException A");
                try {
                    System.out.println(">>>>>>>>>>>>> got expected SecurityException B");
                    aseB.enforceSecurity(false);
                } catch (SecurityException se2){
                    passed = true;
                }
            } 

            aseA.enforceSecurity(false);
            
            return passed;
        }
    }

    static class CheckSecurityEnforcement extends AbstractTest {
        public boolean runImplBasic() {
            ApplicationSecurityEnforcer ase = buildTestTarget();

            try {
                ase.enforceSecurity(true);
                SecurityManager sm = System.getSecurityManager();
                if (sm == ase.lastSecurityManagerInstalled){
                    return true;
                }
            } finally {
                System.setSecurityManager(null);
            }

            return false;
        }
    }

    static class CheckSecurityRemoval extends AbstractTest {
        public boolean runImplBasic() {
            ApplicationSecurityEnforcer ase = buildTestTarget();

            try {
                ase.enforceSecurity(true);
                ase.enforceSecurity(false);
                SecurityManager sm = System.getSecurityManager();
                if (sm == null && ase.lastSecurityManagerInstalled == null) {
                    return true;
                }
            } finally {
                System.setSecurityManager(null);
            }

            return false;
        }
    }

    static class CheckNoPolicyFile extends AbstractTest {
        public boolean runImplBasic() {
            ApplicationSecurityEnforcer ase = 
                new ApplicationSecurityEnforcer(APP_MAIN_CLASS,
                                                "dont.exist.policy");

            try {
                ase.enforceSecurity(true);
            } catch (NullPointerException se) {
                return true;
            } finally {
                ase.enforceSecurity(false);
            }
            return false;
        }
    }

}
