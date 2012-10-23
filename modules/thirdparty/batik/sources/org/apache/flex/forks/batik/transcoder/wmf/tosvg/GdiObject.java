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

package org.apache.flex.forks.batik.transcoder.wmf.tosvg;

/**
 * Represents GDI Objects encountred in WMF Files.
 *
 * @version $Id: GdiObject.java 498740 2007-01-22 18:35:57Z dvholten $
 */
public class GdiObject {
    GdiObject( int _id, boolean _used ) {
        id = _id;
        used = _used;
        type = 0;
    }

    public void clear() {
        used = false;
        type = 0;
    }

    /** Setup this Object, which means that it is used and associated with an Object.
     *  <p>The Object can be any Java <i>Object</i> that is useful for an implementation of
     *  {@link AbstractWMFPainter} that uses this GdiObject.</p>
     *  <p>For example, if the painter paints in a Java <i>Graphics2D</i> :</p>
     *  <ul>
     *  <li>For a PEN or BRUSH GdiObject : the Object will be a <i>Color</i></li>
     *  <li>For a FONT GdiObject : the Object can be a <i>Font</i> (in fact, the actual
     *  {@link WMFPainter} implementation uses a more sophisticated kind of Object in order to keep
     *  track of the associated charset)</li>
     *  </ul>
     *  @param _type the type of this object
     *  @param _obj the associated Object
     */
    public void Setup( int _type, Object _obj ) {
        obj = _obj;
        type = _type;
        used = true;
    }

    /** Return true if this GdiObject is used.
     */
    public boolean isUsed() {
        return used;
    }

    /** Return the type of this GdiObject.
     */
    public int getType() {
        return type;
    }

    /** Return the Object associated with this GdiObject.
     */
    public Object getObject() {
        return obj;
    }

    /** Return the identification of this GdiObject.
     */
    public int getID() {
        return id;
    }

    int id;
    boolean used;
    Object obj;
    int type = 0;
}
