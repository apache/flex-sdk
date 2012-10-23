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

import java.io.DataInputStream;
import java.io.IOException;
import java.net.URL;
import java.util.Vector;

import org.apache.flex.forks.batik.transcoder.wmf.WMFConstants;

/**
 * An object that stores the vector graphics records.
 *
 * @deprecated jan '07 : this class is not used anywhere in Batik, it might be removed in the future.
 *  Probably WMFRecordStore is what you need.
 *
 * @author <a href="mailto:luano@asd.ie">Luan O'Carroll</a>
 * @version $Id: RecordStore.java 501518 2007-01-30 18:56:13Z dvholten $
 */
public class RecordStore {

    public RecordStore(){
        reset();
    }

    /**
     * Resets the internal storage and viewport coordinates.
     */
    public void reset(){
        numRecords = 0;
        vpX = 0;
        vpY = 0;
        vpW = 1000;
        vpH = 1000;
        numObjects = 0;
        records = new Vector( 20, 20 );
        objectVector = new Vector();
    }

    synchronized void setReading( boolean state ){
        bReading = state;
    }

    synchronized boolean isReading(){
        return bReading;
    }

    /**
     * Reads the Wmf file from the specified Stream.
     * A Wmf file can be produced using the GConvert utility found at
     * http://www.asd.ie/Wmf.htm
     *
     * The Wmf format is slightly more compact than the original WMF format and
     * in some cases may produce better handling of colours.
     */
    public boolean read( DataInputStream is ) throws IOException{
        setReading( true );
        reset();

        int functionId = 0;
        numRecords = 0;

        numObjects = is.readShort();
        objectVector.ensureCapacity( numObjects );
        for ( int i = 0; i < numObjects; i++ ) {
            objectVector.add( new GdiObject( i, false ));
        }

        while ( functionId != -1 ) {
            functionId = is.readShort();
            if ( functionId == -1 ){
                break;
            }

            MetaRecord mr;
            switch ( functionId ) {
            case WMFConstants.META_TEXTOUT:
            case WMFConstants.META_DRAWTEXT:
            case WMFConstants.META_EXTTEXTOUT:
            case WMFConstants.META_CREATEFONTINDIRECT:{
                short len = is.readShort();
                byte[] b = new byte[ len ];
                for ( int i = 0; i < len; i++ ) {
                    b[ i ] = is.readByte();
                }
                String str = new String( b );
                mr = new MetaRecord.StringRecord( str );
            }
            break;

            default:
                mr = new MetaRecord();
                break;
            }

            int numPts = is.readShort();
            mr.numPoints = numPts;
            mr.functionId = functionId;

            for ( int j = 0; j < numPts; j++ ){
                mr.AddElement( new Integer( is.readShort()));
            }

            records.add( mr );

            numRecords++;
        }

        setReading( false );
        return true;
    }

    /**
     * Adds a GdiObject to the internal handle table.
     * Adds the object at the next free location.
     *
     * This function should not normally be called by an application.
     */
    public void addObject( int type, Object obj ) {
        for ( int i = 0; i < numObjects; i++ ) {
            GdiObject gdi = (GdiObject)objectVector.get( i );
            if ( ! gdi.used ) {
                gdi.Setup( type, obj );
                lastObjectIdx = i;
                break;
            }
        }
    }

    /**
     * Adds a GdiObject to the internal handle table.
     * Wmf files specify the index as given in EMF records such as
     * EMRCREATEPENINDIRECT whereas WMF files always use 0.
     *
     * This function should not normally be called by an application.
     */
    public void addObjectAt( int type, Object obj, int idx ) {
        if (( idx == 0 ) || ( idx > numObjects )) {
            addObject( type, obj );
            return;
        }
        lastObjectIdx = idx;
        for ( int i = 0; i < numObjects; i++ ) {
            GdiObject gdi = (GdiObject)objectVector.get( i );
            if ( i == idx ) {
                gdi.Setup( type, obj );
                break;
            }
        }
    }

    /**
     * Returns the current URL
     */
    public URL getUrl() {
        return url;
    }

    /**
     * Sets the current URL
     */
    public void setUrl( URL newUrl) {
        url = newUrl;
    }

    /**
     * Returns a GdiObject from the handle table
     */
    public GdiObject getObject( int idx ) {
        return (GdiObject)objectVector.get( idx );
    }

    /**
     * Returns a meta record.
     */
    public MetaRecord getRecord( int idx ) {
        return (MetaRecord)records.get( idx );
    }

    /**
     * Returns a number of records in the image
     */
    public int getNumRecords() {
        return numRecords;
    }

    /**
     * Returns the number of GdiObjects in the handle table
     */
    public int getNumObjects() {
        return numObjects;
    }

    /**
     * Returns the viewport x origin
     */
    public int getVpX() {
        return vpX;
    }

    /**
     * Returns the viewport y origin
     */
    public int getVpY() {
        return vpY;
    }

    /**
     * Returns the viewport width
     */
    public int getVpW() {
        return vpW;
    }

    /**
     * Returns the viewport height
     */
    public int getVpH() {
        return vpH;
    }

    /**
     * Sets the viewport x origin
     */
    public void setVpX( int newValue ) {
        vpX = newValue;
    }

    /**
     * Sets the viewport y origin
     */
    public void setVpY( int newValue ) {
        vpY = newValue;
    }

    /**
     * Sets the viewport width
     */
    public void setVpW( int newValue ) {
        vpW = newValue;
    }

    /**
     * Sets the viewport height
     */
    public void setVpH( int newValue ) {
        vpH = newValue;
    }

    private transient URL url;

    protected transient int numRecords;
    protected transient int numObjects;
    public transient int lastObjectIdx;
    protected transient int vpX;
    protected transient int vpY;
    protected transient int vpW;
    protected transient int vpH;

    protected transient Vector records;
    protected transient Vector objectVector;

    protected transient boolean bReading = false;
}
