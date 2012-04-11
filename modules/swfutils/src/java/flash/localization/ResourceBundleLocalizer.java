/*
 *
 *  Licensed to the Apache Software Foundation (ASF) under one or more
 *  contributor license agreements.  See the NOTICE file distributed with
 *  this work for additional information regarding copyright ownership.
 *  The ASF licenses this file to You under the Apache License, Version 2.0
 *  (the "License"); you may not use this file except in compliance with
 *  the License.  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 */

package flash.localization;

import java.util.Locale;
import java.util.ResourceBundle;
import java.util.Map;
import java.util.MissingResourceException;

/**
 * ILocalizer implementation, which supports looking up text in
 * resource bundles.
 *
 * @author Roger Gonzalez
 */
public class ResourceBundleLocalizer implements ILocalizer
{
    public ILocalizedText getLocalizedText( Locale locale, String id )
    {
        String prefix = id;

        while (true)
        {
            int dot = prefix.lastIndexOf( '.' );
            if (dot == -1)
            {
                break;
            }
            prefix = prefix.substring( 0, dot );
            String suffix = id.substring( dot + 1 );
            try
            {
                ResourceBundle bundle = ResourceBundle.getBundle( prefix, locale );

                if ((bundle != null) && (bundle.getObject( suffix ) != null))
                {
                    return new ResourceBundleText( bundle.getObject( suffix ).toString() );
                }
            }
            catch (MissingResourceException e)
            {
            }
        }

        return null;
    }

    private class ResourceBundleText implements ILocalizedText
    {
        public ResourceBundleText( String text )
        {
            this.text = text;
        }
        public String format( Map parameters )
        {
            return LocalizationManager.replaceInlineReferences( text, parameters );
        }
        private String text;
    }
}
