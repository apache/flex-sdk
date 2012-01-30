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

package mx.collections
{

import flash.events.Event;
import flash.events.EventDispatcher;
import mx.collections.ISort;
import mx.collections.ISortField;
import mx.collections.errors.SortError;
import mx.managers.ISystemManager;
import mx.managers.SystemManager;
import mx.resources.IResourceManager;
import mx.resources.ResourceManager;
import mx.utils.ObjectUtil;

[DefaultProperty("fields")]
[ResourceBundle("collections")]
[Alternative(replacement="spark.collections.Sort", since="4.5")]

/**
 *  Provides the sorting information required to establish a sort on an
 *  existing view (ICollectionView interface or class that implements the
 *  interface). After you assign a Sort instance to the view's
 *  <code>sort</code> property, you must call the view's
 *  <code>refresh()</code> method to apply the sort criteria.
 *
 *  Typically the sort is defined for collections of complex items, that is 
 *  collections in which the sort is performed on one or more properties of 
 *  the objects in the collection.
 *  The following example shows this use:
 *  <pre><code>
 *     var col:ICollectionView = new ArrayCollection();
 *     // In the real world, the collection would have more than one item.
 *     col.addItem({first:"Anders", last:"Dickerson"});
 *     // Create the Sort instance.
 *     var sort:Sort = new Sort();
 *     // Set the sort field; sort on the last name first, first name second.
 *     // Both fields are case-insensitive.
 *     sort.fields = [new SortField("last",true), new SortField("first",true)];
 *       // Assign the Sort object to the view.
 *     col.sort = sort;
 *     // Apply the sort to the collection.
 *     col.refresh();
 *  </code></pre>
 *
 *  <p>There are situations in which the collection contains simple items, 
 *  like <code>String</code>, <code>Date</code>, <code>Boolean</code>, etc.
 *  In this case, apply the sort to the simple type directly.
 *  When constructing a sort for simple items, use a single sort field,
 *  and specify a <code>null</code> <code>name</code> (first) parameter
 *  in the SortField object constructor.
 *  For example:
 *  <pre><code>
 *     var col:ICollectionView = new ArrayCollection();
 *     col.addItem("California");
 *     col.addItem("Arizona");
 *     var sort:Sort = new Sort();
 *     // There is only one sort field, so use a <code>null</code> 
 *     // first parameter.
 *     sort.fields = [new SortField(null, true)];
 *     col.sort = sort;
 *     col.refresh();
 *  </code></pre>
 *  </p>
 *
 *  <p>The Flex implementations of the ICollectionView interface retrieve 
 *  all items from a remote location before executing a sort.
 *  If you use paging with a sorted list, apply the sort to the remote
 *  collection before you retrieve the data.
 *  </p>
 *
 *  <p>By default this Sort class does not provide correct language specific
 *  sorting for strings.  For this type of sorting please see the 
 *  <code>spark.collections.Sort</code> and 
 *  <code>spark.collections.SortField</code> classes.</p>
 * 
 *  @mxml
 *
 *  <p>The <code>&lt;mx:Sort&gt;</code> tag has the following attributes:</p>
 *
 *  <pre>
 *  &lt;mx:Sort
 *  <b>Properties</b>
 *  compareFunction="<em>Internal compare function</em>"
 *  fields="null"
 *  unique="false | true"
 *  /&gt;
 *  </pre>
 *
 *  <p>In case items have inconsistent data types or items have complex data 
 *  types, the use of the default built-in compare functions is not recommended.
 *  Inconsistent sorting results may occur in such cases. To avoid such problem,
 *  provide a custom compare function and/or make the item types consistent.</p>
 *
 *  <p>Just like any other <code>AdvancedStyleClient</code>-based classes, 
 *  the <code>Sort</code> and <code>SortField</code> classes do not have a 
 *  parent-child relationship in terms of event handling. Locale changes in a 
 *  <code>Sort</code> instance are not dispatched to its <code>SortField</code> 
 *  instances automatically. The only exceptional case is the internal default 
 *  <code>SortField</code> instance used when no explicit fields are provided.
 *  In this case, the internal default <code>SortField</code> instance follows 
 *  the locale style that the owner <code>Sort</code> instance has.</p>
 *
 *  @see mx.collections.ICollectionView
 *  @see ISortField
 *  @see spark.collections.Sort
 *  @see spark.collections.SortField
 * 
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class Sort extends EventDispatcher implements ISort
{
    include "../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------

    /**
     *  When executing a find return the index any matching item.
     *
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public static const ANY_INDEX_MODE:String = "any";

    /**
     *  When executing a find return the index for the first matching item.
     *
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public static const FIRST_INDEX_MODE:String = "first";

    /**
     *  When executing a find return the index for the last matching item.
     *
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public static const LAST_INDEX_MODE:String = "last";

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor.
     *
     *  <p>Creates a new Sort with no fields set and no custom comparator.</p>
     *
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function Sort()
    {
        super();
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

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  compareFunction
    //----------------------------------

    /**
     *  @private
     *  Storage for the compareFunction property.
     */
    private var _compareFunction:Function;

    /**
     *  @private
     */
    private var usingCustomCompareFunction:Boolean;

    [Inspectable(category="General")]

    /**
     *  @inheritDoc
     *
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get compareFunction():Function
    {
        return usingCustomCompareFunction ? _compareFunction : internalCompare;
    }

    /**
     *  @private
     */
    public function set compareFunction(value:Function):void
    {
        _compareFunction = value;
        usingCustomCompareFunction = _compareFunction != null;
    }

    //----------------------------------
    //  fields
    //----------------------------------

    /**
     *  @private
     *  Storage for the fields property.
     */
    private var _fields:Array;

    /**
     *  @private
     */
    private var fieldList:Array = [];

    [Inspectable(category="General", arrayType="mx.collections.ISortField")]
    [Bindable("fieldsChanged")]

    /**
     *  @inheritDoc
     *
     *  @default null
     *
     *  @see SortField
     *
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get fields():Array
    {
        return _fields;
    }

    /**
     *  @private
     */
    public function set fields(value:Array):void
    {
        _fields = value;
        fieldList = [];
        if (_fields)
        {
            var field:ISortField;
            for (var i:int = 0; i<_fields.length; i++)
            {
                field = ISortField(_fields[i]);
                fieldList.push(field.name);
            }
        }
        dispatchEvent(new Event("fieldsChanged"));
    }

    //----------------------------------
    //  unique
    //----------------------------------

    /**
     *  @private
     *  Storage for the unique property.
     */
    private var _unique:Boolean;

    [Inspectable(category="General")]

    /**
     *  @inheritDoc
     *
     *  @default false
     *
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get unique():Boolean
    {
        return _unique;
    }

    /**
     *  @inheritDoc
     */
    public function set unique(value:Boolean):void
    {
        _unique = value;
    }

    //--------------------------------------------------------------------------
    //
    //  Overridden Methods
    //
    //--------------------------------------------------------------------------

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
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function findItem(items:Array,
                             values:Object,
                             mode:String,
                             returnInsertionIndex:Boolean = false,
                             compareFunction:Function = null):int
    {
        var compareForFind:Function;
        var fieldsForCompare:Array;
        var message:String;

        if (!items)
        {
            message = resourceManager.getString(
                "collections", "noItems");
            throw new SortError(message);
        }
        else if (items.length == 0)
        {
            return returnInsertionIndex ? 1 : -1;
        }

        if (compareFunction == null)
        {
            compareForFind = this.compareFunction;
            // configure the search criteria
            if (values && fieldList.length > 0)
            {
                fieldsForCompare = [];
                //build up the fields we can compare, if we skip a field in the
                //middle throw an error.  it is ok to not have all the fields
                //though
                var fieldName:String;
                var hadPreviousFieldName:Boolean = true;
                for (var i:int = 0; i < fieldList.length; i++)
                {
                    fieldName = fieldList[i];
                    if (fieldName)
                    {
                        var hasFieldName:Boolean;
                        try
                        {
                            hasFieldName = values[fieldName] !== undefined;
                        }
                        catch(e:Error)
                        {
                            hasFieldName = false;
                        }
                        if (hasFieldName)
                        {
                            if (!hadPreviousFieldName)
                            {
                                message = resourceManager.getString(
                                    "collections", "findCondition", [ fieldName ]);
                                throw new SortError(message);
                            }
                            else
                            {
                                fieldsForCompare.push(fieldName);
                            }
                        }
                        else
                        {
                            hadPreviousFieldName = false;
                        }
                    }
                    else
                    {
                        //this is ok because sometimes a sortfield might
                        //have a custom comparator
                        fieldsForCompare.push(null);
                    }
                }
                if (fieldsForCompare.length == 0)
                {
                    message = resourceManager.getString(
                        "collections", "findRestriction");
                    throw new SortError(message);
                }
                else
                {
                    try
                    {
                        initSortFields(items[0]);
                    }
                    catch(initSortError:SortError)
                    {
                        //oh well, use the default comparators...
                    }
                }
            }
        }
        else
        {
            compareForFind = compareFunction;
        }

        // let's begin searching
        var found:Boolean = false;
        var objFound:Boolean = false;
        var index:int = 0;
        var lowerBound:int = 0;
        var upperBound:int = items.length -1;
        var obj:Object = null;
        var direction:int = 1;
        while(!objFound && (lowerBound <= upperBound))
        {
            index = Math.round((lowerBound+ upperBound)/2);
            obj = items[index];
            //if we were given fields for comparison use that method, but
            //if not the comparator may be for SortField in which case
            //it'd be an error to pass a 3rd parameter
            direction = fieldsForCompare
                ? compareForFind(values, obj, fieldsForCompare)
                : compareForFind(values, obj);

            switch(direction)
            {
                case -1:
                    upperBound = index -1;
                break;

                case 0:
                    objFound = true;
                    switch(mode)
                    {
                        case ANY_INDEX_MODE:
                            found = true;
                        break;

                        case FIRST_INDEX_MODE:
                            found = (index == lowerBound);
                            // start looking towards bof
                            var objIndex:int = index - 1;
                            var match:Boolean = true;
                            while(match && !found && (objIndex >= lowerBound))
                            {
                                obj = items[objIndex];
                                var prevCompare:int = fieldsForCompare
                                    ? compareForFind(values, obj, fieldsForCompare)
                                    : compareForFind(values, obj);
                                match = (prevCompare == 0);
                                if (!match || (match && (objIndex == lowerBound)))
                                {
                                    found= true;
                                    index = objIndex + (match ? 0 : 1);
                                } // if match
                                objIndex--;
                            } // while
                        break;

                        case LAST_INDEX_MODE:
                            // if we where already at the edge case then we already found the last value
                            found = (index == upperBound);
                            // start looking towards eof
                            objIndex = index + 1;
                            match = true;
                            while(match && !found && (objIndex <= upperBound))
                            {
                                obj = items[objIndex];
                                var nextCompare:int = fieldsForCompare
                                    ? compareForFind(values, obj, fieldsForCompare)
                                    : compareForFind(values, obj);
                                match = (nextCompare == 0);
                                if (!match || (match && (objIndex == upperBound)))
                                {
                                    found= true;
                                    index = objIndex - (match ? 0 : 1);
                                } // if match
                                objIndex++;
                            } // while
                        break;
                        default:
                        {
                            message = resourceManager.getString(
                                "collections", "unknownMode");
                            throw new SortError(message);
                        }
                    } // switch
                break;

                case 1:
                    lowerBound = index +1;
                break;
            } // switch
        } // while
        if (!found && !returnInsertionIndex)
        {
            return -1;
        }
        else
        {
            return (direction > 0) ? index + 1 : index;
        }
    }

    /**
     *  @inheritDoc
     *
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function propertyAffectsSort(property:String):Boolean
    {
        if (usingCustomCompareFunction || !fields) return true;
        for (var i:int = 0; i < fields.length; i++)
        {
            var field:ISortField = fields[i];
            if (field.name == property || field.usingCustomCompareFunction)
            {
                return true;
            }
        }
        return false;
    }

    /**
     *  @inheritDoc
     *
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function reverse():void
    {
        if (fields)
        {
            for (var i:int = 0; i < fields.length; i++)
            {
                ISortField(fields[i]).reverse();
            }
        }
        noFieldsDescending = !noFieldsDescending;
    }

    /**
     *  @inheritDoc
     *
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function sort(items:Array):void
    {
        if (!items || items.length <= 1)
        {
            return;
        }

        if (usingCustomCompareFunction)
        {
            // bug 185872
            // the Sort.internalCompare function knows to use Sort._fields; that same logic
            // needs to be part of calling a custom compareFunction. Of course, a user shouldn't
            // be doing this -- so I wrap calls to compareFunction with _fields as the last parameter
            const fixedCompareFunction:Function =
                function (a:Object, b:Object):int
                {
                    // append our fields to the call, since items.sort() won't
                    return compareFunction(a, b, _fields);
                };

            var message:String;

            if (unique)
            {
                var uniqueRet1:Object = items.sort(fixedCompareFunction, Array.UNIQUESORT);
                if (uniqueRet1 == 0)
                {
                    message = resourceManager.getString(
                        "collections", "nonUnique");
                    throw new SortError(message);
                }
            }
            else
            {
                items.sort(fixedCompareFunction);
            }
        }
        else
        {
            var fields:Array = this.fields;
            if (fields && fields.length > 0)
            {
                var i:int;
                //doing the init value each time may be a little inefficient
                //but allows for the data to change and the comparators
                //to update correctly
                //the sortArgs is an object that if non-null means
                //we can use Array.sortOn which will be much faster
                //than going through internalCompare.  However
                //if the Sort is supposed to be unique and fields.length > 1
                //we cannot use sortOn since it only tests uniqueness
                //on the first field
                var sortArgs:Object = initSortFields(items[0], true);

                if (unique)
                {
                    var uniqueRet2:Object;
                    if (sortArgs && fields.length == 1)
                    {
                        uniqueRet2 = items.sortOn(sortArgs.fields[0], sortArgs.options[0] | Array.UNIQUESORT);
                    }
                    else
                    {
                        uniqueRet2 = items.sort(internalCompare,
                                                Array.UNIQUESORT);
                    }
                    if (uniqueRet2 == 0)
                    {
                        message = resourceManager.getString(
                            "collections", "nonUnique");
                        throw new SortError(message);
                    }
                }
                else
                {
                    if (sortArgs)
                    {
                        items.sortOn(sortArgs.fields, sortArgs.options);
                    }
                    else
                    {
                        items.sort(internalCompare);
                    }
                }
            }
            else
            {
                items.sort(internalCompare);
            }
        }
    }

    //--------------------------------------------------------------------------
    //
    //  Private Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  Make sure all SortFields are ready to execute their comparators.
     */
    private function initSortFields(item:Object, buildArraySortArgs:Boolean = false):Object
    {
        var arraySortArgs:Object = null;
        var i:int;
        for (i = 0; i<fields.length; i++)
        {
            ISortField(fields[i]).initializeDefaultCompareFunction(item);
        }
        if (buildArraySortArgs)
        {
            arraySortArgs = {fields: [], options: []};
            for (i = 0; i<fields.length; i++)
            {
                var field:ISortField = fields[i];
                var options:int = field.arraySortOnOptions;
                if (options == -1)
                {
                    return null;
                }
                else
                {
                    arraySortArgs.fields.push(field.name);
                    arraySortArgs.options.push(options);
                }
            }

        }
        return arraySortArgs;
    }

    /**
     *  @private
     *  Compares the values specified based on the sort field options specified
     *  for this sort.  The fields parameter is really just used to get the
     *  number of fields to check.  We don't look at the actual values
     *  to see if they match the actual sort.
     */
    private function internalCompare(a:Object, b:Object, fields:Array = null):int
    {
        var result:int = 0;
        if (!_fields)
        {
            result = noFieldsCompare(a, b);
        }
        else
        {
            var i:int = 0;
            var len:int = fields ? fields.length : _fields.length;
            while (result == 0 && (i < len))
            {
                var sf:ISortField = ISortField(_fields[i]);
                result = sf.compareFunction(a, b);
                if (sf.descending)
                    result *= -1;
                i++;
            }
        }

        return result;
    }

    private var defaultEmptyField:ISortField;
    private var noFieldsDescending:Boolean = false;

    /**
     *  If the sort does not have any sort fields nor a custom comparator
     *  just use an empty SortField object and have it use its default
     *  logic.
     *
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    private function noFieldsCompare(a:Object, b:Object, fields:Array = null):int
    {
        if (!defaultEmptyField)
        {
            defaultEmptyField = new SortField();
            try
            {
                defaultEmptyField.initializeDefaultCompareFunction(a);
            }
            catch(e:SortError)
            {
                //this error message isn't as useful in this case so replace
                var message:String = resourceManager.getString(
                    "collections", "noComparator", [ a ]);
                throw new SortError(message);
            }
        }

        var result:int = defaultEmptyField.compareFunction(a, b);

        if (noFieldsDescending)
        {
            result *= -1;
        }

        return result;
    }
}
}
