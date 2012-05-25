/*

   Copyright 2000-2001  The Apache Software Foundation 

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
package org.apache.flex.forks.batik.i18n;

import java.text.MessageFormat;
import java.util.Locale;
import java.util.ResourceBundle;

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
 * @version $Id: LocalizableSupport.java,v 1.7 2004/08/18 07:14:45 vhardy Exp $
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
    protected ResourceBundle resourceBundle;

    /**
     * Same as LocalizableSupport(s, null).
     */
    public LocalizableSupport(String s) {
        this(s, null);
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
            resourceBundle = null;
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
        getResourceBundle();
        return MessageFormat.format(resourceBundle.getString(key), args);
    }

    /**
     * Implements {@link
     * org.apache.flex.forks.batik.i18n.ExtendedLocalizable#getResourceBundle()}.
     */
    public ResourceBundle getResourceBundle() {
        Locale l;

        if (resourceBundle == null) {
            if (locale == null) {
                if ((l = localeGroup.getLocale()) == null) {
                    usedLocale = Locale.getDefault();
                } else {
                    usedLocale = l;
                }
            } else {
                usedLocale = locale;
            }
            if (classLoader == null) {
                resourceBundle = ResourceBundle.getBundle(bundleName,
                                                          usedLocale);
            } else {
                resourceBundle = ResourceBundle.getBundle(bundleName,
                                                          usedLocale,
                                                          classLoader);
            }
        } else if (locale == null) {
            // Check for group Locale and JVM default locale changes.
            if ((l = localeGroup.getLocale()) == null) {
                if (usedLocale != (l = Locale.getDefault())) {
                    usedLocale = l;
                    if (classLoader == null) {
                        resourceBundle = ResourceBundle.getBundle(bundleName,
                                                                  usedLocale);
                    } else {
                        resourceBundle = ResourceBundle.getBundle(bundleName,
                                                                  usedLocale,
                                                                  classLoader);
                    }
                }
            } else if (usedLocale != l) {
                usedLocale = l;
                if (classLoader == null) {
                    resourceBundle = ResourceBundle.getBundle(bundleName,
                                                              usedLocale);
                } else {
                    resourceBundle = ResourceBundle.getBundle(bundleName,
                                                              usedLocale,
                                                              classLoader);
                }
            }
        }

        return resourceBundle;
    }
}
