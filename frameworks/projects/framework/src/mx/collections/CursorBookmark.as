////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2005-2007 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.collections
{

/**
 *  Encapsulates the positional aspects of a cursor in an 
 *  <code>ICollectionView</code>.  Bookmarks are used to return a cursor to 
 *  an absolute position within the <code>ICollectionView</code>.
 *
 *  @see mx.collections.IViewCursor#bookmark
 *  @see mx.collections.IViewCursor#seek()
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class CursorBookmark
{
    include "../core/Version.as";

    private static var _first:CursorBookmark;
    private static var _last:CursorBookmark;
    private static var _current:CursorBookmark;
    
    /**
     *  A bookmark for the first item in an <code>ICollectionView</code>.
     *
     *  @return The bookmark to the first item.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public static function get FIRST():CursorBookmark
    {
        if (!_first)
            _first = new CursorBookmark("${F}");
        return _first;
    }
    
    /**
     *  A bookmark for the last item in an <code>ICollectionView</code>.
     * If the view has no items, the cursor is at this bookmark.
     *
     *  @return The bookmark to the last item.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public static function get LAST():CursorBookmark
    {
        if (!_last)
            _last = new CursorBookmark("${L}");
        return _last;
    }
    
    /**
     *  A bookmark representing the current item for the <code>IViewCursor</code> in
     *  an <code>ICollectionView</code>.
     *
     *  @return The bookmark to the current item.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public static function get CURRENT():CursorBookmark
    {
        if (!_current)
            _current = new CursorBookmark("${C}");
        return _current;
    }
    
    /**
     *  Creates a new instance of a bookmark with the specified value.
     *
     *  @param value The value of this bookmark.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function CursorBookmark(value:Object)
    {
        super();
        _value = value;
    }
    
    //--------------------------------------------------------------------------
    // 
    // Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    // value
    //----------------------------------

    private var _value:Object;
    
    /**
     *  The underlying marker representation of the bookmark.
     *  This value is generally understood only by the <code>IViewCursor</code>
     *  or <code>ICollectionView</code> implementation.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get value():Object
    {
        return _value;
    }
    
    //--------------------------------------------------------------------------
    // 
    // Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Gets the approximate index of the item represented by this bookmark
     *  in its view. If the item has been paged out, this method could throw an 
     *  ItemPendingError.
     *  
     *  @return The index of the item. If the item is not in the current view, this method returns
     *  -1. This method also returns -1 if index-based location is not possible.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function getViewIndex():int
    {
        return -1;
    }
}

}
