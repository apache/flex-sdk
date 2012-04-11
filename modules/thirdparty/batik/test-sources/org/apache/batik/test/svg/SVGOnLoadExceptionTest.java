/*

   Copyright 2002-2004  The Apache Software Foundation 

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
 
/**
 *  Modified by Adobe Flex.
 */
 
package org.apache.batik.test.svg;

import java.io.File;
import java.net.MalformedURLException;
import java.net.URL;

import org.w3c.dom.Document;
import org.w3c.dom.Element;

import org.apache.batik.bridge.BaseScriptingEnvironment;
import org.apache.batik.bridge.BridgeContext;
import org.apache.batik.bridge.BridgeException;
import org.apache.batik.bridge.DefaultExternalResourceSecurity;
import org.apache.batik.bridge.DefaultScriptSecurity;
import org.apache.batik.bridge.EmbededExternalResourceSecurity;
import org.apache.batik.bridge.EmbededScriptSecurity;
import org.apache.batik.bridge.ExternalResourceSecurity;
import org.apache.batik.bridge.GVTBuilder;
import org.apache.batik.bridge.NoLoadExternalResourceSecurity;
import org.apache.batik.bridge.NoLoadScriptSecurity;
import org.apache.batik.bridge.RelaxedExternalResourceSecurity;
import org.apache.batik.bridge.RelaxedScriptSecurity;
import org.apache.batik.bridge.ScriptSecurity;
import org.apache.batik.bridge.UserAgent;
import org.apache.batik.bridge.UserAgentAdapter;
import org.apache.batik.dom.svg.SAXSVGDocumentFactory;
import org.apache.batik.test.AbstractTest;
import org.apache.batik.test.TestReport;
import org.apache.batik.util.ParsedURL;
import org.apache.batik.util.XMLResourceDescriptor;
import org.apache.batik.util.ApplicationSecurityEnforcer;

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
import java.security.cert.Certificate;

import java.io.FilePermission;

import java.util.Enumeration;

/**
 * This test takes an SVG file as an input. It processes the input SVG
 * (meaning it turns it into a GVT tree) and then dispatches the 'onload'
 * event.
 * 
 * In that process, the test checks for the occurence of a specific
 * exception type and, for BridgeExceptions, for a given error code.
 *
 * If an exception of the given type (and, optionally, code) happens,
 * then the test passes. If an exception of an unexpected type 
 * (or code, for BridgeExceptions) happens, or if no exception happens,
 * the test fails.
 *
 * The following properties control the test's operation:
 * - Scripts: list of allowed script types (e.g., "application/java-archive")
 * - ScriptOrigin: "ANY", "DOCUMENT", "EMBEDED", "NONE"
 * - ResourceOrigin: "ANY", "DOCUMENT", "EMBEDED", "NONE"
 * - ExpectedExceptionClass (e.g., "java.lang.SecurityException")
 * - ExpectedErrorCode (e.g., "err.uri.unsecure")
 * - Validate (e.g., "true")
 *
 * @author <a href="mailto:vhardy@apache.org">Vincent Hardy</a>
 * @version $Id: SVGOnLoadExceptionTest.java,v 1.8 2005/03/29 10:48:04 deweese Exp $
 */
public class SVGOnLoadExceptionTest extends AbstractTest {
    /**
     * Value for the script having successfully run.
     */
    public static final String RAN = "ran";

    /**
     * Error when the expected exception did not occur
     */
    public static final String ERROR_EXCEPTION_DID_NOT_OCCUR
        = "SVGOnLoadExceptionTest.error.exception.did.not.occur";

    /**
     * Error when an exception occured, but not of the expected
     * class
     */
    public static final String ERROR_UNEXPECTED_EXCEPTION
        = "SVGOnLoadExceptionTest.error.unexpected.exception";

    /**
     * Error when a BridgeException occured, as expected, but
     * with an unexpected error code
     */
    public static final String ERROR_UNEXPECTED_ERROR_CODE
        = "SVGOnLoadExceptionTest.error.unexpected.error.code";

    /**
     * Error when the script does not run as expected.
     */
    public static final String ERROR_SCRIPT_DID_NOT_RUN
        = "SVGOnLoadExceptionTest.error.script.did.not.run";

    /**
     * Entry describing the unexpected exception
     */
    public static final String ENTRY_KEY_UNEXPECTED_EXCEPTION
        = "SVGOnLoadExceptionTest.entry.key.unexpected.exception";

    /**
     * Entry describing the unexpected error code
     */
    public static final String ENTRY_KEY_UNEXPECTED_ERROR_CODE
        = "SVGOnLoadExceptionTest.entry.key.unexpected.error.code";

    /**
     * Entry describign the expected error code
     */
    public static final String ENTRY_KEY_EXPECTED_ERROR_CODE
        = "SVGOnLoadExceptionTest.entry.key.expected.error.code";

    /**
     * Entry describing the expected exception
     */
    public static final String ENTRY_KEY_EXPECTED_EXCEPTION
        = "SVGOnLoadExceptionTest.entry.key.expected.exception";

    /**
     * Entry describing the unexpected exception
     */
    public static final String ENTRY_KEY_UNEXPECTED_RESULT
        = "SVGOnLoadExceptionTest.entry.key.unexpected.result";

    /**
     * Value used to disable error code check on BridgeExceptions
     */
    public static final String ERROR_CODE_NO_CHECK
        = "noCheck";

    /**
     * Test Namespace
     */
    public static final String testNS = "http://xml.apache.org/batik/test";

    /**
     * The URL for the input SVG document to be tested
     */
    protected String svgURL;

    /**
     * The allowed script types
     */
    protected String scripts = "text/ecmascript, application/java-archive";
    
    /**
     * Name of the expected exception class
     */
    protected String expectedExceptionClass = "org.apache.batik.bridge.Exception";

    /**
     * Expected error code (for BridgeExceptions)
     */
    protected String expectedErrorCode = "none";

    /**
     * The allowed script origin
     */
    protected String scriptOrigin = "ANY";

    /**
     * The allowed external resource origin
     */
    protected String resourceOrigin = "ANY";

    /**
     * True if the scripts are run securely (i.e., with a security manager)
     */
    protected boolean secure = false;

    /**
     * Controls whether or not the input SVG document should be validated
     */
    protected Boolean validate = new Boolean(false);

    /**
     * The name of the test file
     */
    protected String fileName;

    /**
     * Controls whether on not the document should be processed from
     * a 'restricted' context, one with no createClassLoader permission.
     */
    protected boolean restricted = false;

    public boolean getRestricted() {
        return restricted;
    }

    public void setRestricted(boolean restricted) {
        this.restricted = restricted;
    }

    public void setScripts(String scripts){
        this.scripts = scripts;
    }

    public String getScripts(){
        return scripts;
    }

    public void setScriptOrigin(String scriptOrigin){
        this.scriptOrigin = scriptOrigin;
    }

    public String getScriptOrigin(){
        return this.scriptOrigin;
    }

    public void setResourceOrigin(String resourceOrigin){
        this.resourceOrigin = resourceOrigin;
    }

    public String getResourceOrigin(){
        return this.resourceOrigin;
    }

    public void setSecure(boolean secure){
        this.secure = secure;
    }

    public boolean getSecure(){
        return secure;
    }

    public void setExpectedExceptionClass(String expectedExceptionClass){
        this.expectedExceptionClass = expectedExceptionClass;
    }

    public String getExpectedExceptionClass(){
        return this.expectedExceptionClass;
    }

    public void setExpectedErrorCode(String expectedErrorCode){
        this.expectedErrorCode = expectedErrorCode;
    }

    public String getExpectedErrorCode(){
        return this.expectedErrorCode;
    }

    public Boolean getValidate() {
        return validate;
    }

    public void setValidate(Boolean validate) {
        this.validate = validate;
        if (this.validate == null) {
            this.validate = new Boolean(false);
        }
    }
    
    /**
     * Default constructor
     */
    public SVGOnLoadExceptionTest(){
    }

    public void setId(String id){
        super.setId(id);

        if (id != null) {
            int i = id.indexOf("(");
            if (i != -1) {
                id = id.substring(0, i);
            }
            fileName = "test-resources/org/apache/batik/" + id + ".svg";
            svgURL = resolveURL(fileName);
        }
    }

    /**
     * Resolves the input string as follows.
     * + First, the string is interpreted as a file description.
     *   If the file exists, then the file name is turned into
     *   a URL.
     * + Otherwise, the string is supposed to be a URL. If it
     *   is an invalid URL, an IllegalArgumentException is thrown.
     */
    protected String resolveURL(String url){
        // Is url a file?
        File f = (new File(url)).getAbsoluteFile();
        if(f.getParentFile().exists()){
            try{
                return f.toURL().toString();
            }catch(MalformedURLException e){
                throw new IllegalArgumentException();
            }
        }
        
        // url is not a file. It must be a regular URL...
        try{
            return (new URL(url)).toString();
        }catch(MalformedURLException e){
            throw new IllegalArgumentException(url);
        }
    }


    /**
     * Run this test and produce a report.
     * The test goes through the following steps: <ul>
     * <li>load the input SVG into a Document</li>
     * <li>build the GVT tree corresponding to the 
     *     Document and dispatch the 'onload' event</li>
     * </ul>
     *
     */
    public TestReport runImpl() throws Exception{
        ApplicationSecurityEnforcer ase
            = new ApplicationSecurityEnforcer(this.getClass(),
                                              "org/apache/batik/apps/svgbrowser/resources/svgbrowser.policy");

        if (secure) {
            ase.enforceSecurity(true);
        }

        try {
            if (!restricted) {
                return testImpl();
            } else {
                // Emulate calling from restricted code. We create a 
                // calling context with only the permission to read
                // the file.
                Policy policy = Policy.getPolicy();
                URL classesURL = (new File("classes")).toURL();
                CodeSource cs = new CodeSource(classesURL, (Certificate[])null);
                PermissionCollection permissionsOrig
                    = policy.getPermissions(cs);
                Permissions permissions = new Permissions();
                Enumeration iter = permissionsOrig.elements();
                while (iter.hasMoreElements()) {
                    Permission p = (Permission)iter.nextElement();
                    if (!(p instanceof RuntimePermission)) {
                        if (!(p instanceof java.security.AllPermission)) {
                            permissions.add(p);
                        } 
                    } else {
                        if (!"createClassLoader".equals(p.getName())) {
                            permissions.add(p);
                        } 
                    }
                }

                permissions.add(new FilePermission(fileName, "read"));
                permissions.add(new RuntimePermission("accessDeclaredMembers"));

                ProtectionDomain domain;
                AccessControlContext ctx;
                domain = new ProtectionDomain(null, permissions);
                ctx = new AccessControlContext(new ProtectionDomain[]{domain});

                try {
                    return (TestReport)AccessController.doPrivileged
                        (new PrivilegedExceptionAction() {
                                public Object run() throws Exception {
                                    return testImpl();
                                }
                            }, ctx);
                } catch (PrivilegedActionException pae) {
                    throw pae.getException();
                }
            }
        } finally {
            ase.enforceSecurity(false);
        }
    }

    /**
     * Implementation helper
     */
    protected TestReport testImpl() {
        //
        // First step: 
        //
        // Load the input SVG into a Document object
        //
        String parserClassName = XMLResourceDescriptor.getXMLParserClassName();
        SAXSVGDocumentFactory f = new SAXSVGDocumentFactory(parserClassName);
        f.setValidating(validate.booleanValue());
        Document doc = null;
        
        try {
            doc = f.createDocument(svgURL);
        } catch(Exception e){
            e.printStackTrace();
            return handleException(e);
        } 
        
        //
        // Second step:
        // 
        // Now that the SVG file has been loaded, build
        // a GVT Tree from it
        //
        TestUserAgent userAgent = buildUserAgent();
        GVTBuilder builder = new GVTBuilder();
        BridgeContext ctx = new BridgeContext(userAgent);
        ctx.setDynamic(true);
        Exception e = null;
        try {
            builder.build(ctx, doc);
            BaseScriptingEnvironment scriptEnvironment 
                = new BaseScriptingEnvironment(ctx);
            scriptEnvironment.loadScripts();
            scriptEnvironment.dispatchSVGLoadEvent();
        } catch (Exception ex){
            e = ex;
        } finally {
            if (e == null && userAgent.e != null) {
                e = userAgent.e;
            }
            
            if (e != null) {
                return handleException(e);
            }
        } 
        
        //
        // If we got here, it means that an exception did not
        // happen. Check if this is expected.
        TestReport report = null;
        if (expectedExceptionClass == null) {
            // No error was expected then check that the script ran.
            Element elem = doc.getElementById("testResult");
            String s = elem.getAttributeNS(null, "result");
            if (RAN.equals(s)) {
                report = reportSuccess();
            } else {
                report = reportError(ERROR_SCRIPT_DID_NOT_RUN);
                report.addDescriptionEntry(ENTRY_KEY_UNEXPECTED_RESULT,
                                           s);
            }
        }
        if (report == null) {
            report = reportError(ERROR_EXCEPTION_DID_NOT_OCCUR);
            report.addDescriptionEntry(ENTRY_KEY_EXPECTED_EXCEPTION,
                                       expectedExceptionClass);
        }
        return report;
    }

    /** 
     * Compares the input exception with the expected exception
     * If they match, then the test passes. Otherwise, the test fails
     */
    protected TestReport handleException(Exception e) {
        if (!isMatch(e.getClass(), expectedExceptionClass)) {
            TestReport report = reportError(ERROR_UNEXPECTED_EXCEPTION);
            report.addDescriptionEntry(ENTRY_KEY_UNEXPECTED_EXCEPTION,
                                       e.getClass().getName());
            report.addDescriptionEntry(ENTRY_KEY_EXPECTED_EXCEPTION,
                                       expectedExceptionClass);
            return report;
        } else {
            if (!ERROR_CODE_NO_CHECK.equals(expectedErrorCode)
                && e instanceof BridgeException) {
                if ( !expectedErrorCode.equals(((BridgeException)e).getCode()) ) {
                    TestReport report = reportError(ERROR_UNEXPECTED_ERROR_CODE);
                    report.addDescriptionEntry(ENTRY_KEY_UNEXPECTED_ERROR_CODE,
                                               ((BridgeException)e).getCode());
                    report.addDescriptionEntry(ENTRY_KEY_EXPECTED_ERROR_CODE,
                                               expectedErrorCode);
                    return report;
                }
            }
            return reportSuccess();
        }
    }

    /**
     * Check if the input class' name (or one of its base classes) matches
     * the input name.
     */
    protected boolean isMatch(final Class cl, final String name) {
        if (cl == null) {
            return false;
        } else if (cl.getName().equals(name)) {
            return true;
        } else {
            return isMatch(cl.getSuperclass(), name);
        }
    }

    /**
     * Give subclasses a chance to build their own UserAgent
     */
    protected TestUserAgent buildUserAgent(){
        return new TestUserAgent();
    }

    class TestUserAgent extends UserAgentAdapter {
        Exception e;

        public ExternalResourceSecurity 
            getExternalResourceSecurity(ParsedURL resourceURL,
                                        ParsedURL docURL) {
            if ("ANY".equals(resourceOrigin)) {
                return new RelaxedExternalResourceSecurity(resourceURL,
                                                           docURL);
            } else if ("DOCUMENT".equals(resourceOrigin)) {
                return new DefaultExternalResourceSecurity(resourceURL,
                                                           docURL);
            } else if ("EMBEDED".equals(resourceOrigin)) {
                return new EmbededExternalResourceSecurity(resourceURL);
            } else {
                return new NoLoadExternalResourceSecurity();
            }
        }

        public ScriptSecurity
            getScriptSecurity(String scriptType,
                              ParsedURL scriptURL,
                              ParsedURL docURL) {
            ScriptSecurity result = null;
            if (scripts.indexOf(scriptType) == -1) {
                result = new NoLoadScriptSecurity(scriptType);
            } else {
                if ("ANY".equals(scriptOrigin)) {
                    result = new RelaxedScriptSecurity(scriptType,
                                                     scriptURL,
                                                     docURL);
                } else if ("DOCUMENT".equals(scriptOrigin)) {
                    result = new DefaultScriptSecurity(scriptType,
                                                     scriptURL,
                                                     docURL);
                } else if ("EMBEDED".equals(scriptOrigin)) {
                    result = new EmbededScriptSecurity(scriptType,
                                                     scriptURL,
                                                     docURL);
                } else {
                    result = new NoLoadScriptSecurity(scriptType);
                }
            }
            return result;
        }

        public void displayError(Exception e) {
            this.e = e;
        }
    }

}
