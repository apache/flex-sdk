////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2006-2007 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.styles
{

/**
 * Simple interface to manipulate style modules.
 * You can cast an object to an IStyleModule type so that there is no dependency on the StyleModule
 * type in the loading application.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public interface IStyleModule
{
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  Creates and sets style declarations from the styles modules into the given
     *  style manager. This should be called after the style modules is created.
     *  
     *  @param styleManager The style manager where the style declarations will be 
     *  loaded into. The style declarations will be created relative to the this 
     *  style manager. The unload() function will unload styles from this style 
     *  manager. If null is passed the top-level style manager is used.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 4
     */
//    FIXME: (dloverin) Need to generate this in AST code before it can be 
//    uncommented.    
//    function setStyleDeclarations(styleManager:IStyleManager2):void;
    
    /**
     *  Unloads the style module.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function unload():void;
}

}
