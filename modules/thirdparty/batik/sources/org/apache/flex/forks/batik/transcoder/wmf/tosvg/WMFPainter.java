/*

   Copyright 2001-2004  The Apache Software Foundation 

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.

 */package org.apache.flex.forks.batik.transcoder.wmf.tosvg;

import java.awt.BasicStroke;
import java.awt.Color;
import java.awt.Font;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.Polygon;
import java.awt.Shape;
import java.awt.font.FontRenderContext;
import java.awt.font.TextLayout;
import java.awt.geom.AffineTransform;
import java.awt.geom.GeneralPath;
import java.awt.geom.Point2D;
import java.io.BufferedInputStream;
import java.util.Stack;
import java.util.Vector;

import org.apache.flex.forks.batik.transcoder.wmf.WMFConstants;

/**
  * Core class for rendering the WMF image. It is able to render a
  * WMF file in a <tt>Graphics</tt> object.
  *
  *
  * @version $Id: WMFPainter.java,v 1.11 2004/08/18 07:15:47 vhardy Exp $
  * @author <a href="mailto:luano@asd.ie">Luan O'Carroll</a>
  */
public class WMFPainter {
    private static final String WMF_FILE_EXTENSION = ".wmf";

    /**
     * Size of the buffer used for reading input WMF files
     */
    private static final int INPUT_BUFFER_SIZE = 30720;

    private static BasicStroke solid
        = new BasicStroke( 1.0f,
                           BasicStroke.CAP_BUTT,
                           BasicStroke.JOIN_ROUND );

    /**
     * Basic constructor, initializes the storage.
     */
    public WMFPainter(WMFRecordStore currentStore) {
        setRecordStore(currentStore);
    }

    /**
     * Renders the WMF image(s).
     */
    public void paint( Graphics g ) {
        // Objects on DC stack;
        int           fontHeight = 10;
        int           fontAngle = 0;
        int           penWidth = 0;
        int           startX = 0;
        int           startY = 0;
        int           brushObject = -1;
        int           penObject = -1;
        int           fontObject = -1;
        Color         frgdColor;
        Color         bkgdColor;
        Font          font = null;
        int           vpX, vpY, vpW, vpH;
        Stack         dcStack = new Stack();

        int numRecords = currentStore.getNumRecords();
        int numObjects = currentStore.getNumObjects();
        vpX = currentStore.getVpX();
        vpY = currentStore.getVpY();
        vpW = currentStore.getVpW();
        vpH = currentStore.getVpH();

        if ( !currentStore.isReading()) {
            GdiObject gdiObj;
            int gdiIndex;
            g.setPaintMode();

            brushObject = -1;
            penObject = -1;
            fontObject = -1;
            frgdColor = null;
            bkgdColor = null;
            for ( int i = 0; i < numObjects; i++ ) {
                gdiObj = currentStore.getObject( i );
                gdiObj.Clear();
            }

            int w = vpW;
            int h = vpH;

            g.setColor( Color.white );
            g.fillRect( 0, 0, w, h );
            g.setColor( Color.black );

            double scaleX = (double)w / vpW;
            double scaleY = (double)h / vpH;

            for ( int iRec = 0; iRec < numRecords; iRec++ ) {
                MetaRecord mr = currentStore.getRecord( iRec );

                switch ( mr.functionId ) {
                case WMFConstants.META_SETWINDOWORG:
                    currentStore.setVpX( vpX = -mr.ElementAt( 0 ).intValue());
                    currentStore.setVpY( vpY = -mr.ElementAt( 1 ).intValue());
                    break;

                case WMFConstants.META_SETWINDOWORG_EX: // ???? LOOKS SUSPICIOUS
                case WMFConstants.META_SETWINDOWEXT:
                    currentStore.setVpW( vpW = mr.ElementAt( 0 ).intValue());
                    currentStore.setVpH( vpH = mr.ElementAt( 1 ).intValue());
                    scaleX = (double)w / vpW;
                    scaleY = (double)h / vpH;

                    // Handled in the read function.
                    break;

                case WMFConstants.META_SETVIEWPORTORG:
                case WMFConstants.META_SETVIEWPORTEXT:
                case WMFConstants.META_OFFSETWINDOWORG:
                case WMFConstants.META_SCALEWINDOWEXT:
                case WMFConstants.META_OFFSETVIEWPORTORG:
                case WMFConstants.META_SCALEVIEWPORTEXT:
                    break;


                case WMFConstants.META_SETPOLYFILLMODE:
                    break;

                case WMFConstants.META_CREATEPENINDIRECT:
                    {
                        int objIndex = 0;
                        try {
                            objIndex = mr.ElementAt( 5 ).intValue();
                        }
                        catch ( Exception e ) {}
                        int penStyle = mr.ElementAt( 0 ).intValue();
                        Color newClr;
                        if ( penStyle == 5 ) {
                            newClr = new Color( 255, 255, 255 );
                            objIndex = numObjects + 8;
                            addObjectAt( currentStore, NULL_PEN, newClr, objIndex );
                        }
                        else {
                            newClr = new Color( mr.ElementAt( 1 ).intValue(),
                                                mr.ElementAt( 2 ).intValue(),
                                                mr.ElementAt( 3 ).intValue());
                            addObjectAt( currentStore, PEN, newClr, objIndex );
                        }
                        penWidth = mr.ElementAt( 4 ).intValue();
                    }
                    break;

                case WMFConstants.META_CREATEBRUSHINDIRECT:
                    {
                        int objIndex = 0;
                        try {
                            objIndex = mr.ElementAt( 5 ).intValue();
                        }
                        catch ( Exception e ) {}
                        int brushStyle = mr.ElementAt( 0 ).intValue();
                        if ( brushStyle == 0 ) {
                            addObjectAt(currentStore, BRUSH,
                                        new Color(mr.ElementAt( 1 ).intValue(),
                                                  mr.ElementAt( 2 ).intValue(),
                                                  mr.ElementAt( 3 ).intValue()),
                                        objIndex );
                        }
                        else
                            addObjectAt( currentStore, NULL_BRUSH, new Color( 0,0,0 ), objIndex );
                    }
                    break;

                case WMFConstants.META_CREATEFONTINDIRECT:
                    {
                        int style =(mr.ElementAt( 1 ).intValue() > 0 ? Font.ITALIC : Font.PLAIN );
                        style |=   (mr.ElementAt( 2 ).intValue() > 400 ? Font.BOLD : Font.PLAIN );

                        int size = (int)( scaleY * ( mr.ElementAt( 0 ).intValue()));
                        String face = ((StringRecord)mr).text;
                        if ( size < 0 )
                            size = (int)(size * -1.3 );
                        int objIndex = 0;
                        try {
                            objIndex = mr.ElementAt( 3 ).intValue();
                        }
                        catch ( Exception e ) {}
                        fontHeight = size;
                        //fontAngle = mr.ElementAt( 5 ).intValue();
                        //if ( fontAngle > 0 )
                        //  size = ( size *12 ) / 10;
                        addObjectAt( currentStore, FONT, font = new Font( face, style, size ), objIndex );
                    }
                    break;

                case WMFConstants.META_DIBCREATEPATTERNBRUSH:
                case WMFConstants.META_CREATEBRUSH:
                case WMFConstants.META_CREATEPATTERNBRUSH:
                case WMFConstants.META_CREATEBITMAPINDIRECT:
                case WMFConstants.META_CREATEBITMAP:
                case WMFConstants.META_CREATEREGION:
                case WMFConstants.META_CREATEPALETTE:
                    addObjectAt( currentStore, PALETTE, new Integer( 0 ), 0 );
                    break;

                case WMFConstants.META_SELECTPALETTE:
                case WMFConstants.META_REALIZEPALETTE:
                case WMFConstants.META_ANIMATEPALETTE:
                case WMFConstants.META_SETPALENTRIES:
                case WMFConstants.META_RESIZEPALETTE:
                    break;

                case WMFConstants.META_SELECTOBJECT:
                    gdiIndex = mr.ElementAt( 0 ).intValue();
                    if (( gdiIndex & 0x80000000 ) != 0 ) // Stock Object
                        break;
                    if ( gdiIndex >= numObjects ) {
                        gdiIndex -= numObjects;
                        switch ( gdiIndex ) {
                        case WMFConstants.META_OBJ_NULL_BRUSH:
                            brushObject = -1;
                            break;
                        case WMFConstants.META_OBJ_NULL_PEN:
                            penObject = -1;
                            break;
                        case WMFConstants.META_OBJ_WHITE_BRUSH:
                        case WMFConstants.META_OBJ_LTGRAY_BRUSH:
                        case WMFConstants.META_OBJ_GRAY_BRUSH:
                        case WMFConstants.META_OBJ_DKGRAY_BRUSH:
                        case WMFConstants.META_OBJ_BLACK_BRUSH:
                        case WMFConstants.META_OBJ_WHITE_PEN:
                        case WMFConstants.META_OBJ_BLACK_PEN:
                        case WMFConstants.META_OBJ_OEM_FIXED_FONT:
                        case WMFConstants.META_OBJ_ANSI_FIXED_FONT:
                        case WMFConstants.META_OBJ_ANSI_VAR_FONT:
                        case WMFConstants.META_OBJ_SYSTEM_FONT:
                        case WMFConstants.META_OBJ_DEVICE_DEFAULT_FONT:
                        case WMFConstants.META_OBJ_DEFAULT_PALETTE:
                        case WMFConstants.META_OBJ_SYSTEM_FIXED_FONT:
                            break;
                        }
                        break;
                    }
                    gdiObj = currentStore.getObject( gdiIndex );
                    if ( !gdiObj.used )
                        break;
                    switch( gdiObj.type ) {
                    case PEN:
                        g.setColor( (Color)gdiObj.obj );
                        penObject = gdiIndex;
                        break;
                    case BRUSH:
                        g.setColor( (Color)gdiObj.obj );
                        brushObject = gdiIndex;
                        break;
                    case FONT:
                        g.setFont( font = (Font)gdiObj.obj );
                        fontObject = gdiIndex;
                        break;
                    case NULL_PEN:
                        penObject = -1;
                        break;
                    case NULL_BRUSH:
                        brushObject = -1;
                        break;
                    }
                    break;

                case WMFConstants.META_DELETEOBJECT:
                    gdiIndex = mr.ElementAt( 0 ).intValue();
                    gdiObj = currentStore.getObject( gdiIndex );
                    if ( gdiIndex == brushObject )
                        brushObject = -1;
                    else if ( gdiIndex == penObject )
                        penObject = -1;
                    else if ( gdiIndex == fontObject )
                        fontObject = -1;
                    gdiObj.Clear();
                    break;

                case WMFConstants.META_POLYPOLYGON:
                    {
                      int numPolygons = mr.ElementAt( 0 ).intValue();
                      int[] pts = new int[ numPolygons ];
                      for ( int ip = 0; ip < numPolygons; ip++ )
                          pts[ ip ] = mr.ElementAt( ip + 1 ).intValue();

                      GeneralPath gp = new GeneralPath();
                      int offset = numPolygons+1;
                      for ( int j = 0; j < numPolygons; j++ ) {
                          int count = pts[ j ];
                          int[] xpts = new int[ count ];
                          int[] ypts = new int[ count ];
                          for ( int k = 0; k < count; k++ ) {
                              xpts[k] = (int)(  scaleX * ( vpX + mr.ElementAt( offset + k*2 ).intValue()));
                              ypts[k] = (int)( scaleY * ( vpY + mr.ElementAt( offset + k*2+1 ).intValue()));
                          }
                          offset += count;
                          Polygon p = new Polygon(xpts, ypts, count);
                          gp.append( p, true );
                      }
                      if ( brushObject >= 0 ) {
                          setBrushColor( currentStore, g, brushObject );
                          ( (Graphics2D) g).fill(gp);
                      }
                      setPenColor( currentStore, g, penObject );
                      ( (Graphics2D) g).draw(gp);
                    }
                    break;

                case WMFConstants.META_POLYGON:
                    {
                        int count = mr.ElementAt( 0 ).intValue();
                        int[] _xpts = new int[ count+1 ];
                        int[] _ypts = new int[ count+1 ];
                        for ( int k = 0; k < count; k++ ) {
                            _xpts[k] = (int)( scaleX * ( vpX + mr.ElementAt( k*2+1 ).intValue()));
                            _ypts[k] = (int)( scaleY * ( vpY + mr.ElementAt( k*2+2 ).intValue()));
                        }
                        _xpts[count] = _xpts[0];
                        _ypts[count] = _ypts[0];
                        if ( brushObject >= 0 ) {
                            setBrushColor( currentStore, g, brushObject );
                            g.fillPolygon( _xpts, _ypts, count );
                        }
                        setPenColor( currentStore, g, penObject );
                        g.drawPolygon( _xpts, _ypts, count+1 );
                    }
                    break;

                case WMFConstants.META_MOVETO:
                    startX = (int)( scaleX * ( vpX + mr.ElementAt( 0 ).intValue()));
                    startY = (int)( scaleY * ( vpY + mr.ElementAt( 1 ).intValue()));
                    break;

                case WMFConstants.META_LINETO:
                    {
                        int endX = (int)( scaleX * ( vpX + mr.ElementAt( 0 ).intValue()));
                        int endY = (int)( scaleY * ( vpY + mr.ElementAt( 1 ).intValue()));
                        setPenColor( currentStore, g, penObject );
                        g.drawLine( startX, startY, endX, endY );
                        startX = endX;
                        startY = endY;
                    }
                    break;

                case WMFConstants.META_POLYLINE:
                    {
                        setPenColor( currentStore, g, penObject );
                        int count = mr.ElementAt( 0 ).intValue();
                        int endX, endY;
                        int _startX, _startY;
                        _startX = (int)( scaleX * ( vpX + mr.ElementAt( 1 ).intValue()));
                        _startY = (int)( scaleY * ( vpY + mr.ElementAt( 2 ).intValue()));
                        for ( int j = 1; j < count; j++ ) {
                            endX = (int)( scaleX * ( vpX + mr.ElementAt( j*2+1 ).intValue()));
                            endY = (int)( scaleY * ( vpY + mr.ElementAt( j*2+2 ).intValue()));
                            g.drawLine( _startX, _startY, endX, endY );
                            _startX = endX;
                            _startY = endY;
                        }
                    }
                    break;

                case WMFConstants.META_RECTANGLE:
                    {
                        int x1, y1, x2, y2;
                        x1 = (int)( scaleX * ( vpX + mr.ElementAt( 0 ).intValue()));
                        x2 = (int)( scaleX * ( vpX + mr.ElementAt( 2 ).intValue()));
                        y1 = (int)( scaleY * ( vpY + mr.ElementAt( 1 ).intValue()));
                        y2 = (int)( scaleY * ( vpY + mr.ElementAt( 3 ).intValue()));

                        if ( brushObject >= 0 ) {
                            setBrushColor( currentStore, g, brushObject );
                            g.fillRect( x1, y1, x2-x1-1, y2-y1-1 );
                        }
                        setPenColor( currentStore, g, penObject );
                        g.drawRect( x1, y1, x2-x1-1, y2-y1-1 );
                    }
                    break;

                case WMFConstants.META_ROUNDRECT:
                    {
                        int x1, y1, x2, y2, x3, y3;
                        x1 = (int)( scaleX * ( vpX + mr.ElementAt( 0 ).intValue()));
                        x2 = (int)( scaleX * ( vpX + mr.ElementAt( 2 ).intValue()));
                        x3 = (int)( scaleX * ( mr.ElementAt( 4 ).intValue()));
                        y1 = (int)( scaleY * ( vpY + mr.ElementAt( 1 ).intValue()));
                        y2 = (int)( scaleY * ( vpY + mr.ElementAt( 3 ).intValue()));
                        y3 = (int)( scaleY * ( mr.ElementAt( 5 ).intValue()));

                        if ( brushObject >= 0 ) {
                            setBrushColor( currentStore, g, brushObject );
                            g.fillRoundRect( x1, y1, x2-x1, y2-y1, x3, y3 );
                        }
                        setPenColor( currentStore, g, penObject );
                        g.drawRoundRect( x1, y1, x2-x1, y2-y1, x3, y3 );
                    }
                    break;

                case WMFConstants.META_ELLIPSE:
                    {
                        int x1, y1, x2, y2;
                        x1 = (int)( scaleX * ( vpX + mr.ElementAt( 0 ).intValue()));
                        x2 = (int)( scaleX * ( vpX + mr.ElementAt( 2 ).intValue()));
                        y1 = (int)( scaleY * ( vpY + mr.ElementAt( 1 ).intValue()));
                        y2 = (int)( scaleY * ( vpY + mr.ElementAt( 3 ).intValue()));

                        if ( brushObject >= 0 ) {
                            setBrushColor( currentStore, g, brushObject );
                            g.fillOval( x1, y1, x2-x1, y2-y1 );
                        }
                        setPenColor( currentStore, g, penObject );
                        g.drawOval( x1, y1, x2-x1-1, y2-y1-1 );
                    }
                    break;

                case WMFConstants.META_SETTEXTCOLOR:
                    frgdColor = new Color(mr.ElementAt( 0 ).intValue(),
                                          mr.ElementAt( 1 ).intValue(),
                                          mr.ElementAt( 2 ).intValue());
                    break;

                case WMFConstants.META_SETBKCOLOR:
                    bkgdColor = new Color(mr.ElementAt( 0 ).intValue(),
                                          mr.ElementAt( 1 ).intValue(),
                                          mr.ElementAt( 2 ).intValue());
                    break;

                case WMFConstants.META_EXTTEXTOUT:
                case WMFConstants.META_TEXTOUT:
                case WMFConstants.META_DRAWTEXT:
                    try
                        {
                            Graphics2D g2 = (Graphics2D)g;
                            int x, y;
                            x = (int)( scaleX * ( vpX + mr.ElementAt( 0 ).intValue()));
                            y = (int)( fontHeight + scaleY * ( vpY + mr.ElementAt( 1 ).intValue()));
                            if ( frgdColor != null )
                                g.setColor( frgdColor );
                            else
                                g.setColor( Color.black );
                            StringRecord sr = (StringRecord)mr;

                            FontRenderContext frc = g2.getFontRenderContext();

                            Point2D.Double pen = new Point2D.Double( 0, 0 );
                            GeneralPath gp = new GeneralPath( GeneralPath.WIND_NON_ZERO );
                            TextLayout layout = new TextLayout( sr.text, font, frc );
                            pen.y += layout.getAscent();

                            if (( fontAngle != 0 ) || sr.text.startsWith("Sono una scala verticale di prevalenza") ) {
                                AffineTransform at = new AffineTransform();
                                float height = (float)layout.getBounds().getHeight();

                                AffineTransform textAt = new AffineTransform();
                                textAt.translate( x, y);
                                textAt.rotate(Math.toRadians(270));
                                textAt.translate(0, height);
                                Shape shape = layout.getOutline(textAt);
                                gp.append( at.createTransformedShape( shape )/*layout.getOutline( null ))*/, false );
                                g2.draw( shape );
                            }
                            else
                                g.drawString( sr.text, x, y );
                        }
                    catch ( Exception e )
                        {
                        }
                    break;

                case WMFConstants.META_ARC:
                case WMFConstants.META_PIE:
                    {
                        int x1, y1, x2, y2, x3, y3, x4, y4;
                        x1 = (int)( scaleX * ( vpX + mr.ElementAt( 0 ).intValue()));
                        x2 = (int)( scaleX * ( vpX + mr.ElementAt( 2 ).intValue()));
                        x3 = (int)( scaleX * ( mr.ElementAt( 4 ).intValue()));
                        x4 = (int)( scaleX * ( mr.ElementAt( 6 ).intValue()));
                        y1 = (int)( scaleY * ( vpY + mr.ElementAt( 1 ).intValue()));
                        y2 = (int)( scaleY * ( vpY + mr.ElementAt( 3 ).intValue()));
                        y3 = (int)( scaleY * ( mr.ElementAt( 5 ).intValue()));
                        y4 = (int)( scaleY * ( mr.ElementAt( 7 ).intValue()));
                        setBrushColor( currentStore, g, brushObject );

                        int mx = x1+(x2-x1)/2;
                        int my = y1+(y2-y1)/2;
                        int startAngle = (int)Math.atan( (y3-my)/(x3-mx));
                        int endAngle = (int)Math.atan( (y4-my)/(x4-mx));
                        if ( mr.functionId == 0x0817 )
                            g.drawArc( x1, y1, x2-x1, y2-y1, startAngle, endAngle );
                        else
                            g.fillArc( x1, y1, x2-x1, y2-y1, startAngle, endAngle );

                    }
                    break;


                case WMFConstants.META_CHORD:
                    break;

                case WMFConstants.META_SAVEDC:
                    dcStack.push( new Integer( penWidth ));
                    dcStack.push( new Integer( startX ));
                    dcStack.push( new Integer( startY ));
                    dcStack.push( new Integer( brushObject ));
                    dcStack.push( new Integer( penObject ));
                    dcStack.push( new Integer( fontObject ));
                    dcStack.push( frgdColor );
                    dcStack.push( bkgdColor );
                    break;

                case WMFConstants.META_RESTOREDC:
                    bkgdColor = (Color)dcStack.pop();
                    frgdColor = (Color)dcStack.pop();
                    fontObject = ((Integer)(dcStack.pop())).intValue();
                    penObject = ((Integer)(dcStack.pop())).intValue();
                    brushObject = ((Integer)(dcStack.pop())).intValue();
                    startY = ((Integer)(dcStack.pop())).intValue();
                    startX = ((Integer)(dcStack.pop())).intValue();
                    penWidth = ((Integer)(dcStack.pop())).intValue();
                    break;

                case WMFConstants.META_POLYBEZIER16:
                    try
                        {
                            Graphics2D g2 = (Graphics2D)g;
                            setPenColor( currentStore, g, penObject );

                            int pointCount = mr.ElementAt( 0 ).intValue();
                            int bezierCount = ( pointCount-1 ) / 3;
                            float endX, endY;
                            float cp1X, cp1Y;
                            float cp2X, cp2Y;
                            float _startX, _startY;
                            _startX = (float)( scaleX * ( vpX + mr.ElementAt( 1 ).intValue()));
                            _startY = (float)( scaleY * ( vpY + mr.ElementAt( 2 ).intValue()));

                            GeneralPath gp = new GeneralPath( GeneralPath.WIND_NON_ZERO );
                            gp.moveTo( _startX, _startY );

                            for ( int j = 0; j < bezierCount; j++ ) {
                                cp1X = (float)( scaleX * ( vpX + mr.ElementAt( j*6+3 ).intValue()));
                                cp1Y = (float)( scaleY * ( vpY + mr.ElementAt( j*6+4 ).intValue()));

                                cp2X = (float)( scaleX * ( vpX + mr.ElementAt( j*6+5 ).intValue()));
                                cp2Y = (float)( scaleY * ( vpY + mr.ElementAt( j*6+6 ).intValue()));

                                endX = (float)( scaleX * ( vpX + mr.ElementAt( j*6+7 ).intValue()));
                                endY = (float)( scaleY * ( vpY + mr.ElementAt( j*6+8 ).intValue()));

                                gp.curveTo( cp1X, cp1Y, cp2X, cp2Y, endX, endY );
                                _startX = endX;
                                _startY = endY;
                            }
                                //gp.closePath();
                            g2.setStroke( solid );
                            g2.draw( gp );
                        }
                    catch ( Exception e ) {
                        System.out.println( "Unable to draw static text as a 2D graphics context is required" );
                    }
                    break;

                case WMFConstants.META_EXCLUDECLIPRECT:
                case WMFConstants.META_INTERSECTCLIPRECT:

                case WMFConstants.META_OFFSETCLIPRGN:
                case WMFConstants.META_SELECTCLIPREGION:

                case WMFConstants.META_SETBKMODE:
                case WMFConstants.META_SETMAPMODE:
                case WMFConstants.META_SETROP2:
                case WMFConstants.META_SETRELABS:
                case WMFConstants.META_SETSTRETCHBLTMODE:
                case WMFConstants.META_SETTEXTCHAREXTRA:
                case WMFConstants.META_SETTEXTJUSTIFICATION:
                case WMFConstants.META_FLOODFILL:
                case WMFConstants.META_PATBLT:
                case WMFConstants.META_SETPIXEL:
                case WMFConstants.META_BITBLT:
                case WMFConstants.META_STRETCHBLT:
                case WMFConstants.META_ESCAPE:
                case WMFConstants.META_FILLREGION:
                case WMFConstants.META_FRAMEREGION:
                case WMFConstants.META_INVERTREGION:
                case WMFConstants.META_PAINTREGION:
                case WMFConstants.META_SETTEXTALIGN:
                case WMFConstants.META_SETMAPPERFLAGS:
                case WMFConstants.META_SETDIBTODEV:
                case WMFConstants.META_DIBBITBLT:
                case WMFConstants.META_DIBSTRETCHBLT:
                case WMFConstants.META_STRETCHDIB:
                default:
                    {
                        //int count = sizeof( MetaFunctions ) / sizeof( EMFMETARECORDS );
                        //for ( int i = 0; i < count; i++ ) {
                        //  if ( MetaFunctions[ i ].value == lpMFR->rdFunction ) {
                        //  os << MetaFunctions[ i ].szFuncName;
                        //  break;
                        //  }
                        //}
                    }
                    //os << " ------Unknown Function------";
                    break;
                }
            }

        }
    }

    private void setPenColor( WMFRecordStore currentStore, Graphics g, int penObject) {
        if ( penObject >= 0 ) {
            GdiObject gdiObj = currentStore.getObject( penObject );
            g.setColor( (Color)gdiObj.obj );
            penObject = -1;
        }
    }

    private void setBrushColor( WMFRecordStore currentStore, Graphics g, int brushObject) {
        if ( brushObject >= 0 ) {
            GdiObject gdiObj = currentStore.getObject( brushObject );
            g.setColor( (Color)gdiObj.obj );
            brushObject = -1;
        }
    }

    /**
     * Sets the WMFRecordStore this WMFPainter should use to render
     */
    public void setRecordStore(WMFRecordStore currentStore){
        if(currentStore == null){
            throw new IllegalArgumentException();
        }

        this.currentStore = currentStore;
    }

    /**
     * Returns the WMFRecordStore this WMFPainter renders
     */
    public WMFRecordStore getRecordStore(){
        return currentStore;
    }

    private void addObject( WMFRecordStore currentStore, int type, Object obj ) {
        currentStore.addObject( type, obj );
    }

    private void addObjectAt( WMFRecordStore currentStore, int type, Object obj, int idx ) {
        currentStore.addObjectAt( type, obj, idx );
    }

    public static final int PEN = 1;
    public static final int BRUSH = 2;
    public static final int FONT = 3;
    public static final int NULL_PEN = 4;
    public static final int NULL_BRUSH = 5;
    public static final int PALETTE = 6;

    private WMFRecordStore currentStore;
    transient private boolean bReadingWMF = true;
    transient private BufferedInputStream bufStream = null;

}


class MetaRecord /*implements Serializable*/
{
        public int	functionId;
        public int	numPoints;

        private Vector	ptVector;

        public MetaRecord()
        {
                ptVector = new Vector();
        }

        public void EnsureCapacity( int cc )
        {
                ptVector.ensureCapacity( cc );
        }

        public void AddElement( Object obj )
        {
                ptVector.addElement( obj );
        }

        public Integer ElementAt( int offset )
        {
                return (Integer)ptVector.elementAt( offset );
        }
}

class StringRecord extends MetaRecord /*implements Serializable*/
{
        public String	text;

        public StringRecord( String newText )
        {
                text = new String( newText );
        }
}

class GdiObject /*implements Serializable*/
{
        GdiObject( int _id, boolean _used )
        {
        id = _id;
        used = _used;
        type = 0;
        }

        public void Clear()
        {
        used = false;
        type = 0;
        }

        public void Setup( int _type, Object _obj )
        {
        obj = _obj;
        type = _type;
        used = true;
        }

        int id;
        boolean used;
        Object obj;
        int type = 0;
}


