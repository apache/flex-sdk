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
import java.util.ArrayList;
import java.util.List;

import org.apache.flex.forks.batik.transcoder.wmf.WMFConstants;

/**
 * Reads a WMF file, including an Aldus Placable Metafile Header.
 *
 * @author <a href="mailto:luano@asd.ie">Luan O'Carroll</a>
 * @version $Id: WMFRecordStore.java 606882 2007-12-26 11:18:04Z cam $
 */
public class WMFRecordStore extends AbstractWMFReader {

    private URL url;

    protected int numRecords;
    protected float vpX, vpY;
    protected List records;

    private boolean _bext = true;


    public WMFRecordStore() {
      super();
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
      scaleX = 1;
      scaleY = 1;
      scaleXY = 1f;      
      inch = 84;
      records = new ArrayList( 20 );
    }

    /**
     * Reads the WMF file from the specified Stream.
     */
    protected boolean readRecords( DataInputStream is ) throws IOException {

        short functionId = 1;
        int recSize = 0;
        short recData;

        numRecords = 0;

        while ( functionId > 0) {
            recSize = readInt( is );
            // Subtract size in 16-bit words of recSize and functionId;
            recSize -= 3;
            functionId = readShort( is );
            if ( functionId <= 0 )
            break;

            MetaRecord mr = new MetaRecord();
            switch ( functionId ) {
            case WMFConstants.META_SETMAPMODE: {
                    mr.numPoints = recSize;
                    mr.functionId = functionId;

                    int mapmode = readShort( is ); 
                    if (mapmode == WMFConstants.MM_ANISOTROPIC) isotropic = false;
                    mr.addElement(mapmode);
                    records.add( mr );
            }
                break;                
            case WMFConstants.META_DRAWTEXT:
                {
                    for ( int i = 0; i < recSize; i++ )
                        recData = readShort( is );      // todo shouldn't the read data be used for something??
                    numRecords--;
                }
                break;

            case WMFConstants.META_EXTTEXTOUT:
                {
                    int yVal = readShort( is ) * ySign;
                    int xVal = (int) (readShort( is ) * xSign * scaleXY);
                    int lenText = readShort( is );
                    int flag = readShort( is );
                    int read = 4; // used to track the actual size really read
                    boolean clipped = false;
                    int x1 = 0, y1 = 0, x2 = 0, y2 = 0;
                    int len;
                    // determination of clipping property
                    if ((flag & WMFConstants.ETO_CLIPPED) != 0) {
                        x1 =  (int) (readShort( is ) * xSign * scaleXY);
                        y1 =  readShort( is ) * ySign;
                        x2 =  (int) (readShort( is ) * xSign * scaleXY);
                        y2 =  readShort( is ) * ySign;
                        read += 4;
                        clipped = true;
                    }
                    byte[] bstr = new byte[ lenText ];
                    int i = 0;
                    for ( ; i < lenText; i++ ) {
                        bstr[ i ] = is.readByte();
                    }
                    read += (lenText + 1)/2;
                    /* must do this because WMF strings always have an even number of bytes, even
                     * if there is an odd number of characters
                     */
                    if (lenText % 2 != 0) is.readByte();
                    // if the record was not completely read, finish reading
                    if (read < recSize) for (int j = read; j < recSize; j++) readShort( is );

                    /* get the StringRecord, having decoded the String, using the current
                     * charset (which was given by the last META_CREATEFONTINDIRECT)
                     */
                    mr = new MetaRecord.ByteRecord(bstr);
                    mr.numPoints = recSize;
                    mr.functionId = functionId;

                    mr.addElement( xVal );
                    mr.addElement( yVal );
                    mr.addElement( flag );
                    if (clipped) {
                        mr.addElement( x1 );
                        mr.addElement( y1 );
                        mr.addElement( x2 );
                        mr.addElement( y2 );
                    }
                    records.add( mr );
                }
                break;

            case WMFConstants.META_TEXTOUT:
                {
                    int len = readShort( is );
                    int read = 1; // used to track the actual size really read
                    byte[] bstr = new byte[ len ];
                    for ( int i = 0; i < len; i++ ) {
                        bstr[ i ] = is.readByte();
                    }
                    /* must do this because WMF strings always have an even number of bytes, even
                     * if there is an odd number of characters
                     */
                    if (len % 2 != 0) is.readByte();
                    read += (len + 1) / 2;

                    int yVal = readShort( is ) * ySign;
                    int xVal = (int) (readShort( is ) * xSign * scaleXY);
                    read += 2;
                    // if the record was not completely read, finish reading
                    if (read < recSize) for (int j = read; j < recSize; j++) readShort( is );

                    /* get the StringRecord, having decoded the String, using the current
                     * charset (which was givben by the last META_CREATEFONTINDIRECT)
                     */
                    mr = new MetaRecord.ByteRecord(bstr);
                    mr.numPoints = recSize;
                    mr.functionId = functionId;

                    mr.addElement( xVal );
                    mr.addElement( yVal );
                    records.add( mr );
                }
                break;


            case WMFConstants.META_CREATEFONTINDIRECT:
                {
                    int lfHeight = readShort( is );
                    int lfWidth = readShort( is );
                    int lfEscapement = readShort( is );
                    int lfOrientation = readShort( is );
                    int lfWeight = readShort( is );

                    int lfItalic = is.readByte();
                    int lfUnderline = is.readByte();
                    int lfStrikeOut = is.readByte();
                    int lfCharSet = is.readByte() & 0x00ff;
                    //System.out.println("lfCharSet: "+(lfCharSet & 0x00ff));
                    int lfOutPrecision = is.readByte();
                    int lfClipPrecision = is.readByte();
                    int lfQuality = is.readByte();
                    int lfPitchAndFamily = is.readByte();

                    // don't need to read the end of the record,
                    // because it will always be completely used
                    int len = (2*(recSize-9));
                    byte[] lfFaceName = new byte[ len ];
                    byte ch;
                    for ( int i = 0; i < len; i++ ) lfFaceName[ i ] = is.readByte();

                    String str = new String( lfFaceName );    // what locale ?? ascii ?? platform ??

                    mr = new MetaRecord.StringRecord( str );
                    mr.numPoints = recSize;
                    mr.functionId = functionId;

                    mr.addElement( lfHeight );
                    mr.addElement( lfItalic );
                    mr.addElement( lfWeight );
                    mr.addElement( lfCharSet );
                    mr.addElement( lfUnderline );
                    mr.addElement( lfStrikeOut );
                    mr.addElement( lfOrientation );
                    // escapement is the orientation of the text in tenth of degrees
                    mr.addElement( lfEscapement );
                    records.add( mr );
                }
                break;

            case WMFConstants.META_SETVIEWPORTORG:
            case WMFConstants.META_SETVIEWPORTEXT:
            case WMFConstants.META_SETWINDOWORG:
            case WMFConstants.META_SETWINDOWEXT: {
                    mr.numPoints = recSize;
                    mr.functionId = functionId;

                    int height = readShort( is );
                    int width = readShort( is );
                    // inverse the values signs if they are negative
                    if (width < 0) {
                        width = -width;
                        xSign = -1;
                    }
                    if (height < 0) {
                        height = -height;
                        ySign = -1;
                    }

                    mr.addElement((int)(width  * scaleXY));
                    mr.addElement( height );
                    records.add( mr );

                    if (_bext && functionId == WMFConstants.META_SETWINDOWEXT) {
                      vpW = width;
                      vpH = height;
                      if (! isotropic) scaleXY = (float)vpW / (float)vpH;
                      vpW = (int)(vpW * scaleXY);                      
                      _bext = false;
                    }
                    // sets the width, height of the image if the file does not have an APM (in this case it is retrieved
                    // from the viewport)
                    if (! isAldus) {
                        this.width = vpW;
                        this.height = vpH;
                    }                            
                }
                break;

            case WMFConstants.META_OFFSETVIEWPORTORG:
            case WMFConstants.META_OFFSETWINDOWORG: {
                    mr.numPoints = recSize;
                    mr.functionId = functionId;

                    int y = readShort( is ) * ySign;
                    int x = (int)(readShort( is ) * xSign * scaleXY);
                    mr.addElement( x );
                    mr.addElement( y );
                    records.add( mr );
                }
                break;

            case WMFConstants.META_SCALEVIEWPORTEXT:
            case WMFConstants.META_SCALEWINDOWEXT: {
                    mr.numPoints = recSize;
                    mr.functionId = functionId;

                    int ydenom = readShort( is );
                    int ynum = readShort( is );
                    int xdenom= readShort( is );
                    int xnum = readShort( is );
                    mr.addElement( xdenom );
                    mr.addElement( ydenom );
                    mr.addElement( xnum );
                    mr.addElement( ynum );
                    records.add( mr );
                    scaleX = scaleX * (float)xdenom / (float)xnum;
                    scaleY = scaleY * (float)ydenom / (float)ynum;
                }
                break;

            case WMFConstants.META_CREATEBRUSHINDIRECT:
                {
                    mr.numPoints = recSize;
                    mr.functionId = functionId;

                    // The style
                    mr.addElement( readShort( is ));

                    int colorref =  readInt( is );
                    int red = colorref & 0xff;
                    int green = ( colorref & 0xff00 ) >> 8;
                    int blue = ( colorref & 0xff0000 ) >> 16;
                    int flags = ( colorref & 0x3000000 ) >> 24;
                    mr.addElement( red );
                    mr.addElement( green );
                    mr.addElement(  blue );

                    // The hatch style
                    mr.addElement( readShort( is ) );

                    records.add( mr );
                }
                break;

            case WMFConstants.META_CREATEPENINDIRECT:
                {
                    mr.numPoints = recSize;
                    mr.functionId = functionId;

                    // The style
                    mr.addElement( readShort( is ) );

                    int width = readInt( is );
                    int colorref =  readInt( is );

                    /**
                     * sometimes records generated by PPT have a
                     * recSize of 6 and not 5 => in this case only we have
                     * to read a last short element
                     **/
                    //int height = readShort( is );
                    if (recSize == 6) readShort(is);

                    int red = colorref & 0xff;    // format: fff.bbbbbbbb.gggggggg.rrrrrrrr
                    int green = ( colorref & 0xff00 ) >> 8;
                    int blue = ( colorref & 0xff0000 ) >> 16;
                    int flags = ( colorref & 0x3000000 ) >> 24;

                    mr.addElement( red );
                    mr.addElement( green );
                    mr.addElement( blue );

                    // The pen width
                    mr.addElement( width );

                    records.add( mr );
                }
                break;

            case WMFConstants.META_SETTEXTALIGN:
                {
                    mr.numPoints = recSize;
                    mr.functionId = functionId;
                    int align = readShort( is );
                    // need to do this, because sometimes there is more than one short
                    if (recSize > 1) for (int i = 1; i < recSize; i++) readShort( is );
                    mr.addElement( align );
                    records.add( mr );
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
                    int flags = ( colorref & 0x3000000 ) >> 24;
                    mr.addElement( red );
                    mr.addElement( green );
                    mr.addElement( blue );
                    records.add( mr );
                }
                break;

            case WMFConstants.META_LINETO:
            case WMFConstants.META_MOVETO:
                {
                    mr.numPoints = recSize;
                    mr.functionId = functionId;

                    int y = readShort( is ) * ySign;
                    int x = (int)(readShort( is ) * xSign * scaleXY);
                    mr.addElement( x );
                    mr.addElement( y );
                    records.add( mr );
                }
                break;

            case WMFConstants.META_SETPOLYFILLMODE :
                {
                    mr.numPoints = recSize;
                    mr.functionId = functionId;

                    int mode = readShort( is );
                    // need to do this, because sometimes there is more than one short
                    if (recSize > 1) for (int i = 1; i < recSize; i++) readShort( is );
                    mr.addElement( mode );
                    records.add( mr );
                }
                break;

            case WMFConstants.META_POLYPOLYGON:
                {
                    mr.numPoints = recSize;
                    mr.functionId = functionId;

                    int count = readShort( is ); // number of polygons
                    int[] pts = new int[ count ];
                    int ptCount = 0;
                    for ( int i = 0; i < count; i++ ) {
                        pts[ i ] = readShort( is ); // number of points for the polygon
                        ptCount += pts[ i ];
                    }
                    mr.addElement( count );

                    for ( int i = 0; i < count; i++ )
                        mr.addElement( pts[ i ] );

                    int offset = count+1;
                    for ( int i = 0; i < count; i++ ) {
                        int nPoints = pts[ i ];
                        for ( int j = 0; j < nPoints; j++ ) {
                            mr.addElement((int)(readShort( is )  * xSign * scaleXY)); // x position of the polygon
                            mr.addElement( readShort( is ) * ySign ); // y position of the polygon
                        }
                    }
                    records.add( mr );
                }
                break;

            case WMFConstants.META_POLYLINE:
            case WMFConstants.META_POLYGON:
                {
                    mr.numPoints = recSize;
                    mr.functionId = functionId;

                    int count = readShort( is );
                    mr.addElement( count );
                    for ( int i = 0; i < count; i++ ) {
                        mr.addElement((int)(readShort( is ) * xSign * scaleXY));
                        mr.addElement( readShort( is ) * ySign );
                    }
                    records.add( mr );
                }
                break;

            case WMFConstants.META_ELLIPSE:
            case WMFConstants.META_INTERSECTCLIPRECT:
            case WMFConstants.META_RECTANGLE:
                {
                    mr.numPoints = recSize;
                    mr.functionId = functionId;

                    int bottom = readShort( is ) * ySign;
                    int right = (int)(readShort( is ) * xSign * scaleXY);
                    int top = readShort( is ) * ySign;
                    int left = (int)(readShort( is ) * xSign * scaleXY);
                    mr.addElement( left );
                    mr.addElement( top );
                    mr.addElement( right );
                    mr.addElement( bottom );
                    records.add( mr );
                }
                break;

            case WMFConstants.META_CREATEREGION: {
                    mr.numPoints = recSize;
                    mr.functionId = functionId;
                    int left = (int)(readShort( is ) * xSign * scaleXY);
                    int top = readShort( is ) * ySign;
                    int right = (int)(readShort( is ) * xSign * scaleXY);
                    int bottom = readShort( is ) * ySign;
                    mr.addElement( left );
                    mr.addElement( top );
                    mr.addElement( right );
                    mr.addElement( bottom );
                    records.add( mr );
            }
            break;

            case WMFConstants.META_ROUNDRECT: {
                    mr.numPoints = recSize;
                    mr.functionId = functionId;

                    int el_height = readShort( is ) * ySign;
                    int el_width = (int)(readShort( is ) * xSign * scaleXY);
                    int bottom = readShort( is ) * ySign;
                    int right = (int)(readShort( is ) * xSign * scaleXY);
                    int top = readShort( is ) * ySign;
                    int left = (int)(readShort( is ) * xSign * scaleXY);
                    mr.addElement( left );
                    mr.addElement( top );
                    mr.addElement( right );
                    mr.addElement( bottom );
                    mr.addElement( el_width );
                    mr.addElement( el_height );
                    records.add( mr );
                }
                break;

            case WMFConstants.META_ARC:
            case WMFConstants.META_PIE:
                {
                    mr.numPoints = recSize;
                    mr.functionId = functionId;

                    int yend = readShort( is ) * ySign;
                    int xend = (int)(readShort( is ) * xSign * scaleXY);
                    int ystart = readShort( is ) * ySign;
                    int xstart = (int)(readShort( is ) * xSign * scaleXY);
                    int bottom = readShort( is ) * ySign;
                    int right = (int)(readShort( is ) * xSign * scaleXY);
                    int top = readShort( is ) * ySign;
                    int left = (int)(readShort( is ) * xSign * scaleXY);
                    mr.addElement( left );
                    mr.addElement( top );
                    mr.addElement( right );
                    mr.addElement( bottom );
                    mr.addElement( xstart );
                    mr.addElement( ystart );
                    mr.addElement( xend );
                    mr.addElement( yend );
                    records.add( mr );
                }
                break;

            // META_PATBLT added
            case WMFConstants.META_PATBLT :
                {
                    mr.numPoints = recSize;
                    mr.functionId = functionId;

                    int rop = readInt( is );
                    int height = readShort( is ) * ySign;
                    int width = (int)(readShort( is ) * xSign * scaleXY);
                    int left = (int)(readShort( is ) * xSign * scaleXY);
                    int top = readShort( is ) * ySign;

                    mr.addElement( rop );
                    mr.addElement( height );
                    mr.addElement( width );
                    mr.addElement( top );
                    mr.addElement( left );

                    records.add( mr );
                }
                break;

            case WMFConstants.META_SETBKMODE:
                {
                    mr.numPoints = recSize;
                    mr.functionId = functionId;

                    int mode = readShort( is );
                    mr.addElement( mode );
                    //if (recSize > 1) readShort( is );
                    if (recSize > 1) for (int i = 1; i < recSize; i++) readShort( is );
                    records.add( mr );
                }
                break;

            // UPDATED : META_SETROP2 added
            case WMFConstants.META_SETROP2:
                {
                    mr.numPoints = recSize;
                    mr.functionId = functionId;

                    // rop should always be a short, but it is sometimes an int...
                    int rop;
                    if (recSize == 1) rop = readShort( is );
                    else rop = readInt( is );

                    mr.addElement( rop );
                    records.add( mr );
                }
                break;
            // UPDATED : META_DIBSTRETCHBLT added
            case WMFConstants.META_DIBSTRETCHBLT:
                {
                    int mode = is.readInt() & 0xff;
                    int heightSrc = readShort( is ) * ySign;
                    int widthSrc = readShort( is ) * xSign;
                    int sy = readShort( is ) * ySign;
                    int sx = readShort( is ) * xSign;
                    int heightDst = readShort( is ) * ySign;
                    int widthDst = (int)(readShort( is ) * xSign * scaleXY);  
                    int dy = readShort( is ) * ySign;
                    int dx = (int)(readShort( is ) * xSign * scaleXY);  

                    int len = 2*recSize - 20;
                    byte[] bitmap = new byte[len];
                    for (int i = 0; i < len; i++) bitmap[i] = is.readByte();

                    mr = new MetaRecord.ByteRecord(bitmap);
                    mr.numPoints = recSize;
                    mr.functionId = functionId;
                    mr.addElement( mode );
                    mr.addElement( heightSrc );
                    mr.addElement( widthSrc );
                    mr.addElement( sy );
                    mr.addElement( sx );
                    mr.addElement( heightDst );
                    mr.addElement( widthDst );
                    mr.addElement( dy );
                    mr.addElement( dx );
                    records.add( mr );
                }
                break;
            case WMFConstants.META_STRETCHDIB: {
                    int mode = is.readInt() & 0xff;
                    int usage = readShort( is );                    
                    int heightSrc = readShort( is ) * ySign;
                    int widthSrc = readShort( is ) * xSign;
                    int sy = readShort( is ) * ySign;
                    int sx = readShort( is ) * xSign;
                    int heightDst = readShort( is ) * ySign;
                    int widthDst = (int)(readShort( is ) * xSign * scaleXY);  
                    int dy = readShort( is ) * ySign;                                        
                    int dx = (int)(readShort( is ) * xSign * scaleXY);  
                    
                    int len = 2*recSize - 22;
                    byte bitmap[] = new byte[len];                    
                    for (int i = 0; i < len; i++) bitmap[i] = is.readByte();
                    
                    mr = new MetaRecord.ByteRecord(bitmap);
                    mr.numPoints = recSize;
                    mr.functionId = functionId;                    
                    mr.addElement(mode);
                    mr.addElement(heightSrc);                    
                    mr.addElement(widthSrc);                                        
                    mr.addElement(sy);
                    mr.addElement(sx);
                    mr.addElement(heightDst); 
                    mr.addElement(widthDst); 
                    mr.addElement(dy);
                    mr.addElement(dx);                      
                    records.add( mr );                
            }
            break;                                                                                
            // UPDATED : META_DIBBITBLT added
            case WMFConstants.META_DIBBITBLT:
                {
                    int mode = is.readInt() & 0xff;
                    int sy = readShort( is );
                    int sx = readShort( is );
                    int hdc = readShort( is );
                    int height = readShort( is );
                    int width = (int)(readShort( is ) * xSign * scaleXY); 
                    int dy = readShort( is );
                    int dx = (int)(readShort( is ) * xSign * scaleXY);   

                    int len = 2*recSize - 18;
                    if (len > 0) {
                        byte[] bitmap = new byte[len];
                        for (int i = 0; i < len; i++)
                            bitmap[i] = is.readByte();
                        mr = new MetaRecord.ByteRecord(bitmap);
                        mr.numPoints = recSize;
                        mr.functionId = functionId;
                    } else {
                        // what does this mean?? len <= 0 ??
                        mr.numPoints = recSize;
                        mr.functionId = functionId;
                        for (int i = 0; i < len; i++) is.readByte();
                    }

                    mr.addElement( mode );
                    mr.addElement( height );
                    mr.addElement( width );
                    mr.addElement( sy );
                    mr.addElement( sx );
                    mr.addElement( dy );
                    mr.addElement( dx );
                    records.add( mr );
                }
                break;
            // UPDATED : META_CREATEPATTERNBRUSH added
            case WMFConstants.META_DIBCREATEPATTERNBRUSH:
                {
                    int type = is.readInt() & 0xff;
                    int len = 2*recSize - 4;
                    byte[] bitmap = new byte[len];
                    for (int i = 0; i < len; i++) bitmap[i] = is.readByte();

                    mr = new MetaRecord.ByteRecord(bitmap);
                    mr.numPoints = recSize;
                    mr.functionId = functionId;
                    mr.addElement( type );
                    records.add( mr );
                }
                break;
            default:
                mr.numPoints = recSize;
                mr.functionId = functionId;

                for ( int j = 0; j < recSize; j++ )
                    mr.addElement( readShort( is ) );

                records.add( mr );
                break;

            }

            numRecords++;
        }

        // sets the characteristics of the image if the file does not have an APM (in this case it is retrieved
        // from the viewport). This is only useful if one wants to retrieve informations about the file after
        // decoding it.
        if (! isAldus) {
            right = (int)vpX;
            left = (int)(vpX + vpW);
            top = (int)vpY;
            bottom = (int)(vpY + vpH);
        }                
        setReading( false );
        return true;
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
     * Returns the viewport x origin
     */
    public float getVpX() {
      return vpX;
    }

    /**
     * Returns the viewport y origin
     */
    public float getVpY() {
      return vpY;
    }

    /**
     * Sets the viewport x origin
     */
    public void setVpX(float newValue ) {
      vpX = newValue;
    }

    /**
     * Sets the viewport y origin
     */
    public void setVpY(float newValue ) {
      vpY = newValue;
    }

}
