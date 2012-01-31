////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2005-2010 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package spark.collections
{

import flash.errors.IllegalOperationError;
import flash.events.Event;
import flash.events.EventDispatcher;

import mx.collections.ISortField;
import mx.collections.errors.SortError;
import mx.core.FlexGlobals;
import mx.core.UIComponent;
import mx.managers.ISystemManager;
import mx.managers.SystemManager;
import mx.resources.IResourceManager;
import mx.resources.ResourceManager;
import mx.styles.AdvancedStyleClient;
import mx.utils.ObjectUtil;

import spark.globalization.SortingCollator;

[ResourceBundle("collections")]

//--------------------------------------
//  Styles
//--------------------------------------

/**
 *  The locale identifier that specifies the language, region, script
 *  and optionally other related tags and keys.
 *  The syntax of this identifier must follow the syntax defined
 *  by the Unicode Technical Standard #35 (for example, en-US, de-DE, zh-Hans-CN).
 * 
 *  <p>For browser based apps, the default locale is based on the language settings from the browser. 
 *  (Note that this is not the browser UI language that is available from Javascript, but rather is the list of 
 *  preferred locales for web pages that the user has set in the browser preferences.) For AIR applications, 
 *  the default UI locale is based on the user's system preferences.</p>
 * 
 *  @see http://www.unicode.org/reports/tr35/
 *
 *  @langversion 3.0
 *  @playerversion Flash 10.1
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
[Style(name="locale", type="String", inherit="yes")]

/**
 *  Provides the sorting information required to establish a sort on a field
 *  or property in a collection view.
 *
 *  SortField class is meant to be used with Sort class.
 *
 *  Typically the sort is defined for collections of complex items, that
 *  is items in which the sort is performed on properties of those objects.
 *  As in the following example:
 *
 *  <pre><code>
 *     var col:ICollectionView = new ArrayCollection();
 *     col.addItem({first:"Anders", last:"Dickerson"});
 *     var sort:Sort = new Sort();
 *     var sortfield:SortField = new SortField("first", true);
 *     sortfield.setStyle("locale", "en-US");
 *     sort.fields = [sortfield];
 *     col.sort = sort;
 *  </code></pre>
 *
 *  There are situations in which the collection contains simple items, like
 *  <code>String</code>, <code>Date</code>, <code>Boolean</code>, etc.
 *  In this case, sorting should be applied to the simple type directly.
 *  When constructing a sort for this situation only a single sort field is
 *  required and should not have a <code>name</code> specified.
 *  For example:
 *
 *  <pre><code>
 *     var col:ICollectionView = new ArrayCollection();
 *     col.addItem("California");
 *     col.addItem("Arizona");
 *     var sort:Sort = new Sort();
 *     var sortfield:SortField = new SortField(null, true);
 *     sortfield.setStyle("locale", "en-US");
 *     sort.fields = [sortfield];
 *     col.sort = sort;
 *  </code></pre>
 *
 *  <p>The default comparison provided by the <code>SortField</code> class 
 *  provides correct language specific
 *  sorting for strings. The language is selected by the setting the locale
 *  style on an instance of the class in one of the following ways:
 *  </p>
 *  <ul>
 *  <li>
 *  By using the class in an MXML declaration and inheriting the
 *  locale from the document that contains the declaration.
 *  </li>
 *  Example:
 *  <pre>
 *  &lt;fx:Declarations&gt; <br>
 *         &lt;s:SortField id="sf" /&gt; <br>
 *  &lt;/fx:Declarations&gt;
 *  </pre>
 *  <li>
 *  By using an MXML declaration and specifying the locale value
 *  in the list of assignments.
 *  </li>
 *  Example:
 *  <pre>
 *  &lt;fx:Declarations&gt; <br>
 *      &lt;s:SortField id="sf_SimplifiedChinese" locale="zh-Hans-CN" /&gt; <br>
 *  &lt;/fx:Declarations&gt;
 *  </pre>
 *  <li>
 *  Calling the <code>setStyle</code> method,
 *  e.g. <code>sf.setStyle("locale", "zh-Hans-CN")</code>
 *  </li>
 *  <li> 
 *  Inheriting the style from a <code>UIComponent</code> by calling the
 *  UIComponent's <code>addStyleClient()</code> method.
 *  </li>
 *  </ul>
 *  
 *  @mxml
 *
 *  <p>The <code>&lt;s:SortField&gt;</code> tag has the following attributes:</p>
 *
 *  <pre>
 *  &lt;s:SortField
 *  <b>Properties</b>
 *  compareFunction="<em>Internal compare function</em>"
 *  descending="false"
 *  name="null"
 *  numeric="null"
 *  /&gt;
 *  </pre>
 *
 *  @includeExample examples/SortExample1.mxml
 *  @includeExample examples/SortExample2.mxml
 * 
 *  @see mx.collections.ICollectionView
 *  @see spark.collections.Sort
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10.1
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
public class SortField extends AdvancedStyleClient implements ISortField
{
    include "../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor.
     *
     *  @param name The name of the property that this field uses for
     *              comparison.
     *              If the object is a simple type, pass <code>null</code>.
     *  @param descending Tells the comparator whether to arrange items in
     *              descending order.
     *  @param numeric Tells the comparator whether to compare sort items as
     *              numbers, instead of alphabetically.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function SortField(name:String = null,
                              descending:Boolean = false,
                              numeric:Object = null)
    {
        super();

        _name = name;
        _descending = descending;
        _numeric = numeric;
        _compareFunction = stringCompare;
    }

    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  Used for accessing localized Error messages.
     */
    private var resourceManager:IResourceManager =
                                    ResourceManager.getInstance();

    /**
     *  @private
     *  Cache for "locale" style.
     *
     *  The code needs be able to find out if the locale style has been changed
     *  from earlier.
     */
    private var localeStyle:* = undefined;

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    /**
    *  @inheritDoc
    * 
    *  @langversion 3.0
    *  @playerversion Flash 10.1
    *  @playerversion AIR 2.5
    *  @productversion Flex 4.5
    */
    public function get arraySortOnOptions():int
    {
        if (usingCustomCompareFunction
            || name == null
            || _compareFunction == xmlCompare
            || _compareFunction == dateCompare)
        {
            return -1;
        }
        var options:int = 0;
        if (descending) options |= Array.DESCENDING;
        if (numeric == true || _compareFunction == numericCompare) options |= Array.NUMERIC;
        return options;
    }

    //---------------------------------
    //  compareFunction
    //---------------------------------

    /**
     *  @private
     *  Storage for the compareFunction property.
     */
    private var _compareFunction:Function;

    [Inspectable(category="General")]

    /**
     *  The function that compares two items during a sort of items for the
     *  associated collection. If you specify a <code>compareFunction</code>
     *  property in an <code>ISort</code> object, Flex ignores any 
     *  <code>compareFunction</code> properties of the ISort's 
     *  <code>SortField</code> objects.
     * 
     *  <p>The compare function must have the following signature:</p>
     *
     *  <p><code>function myCompare(a:Object, b:Object):int</code></p>
     *
     *  <p>This function must return the following values:</p>
     *
     *   <ul>
     *        <li>-1, if the <code>Object a</code> should appear before the 
     *        <code>Object b</code> in the sorted sequence</li>
     *        <li>0, if the <code>Object a</code> equals the 
     *        <code>Object b</code></li>
     *        <li>1, if the <code>Object a</code> should appear after the 
     *        <code>Object b</code> in the sorted sequence</li>
     *  </ul>
     *
     *  <p>The default value is an internal compare function that can perform
     *  a string, numeric, or date comparison in ascending or descending order.
     *  The string comparison is performed using the locale (language,
     *  region and script) specific comparison method from the
     *  <code>SortingCollator</code> class.
     *  This class uses the locale style to determine a locale
     *  Specify your own function only if you need a need a custom comparison
     *  algorithm. This is normally only the case if a calculated field is
     *  used in a display.</p>
     *
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get compareFunction():Function
    {
        return _compareFunction;
    }

    /**
     *  @private
     */
    public function set compareFunction(c:Function):void
    {
        _compareFunction = c;
        _usingCustomCompareFunction = (c != null);
    }

    //---------------------------------
    //  descending
    //---------------------------------

    /**
     *  @private
     *  Storage for the descending property.
     */
    private var _descending:Boolean;

    [Inspectable(category="General")]
    [Bindable("descendingChanged")]

    /**
     *  @inheritDoc
     *
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get descending():Boolean
    {
        return _descending;
    }

    /**
     *  @private
     */
    public function set descending(value:Boolean):void
    {
        if (_descending != value)
        {
            _descending = value;
            dispatchEvent(new Event("descendingChanged"));
        }
    }

    //---------------------------------
    //  name
    //---------------------------------

    /**
     *  @private
     *  Storage for the name property.
     */
    private var _name:String;

    [Inspectable(category="General")]
    [Bindable("nameChanged")]

    /**
     *  @inheritDoc
     *
     *  @default null
     *
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get name():String
    {
        return _name;
    }

    /**
     *  @private
     */
    public function set name(n:String):void
    {
        _name = n;
        dispatchEvent(new Event("nameChanged"));
    }

    //---------------------------------
    //  numeric
    //---------------------------------

    /**
     *  @private
     *  Storage for the numeric property.
     */
    private var _numeric:Object;

    [Inspectable(category="General")]
    [Bindable("numericChanged")]

    /**
     *  @inheritDoc
     *
     *  @default null
     *
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get numeric():Object
    {
        return _numeric;
    }

    /**
     *  @private
     */
    public function set numeric(value:Object):void
    {
        if (_numeric != value)
        {
            _numeric = value;
            dispatchEvent(new Event("numericChanged"));
        }
    }

    //---------------------------------
    //  usingCustomCompareFunction
    //---------------------------------

    private var _usingCustomCompareFunction:Boolean;

    /**
     *  @inheritDoc
     *
     *  @see @compareFunction
     *
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get usingCustomCompareFunction():Boolean
    {
        return _usingCustomCompareFunction;
    }

    //--------------------------------------------------------------------------
    //
    //  Overridden Methods
    //
    //--------------------------------------------------------------------------

    /**
    *  @private
    */
    override public function getStyle(styleProp:String):*
    {
        if (styleProp != "locale")
            return super.getStyle(styleProp);

        if ((localeStyle !== undefined) && (localeStyle !== null))
            return localeStyle;

        if (styleParent)
            return styleParent.getStyle(styleProp);

        if (FlexGlobals.topLevelApplication)
            return FlexGlobals.topLevelApplication.getStyle(styleProp);

        return undefined;
    }

    /**
     *  @private
     *  Intercept style change for "locale".
     *
     *  In the case that there is no associated UI component or the
     *  module factory of the UIComponent has not yet been intialized
     *  style changes are only recorded but the styleChanged method
     *  is not called.  Overriding the setStyle method allows
     *  the class to be updated immediately when the locale style is
     *  set directly on this class instance.
     */
    override public function setStyle(styleProp:String, newValue:*):void
    {
        super.setStyle(styleProp, newValue);

        if (styleProp != "locale")
            return;

        localeChanged();
    }

    /**
     *  @private
     *  Detects changes to style properties. When any style property is set,
     *  Flex calls the <code>styleChanged()</code> method,
     *  passing to it the name of the style being set.
     *
     *  For the Collator class this method determines whether or not the
     *  locale style has changed and if needed updates the instance of
     *  the class to reflect this change. If the locale has been
     *  updated the <code>change</code> event will be dispatched and
     *  uses of the bindable methods or properties will be updated.
     *
     *  @param styleProp The name of the style property, or null if
     *  all styles for this component have changed.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    override public function styleChanged(styleProp:String):void
    {
        localeChanged();
        super.styleChanged(styleProp);
    }

    /**
     *  @private
     *  A pretty printer for Sort that lists the sort fields and their
     *  options.
     */
    override public function toString():String
    {
        return ObjectUtil.toString(this);
    }

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @inheritDoc
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function initializeDefaultCompareFunction(obj:Object):void
    {
        // if the compare function is not already set then we can set it
        if (!usingCustomCompareFunction)
        {
            if (numeric == true)
                _compareFunction = numericCompare;
            else if (numeric == false)
                _compareFunction = stringCompare;
            else
            {
                // we need to introspect the data a little bit
                var value:Object;
                if (_name)
                {
                    try
                    {
                        value = obj[_name];
                    }
                    catch(error:Error)
                    {
                    }
                }
                //this needs to be an == null check because !value will return true
                //where value == 0 or value == false
                if (value == null)
                {
                    value = obj;
                }

                var typ:String = typeof(value);
                switch (typ)
                {
                    case "string":
                        _compareFunction = stringCompare;
                    break;
                    case "object":
                        if (value is Date)
                        {
                            _compareFunction = dateCompare;
                        }
                        else
                        {
                            _compareFunction = stringCompare;
                            var test:String;
                            try
                            {
                                test = value.toString();
                            }
                            catch(error2:Error)
                            {
                            }
                            if (!test || test == "[object Object]")
                            {
                                _compareFunction = nullCompare;
                            }
                        }
                    break;
                    case "xml":
                        _compareFunction = xmlCompare;
                    break;
                    case "boolean":
                    case "number":
                        _compareFunction = numericCompare;
                    break;
                }
            }  // else
        } // if
    }

    /**
     *  @inheritDoc
     *
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function reverse():void
    {
        descending = !descending;
    }

    //--------------------------------------------------------------------------
    //
    // Private Properties
    //
    //--------------------------------------------------------------------------

    //---------------------------------
    //  stringCollator
    //---------------------------------

    /**
     *  @private
     *  Locale-aware string collator.
     */
    private var internalStringCollator:SortingCollator;

    /**
     *  @private
     *  Locale-aware string collator
     *
     *  @default false
     *
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    private function get stringCollator():SortingCollator
    {
        if (!internalStringCollator)
        {
            ensureStyleSource();
            const locale:* = getStyle("locale");

            internalStringCollator = new SortingCollator();
            internalStringCollator.setStyle("locale", locale);
        }

        return internalStringCollator;
    }

    //--------------------------------------------------------------------------
    //
    //  Private Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  Ensure some style source exists for this instance of a globalization
     *  object.
     *
     *  A style source is considered exist if (A) styleParent value is non-null,
     *  or (B) localeStyle value has some useable value.
     *  If neither is the case, this style client will be added to the
     *  FlexGlobals.topLevelApplication as a child if possible.
     *
     *  As a side effect this will call the styleChanged method and if the
     *  locale has changed will cause the createWorkingInstance method
     *  to be called.
     */
    private function ensureStyleSource():void
    {
        if (!styleParent &&
            ((localeStyle === undefined) || (localeStyle === null)))
        {
            if (FlexGlobals.topLevelApplication) 
            {
                FlexGlobals.topLevelApplication.addStyleClient(this);
            }
        }
    }

    private function nullCompare(a:Object, b:Object):int
    {
        var value:Object;
        var left:Object;
        var right:Object;

        var found:Boolean = false;

        // return 0 (ie equal) if both are null
        if (a == null && b == null)
        {
            return 0;
        }

        // we need to introspect the data a little bit
        if (_name)
        {
            try
            {
                left = a[_name];
            }
            catch(error:Error)
            {
            }

            try
            {
                right = b[_name];
            }
            catch(error:Error)
            {
            }
        }

        // return 0 (ie equal) if both are null
        if (left == null && right == null)
            return 0;

        if (left == null && !_name)
            left = a;

        if (right == null && !_name)
            right = b;


        var typeLeft:String = typeof(left);
        var typeRight:String = typeof(right);


        if (typeLeft == "string" || typeRight == "string")
        {
                found = true;
                _compareFunction = stringCompare;
        }
        else if (typeLeft == "object" || typeRight == "object")
        {
            if (left is Date || right is Date)
            {
                found = true;
                _compareFunction = dateCompare
            }
        }
        else if (typeLeft == "xml" || typeRight == "xml")
        {
                found = true;
                _compareFunction = xmlCompare;
        }
        else if (typeLeft == "number" || typeRight == "number"
                 || typeLeft == "boolean" || typeRight == "boolean")
        {
                found = true;
                _compareFunction = numericCompare;
        }

        if (found)
        {
            return _compareFunction(left, right);
        }
        else
        {
            var message:String = resourceManager.getString(
                "collections", "noComparatorSortField", [ name ]);
            throw new SortError(message);
        }
    }

    /**
     *  Pull the numbers from the objects and call the implementation.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    private function numericCompare(a:Object, b:Object):int
    {
        var fa:Number;
        try
        {
            fa = _name == null ? Number(a) : Number(a[_name]);
        }
        catch(error:Error)
        {
        }

        var fb:Number;
        try
        {
            fb = _name == null ? Number(b) : Number(b[_name]);
        }
        catch(error:Error)
        {
        }

        return ObjectUtil.numericCompare(fa, fb);
    }

    /**
     *  Pull the date objects from the values and compare them.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    private function dateCompare(a:Object, b:Object):int
    {
        var fa:Date;
        try
        {
            fa = _name == null ? a as Date : a[_name] as Date;
        }
        catch(error:Error)
        {
        }

        var fb:Date;
        try
        {
            fb = _name == null ? b as Date : b[_name] as Date;
        }
        catch(error:Error)
        {
        }

        return ObjectUtil.dateCompare(fa, fb);
    }

    /**
     *  Pull the strings from the objects and call the implementation.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    private function stringCompare(a:Object, b:Object):int
    {
        var fa:String;
        try
        {
            fa = _name == null ? String(a) : String(a[_name]);
        }
        catch(error:Error)
        {
        }

        var fb:String;
        try
        {
            fb = _name == null ? String(b) : String(b[_name]);
        }
        catch(error:Error)
        {
        }

        return stringCollator.compare(fa, fb);
    }

    /**
     *  Pull the values out fo the XML object, then compare
     *  using the string or numeric comparator depending
     *  on the numeric flag.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    private function xmlCompare(a:Object, b:Object):int
    {
        var sa:String;
        try
        {
            sa = _name == null ? a.toString() : a[_name].toString();
        }
        catch(error:Error)
        {
        }

        var sb:String;
        try
        {
            sb = _name == null ? b.toString() : b[_name].toString();
        }
        catch(error:Error)
        {
        }

        if (numeric == true)
        {
            return ObjectUtil.numericCompare(parseFloat(sa), parseFloat(sb));
        }
        else
        {
            return stringCollator.compare(sa, sb);
        }
    }

    /**
     *  @private
     *  This method is called if a style is changed on the instances of
     *  this formatter.
     *
     *  This method determines if the locale style has changed and if
     *  so it updates the formatter to reflect this change.
     *  If the locale has been updated the <code>change</code> event
     *  will be dispatched and uses of the
     *  bindable methods or properties will be updated.
     */
    private function localeChanged():void
    {
        const newlocaleStyle:* = super.getStyle("locale");

        if (localeStyle === newlocaleStyle)
            return;

        localeStyle = newlocaleStyle;

        if (internalStringCollator)
        {
            internalStringCollator.setStyle("locale", localeStyle);
        }

        dispatchEvent(new Event(Event.CHANGE));
    }
}
}
