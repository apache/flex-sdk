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
package org.apache.flex.forks.batik;

/**
 * This class defines the Batik version number.
 *
 * @author <a href="mailto:vincent.hardy@sun.com">Vincent Hardy</a>
 * @version $Id: Version.java 568875 2007-08-23 08:12:11Z cam $
 */
public final class Version {

    /**
     * Returns the Batik version.
     * <p>
     *   This is based on the Implementation-Version attribute in the
     *   batik-util.jar (which is where this Version class lives) and
     *   the 'HeadURL' SVN keyword.  The keyword be substituted with
     *   the URL of this file, which is then inspected to determine if this
     *   file was compiled from the trunk, a tag (a release version), or a
     *   branch.  The format of the returned string will be one of the
     *   following:
     * </p>
     * <table>
     *   <tr>
     *     <th>Source</th>
     *     <th>Version string</th>
     *   </tr>
     *   <tr>
     *     <td>Release version</td>
     *     <td><em>version</em></td>
     *   </tr>
     *   <tr>
     *     <td>Trunk</td>
     *     <td><em>version</em>+r<em>revision</em></td>
     *   </tr>
     *   <tr>
     *     <td>Branch</td>
     *     <td><em>version</em>+r<em>revision</em>; <em>branch-name</em></td>
     *   </tr>
     *   <tr>
     *     <td>Unknown</td>
     *     <td>development version</td>
     *   </tr>
     * </table>
     * <p>
     *   Prior to release 1.7, the version string would
     *   be the straight tag (e.g. <code>"batik-1_6"</code>) or the
     *   string <code>"development.version"</code>.  <em>revision</em> is the
     *   Subversion working copy's revision number.
     * </p>
     */
    public static String getVersion() {
        Package pkg = Version.class.getPackage();
        String version = null;
        if (pkg != null) {
            version = pkg.getImplementationVersion();
        }
        String headURL = "$HeadURL: https://svn.apache.org/repos/asf/xmlgraphics/batik/tags/batik-1_7/sources/org/apache/batik/Version.java $";
        String prefix = "$HeadURL: ";
        String suffix = "/sources/org/apache/batik/Version.java $";
        if (headURL.startsWith(prefix) && headURL.endsWith(suffix)) {
            headURL = headURL.substring
                (prefix.length(), headURL.length() - suffix.length());
            if (!headURL.endsWith("/trunk")) {
                int index1 = headURL.lastIndexOf('/');
                int index2 = headURL.lastIndexOf('/', index1 - 1);
                String name = headURL.substring(index1 + 1);
                String type = headURL.substring(index2 + 1, index1);
                String tagPrefix = "batik-";
                if (type.equals("tags") && name.startsWith(tagPrefix)) {
                    // Release, just use the tag name
                    version = name.substring(tagPrefix.length())
                                  .replace('_', '.');
                } else if (type.equals("branches")) {
                    // SVN branch
                    version += "; " + name;
                }
            }
        }
        if (version == null) {
            version = "development version";
        }

        return version;
    }
}
