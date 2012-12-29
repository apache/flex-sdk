<!-- ....................................................................... -->
<!-- SVG 1.1 Basic Text Module ............................................. -->
<!-- file: svg-basic-text.mod

     This is SVG, a language for describing two-dimensional graphics in XML.
     Copyright 2001, 2002 W3C (MIT, INRIA, Keio), All Rights Reserved.
     Revision: $Id: svg-basic-text.mod 201058 2002-11-13 09:51:12Z vhardy $

     This DTD module is identified by the PUBLIC and SYSTEM identifiers:

        PUBLIC "-//W3C//ELEMENTS SVG 1.1 Basic Text//EN"
        SYSTEM "http://www.w3.org/Graphics/SVG/1.1/DTD/svg-basic-text.mod"

     ....................................................................... -->

<!-- Basic Text

        text, altGlyph, altGlyphDef, glyphRef

     This module declares markup to provide support for text.
-->

<!-- 'font-family' property/attribute value (i.e., list of fonts) -->
<!ENTITY % FontFamilyValue.datatype "CDATA" >

<!-- 'font-size' property/attribute value -->
<!ENTITY % FontSizeValue.datatype "CDATA" >

<!-- Qualified Names (Default) ......................... -->

<!ENTITY % SVG.text.qname "text" >
<!ENTITY % SVG.altGlyph.qname "altGlyph" >
<!ENTITY % SVG.altGlyphDef.qname "altGlyphDef" >
<!ENTITY % SVG.glyphRef.qname "glyphRef" >

<!-- Attribute Collections (Default) ................... -->

<!ENTITY % SVG.Core.attrib "" >
<!ENTITY % SVG.Conditional.attrib "" >
<!ENTITY % SVG.Style.attrib "" >
<!ENTITY % SVG.Paint.attrib "" >
<!ENTITY % SVG.Color.attrib "" >
<!ENTITY % SVG.Opacity.attrib "" >
<!ENTITY % SVG.Graphics.attrib "" >
<!ENTITY % SVG.Clip.attrib "" >
<!ENTITY % SVG.Mask.attrib "" >
<!ENTITY % SVG.Filter.attrib "" >
<!ENTITY % SVG.GraphicalEvents.attrib "" >
<!ENTITY % SVG.Cursor.attrib "" >
<!ENTITY % SVG.XLink.attrib "" >
<!ENTITY % SVG.External.attrib "" >

<!-- SVG.Text.class .................................... -->

<!ENTITY % SVG.Text.extra.class "" >

<!ENTITY % SVG.Text.class
    "| %SVG.text.qname; | %SVG.altGlyphDef.qname; %SVG.Text.extra.class;"
>

<!-- SVG.TextContent.class ............................. -->

<!ENTITY % SVG.TextContent.extra.class "" >

<!ENTITY % SVG.TextContent.class
    "| %SVG.altGlyph.qname; %SVG.TextContent.extra.class;"
>

<!-- SVG.Font.attrib ................................... -->

<!ENTITY % SVG.Font.extra.attrib "" >

<!ENTITY % SVG.Font.attrib
    "font-family %FontFamilyValue.datatype; #IMPLIED
     font-size %FontSizeValue.datatype; #IMPLIED
     font-style ( normal | italic | oblique | inherit ) #IMPLIED
     font-weight ( normal | bold | bolder | lighter | 100 | 200 | 300 | 400 |
                   500 | 600 | 700 | 800 | 900 | inherit ) #IMPLIED
     %SVG.Font.extra.attrib;"
>

<!-- text: Text Element ................................ -->

<!ENTITY % SVG.text.extra.content "" >

<!ENTITY % SVG.text.element "INCLUDE" >
<![%SVG.text.element;[
<!ENTITY % SVG.text.content
    "( #PCDATA | %SVG.Description.class; | %SVG.Animation.class;
       %SVG.TextContent.class; %SVG.Hyperlink.class;
       %SVG.text.extra.content; )*"
>
<!ELEMENT %SVG.text.qname; %SVG.text.content; >
<!-- end of SVG.text.element -->]]>

<!ENTITY % SVG.text.attlist "INCLUDE" >
<![%SVG.text.attlist;[
<!ATTLIST %SVG.text.qname;
    %SVG.Core.attrib;
    %SVG.Conditional.attrib;
    %SVG.Style.attrib;
    %SVG.Font.attrib;
    %SVG.Paint.attrib;
    %SVG.Color.attrib;
    %SVG.Opacity.attrib;
    %SVG.Graphics.attrib;
    %SVG.Clip.attrib;
    %SVG.Mask.attrib;
    %SVG.Filter.attrib;
    %SVG.GraphicalEvents.attrib;
    %SVG.Cursor.attrib;
    %SVG.External.attrib;
    x %Coordinates.datatype; #IMPLIED
    y %Coordinates.datatype; #IMPLIED
    rotate %Numbers.datatype; #IMPLIED
    transform %TransformList.datatype; #IMPLIED
>
<!-- end of SVG.text.attlist -->]]>

<!-- altGlyph: Alternate Glyph Element ................. -->

<!ENTITY % SVG.altGlyph.extra.content "" >

<!ENTITY % SVG.altGlyph.element "INCLUDE" >
<![%SVG.altGlyph.element;[
<!ENTITY % SVG.altGlyph.content
    "( #PCDATA %SVG.altGlyph.extra.content; )*"
>
<!ELEMENT %SVG.altGlyph.qname; %SVG.altGlyph.content; >
<!-- end of SVG.altGlyph.element -->]]>

<!ENTITY % SVG.altGlyph.attlist "INCLUDE" >
<![%SVG.altGlyph.attlist;[
<!ATTLIST %SVG.altGlyph.qname;
    %SVG.Core.attrib;
    %SVG.Conditional.attrib;
    %SVG.Style.attrib;
    %SVG.Font.attrib;
    %SVG.Paint.attrib;
    %SVG.Color.attrib;
    %SVG.Opacity.attrib;
    %SVG.Graphics.attrib;
    %SVG.Clip.attrib;
    %SVG.Mask.attrib;
    %SVG.Filter.attrib;
    %SVG.GraphicalEvents.attrib;
    %SVG.Cursor.attrib;
    %SVG.XLink.attrib;
    %SVG.External.attrib;
    glyphRef CDATA #IMPLIED
    format CDATA #IMPLIED
>
<!-- end of SVG.altGlyph.attlist -->]]>

<!-- altGlyphDef: Alternate Glyph Definition Element ... -->

<!ENTITY % SVG.altGlyphDef.extra.content "" >

<!ENTITY % SVG.altGlyphDef.element "INCLUDE" >
<![%SVG.altGlyphDef.element;[
<!ENTITY % SVG.altGlyphDef.content
    "( %SVG.glyphRef.qname;+ %SVG.altGlyphDef.extra.content; )"
>
<!ELEMENT %SVG.altGlyphDef.qname; %SVG.altGlyphDef.content; >
<!-- end of SVG.altGlyphDef.element -->]]>

<!ENTITY % SVG.altGlyphDef.attlist "INCLUDE" >
<![%SVG.altGlyphDef.attlist;[
<!ATTLIST %SVG.altGlyphDef.qname;
    %SVG.Core.attrib;
>
<!-- end of SVG.altGlyphDef.attlist -->]]>

<!-- glyphRef: Glyph Reference Element ................. -->

<!ENTITY % SVG.glyphRef.element "INCLUDE" >
<![%SVG.glyphRef.element;[
<!ENTITY % SVG.glyphRef.content "EMPTY" >
<!ELEMENT %SVG.glyphRef.qname; %SVG.glyphRef.content; >
<!-- end of SVG.glyphRef.element -->]]>

<!ENTITY % SVG.glyphRef.attlist "INCLUDE" >
<![%SVG.glyphRef.attlist;[
<!ATTLIST %SVG.glyphRef.qname;
    %SVG.Core.attrib;
    %SVG.Style.attrib;
    %SVG.Font.attrib;
    %SVG.XLink.attrib;
    glyphRef CDATA #IMPLIED
    format CDATA #IMPLIED
>
<!-- end of SVG.glyphRef.attlist -->]]>

<!-- end of svg-basic-text.mod -->
