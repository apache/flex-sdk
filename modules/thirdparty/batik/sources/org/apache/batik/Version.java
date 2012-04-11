/*

   Copyright 2003 The Apache Software Foundation 

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

package org.apache.batik;

/**
 * This class defines the Batik version number.
 *
 * @author <a href="mailto:vincent.hardy@sun.com">Vincent Hardy</a>
 * @version $Id: Version.java,v 1.3 2004/09/24 10:56:36 deweese Exp $
 */
public final class Version {
    public static final String LABEL_DEVELOPMENT_BUILD
        = "development.build";
    
    /**
     * @return the Batik version. This is based on the CVS tag.
     * If this Version is not part of a tagged release, then
     * the returned value is a constant reflecting a development
     * build.
     */
    public static String getVersion() {
        String tagName = "$Name: batik-1_6 $";
        if (tagName.startsWith("$Name:")) {
            tagName = tagName.substring(6, tagName.length()-1);
        } else {
            tagName = "";
        }
        
        if(tagName.trim().intern().equals("")){
            tagName = LABEL_DEVELOPMENT_BUILD;
        }

        return tagName;
    }
}
