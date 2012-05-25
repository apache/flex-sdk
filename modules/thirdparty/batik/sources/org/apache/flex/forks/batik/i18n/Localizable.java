/*

   Copyright 2000  The Apache Software Foundation 

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

import java.util.Locale;
import java.util.MissingResourceException;

/**
 * This interface must be implemented by the classes which must provide a
 * way to override the default locale. 
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: Localizable.java,v 1.3 2004/08/18 07:14:45 vhardy Exp $
 */
public interface Localizable {
    /**
     * Provides a way to the user to specify a locale which override the
     * default one. If null is passed to this method, the used locale
     * becomes the global one. 
     * @param l The locale to set.
     */
    void setLocale(Locale l);

    /**
     * Returns the current locale or null if the locale currently used is
     * the default one.     
     */
    Locale getLocale();

    /**
     * Creates and returns a localized message, given the key of the message
     * in the resource bundle and the message parameters.
     * The messages in the resource bundle must have the syntax described in
     * the java.text.MessageFormat class documentation.
     * @param key  The key used to retreive the message from the resource
     *             bundle.
     * @param args The objects that compose the message.
     * @exception MissingResourceException if the key is not in the bundle.
     */
    String formatMessage(String key, Object[] args)
        throws MissingResourceException;
}
