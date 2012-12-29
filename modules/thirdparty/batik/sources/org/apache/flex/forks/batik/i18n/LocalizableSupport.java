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
package org.apache.flex.forks.batik.i18n;

import java.text.MessageFormat;
import java.util.ArrayList;
import java.util.Locale;
import java.util.List;
import java.util.ResourceBundle;
import java.util.MissingResourceException;

/**
 * This class provides a default implementation of the Localizable interface.
 * You can use it as a base class or as a member field and delegates various
 * work to it.<p>
 * For example, to implement Localizable, the following code can be used:
 * <pre>
 *  package mypackage;
 *  ...
 *  public class MyClass implements Localizable {
 *      // This code fragment requires a file named
 *      // 'mypackage/resources/Messages.properties', or a
 *      // 'mypackage.resources.Messages' class which extends
 *      // java.util.ResourceBundle, accessible using the current
 *      // classpath.
 *      LocalizableSupport localizableSupport =
 *          new LocalizableSupport("mypackage.resources.Messages");
 *
 *      public void setLocale(Locale l) {
 *          localizableSupport.setLocale(l);
 *      }
 *      public Local getLocale() {
 *          return localizableSupport.getLocale();
 *      }
 *      public String formatMessage(String key, Object[] args) {
 *          return localizableSupport.formatMessage(key, args);
 *      }
 *  }
 * </pre>
 * The algorithm for the Locale lookup in a LocalizableSupport object is:
 * <ul>
 *   <li>
 *     if a Locale has been set by a call to setLocale(), use this Locale,
 *     else,
 *   <li/>
 *   <li>
 *     if a Locale has been set by a call to the setDefaultLocale() method
 *     of a LocalizableSupport object in the current LocaleGroup, use this
 *     Locale, else,
 *   </li>
 *   <li>
 *     use the object returned by Locale.getDefault() (and set by
 *     Locale.setDefault()).
 *   <li/>
 * </ul>
 * This offers the possibility to have a different Locale for each object,
 * a Locale for a group of object and/or a Locale for the JVM instance.
 * <p>
 * Note: if no group is specified a LocalizableSupport object belongs to a
 * default group common to each instance of LocalizableSupport.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: LocalizableSupport.java 594379 2007-11-13 01:08:28Z cam $
 */
public class LocalizableSupport implements Localizable {
    /**
     * The locale group to which this object belongs.
     */
    protected LocaleGroup localeGroup = LocaleGroup.DEFAULT;

    /**
     * The resource bundle classname.
     */
    protected String bundleName;

    /**
     * The classloader to use to create the resource bundle.
     */
    protected ClassLoader classLoader;

    /**
     * The current locale.
     */
    protected Locale locale;

    /**
     * The locale in use.
     */
    protected Locale usedLocale;

    /**
     * The resources
     */
    List resourceBundles = new ArrayList();
    Class lastResourceClass;


    /**
     * The class to lookup bundleName from.
     */
    Class cls;

    /**
     * Same as LocalizableSupport(cls, null).
     */
    public LocalizableSupport(String s, Class cls) {
        this(s, cls, null);
    }

    /**
     * Same as LocalizableSupport(cls, null).
     */
    public LocalizableSupport(String s, Class cls, ClassLoader cl) {
        bundleName = s;
        this.cls = cls;
        classLoader = cl;
    }

    /**
     * Same as LocalizableSupport(s, null).
     */
    public LocalizableSupport(String s) {
        this(s, (ClassLoader)null);
    }

    /**
     * Creates a new Localizable object.
     * The resource bundle class name is required allows the use of custom
     * classes of resource bundles.
     * @param s  must be the name of the class to use to get the appropriate
     *           resource bundle given the current locale.
     * @param cl is the classloader used to create the resource bundle,
     *           or null.
     * @see java.util.ResourceBundle
     */
    public LocalizableSupport(String s, ClassLoader cl) {
        bundleName = s;
        classLoader = cl;
    }

    /**
     * Implements {@link org.apache.flex.forks.batik.i18n.Localizable#setLocale(Locale)}.
     */
    public void setLocale(Locale l) {
        if (locale != l) {
            locale = l;
            resourceBundles.clear();
            lastResourceClass = null;
        }
    }

    /**
     * Implements {@link org.apache.flex.forks.batik.i18n.Localizable#getLocale()}.
     */
    public Locale getLocale() {
        return locale;
    }

    /**
     * Implements {@link
     * org.apache.flex.forks.batik.i18n.ExtendedLocalizable#setLocaleGroup(LocaleGroup)}.
     */
    public void setLocaleGroup(LocaleGroup lg) {
        localeGroup = lg;
    }

    /**
     * Implements {@link
     * org.apache.flex.forks.batik.i18n.ExtendedLocalizable#getLocaleGroup()}.
     */
    public LocaleGroup getLocaleGroup() {
        return localeGroup;
    }

    /**
     * Implements {@link
     * org.apache.flex.forks.batik.i18n.ExtendedLocalizable#setDefaultLocale(Locale)}.
     * Later invocations of the instance methods will lead to update the
     * resource bundle used.
     */
    public void setDefaultLocale(Locale l) {
        localeGroup.setLocale(l);
    }

    /**
     * Implements {@link
     * org.apache.flex.forks.batik.i18n.ExtendedLocalizable#getDefaultLocale()}.
     */
    public Locale getDefaultLocale() {
        return localeGroup.getLocale();
    }

    /**
     * Implements {@link
     * org.apache.flex.forks.batik.i18n.Localizable#formatMessage(String,Object[])}.
     */
    public String formatMessage(String key, Object[] args) {
        return MessageFormat.format(getString(key), args);
    }

    protected Locale getCurrentLocale() {
        if (locale != null) return locale;
        Locale l = localeGroup.getLocale();
        if (l != null) return l;
        return Locale.getDefault();
    }

    /**
     * returns true if the locale is different from the previously
     * used locale.  Also sets 'usedLocale' to the current locale.
     */
    protected boolean setUsedLocale() {
        Locale l = getCurrentLocale();
        if (usedLocale == l) return false;
        usedLocale = l;
        resourceBundles.clear();
        lastResourceClass = null;
        return true;
    }

    /**
     * Here for backwards compatability
     */
    public ResourceBundle getResourceBundle() {
        return getResourceBundle(0);
    }

    protected boolean hasNextResourceBundle(int i) {
        if (i == 0) return true;
        if (i < resourceBundles.size()) return true;

        if (lastResourceClass == null) return false;
        if (lastResourceClass == Object.class) return false;
        return true;
    }

    protected ResourceBundle lookupResourceBundle(String bundle,
                                                  Class theClass){
        ClassLoader cl = classLoader;
        ResourceBundle rb=null;
        if (cl != null) {
            try {
                rb = ResourceBundle.getBundle(bundle, usedLocale, cl);
            } catch (MissingResourceException mre) {
            }
            if (rb != null)
                return rb;
        }

        if (theClass != null) {
            try {
                cl = theClass.getClassLoader();
            } catch (SecurityException se) {
            }
        }
        if (cl == null)
            cl = getClass().getClassLoader();
        try {
            rb = ResourceBundle.getBundle(bundle, usedLocale, cl);
        } catch (MissingResourceException mre) {
        }
        return rb;
    }

    protected ResourceBundle getResourceBundle(int i) {
        setUsedLocale();
        ResourceBundle rb=null;
        if (cls == null) {
            // Old behavour
            if (resourceBundles.size() == 0) {
                rb = lookupResourceBundle(bundleName, null);
                resourceBundles.add(rb);
            }
            return (ResourceBundle)resourceBundles.get(0);
        }

        while (i >= resourceBundles.size()) {
            if (lastResourceClass == Object.class)
                return null;
            if (lastResourceClass == null)
                lastResourceClass = cls;
            else
                lastResourceClass = lastResourceClass.getSuperclass();
            Class cl = lastResourceClass;
            String bundle = (cl.getPackage().getName() + "." + bundleName);
            resourceBundles.add(lookupResourceBundle(bundle, cl));
        }
        return (ResourceBundle)resourceBundles.get(i);
    }

    /**
     */
    public String getString(String key) throws MissingResourceException {
        setUsedLocale();
        for (int i=0; hasNextResourceBundle(i); i++) {
            ResourceBundle rb = getResourceBundle(i);
            if (rb == null) continue;
            try {
                String ret = rb.getString(key);
                if (ret != null) return ret;
            } catch (MissingResourceException mre) {
            }
        }
        String classStr = (cls != null)?cls.toString():bundleName;
        throw new MissingResourceException("Unable to find resource: " + key,
                                           classStr, key);
    }

    /**
     * Returns the integer mapped with the given string
     * @param key a key of the resource bundle
     * @throws MissingResourceException if key is not the name of a resource
     */
    public int getInteger(String key)
        throws MissingResourceException {
        String i = getString(key);
        
        try {
            return Integer.parseInt(i);
        } catch (NumberFormatException e) {
            throw new MissingResourceException
                ("Malformed integer", bundleName, key);
        }
    }

    public int getCharacter(String key)
        throws MissingResourceException {
        String s = getString(key);
        
        if(s == null || s.length() == 0){
            throw new MissingResourceException
                ("Malformed character", bundleName, key);
        }

        return s.charAt(0);
    }
}
