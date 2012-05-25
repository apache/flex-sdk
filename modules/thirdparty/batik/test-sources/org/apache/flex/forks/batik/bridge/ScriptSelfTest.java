/*
 * Copyright 1999-2004 The Apache Software Foundation.
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *      http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.apache.flex.forks.batik.bridge;

import org.apache.flex.forks.batik.test.*;
import org.apache.flex.forks.batik.util.ApplicationSecurityEnforcer;
import org.apache.flex.forks.batik.util.ParsedURL;
import org.apache.flex.forks.batik.test.svg.SelfContainedSVGOnLoadTest;

import java.security.AccessController;
import java.security.AccessControlContext;
import java.security.CodeSource;
import java.security.PrivilegedExceptionAction;
import java.security.PrivilegedActionException;
import java.security.ProtectionDomain;
import java.security.Permission;
import java.security.PermissionCollection;
import java.security.Permissions;
import java.security.Policy;

import java.io.FilePermission;
import java.io.File;

import java.net.URL;

import java.util.Enumeration;
/**
 * Helper class to simplify writing the unitTesting.xml file for 
 * the bridge.
 *
 * @author <a href="mailto:vhardy@apache.org">Vincent Hardy</a>
 * @version $Id: ScriptSelfTest.java,v 1.8 2005/04/01 02:28:16 deweese Exp $
 */

public class ScriptSelfTest extends SelfContainedSVGOnLoadTest {
    String scripts = "text/ecmascript, application/java-archive";
    boolean secure = true;
    String scriptOrigin = "any";
    String fileName;

    TestUserAgent userAgent = new TestUserAgent();

    public void setId(String id){
        super.setId(id);

        if (id != null) {
            int i = id.indexOf("(");
            if (i != -1) {
                id = id.substring(0, i);
            }
            fileName = "test-resources/org/apache/batik/bridge/" + id + ".svg";
            svgURL = resolveURL(fileName);
        }
    }

    public void setSecure(boolean secure){
        this.secure = secure;
    }

    public boolean getSecure(){
        return secure;
    }

    public String getScriptOrigin() {
        return scriptOrigin;
    }

    public void setScriptOrigin(String scriptOrigin) {
        this.scriptOrigin = scriptOrigin;
    }

    public void setScripts(String scripts){
        this.scripts = scripts;
    }

    public String getScripts(){
        return scripts;
    }

    public TestReport runImpl() throws Exception {
        ApplicationSecurityEnforcer ase
            = new ApplicationSecurityEnforcer(this.getClass(),
                                              "org/apache/batik/apps/svgbrowser/resources/svgbrowser.policy");

        if (secure) {
            ase.enforceSecurity(true);
        }

        try {
            return super.runImpl();
        } catch (ExceptionInInitializerError e) {
            e.printStackTrace();
            throw e;
        } catch (NoClassDefFoundError e) {
            // e.printStackTrace();
            throw new Exception(e.getMessage());
        } finally {
            ase.enforceSecurity(false);
        }
    }

    protected UserAgent buildUserAgent(){
        return userAgent;
    }
    
    class TestUserAgent extends UserAgentAdapter {
        public ScriptSecurity getScriptSecurity(String scriptType,
                                                ParsedURL scriptPURL,
                                                ParsedURL docPURL){
            ScriptSecurity scriptSecurity = null;
            if (scripts.indexOf(scriptType) == -1){
                scriptSecurity = new NoLoadScriptSecurity(scriptType);
            } else {
                if ("any".equals(scriptOrigin)) {
                     scriptSecurity = new RelaxedScriptSecurity
                        (scriptType, scriptPURL, docPURL);
                } else if ("document".equals(scriptOrigin)) {
                    scriptSecurity = new DefaultScriptSecurity
                        (scriptType, scriptPURL, docPURL);
                } else if ("embeded".equals(scriptOrigin)) {
                    scriptSecurity = new EmbededScriptSecurity
                        (scriptType, scriptPURL, docPURL);
                } else if ("none".equals(scriptOrigin)) {
                    scriptSecurity = new NoLoadScriptSecurity(scriptType);
                } else {
                    throw new Error("Wrong scriptOrigin : " + scriptOrigin);
                }
            }

            return scriptSecurity;
        }
    }

}
