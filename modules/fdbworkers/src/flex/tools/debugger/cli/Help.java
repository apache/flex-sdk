/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package flex.tools.debugger.cli;

import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

public class Help
{
    private Help()
    {
    }

    public static InputStream getResourceAsStream()
    {
		List<String> names = calculateLocalizedFilenames("fdbhelp", ".txt", Locale.getDefault()); //$NON-NLS-1$ //$NON-NLS-2$
		for (int i=names.size()-1; i>=0; --i) {
			InputStream stm = Help.class.getResourceAsStream(names.get(i));
			if (stm != null) {
				return stm;
			}
		}
		return null;
    }

    /**
     * Returns an array of filenames that might match the given baseName and locale.
     * For example, if baseName is "fdbhelp", the extension is ".txt", and the locale
     * is "en_US", then the returned array will be (in this order):
     * 
     * <ul>
     *  <li> <code>fdbhelp.txt</code> </li>
     *  <li> <code>fdbhelp_en.txt</code> </li>
     * 	<li> <code>fdbhelp_en_US.txt</code> </li>
     * </ul>
     */
    private static List<String> calculateLocalizedFilenames(String baseName, String extensionWithDot, Locale locale) {
    	List<String> names = new ArrayList<String>();
        String language = locale.getLanguage();
        String country = locale.getCountry();
        String variant = locale.getVariant();

        names.add(baseName + extensionWithDot);

        if (language.length() + country.length() + variant.length() == 0) {
            //The locale is "", "", "".
            return names;
        }
        final StringBuilder temp = new StringBuilder(baseName);
        temp.append('_');
        temp.append(language);
        if (language.length() > 0) {
            names.add(temp.toString() + extensionWithDot);
        }

        if (country.length() + variant.length() == 0) {
            return names;
        }
        temp.append('_');
        temp.append(country);
        if (country.length() > 0) {
            names.add(temp.toString() + extensionWithDot);
        }

        if (variant.length() == 0) {
            return names;
        }
        temp.append('_');
        temp.append(variant);
        names.add(temp.toString() + extensionWithDot);

        return names;
    }
}
