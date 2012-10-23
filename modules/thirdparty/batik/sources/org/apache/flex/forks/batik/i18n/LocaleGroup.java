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

import java.util.Locale;

/**
 * This class represents a group of ExtendedLocalizable objects which
 * have a shared default locale.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: LocaleGroup.java 478188 2006-11-22 15:19:17Z dvholten $
 */
public class LocaleGroup {
    /**
     * The default group.
     */
    public static final LocaleGroup DEFAULT = new LocaleGroup();

    /**
     * The shared Locale.
     */
    protected Locale locale;

    /**
     * Sets the default locale for all the instances of ExtendedLocalizable
     * in this group.
     */
    public void setLocale(Locale l) {
        locale = l;
    }

    /**
     * Gets the current default locale in this group, or null.
     */
    public Locale getLocale() {
        return locale;
    }
}
