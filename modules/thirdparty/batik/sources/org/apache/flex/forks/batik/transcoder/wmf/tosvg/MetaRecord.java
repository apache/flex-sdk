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

import java.util.List;
import java.util.ArrayList;

/**
 * This is used to keep data while processing WMF-files.
 * It is tagged with a type and holds a list of Integer-objects.
 * It seems, it might be rewritten to keep just the plain int-data.
 *
 * @author <a href="mailto:bella.robinson@cmis.csiro.au">Bella Robinson</a>
 * @version $Id: MetaRecord.java 582434 2007-10-06 02:11:51Z cam $
 */
public class MetaRecord /*implements Serializable*/ {

    public int functionId;
    public int numPoints;

    private final List ptVector = new ArrayList();

    public MetaRecord() {
    }

    public void EnsureCapacity( int cc ) {
    }

    /**
     * when you are storing Integer-objects, consider using addElement( int ) instead.
     * @param obj
     */
    public void AddElement( Object obj ) {
        ptVector.add( obj );
    }

    /**
     * helper method to add int-values. This way we keep the call to new Integer()
     * in one place, here.
     *
     * @param iValue  the value to add to ptVector, wrapped in an Integer
     */
    public final void addElement( int iValue ){
        ptVector.add( new Integer( iValue ) );
    }

    /**
     * if you dont really need the Integer-object from this method
     * it is recommended to use the <code>elementAt()</code>-method instead,
     * which returns an <code>int</code>.
     */
    public Integer ElementAt( int offset ) {
        return (Integer)ptVector.get( offset );
    }

    /**
     * helper-method to return the plain int-value from the record
     * and save the .intValue()-call at the caller's site.
     * @param offset of the element to get
     * @return the intValue of the element at offset
     */
    public final int elementAt( int offset ){
        return ((Integer)ptVector.get( offset )).intValue();
    }

    /** A record that contain byte arrays elements.
     */
    public static class ByteRecord extends MetaRecord {
        public final byte[] bstr;

        public ByteRecord(byte[] bstr) {
            this.bstr = bstr;
        }
    }

    public static class StringRecord extends MetaRecord /*implements Serializable*/ {
        public final String text;

        public StringRecord( String newText ) {
            text = newText;
        }
    }
}
