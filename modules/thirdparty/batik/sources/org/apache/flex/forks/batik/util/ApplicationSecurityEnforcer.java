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
package org.apache.flex.forks.batik.util;

import java.net.URL;
import java.security.Policy;

/**
 * This is a helper class which helps applications enforce secure
 * script execution.
 * <br />
 * It is used by the Squiggle browser as well as the rasterizer.
 * <br />
 * This class can install a <tt>SecurityManager</tt> for an application
 * and resolves whether the application runs in a development
 * environment or from a jar file (in other words, it resolves code-base
 * issues for the application).
 * <br />
 *
 * @author <a mailto="vincent.hardy@sun.com">Vincent Hardy</a>
 * @version $Id: ApplicationSecurityEnforcer.java 475477 2006-11-15 22:44:28Z cam $
 */
public class ApplicationSecurityEnforcer {
    /**
     * Message for the SecurityException thrown when there is already
     * a SecurityManager installed at the time Squiggle tries
     * to install its own security settings.
     */
    public static final String EXCEPTION_ALIEN_SECURITY_MANAGER
        = "ApplicationSecurityEnforcer.message.security.exception.alien.security.manager";

    /**
     * Message for the NullPointerException thrown when no policy
     * file can be found.
     */
    public static final String EXCEPTION_NO_POLICY_FILE
        = "ApplicationSecurityEnforcer.message.null.pointer.exception.no.policy.file";

    /**
     * System property for specifying an additional policy file.
     */
    public static final String PROPERTY_JAVA_SECURITY_POLICY 
        = "java.security.policy";

    /**
     * Files in a jar file have a URL with the jar protocol
     */
    public static final String JAR_PROTOCOL
        = "jar:";

    /**
     * Used in jar file urls to separate the jar file name 
     * from the referenced file
     */
    public static final String JAR_URL_FILE_SEPARATOR
        = "!/";

    /**
     * System property for App's development base directory
     */
    public static final String PROPERTY_APP_DEV_BASE
        = "app.dev.base";

    /**
     * System property for App's jars base directory
     */
    public static final String PROPERTY_APP_JAR_BASE
        = "app.jar.base";

    /**
     * Directory where classes are expanded in the development
     * version
     */
    public static final String APP_MAIN_CLASS_DIR
        = "classes/";

    /**
     * The application's main entry point
     */
    protected Class appMainClass;

    /**
     * The application's security policy
     */
    protected String securityPolicy;

    /**
     * The resource name for the application's main class
     */
    protected String appMainClassRelativeURL;

    /**
     * Keeps track of the last SecurityManager installed
     */
    protected BatikSecurityManager lastSecurityManagerInstalled;

    /**
     * Creates a new ApplicationSecurityEnforcer.
     * @param appMainClass class of the applications's main entry point
     * @param securityPolicy resource for the security policy which 
     *        should be enforced for the application. 
     * @param appJarFile the Jar file into which the application is
     *        packaged.
     * @deprecated This constructor is now deprecated. Use the two 
     *             argument constructor instead as this version will
     *             be removed after the 1.5beta4 release.
     */
    public ApplicationSecurityEnforcer(Class appMainClass,
                                       String securityPolicy,
                                       String appJarFile){
        this(appMainClass, securityPolicy);
    }


    /**
     * Creates a new ApplicationSecurityEnforcer.
     * @param appMainClass class of the applications's main entry point
     * @param securityPolicy resource for the security policy which 
     *        should be enforced for the application. 
     */
    public ApplicationSecurityEnforcer(Class appMainClass,
                                       String securityPolicy){
        this.appMainClass = appMainClass;
        this.securityPolicy = securityPolicy;
        this.appMainClassRelativeURL = 
            appMainClass.getName().replace('.', '/')
            +
            ".class";
            
    }

    /**
     * Enforces security by installing a <tt>SecurityManager</tt>.
     * This will throw a <tt>SecurityException</tt> if installing
     * a <tt>SecurityManager</tt> requires overriding an existing
     * <tt>SecurityManager</tt>. In other words, this method will 
     * not install a new <tt>SecurityManager</tt> if there is 
     * already one it did not install in place.
     */
    public void enforceSecurity(boolean enforce){
        SecurityManager sm = System.getSecurityManager();

        if (sm != null && sm != lastSecurityManagerInstalled) {
            // Throw a Security exception: we do not want to override
            // an 'alien' SecurityManager with either null or 
            // a new SecurityManager.
            throw new SecurityException
                (Messages.getString(EXCEPTION_ALIEN_SECURITY_MANAGER));
        }
        
        if (enforce) {
            // We first set the security manager to null to
            // force reloading of the policy file in case there
            // has been a change since it was last enforced (this
            // may happen with dynamically generated policy files).
            System.setSecurityManager(null);
            installSecurityManager();
        } else {
            if (sm != null) {
                System.setSecurityManager(null);
                lastSecurityManagerInstalled = null;
            }
        }
    }

    /**
     * Returns the url for the default policy. This never 
     * returns null, but it may throw a NullPointerException
     */
    public URL getPolicyURL() {
        ClassLoader cl = appMainClass.getClassLoader();
        URL policyURL = cl.getResource(securityPolicy);
        
        if (policyURL == null) {
            throw new NullPointerException
                (Messages.formatMessage(EXCEPTION_NO_POLICY_FILE,
                                        new Object[]{securityPolicy}));
        }

        return policyURL;
    }

    /**
     * Installs a SecurityManager on behalf of the application
     */
    public void installSecurityManager(){
        Policy policy = Policy.getPolicy();
        BatikSecurityManager securityManager = new BatikSecurityManager();

        //
        // If there is a java.security.policy property defined,
        // it takes precedence over the one passed to this object.
        // Otherwise, we default to the one passed to the constructor
        //
        ClassLoader cl = appMainClass.getClassLoader();
        String securityPolicyProperty 
            = System.getProperty(PROPERTY_JAVA_SECURITY_POLICY);

        if (securityPolicyProperty == null || securityPolicyProperty.equals("")) {
            // Specify app's security policy in the
            // system property. 
            URL policyURL = getPolicyURL();
            
            System.setProperty(PROPERTY_JAVA_SECURITY_POLICY,
                               policyURL.toString());
        }
        
        // 
        // The following detects whether the application is running in the
        // development environment, in which case it will set the 
        // app.dev.base property or if it is running in the binary
        // distribution, in which case it will set the app.jar.base
        // property. These properties are expanded in the security 
        // policy files.
        // Property expansion is used to provide portability of the 
        // policy files between various code bases (e.g., file base,
        // server base, etc..).
        //
        URL mainClassURL = cl.getResource(appMainClassRelativeURL);
        if (mainClassURL == null){
            // Something is really wrong: we would be running a class
            // which can't be found....
            throw new Error(appMainClassRelativeURL);
        }
        
        String expandedMainClassName = mainClassURL.toString();
        if (expandedMainClassName.startsWith(JAR_PROTOCOL) ) {
            setJarBase(expandedMainClassName);
        } else {
            setDevBase(expandedMainClassName);
        }
        
        // Install new security manager
        System.setSecurityManager(securityManager);
        lastSecurityManagerInstalled = securityManager;
        
        // Forces re-loading of the security policy
        policy.refresh();

        if (securityPolicyProperty == null || securityPolicyProperty.equals("")) {
            System.setProperty(PROPERTY_JAVA_SECURITY_POLICY, "");
        }
    }

    private void setJarBase(String expandedMainClassName){
        //
        // Only set the app.jar.base if it is not already defined
        //
        String curAppJarBase = System.getProperty(PROPERTY_APP_JAR_BASE);
        if (curAppJarBase == null) {
            expandedMainClassName = expandedMainClassName.substring(JAR_PROTOCOL.length());
            
            int codeBaseEnd = 
                expandedMainClassName.indexOf(JAR_URL_FILE_SEPARATOR +
                                              appMainClassRelativeURL);
            
            if (codeBaseEnd == -1){
                // Something is seriously wrong. This should *never* happen
                // as the APP_SECURITY_POLICY_URL is such that it will be
                // a substring of its corresponding URL value
                throw new Error();
            }
            
            String appCodeBase = expandedMainClassName.substring(0, codeBaseEnd);

            // At this point appCodeBase contains the JAR file name
            // Now, we extract it.
            codeBaseEnd = appCodeBase.lastIndexOf('/');
            if (codeBaseEnd == -1) {
                appCodeBase = "";
            } else {
                appCodeBase = appCodeBase.substring(0, codeBaseEnd);
            }

            System.setProperty(PROPERTY_APP_JAR_BASE, appCodeBase);
        }
    }

    /**
     * Position the app.dev.base property for expansion in 
     * the policy file used when App is running in its 
     * development version
     */
    private void setDevBase(String expandedMainClassName){
        //
        // Only set the app.code.base property if it is not already
        // defined.
        //
        String curAppCodeBase = System.getProperty(PROPERTY_APP_DEV_BASE);
        if (curAppCodeBase == null) {
            int codeBaseEnd = 
                expandedMainClassName.indexOf(APP_MAIN_CLASS_DIR
                                              + appMainClassRelativeURL);
            
            if (codeBaseEnd == -1){
                // Something is seriously wrong. This should *never* happen
                // as the APP_SECURITY_POLICY_URL is such that it will be
                // a substring of its corresponding URL value
                throw new Error();
            }
            
            String appCodeBase = expandedMainClassName.substring(0, codeBaseEnd);
            System.setProperty(PROPERTY_APP_DEV_BASE, appCodeBase);
        }
    }


}

