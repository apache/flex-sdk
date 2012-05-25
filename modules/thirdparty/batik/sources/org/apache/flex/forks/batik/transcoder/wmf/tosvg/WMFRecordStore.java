/*

   Copyright 2001-2003  The Apache Software Foundation 

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
package org.apache.flex.forks.batik.transcoder.wmf.tosvg;

import java.io.DataInputStream;
import java.io.IOException;
import java.net.URL;
import java.util.Vector;

import org.apache.flex.forks.batik.transcoder.wmf.WMFConstants;

/**
 * Reads a WMF file, including an Aldus Placable Metafile Header.
 *
 * @author <a href="mailto:luano@asd.ie">Luan O'Carroll</a>
 * @version $Id: WMFRecordStore.java,v 1.6 2004/08/18 07:15:47 vhardy Exp $
 */
public class WMFRecordStore implements WMFConstants{

    public WMFRecordStore(){
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

    private short readShort( DataInputStream is  ) throws IOException{
        byte js[] = new byte[ 2 ];
        is.read( js );
        int iTemp = ((0xff) & js[ 1 ] ) << 8;
        short i = (short)(0xffff & iTemp);
        i |= ((0xff) & js[ 0 ] );
        return i;
    }

    private int readInt( DataInputStream is  ) throws IOException {
        byte js[] = new byte[ 4 ];
        is.read( js );
        int i = ((0xff) & js[ 3 ] ) << 24;
        i |= ((0xff) & js[ 2 ] ) << 16;
        i |= ((0xff) & js[ 1 ] ) << 8;
        i |= ((0xff) & js[ 0 ] );
        return i;
    }

    /**
     * Reads the WMF file from the specified Stream.
     */
    public boolean read( DataInputStream is ) throws IOException{
        reset();

        setReading( true );
        int dwIsAldus = readInt( is );
        if ( dwIsAldus == WMFConstants.META_ALDUS_APM ) {
            // Read the aldus placeable header.
            /* int   key      = dwIsAldus; */
            /* short hmf      = */ readShort( is );
            /* short left     = */ readShort( is );
            /* short top      = */ readShort( is );
            /* short right    = */ readShort( is );
            /* short  bottom  = */ readShort( is );
            /* short inch     = */ readShort( is );
            /* int   reserved = */ readInt  ( is );
            /* short checksum = */ readShort( is );
        }
        else {
            System.out.println( "Unable to read file, it is not a Aldus Placable Metafile" );
            setReading( false );
            return false;
        }

        /* int mtType         = */ readShort( is );
        /* int mtHeaderSize   = */ readShort( is );
        /* int mtVersion      = */ readShort( is );
        /* int mtSize         = */ readInt  ( is );
        int mtNoObjects       =    readShort( is );
        /* int mtMaxRecord    = */ readInt  ( is );
        /* int mtNoParameters = */ readShort( is );


        short functionId = 1;
        int recSize = 0;

        numRecords = 0;

        numObjects = mtNoObjects;
        objectVector.ensureCapacity( numObjects );
        for ( int i = 0; i < numObjects; i++ ) {
            objectVector.addElement( new GdiObject( i, false ));
        }

        while ( functionId > 0 ) {
            recSize = readInt( is );
            // Subtract size in 16-bit words of recSize and functionId;
            recSize -= 3;
            functionId = readShort( is );
            if ( functionId <= 0 )
                break;

            MetaRecord mr = new MetaRecord();
            switch ( functionId ) {
            case WMFConstants.META_DRAWTEXT:
                {
                    for ( int i = 0; i < recSize; i++ )
                        readShort( is );
                    numRecords--;
                }
                break;

            case WMFConstants.META_EXTTEXTOUT:
                {
                    int yVal = readShort( is );
                    int xVal = readShort( is );
                    int lenText = readInt( is );
                    int len = 2*(recSize-4);
                    byte bstr[] = new byte[ lenText ];
                    //is.read( bstr );
                    int i = 0;
                    for ( ; i < lenText; i++ )
                        bstr[ i ] = is.readByte();
                    for ( ; i < len; i++ )
                        is.readByte();

                    String str = new String( bstr );
                    mr = new StringRecord( str );
                    mr.numPoints = recSize;
                    mr.functionId = functionId;

                    mr.AddElement( new Integer( xVal ));
                    mr.AddElement( new Integer( yVal ));
                    records.addElement( mr );
                }
                break;

            case WMFConstants.META_TEXTOUT:
                {
                    int len = readShort( is );
                    byte bstr[] = new byte[ len ];
                    //is.read( bstr );
                    for ( int i = 0; i < len; i++ )
                        bstr[ i ] = is.readByte();
                    int yVal = readShort( is );
                    int xVal = readShort( is );

                    String str = new String( bstr );
                    mr = new StringRecord( str );
                    mr.numPoints = recSize;
                    mr.functionId = functionId;

                    mr.AddElement( new Integer( xVal ));
                    mr.AddElement( new Integer( yVal ));
                    records.addElement( mr );
                }
                break;


            case WMFConstants.META_CREATEFONTINDIRECT:
                {
                    int lfHeight = readShort( is );
                    /* int lfWidth       = */ readShort( is );
                    /* int lfEscapement  = */ readShort( is );
                    /* int lfOrientation = */ readShort( is );
                    int lfWeight = readShort( is );

                    int lfItalic = is.readByte();
                    /* int lfUnderline      = */ is.readByte();
                    /* int lfStrikeOut      = */ is.readByte();
                    /* int lfCharSet        = */ is.readByte();
                    /* int lfOutPrecision   = */ is.readByte();
                    /* int lfClipPrecision  = */ is.readByte();
                    /* int lfQuality        = */ is.readByte();
                    /* int lfPitchAndFamily = */ is.readByte();

                    int len = (2*(recSize-9));//13));
                    byte lfFaceName[] = new byte[ len ];
                    for ( int i = 0; i < len; i++ )
                        lfFaceName[ i ] = is.readByte();


                    String str = new String( lfFaceName );

                    mr = new StringRecord( str );
                    mr.numPoints = recSize;
                    mr.functionId = functionId;

                    mr.AddElement( new Integer( lfHeight ));
                    mr.AddElement( new Integer( lfItalic ));
                    mr.AddElement( new Integer( lfWeight ));
                    records.addElement( mr );
                }
                break;

            case WMFConstants.META_SETWINDOWORG:
            case WMFConstants.META_SETWINDOWEXT:
                {
                    mr.numPoints = recSize;
                    mr.functionId = functionId;

                    int i0 = readShort( is );
                    int i1 = readShort( is );
                    mr.AddElement( new Integer( i1 ));
                    mr.AddElement( new Integer( i0 ));
                    records.addElement( mr );

                    if ( functionId == WMFConstants.META_SETWINDOWEXT ) {
                      vpW = i0;
                      vpH = i1;
                    }
                }
                break;

            case WMFConstants.META_CREATEBRUSHINDIRECT:
                {
                    mr.numPoints = recSize;
                    mr.functionId = functionId;

                    // The style
                    mr.AddElement( new Integer( readShort( is )));

                    int colorref =  readInt( is );
                    int red = colorref & 0xff;
                    int green = ( colorref & 0xff00 ) >> 8;
                    int blue = ( colorref & 0xff0000 ) >> 16;
                    // int flags = ( colorref & 0x3000000 ) >> 24;
                    mr.AddElement( new Integer( red ));
                    mr.AddElement( new Integer( green ));
                    mr.AddElement( new Integer( blue ));

                    // The hatch style
                    mr.AddElement( new Integer( readShort( is )));

                    records.addElement( mr );
                }
                break;

            case WMFConstants.META_CREATEPENINDIRECT:
                {
                    mr.numPoints = recSize;
                    mr.functionId = functionId;

                    // The style
                    Integer style = new Integer( readShort( is ));
                    mr.AddElement( style );

                    int width     =    readShort( is );
                    int colorref  =    readInt  ( is );
                    /* int height = */ readShort( is );

                    int red   =   colorref & 0xff;
                    int green = ( colorref & 0xff00 ) >> 8;
                    int blue  = ( colorref & 0xff0000 ) >> 16;
                    // int flags = ( colorref & 0x3000000 ) >> 24;
                    mr.AddElement( new Integer( red ));
                    mr.AddElement( new Integer( green ));
                    mr.AddElement( new Integer( blue ));

                    // The pen width
                    mr.AddElement( new Integer( width ));

                    records.addElement( mr );
                }
                break;

            case WMFConstants.META_SETTEXTCOLOR:
            case WMFConstants.META_SETBKCOLOR:
                {
                    mr.numPoints = recSize;
                    mr.functionId = functionId;

                    int colorref =  readInt( is );
                    int red = colorref & 0xff;
                    int green = ( colorref & 0xff00 ) >> 8;
                    int blue = ( colorref & 0xff0000 ) >> 16;
                    // int flags = ( colorref & 0x3000000 ) >> 24;
                    mr.AddElement( new Integer( red ));
                    mr.AddElement( new Integer( green ));
                    mr.AddElement( new Integer( blue ));
                    records.addElement( mr );
                }
                break;

            case WMFConstants.META_LINETO:
            case WMFConstants.META_MOVETO:
                {
                    mr.numPoints = recSize;
                    mr.functionId = functionId;

                    int i0 = readShort( is );
                    int i1 = readShort( is );
                    mr.AddElement( new Integer( i1 ));
                    mr.AddElement( new Integer( i0 ));
                    records.addElement( mr );
                }
                break;

            case WMFConstants.META_POLYPOLYGON:
                {
                    mr.numPoints = recSize;
                    mr.functionId = functionId;

                    int count = readShort( is );
                    int pts[] = new int[ count ];
                    int ptCount = 0;
                    for ( int i = 0; i < count; i++ ) {
                        pts[ i ] = readShort( is );
                        ptCount += pts[ i ];
                    }
                    mr.AddElement( new Integer( count ));

                    for ( int i = 0; i < count; i++ )
                        mr.AddElement( new Integer( pts[ i ] ));

                    for ( int i = 0; i < count; i++ ) {
                        for ( int j = 0; j < pts[ i ]; j++ ) {
                            mr.AddElement( new Integer( readShort( is )));
                            mr.AddElement( new Integer( readShort( is )));
                        }
                    }
                    records.addElement( mr );
                }
                break;

            case WMFConstants.META_POLYGON:
                {
                    mr.numPoints = recSize;
                    mr.functionId = functionId;

                    int count = readShort( is );
                    mr.AddElement( new Integer( count ));
                    for ( int i = 0; i < count; i++ ) {
                        mr.AddElement( new Integer( readShort( is )));
                        mr.AddElement( new Integer( readShort( is )));
                    }
                    records.addElement( mr );
                }
                break;

            case WMFConstants.META_ELLIPSE:
            case WMFConstants.META_INTERSECTCLIPRECT:
            case WMFConstants.META_RECTANGLE:
                {
                    mr.numPoints = recSize;
                    mr.functionId = functionId;

                    int i0 = readShort( is );
                    int i1 = readShort( is );
                    int i2 = readShort( is );
                    int i3 = readShort( is );
                    mr.AddElement( new Integer( i3 ));
                    mr.AddElement( new Integer( i2 ));
                    mr.AddElement( new Integer( i1 ));
                    mr.AddElement( new Integer( i0 ));
                    records.addElement( mr );
                }
                break;

            case WMFConstants.META_ROUNDRECT:
                {
                    mr.numPoints = recSize;
                    mr.functionId = functionId;

                    int i0 = readShort( is );
                    int i1 = readShort( is );
                    int i2 = readShort( is );
                    int i3 = readShort( is );
                    int i4 = readShort( is );
                    int i5 = readShort( is );
                    mr.AddElement( new Integer( i5 ));
                    mr.AddElement( new Integer( i4 ));
                    mr.AddElement( new Integer( i3 ));
                    mr.AddElement( new Integer( i2 ));
                    mr.AddElement( new Integer( i1 ));
                    mr.AddElement( new Integer( i0 ));
                    records.addElement( mr );
                }
                break;

            case WMFConstants.META_ARC:
            case WMFConstants.META_PIE:
                {
                    mr.numPoints = recSize;
                    mr.functionId = functionId;

                    int i0 = readShort( is );
                    int i1 = readShort( is );
                    int i2 = readShort( is );
                    int i3 = readShort( is );
                    int i4 = readShort( is );
                    int i5 = readShort( is );
                    int i6 = readShort( is );
                    int i7 = readShort( is );
                    mr.AddElement( new Integer( i7 ));
                    mr.AddElement( new Integer( i6 ));
                    mr.AddElement( new Integer( i5 ));
                    mr.AddElement( new Integer( i4 ));
                    mr.AddElement( new Integer( i3 ));
                    mr.AddElement( new Integer( i2 ));
                    mr.AddElement( new Integer( i1 ));
                    mr.AddElement( new Integer( i0 ));
                    records.addElement( mr );
                }
                break;

            default:
                mr.numPoints = recSize;
                mr.functionId = functionId;

                for ( int j = 0; j < recSize; j++ )
                    mr.AddElement( new Integer( readShort( is )));

                records.addElement( mr );
                break;

            }

            numRecords++;
        }

        setReading( false );
        return true;
    }

    public void addObject( int type, Object obj ){
        int startIdx = 0;
        //     if ( type == Wmf.PEN ) {
        //       startIdx = 2;
        //     }
        for ( int i = startIdx; i < numObjects; i++ ) {
            GdiObject gdi = (GdiObject)objectVector.elementAt( i );
            if ( gdi.used == false ) {
                gdi.Setup( type, obj );
                lastObjectIdx = i;
                break;
            }
        }
    }

    synchronized void setReading( boolean state ){
      bReading = state;
    }

    synchronized boolean isReading(){
      return bReading;
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
        GdiObject gdi = (GdiObject)objectVector.elementAt( i );
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
      return (GdiObject)objectVector.elementAt( idx );
    }

    /**
     * Returns a meta record.
     */
    public MetaRecord getRecord( int idx ) {
      return (MetaRecord)records.elementAt( idx );
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


    transient private URL url;

    transient protected int numRecords;
    transient protected int numObjects;
    transient public int lastObjectIdx;
    transient protected int vpX, vpY, vpW, vpH;
    transient protected Vector	records;
    transient protected Vector	objectVector;

    transient protected boolean bReading = false;
}
