////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2010 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package spark.components.supportClasses
{
import spark.components.supportClasses.ItemRenderer;

public class GridItemRenderer extends ItemRenderer
{
    include "../../core/Version.as";    

    public function GridItemRenderer()
    {
        super();
    }
    
    public var column:GridColumn;
    
}
}