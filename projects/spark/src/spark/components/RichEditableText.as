////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2008 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package spark.primitives
{

import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.IOErrorEvent;
import flash.events.KeyboardEvent;
import flash.geom.Matrix;
import flash.geom.Rectangle;
import flash.system.IME;
import flash.system.IMEConversionMode;
import flash.text.TextFormat;
import flash.text.engine.ElementFormat;
import flash.text.engine.FontDescription;
import flash.text.engine.FontLookup;
import flash.text.engine.TextBlock;
import flash.text.engine.TextElement;
import flash.text.engine.TextLine;
import flash.ui.Keyboard;

import flashx.textLayout.compose.ITextLineCreator;
import flashx.textLayout.container.ContainerController;
import flashx.textLayout.container.TextContainerManager;
import flashx.textLayout.conversion.ConversionType;
import flashx.textLayout.conversion.ITextImporter;
import flashx.textLayout.conversion.TextFilter;
import flashx.textLayout.edit.EditManager;
import flashx.textLayout.edit.EditingMode;
import flashx.textLayout.edit.IEditManager;
import flashx.textLayout.edit.ISelectionManager;
import flashx.textLayout.edit.SelectionManager;
import flashx.textLayout.edit.SelectionState;
import flashx.textLayout.edit.TextScrap;
import flashx.textLayout.elements.Configuration;
import flashx.textLayout.elements.FlowElement;
import flashx.textLayout.elements.InlineGraphicElementStatus;
import flashx.textLayout.elements.ParagraphElement;
import flashx.textLayout.elements.SpanElement;
import flashx.textLayout.elements.TextFlow;
import flashx.textLayout.events.CompositionCompletionEvent;
import flashx.textLayout.events.DamageEvent;
import flashx.textLayout.events.FlowOperationEvent;
import flashx.textLayout.events.SelectionEvent;
import flashx.textLayout.events.StatusChangeEvent;
import flashx.textLayout.formats.Category;
import flashx.textLayout.formats.FormatValue;
import flashx.textLayout.formats.ITextLayoutFormat;
import flashx.textLayout.formats.TextLayoutFormat;
import flashx.textLayout.operations.CutOperation;
import flashx.textLayout.operations.DeleteTextOperation;
import flashx.textLayout.operations.FlowOperation;
import flashx.textLayout.operations.FlowTextOperation;
import flashx.textLayout.operations.InsertTextOperation;
import flashx.textLayout.operations.PasteOperation;
import flashx.textLayout.tlf_internal;
import flashx.undo.IUndoManager;

import mx.core.EmbeddedFont;
import mx.core.IEmbeddedFontRegistry;
import mx.core.IFlexModuleFactory;
import mx.core.IIMESupport;
import mx.core.IUIComponent;
import mx.core.Singleton;
import mx.core.UIComponent;
import mx.core.mx_internal;
import mx.events.FlexEvent;
import mx.managers.ISystemManager;
import mx.resources.ResourceManager;
import mx.utils.StringUtil;

import spark.components.TextSelectionVisibility;
import spark.core.CSSTextLayoutFormat;
import spark.core.IViewport;
import spark.core.ScrollUnit;
import spark.events.TextOperationEvent;
import spark.primitives.supportClasses.RichEditableTextContainerManager;
import spark.utils.TextUtil;

use namespace mx_internal;

//--------------------------------------
//  Events
//--------------------------------------

/**
 *  Dispached after the <code>selectionAnchorPosition</code> and/or
 *  <code>selectionActivePosition</code> properties have changed.
 *  due to a user interaction.
 *
 *  @eventType mx.events.FlexEvent.SELECTION_CHANGE
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Event(name="selectionChange", type="mx.events.FlexEvent")]

/**
 *  Dispatched before a user editing operation occurs.
 *  You can alter the operation, or cancel the event
 *  to prevent the operation from being processed.
 *
 *  @eventType spark.events.TextOperationEvent.CHANGING
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Event(name="changing", type="spark.events.TextOperationEvent")]

/**
 *  Dispatched after a user editing operation is complete.
 *
 *  @eventType spark.events.TextOperationEvent.CHANGE
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Event(name="change", type="spark.events.TextOperationEvent")]

/**
 *  Dispatched when the user pressed the Enter key.
 *
 *  @eventType mx.events.FlexEvent.ENTER
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Event(name="enter", type="mx.events.FlexEvent")]

//--------------------------------------
//  Styles
//--------------------------------------

include "../styles/metadata/AdvancedTextLayoutFormatStyles.as"
include "../styles/metadata/BasicTextLayoutFormatStyles.as"
include "../styles/metadata/NonInheritingTextLayoutFormatStyles.as"
include "../styles/metadata/SelectionFormatTextStyles.as"

/**
 *  The alpha level of the color defined by
 *  the <code>backgroundColor</code> style.
 *  Valid values range from 0.0 to 1.0.
 * 
 *  @default 1.0
 *
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="backgroundAlpha", type="Number", inherit="no")]

/**
 *  The color of the background of the entire
 *  bounding rectangle of this component.
 *  If this style is <code>undefined</code>,
 *  no background is drawn.
 *  Otherwise, this RGB color is drawn with an alpha level
 *  determined by the <code>backgroundAlpha</code> style.
 * 
 *  @default undefined
 *
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="backgroundColor", type="uint", format="Color", inherit="no")]

//--------------------------------------
//  Other metadata
//--------------------------------------

[DefaultProperty("content")]

[IconFile("RichEditableText.png")]

/**
 *  Displays text. 
 *  
 *  <p>RichEditableText has more functionality than SimpleText and RichText. In 
 *  addition to the text rendering capabilities of RichText, TextView also 
 * supports hyperlinks, scrolling, selecting, and editing.</p>
 *  
 *  <p>The RichEditableText class is similar to the spark.components.TextArea 
 *  control, except that it does not have chrome.</p>
 *  
 *  <p>The RichEditableText class does not support drawing a background, border, 
 *  or scrollbars. To do that, you combine it with other components.</p>
 *  
 *  <p>Because RichEditableText extends UIComponent, it can take focus and 
 *  allows user interaction such as selection.</p>
 *  
 *  @see spark.primitives.SimpleText
 *  @see spark.primitives.RichText
 *
 *  @includeExample examples/TextViewExample.mxml
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class RichEditableText extends UIComponent
	implements IViewport, IIMESupport
{
    include "../core/Version.as";
        
    //--------------------------------------------------------------------------
    //
    //  Class initialization
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    private static function initClass():void
    {
    	// Create a single Configuration used by all TextContainerManager 
    	// instances.  It tells the TextContainerManager that we don't want it 
    	// to handle the ENTER key, because we need the ENTER key to behave 
    	// differently based on the 'multiline' property.
    	staticTextContainerManagerConfiguration =
    		Configuration(TextContainerManager.defaultConfiguration).clone();
    	staticTextContainerManagerConfiguration.manageEnterKey = false;
    	
    	staticTextLayoutFormat = new TextLayoutFormat;
    	
    	staticImportConfiguration = new Configuration();
    	
    	staticTextFormat = new TextFormat();
    }
    
    initClass();    
    
    //--------------------------------------------------------------------------
    //
    //  Class variables
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
	 *  Used for telling TextContainerManager not to process the Enter key.
     */
    private static var staticTextContainerManagerConfiguration:Configuration;
    
    /**
     *  @private
     *  Used for determining whitespace processing
     *  when the 'content' property is set.
     */
    private static var staticTextLayoutFormat:TextLayoutFormat;
        
    /**
     *  @private
     *  Used for determining whitespace processing
     *  when the 'content' property is set.
     */
    private static var staticImportConfiguration:Configuration;
    
    /**
     *  @private
     *  Used in getEmbeddedFontContext().
     */
    private static var staticTextFormat:TextFormat;
        
    /**
     *  @private
	 *  Used for debugging.
	 *  Set this to true to get trace output
	 *  showing what TextContainerManager APIs are being called.
     */
    mx_internal static var debug:Boolean = false;
    
    //--------------------------------------------------------------------------
    //
    //  Class properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  embeddedFontRegistry
    //----------------------------------

    /**
     *  @private
     *  Storage for the _embeddedFontRegistry property.
     *  Note: This gets initialized on first access,
     *  not when this class is initialized, in order to ensure
     *  that the Singleton registry has already been initialized.
     */
    private static var _embeddedFontRegistry:IEmbeddedFontRegistry;

    /**
     *  @private
     *  A reference to the embedded font registry.
     *  Single registry in the system.
     *  Used to look up the moduleFactory of a font.
     */
    private static function get embeddedFontRegistry():IEmbeddedFontRegistry
    {
        if (!_embeddedFontRegistry)
        {
            _embeddedFontRegistry = IEmbeddedFontRegistry(
                Singleton.getInstance("mx.core::IEmbeddedFontRegistry"));
        }

        return _embeddedFontRegistry;
    }

    //--------------------------------------------------------------------------
    //
    //  Class methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    private static function splice(str:String, start:int, end:int,
                                   strToInsert:String):String
    {
        return str.substring(0, start) +
               strToInsert +
               str.substring(end, str.length);
    }

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function RichEditableText()
    {
        super();
        
        // Create the TLF TextContainerManager, using this component
        // as the DisplayObjectContainer for its TextLines.
        // This TextContainerManager instance persists for the lifetime
        // of the component.
        _textContainerManager = createTextContainerManager();

        // Add event listeners on this component.

        // The focusInHandler is called by the TCMContainer focusInHandler.
        
        addEventListener(FocusEvent.FOCUS_OUT, focusOutHandler);
        
        addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
        
        addEventListener(FlexEvent.UPDATE_COMPLETE, updateCompleteHandler);
        
        // Add event listeners on its TextContainerManager.
        
        _textContainerManager.addEventListener(
            CompositionCompletionEvent.COMPOSITION_COMPLETE,
            textContainerManager_compositionCompleteHandler);
        
        _textContainerManager.addEventListener(
        	DamageEvent.DAMAGE, textContainerManager_damageHandler);

        _textContainerManager.addEventListener(
        	Event.SCROLL, textContainerManager_scrollHandler);

        _textContainerManager.addEventListener(
            SelectionEvent.SELECTION_CHANGE,
            textContainerManager_selectionChangeHandler);

        _textContainerManager.addEventListener(
            FlowOperationEvent.FLOW_OPERATION_BEGIN,
            textContainerManager_flowOperationBeginHandler);

        _textContainerManager.addEventListener(
            FlowOperationEvent.FLOW_OPERATION_END,
            textContainerManager_flowOperationEndHandler);

        _textContainerManager.addEventListener(
            StatusChangeEvent.INLINE_GRAPHIC_STATUS_CHANGE, 
            textContainerManager_inlineGraphicStatusChangeHandler);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  This object reports the TLF formats that correspond
     *  to this component's CSS styles.
     */
    private var hostFormat:ITextLayoutFormat;

    /**
     *  @private
     *  This variable is initialize to true so that hostFormat
     *  gets initialized the first time through commitProperties().
     */
    private var hostFormatChanged:Boolean = true;

    /**
     *  @private
     */
    private var fontMetricsInvalid:Boolean = false;
    
    /**
     *  @private
     */
    private var ascent:Number;
    
    /**
     *  @private
     */
    private var descent:Number;

    /**
     *  @private
     *  True if TextOperationEvent.CHANGING should be dispatched at
     *  operationEnd.
     */
    private var dispatchChangingEvent:Boolean = true;
    
    /**
     *  @private
     */
    mx_internal var passwordChar:String = "*";

    /**
     *  @private
     */
    mx_internal var undoManager:IUndoManager;

    /**
     *  @private
     */
    mx_internal var clearUndoOnFocusOut:Boolean = true;

    /**
     *  @private
     *  Holds the last recorded value of the module factory used to create the font.
     */
    mx_internal var embeddedFontContext:IFlexModuleFactory;

    /**
     *  @private
     *  Previous imeMode.
     */
    private var prevMode:String = IMEConversionMode.UNKNOWN;

    /**
     *  @private
     */    
    private var errorCaught:Boolean = false;
    
    /**
     *  @private
     *  If true, the content of the textFlow has changed in some way.  In most
     *  cases this is the same as damaged.  The one exception is if setText 
     *  is used to initialize the TextContainerManager.  It does not dispatch
     *  a damage event (although it probably should).
     * 
     *  At the end of composition, the change event should be dispatched if it
     *  wasn't already dispatched one or more times for editing operations.
     *
     */    
    private var textFlowChanged:Boolean = false;
            

    /**
     *  @private
     *  Hold the previous editingMode while using a specific instance manager
     *  so that the editingMode can be restored when the instance manager is
     *  released.
     */
    private var priorEditingMode:String;

    /**
     *  @private
     *  Cache the width constraint as set by the layout in setLayoutBoundsSize()
     *  so that text reflow can be calculated during a subsequent measure pass.
     */
    private var widthConstraint:Number = NaN;
                
    /**
     *  @private
     *  True if this component sizes itself based on its actual
     *  contents.  This happens if it's configured for autoSize, it is not
     *  contained within a scroller and an explicit width and height are not
     *  specified.
     */
    mx_internal var actuallyAutoSizing:Boolean = false;
                
    //--------------------------------------------------------------------------
    //
    //  Overridden properties: UIComponent
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  baselinePosition
    //----------------------------------

    /**
     *  @private
     */
    override public function get baselinePosition():Number
    {
        // Update ascent, if fontMetrics changed.
        calculateFontMetrics();    

        return getStyle("paddingTop") + ascent;
    }

    //----------------------------------
    //  enabled
    //----------------------------------

    /**
     *  @private
     */
    private var enabledChanged:Boolean = false;

    /**
     *  @private
     */
    override public function set enabled(value:Boolean):void
    {
        if (value == super.enabled)
            return;

        super.enabled = value;
        enabledChanged = true;

        invalidateProperties();
        invalidateDisplayList();
    }

    //--------------------------------------------------------------------------
    //
    //  Properties: IViewport
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  clipAndEnableScrolling
    //----------------------------------
        
    /**
     *  @private
     */
    private var _clipAndEnableScrolling:Boolean = false;

    /**
     *  @private
     */
    private var clipAndEnableScrollingChanged:Boolean = false;

    /**
     *  @copy mx.layout.LayoutBase#clipAndEnableScrolling
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get clipAndEnableScrolling():Boolean 
    {
        return _clipAndEnableScrolling;
    }
    
    /**
     *  @private
     *  Set to true by a scroller when it installs this as a viewport.
     *  Set to false by a scroller when it uninstalls this as a viewport.
     */
    public function set clipAndEnableScrolling(value:Boolean):void 
    {
        if (value == _clipAndEnableScrolling) 
            return;
    
        _clipAndEnableScrolling = value;
        clipAndEnableScrollingChanged = true;
        
        // Value could impact whether we are actually autoSizing.
        invalidateSize();
        invalidateDisplayList();
    }
        
    //----------------------------------
    //  contentHeight
    //----------------------------------

    /**
     *  @private
     */
    private var _contentHeight:Number = 0;

    [Bindable("propertyChange")]
    
    /**
     *  Documentation is not currently available.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get contentHeight():Number
    {
        return _contentHeight;
    }

    //----------------------------------
    //  contentWidth
    //----------------------------------

    /**
     *  @private
     */
    private var _contentWidth:Number = 0;

    [Bindable("propertyChange")]
    
    /**
     *  Documentation is not currently available.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get contentWidth():Number
    {
        return _contentWidth;
    }

    //----------------------------------
    //  horizontalScrollPosition
    //----------------------------------

    /**
     *  @private
     */
    private var _horizontalScrollPosition:Number = 0;

    /**
     *  @private
     */
    private var horizontalScrollPositionChanged:Boolean = false;
 
    [Bindable("propertyChange")]
    
    /**
     *  Documentation is not currently available.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get horizontalScrollPosition():Number
    {
        return _horizontalScrollPosition;
    }

    /**
     *  @private
     */
    public function set horizontalScrollPosition(value:Number):void
    {
        if (value == _horizontalScrollPosition)
            return;

        _horizontalScrollPosition = value;
        horizontalScrollPositionChanged = true;

        invalidateProperties();
    }
    
    //----------------------------------
    //  verticalScrollPosition
    //----------------------------------

    /**
     *  @private
     */
    private var _verticalScrollPosition:Number = 0;

    /**
     *  @private
     */
    private var verticalScrollPositionChanged:Boolean = false;
 
    [Bindable("propertyChange")]
    
    /**
     *  Documentation is not currently available.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get verticalScrollPosition():Number
    {
        return _verticalScrollPosition;
    }

    /**
     *  @private
     */
    public function set verticalScrollPosition(value:Number):void
    {
        if (value == _verticalScrollPosition)
            return;

        _verticalScrollPosition = value;
        verticalScrollPositionChanged = true;

        invalidateProperties();
    }
        
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  autoSize
    //----------------------------------
        
    /**
     *  @private
     *  The default is true.
     */
    private var _autoSize:Boolean = true;

    /**
     *  Documentation is not currently available.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get autoSize():Boolean 
    {
        return _autoSize;
    }
    
    /**
     *  @private
     */
    public function set autoSize(value:Boolean):void 
    {
        if (value == _autoSize) 
            return;
    
        _autoSize = value;

        invalidateSize();
        invalidateDisplayList();
    }
        
    //----------------------------------
    //  content
    //----------------------------------

    /**
     *  @private
     */
    private var _content:Object;

    /**
     *  @private
     */
    private var contentChanged:Boolean = false;

    /**
     *  @private
     *  This metadata tells the MXML compiler to disable some of its default
     *  interpretation of the value specified for the 'content' property.
     *  Normally, for properties of type Object, it assumes that things
     *  looking like numbers are numbers and things looking like arrays
     *  are arrays. But <content>1</content> should generate code to set the
     *  content to  the String "1", not the int 1, and <content>[1]</content>
     *  should set it to the String "[1]", not the Array [ 1 ].
     *  However, {...} continues to be interpreted as a databinding
     *  expression, and @Resource(...), @Embed(...), etc.
     *  as compiler directives.
     *  Similar metadata on TLF classes causes the same rules to apply
     *  within <p>, <span>, etc.
     */
    [RichTextContent]
        
    /**
     *  Documentation is not currently available.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get content():Object
    {
        return _content;
    }

    /**
     *  @private
     */
    public function set content(value:Object):void
    {
        if (value == _content)
            return;

        // Setting 'content' temporarily causes 'text' to become null.
        // Later, after the 'content' has been committed into the TextFlow,
        // getting 'text' will extract the text from the TextFlow.
        _text = null;
        textChanged = false;

        _content = value;
        contentChanged = true;

        invalidateProperties();
        invalidateSize();
        invalidateDisplayList();
    }
    
    //----------------------------------
    //  displayAsPassword
    //----------------------------------

    /**
     *  @private
     */
    private var _displayAsPassword:Boolean = false;

    /**
     *  @private
     */
    private var displayAsPasswordChanged:Boolean = false;
    
    /**
     *  Documentation is not currently available.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get displayAsPassword():Boolean
    {
        return _displayAsPassword;
    }

    /**
     *  @private
     */
    public function set displayAsPassword(value:Boolean):void
    {
        if (value == _displayAsPassword)
            return;

        _displayAsPassword = value;
        displayAsPasswordChanged = true;

        invalidateProperties();
        invalidateSize();
        invalidateDisplayList();
    }

    //----------------------------------
    //  editable
    //----------------------------------

    /**
     *  @private
     */
    private var _editable:Boolean = true;

    /**
     *  @private
     */
    private var editableChanged:Boolean = false;

    /**
     *  Specifies whether the user is allowed to edit the text in this control.
     *
     *  @default true;
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get editable():Boolean
    {
        return _editable;
    }

    /**
     *  @private
     */
    public function set editable(value:Boolean):void
    {
        if (value == _editable)
            return;

        _editable = value;
        editableChanged = true;

        invalidateProperties();
        invalidateDisplayList();
    }

    //----------------------------------
    //  editingMode
    //----------------------------------
    
    /**
     *  @private
     *  The editingMode of this component's TextContainerManager.
     *  Note that this is not a public property
     *  and does not use the invalidation mechanism.
     */
    private function get editingMode():String
    {
    	return _textContainerManager.editingMode;
    }
    
    /**
     *  @private
     */
    private function set editingMode(value:String):void
    {
    	if (debug)
     		trace("editingMode = ", value);

        // ToDo: TextContainerManager should do this check.
        if (_textContainerManager.editingMode == value)
            return;

     	_textContainerManager.editingMode = value;
    }

    //----------------------------------
    //  heightInLines
    //----------------------------------

    /**
     *  @private
     */
    private var _heightInLines:Number = 10;

    /**
     *  @private
     */
    private var heightInLinesChanged:Boolean = false;
    
    /**
     *  The height of the control, in lines.
     *  
     *  <p>TextView's measure() method does not determine the measured size from 
     *  the text to be displayed, because a TextView often starts out with no 
     *  text. Instead it uses this property, and the widthInChars property 
     *  to determine its measuredWidth and measuredHeight. These are 
     *  similar to the cols and rows of an HTML TextArea.</p>
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get heightInLines():Number
    {
        return _heightInLines;
    }

    /**
     *  @private
     */
    public function set heightInLines(value:Number):void
    {
        if (value == _heightInLines)
            return;

        _heightInLines = value;
        heightInLinesChanged = true;

        invalidateSize();
        invalidateDisplayList();
    }
    
    //----------------------------------
    //  imeMode
    //----------------------------------

    /**
     *  @private
     */
    private var _imeMode:String = null;

    /**
     *  Specifies the IME (input method editor) mode.
     *  The IME enables users to enter text in Chinese, Japanese, and Korean.
     *  Flex sets the specified IME mode when the control gets the focus,
     *  and sets it back to the previous value when the control loses the focus.
     *
     *  <p>The flash.system.IMEConversionMode class defines constants for the
     *  valid values for this property.
     *  You can also specify <code>null</code> to specify no IME.</p>
     *
     *  @default null
     * 
     * @see flash.system.IMEConversionMode
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
     public function get imeMode():String
    {
        return _imeMode;
    }

    /**
     *  @private
     */
    public function set imeMode(value:String):void
    {
        _imeMode = value;
    }

    //----------------------------------
    //  textContainerManager
    //----------------------------------

    /**
     *  @private
     */
    private var _textContainerManager:TextContainerManager;
            
    /**
     *  @private
     *  The TLF TextContainerManager instance that displays,
     *  scrolls, and edits the text in this component.
     */
	mx_internal function get textContainerManager():TextContainerManager
	{
		return _textContainerManager;
	}
	
    //----------------------------------
    //  maxChars
    //----------------------------------

    /**
     *  @private
     */
    private var _maxChars:int = 0;

    /**
     *  The maximum number of characters that the TextView can contain,
     *  as entered by a user.
     *  A script can insert more text than maxChars allows;
     *  the maxChars property indicates only how much text a user can enter.
     *  If the value of this property is 0,
     *  a user can enter an unlimited amount of text. 
     * 
     *  @default 0
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get maxChars():int 
    {
        return _maxChars;
    }
    
    /**
     *  @private
     */
    public function set maxChars(value:int):void
    {
        _maxChars = value;
    }

    //----------------------------------
    //  multiline
    //----------------------------------

    /**
     *  @private
     */
    private var _multiline:Boolean = true;

    /**
     *  Determines whether the user can enter multiline text.
     *  If <code>true</code>, the Enter key starts a new paragraph.
     *  If <code>false</code>, the Enter key doesn't affect the text
     *  but causes the TextView to dispatch an <code>"enter"</code> event.
     * 
     *  @default true
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get multiline():Boolean 
    {
        return _multiline;
    }
    
    /**
     *  @private
     */
    public function set multiline(value:Boolean):void
    {
        _multiline = value;
    }

    //----------------------------------
    //  restrict
    //----------------------------------

    /**
     *  @private
     */
    private var _restrict:String = null;

    /**
     *  Documentation is not currently available.
     * 
     *  @default null
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get restrict():String 
    {
        return _restrict;
    }
    
    /**
     *  @private
     */
    public function set restrict(value:String):void
    {
        _restrict = value;
    }

    //----------------------------------
    //  selectable
    //----------------------------------

    /**
     *  @private
     */
    private var _selectable:Boolean = true;

    /**
     *  @private
     */
    private var selectableChanged:Boolean = false;

    /**
     *  Specifies whether the text can be selected.
     *  Making the text selectable lets you copy text from the control.
     *
     *  @default true;
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get selectable():Boolean
    {
        return _selectable;
    }

    /**
     *  @private
     */
    public function set selectable(value:Boolean):void
    {
        if (value == _selectable)
            return;

        _selectable = value;
        selectableChanged = true;

        invalidateProperties();
        invalidateDisplayList();
    }

    //----------------------------------
    //  selectionActivePosition
    //----------------------------------

    /**
     *  @private
     */
    private var _selectionActivePosition:int = -1;

	[Bindable("selectionChange")]

    /**
     *  The active position of the selection.
     *  The "active" point is the end of the selection
     *  which is changed when the selection is extended.
     *  The active position may be either the start
     *  or the end of the selection. 
     *
     *  @default -1
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get selectionActivePosition():int
    {
        return _selectionActivePosition;
    }

    //----------------------------------
    //  selectionAnchorPosition
    //----------------------------------
    
    /**
     *  @private
     */
    private var _selectionAnchorPosition:int = -1;

	[Bindable("selectionChange")]

    /**
     *  The anchor position of the selection.
     *  The "anchor" point is the stable end of the selection
     *  when the selection is extended.
     *  The anchor position may be either the start
     *  or the end of the selection.
     *
     *  @default -1
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get selectionAnchorPosition():int
    {
        return _selectionAnchorPosition;
    }

    //----------------------------------
    //  selectionVisibility
    //----------------------------------

    /**
     *  @private
     */
    private var _selectionVisibility:String =
        TextSelectionVisibility.WHEN_FOCUSED;

    /**
     *  @private
     *  To indicate either selection visibility or selection styles have
     *  changed.
     */
    private var selectionFormatsChanged:Boolean = false;

    /**
     *  Documentation is not currently available.
     *  
     *  Possible values are <code>ALWAYS</code>, <code>WHEN_FOCUSED</code>, and <code>WHEN_ACTIVE</code>.
     *  
     *  @see mx.components.TextSelectionVisibility
     * 
     *  @default TextSelectionVisibility.WHEN_FOCUSED
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get selectionVisibility():String 
    {
        return _selectionVisibility;
    }
    
    /**
     *  @private
     */
    public function set selectionVisibility(value:String):void
    {
        if (value == _selectionVisibility)
            return;
            
        _selectionVisibility = value;
        selectionFormatsChanged = true;
        
        invalidateProperties();
        invalidateDisplayList();
    }

    //----------------------------------
    //  text
    //----------------------------------

    /**
     *  @private
     */
    private var _text:String = "";

    /**
     *  @private
     */
    private var textChanged:Boolean = false;

    //[Bindable("change")]

    /**
     *  The text String displayed by this TextView.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get text():String 
    {
        if (!displayAsPassword)
            _text = _textContainerManager.getText("\n");
        
        return _text;
    }
    
    /**
     *  @private
     */
    public function set text(value:String):void
    {
        // ToDo: remove this when Vellum fixes this bug.
        // TextContainerManager setText()/getText() doesn't deal with null 
        // correctly so if text is set to null, convert it to the empty string.
        if (value == null)
            value = "";
            
        // Use the setter so _text is refreshed if needed.  This check is
        // needed to block property binding recursion (set causes change event
        // which causes binding to fire which repeats the process).
        if (value == text)
            return;
        
        // If we have focus, then we need to immediately create a TextFlow so
        // the interaction manager will be created and editing/selection can
        // be done without having to mouse click or mouse hover over this field.
        // Normally this is done in our focusIn handler by making sure there
        // is a selection.    
        if (getFocus() == this)
        {
           content = importToFlow(value);
           return;
        }
                    
        // Setting 'text' temporarily causes 'content' to become null.
        // Later, after the 'text' has been committed into the TextFlow,
        // getting 'content' will return the TextFlow.
        _content = null;
        contentChanged = false;
        
        _text = value;

        // Need to set it right away so that the getter can return it.
        _textContainerManager.setText(_text);
        
        textChanged = true;
        
        invalidateProperties();
        invalidateSize();
        invalidateDisplayList();
    }
    
    //----------------------------------
    //  textFlow
    //----------------------------------
    
    /**
     *  Documentation is not currently available.
     */
    public function get textFlow():TextFlow
    {
    	if (debug)
    		trace("getTextFlow()");
    	return _textContainerManager.getTextFlow();
    }
    
    //----------------------------------
    //  widthInChars
    //----------------------------------

    /**
     *  @private
     *  These are measured in ems.
     */
    private var _widthInChars:Number = 15;

    /**
     *  @private
     */
    private var widthInCharsChanged:Boolean = true;
        
    /**
     *  The default width for the TextInput, measured in em units.
     *  Em is defined as simply the current point size.  The width
     *  of the "M" character is used for the calculation.
     *
     *  @default
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get widthInChars():Number 
    {
        return _widthInChars;
    }
    
    /**
     *  @private
     */
    public function set widthInChars(value:Number):void
    {
        if (value == _widthInChars)
            return;

        _widthInChars = value;
        widthInCharsChanged = true;
        
        invalidateSize();
        invalidateDisplayList();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Methods: UIComponent
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    override protected function commitProperties():void
    {
        super.commitProperties();
        
        if (hostFormatChanged)
        {
	        // If the CSS styles for this component specify an embedded font,
	        // embeddedFontContext will be set to the module factory that
	        // should create TextLines (since they must be created in the
	        // SWF where the embedded font is.)
	        // Otherwise, this will be null.
            embeddedFontContext = getEmbeddedFontContext();
            
            if (debug)
            	trace("hostFormat=");
            _textContainerManager.hostFormat =
            	hostFormat = new CSSTextLayoutFormat(this);
       			// Note: CSSTextLayoutFormat has special processing
        		// for the fontLookup style. If it is "auto",
        		// the fontLookup format is set to either
        		// "device" or "embedded" depending on whether
        		// embeddedFontContext is null or non-null.

            hostFormatChanged = false;
        }
        
        if (selectionFormatsChanged)
        {
        	if (debug)
        		trace("invalidateInteractionManager()");
        	_textContainerManager.invalidateSelectionFormats();
        	
        	selectionFormatsChanged = false;
        }

        // If the text has line-ending sequences such as LF or CR+LF, 
        // a TextFlow with multiple paragraph is produced as the 'content'. 
        // Otherwise all of the multi-line text got stuffed into one span in 
        // one paragraph. But when you have a large paragraph 
        // (i.e., a large TextBlock), FTE is slow to break the first 
        // TextLine because it analyzes all of the text first.       
        if (textChanged && textHasLineBreaks())
            content = importToFlow(_text);
                          
        if (textChanged)
        {
        	if (debug)
        		trace("setText()");
        	
            textFlowChanged = true;

            // Handle case where content is intially displayed as password.         
            if (displayAsPassword)
               displayAsPasswordChanged = true;


            // Do not set textChanged to false until the compositionComplete
            // handler since the CHANGE event for text that is initially set
            // is a special case since there is no flowOperationEnd event
            // for this.
        }
        else if (contentChanged)
        {
        	var textFlow:TextFlow = createTextFlowFromContent();
        	
        	textFlowChanged = true;
        	
        	if (debug)
        		trace("setTextFlow()");
        	_textContainerManager.setTextFlow(textFlow);

            // Handle case where content is intially displayed as password.        	
        	if (displayAsPassword)
        	   displayAsPasswordChanged = true;
        	   
            // Do not set contentChanged to false until the compositionComplete
            // handler since the CHANGE event for content that is initially set
            // is a special case since there is no flowOperationEnd event
            // for this.
        }

        // If the text or content changed, there is no selection.  If we already
        // have focus, set the selection, since we've already executed our
        // focusIn handler where this is normally done.
        if (textFlowChanged && getFocus() == this)
            setSelectionBasedOnScrolling();
                
        // If displayAsPassword changed, it only applies to the display, 
        // not the underlying text.  Do not mark the textFlow as changed.
        if (displayAsPasswordChanged)
        {
            // If there is any text, convert it to the passwordChar.
            if (displayAsPassword)
            {
                // Make sure _text is set with the actual text before we
                // change the displayed text.
                _text = _textContainerManager.getText("\n");
                
                // ToDo: if content, should the paragraph terminators be
                // left in the string so the displayAsPassword string has the
                // same form as the original string?  This is only an issue
                // for TextArea.
                var textToDisplay:String = StringUtil.repeat(
                    passwordChar, _text.length);
                    
                _textContainerManager.setText(textToDisplay);                            
            }
            else
            {
                _textContainerManager.setText(_text);
            }

            displayAsPasswordChanged = false;
        }
        
        if (enabledChanged || selectableChanged || editableChanged)
        {
        	updateEditingMode();
        	
            enabledChanged = false;
            editableChanged = false;
            selectableChanged = false;        	
        }
                        
        if (clipAndEnableScrollingChanged)
        {
            // Not sure if there is any real difference between on and auto.
            // The TLF code seems to check for !off.
            if (_clipAndEnableScrolling)
            {
                _textContainerManager.horizontalScrollPolicy = "on";
                _textContainerManager.verticalScrollPolicy = "on";
            }
            else
            {
                _textContainerManager.horizontalScrollPolicy = "auto";
                _textContainerManager.verticalScrollPolicy = "auto";
            }
            clipAndEnableScrollingChanged = false;
        }
                                    
        if (horizontalScrollPositionChanged)
        {
            var oldHorizontalScrollPosition:Number = 
                _textContainerManager.horizontalScrollPosition;
                
            _textContainerManager.horizontalScrollPosition =
                _horizontalScrollPosition; 
                           
            dispatchPropertyChangeEvent("horizontalScrollPosition",
                oldHorizontalScrollPosition, _horizontalScrollPosition);
            
            horizontalScrollPositionChanged = false;            
        }
        
        if (verticalScrollPositionChanged)
        {
            var oldVerticalScrollPosition:Number = 
                _textContainerManager.verticalScrollPosition;
                
            _textContainerManager.verticalScrollPosition =
                _verticalScrollPosition;
                
            dispatchPropertyChangeEvent("verticalScrollPosition",
                oldVerticalScrollPosition, _verticalScrollPosition);
            
            verticalScrollPositionChanged = false;            
        }
    }

    /**
     *  @private
     *  We override the setLayoutBoundsSize to determine whether to perform
     *  text reflow. This is a convenient place, as the layout passes NaN
     *  for a dimension not constrained to the parent.
     */
    override public function setLayoutBoundsSize(
                                width:Number, height:Number,
                                postLayoutTransform:Boolean = true):void
    {
        //trace("setLayoutBoundsSize", width, height);
        
        super.setLayoutBoundsSize(width, height, postLayoutTransform);

        // Only autoSize cares about the real measured width.
        if (!actuallyAutoSizing)
            return;
            
        // TODO Possible optimization - if we reflow the text
        // immediately, we'll be able to detect whether the constrained
        // width causes the measured height to change.
        // Also certain layouts like vertical/horizontal will
        // be able to get the better performance as subsequent elements
        // will not go through updateDisplayList twice. This also has the
        // potential of avoiding text compositing during measure.

        // Did we already constrain the width?
        if (widthConstraint == width)
            return;
        
        // No reflow for explicit lineBreak
        if (getStyle("lineBreak") == "explicit")
            return;

        // If we don't measure
        if (super.skipMeasure())
            return;

        if (!isNaN(explicitHeight))
            return;

        // We support reflow only in the case of constrained width and
        // unconstrained height. Note that we compare with measuredWidth,
        // as for example the RichEditableText can be
        // constrained by the layout with "left" and "right", but the
        // container width itself may not be constrained and it would depend
        // on the element's measuredWidth.
        var constrainedWidth:Boolean = 
                !isNaN(width) && (width != measuredWidth) && (width != 0);                 
        if (!constrainedWidth)
            return;
            
        // We support reflow only when we don't have a transform.
        // We could add support for scale, but not skew or rotation.
        var matrix:Matrix = postLayoutTransform ? nonDeltaLayoutMatrix() : null;
        if (matrix != null)
            return;

        widthConstraint = width;
        
        invalidateSize();
    }
    
    /**
     *  @private
     */
    override protected function skipMeasure():Boolean
    {
        // If explicit width and height then definately not autoSizing.
        if (super.skipMeasure())
        {
            actuallyAutoSizing = false;
            return true;
        }
        
        var oldActuallyAutoSizing:Boolean = actuallyAutoSizing;
        
        // AutoSize if it is requested and this component isn't the viewport
        // of a scroller.  autoSize and scrolling don't play well together.            
        actuallyAutoSizing = _autoSize && !_clipAndEnableScrolling;
        
        // If we're autoSizing now, make sure we aren't scrolled from previously
        // not being autoSized.
        if (actuallyAutoSizing && !oldActuallyAutoSizing)
        {
            _textContainerManager.horizontalScrollPosition = 0;
            _textContainerManager.verticalScrollPosition = 0;
        }
        
        return false;        
    }
    
    /**
     *  @private
     */
    override protected function measure():void 
    {
        super.measure();
        
        // Recalculate the ascent, and descent, if fontMetrics changed.
        calculateFontMetrics();    
    
        if (actuallyAutoSizing)
        {
            measureForAutoSize();
        }
        else
        {
            // Go large.  For performance reasons, want to avoid a scrollRect 
            // whenever possible in drawBackgroundAndSetScrollRect().  This is
            // particularly true for 1 line TextInput components.
            measuredWidth = Math.ceil(calculateWidthInChars());
            measuredHeight = Math.ceil(calculateHeightInLines());
        }    
               
        //trace("measure", measuredWidth, measuredHeight);
    }

    /**
     *  @private
     */
    override protected function updateDisplayList(unscaledWidth:Number,
                                                  unscaledHeight:Number):void 
    {
        //trace("updateDisplayList", unscaledWidth, unscaledHeight);

        super.updateDisplayList(unscaledWidth, unscaledHeight);

        // If we're autoSizing we're telling the layout manager one set of
        // values and TLF another set of values so there is room for the text
        // to grow.  The composition values for autoSize were set when the 
        // text was measured.
        if (!actuallyAutoSizing)
        {
            _textContainerManager.compositionWidth = unscaledWidth;
            _textContainerManager.compositionHeight = unscaledHeight;
        }

		if (debug)
			trace("updateContainer()");
			
        _textContainerManager.textLineCreator = 
            ITextLineCreator(embeddedFontContext);
            
        _textContainerManager.updateContainer();
    }

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    override public function stylesInitialized():void
    {
        super.stylesInitialized();

        fontMetricsInvalid = true;
        hostFormatChanged = true;
    }

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    override public function styleChanged(styleProp:String):void
    {
        super.styleChanged(styleProp);

        if (styleProp == null || styleProp == "styleName" ||
            styleProp == "fontFamily" || styleProp == "fontSize")
        {
            fontMetricsInvalid = true;
        }

        // If null or "styleName" is passed, indicating that
        // multiple styles may have changed, set a flag indicating
        // that hostContainerFormat, hostParagraphFormat,
        // and hostCharacterFormat need to be recalculated later.
        // But if a single style has changed, update the corresponding
        // property in either hostContainerFormat, hostParagraphFormat,
        // or hostCharacterFormat immediately.
        if (styleProp == null || styleProp == "styleName")
        {
            hostFormatChanged = true;
            selectionFormatsChanged = true;
        }
        else if (isSelectionFormat(styleProp))
        {
            selectionFormatsChanged = true;
        }
        else
        {
            hostFormatChanged = true;
        }

        // Need to regenerate text flow.
        invalidateProperties();
    }

    //--------------------------------------------------------------------------
    //
    //  Methods: IViewport
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  horizontalScrollPositionDelta
    //----------------------------------

    /**
     *  @copy mx.layout.LayoutBase#getHorizontalScrollPositionDelta
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function getHorizontalScrollPositionDelta(scrollUnit:uint):Number
    {
        var scrollR:Rectangle = scrollRect;
        if (!scrollR)
            return 0;

        // maxDelta is the horizontalScrollPosition delta required 
        // to scroll to the RIGHT and minDelta scrolls to LEFT. 
        var maxDelta:Number = contentWidth - scrollR.right;
        var minDelta:Number = -scrollR.left;
        
        // Scroll by a "character" which is 1 em (matches widthInChars()).
        var em:Number = getStyle("fontSize");
            
        // ToDo: what if blockDirection!=TB and direction!=LTR?                   
        switch (scrollUnit)
        {
            case ScrollUnit.LEFT:
                return (scrollR.left <= 0) ? 0 : Math.max(minDelta, -em);
                
            case ScrollUnit.RIGHT:
                return (scrollR.right >= contentWidth) ? 0 : Math.min(maxDelta, em);
                
            case ScrollUnit.PAGE_LEFT:
                return Math.max(minDelta, -scrollR.width);
                
            case ScrollUnit.PAGE_RIGHT:
                return Math.min(maxDelta, scrollR.width);
                
            case ScrollUnit.HOME: 
                return minDelta;
                
            case ScrollUnit.END: 
                return maxDelta;
                
            default:
                return 0;
        }
    }
    
    //----------------------------------
    //  verticalScrollPositionDelta
    //----------------------------------

    /**
     *  @copy mx.layout.LayoutBase#getVerticalScrollPositionDelta
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function getVerticalScrollPositionDelta(scrollUnit:uint):Number
    {
        var scrollR:Rectangle = scrollRect;
        if (!scrollR)
            return 0;

        // maxDelta is the horizontalScrollPosition delta required 
        // to scroll to the END and minDelta scrolls to HOME. 
        var maxDelta:Number = contentHeight - scrollR.bottom;
        var minDelta:Number = -scrollR.top;
                
        // ToDo: what if blockDirection!=TB and direction!=LTR?                   
        switch (scrollUnit)
        {
            case ScrollUnit.UP:
                return _textContainerManager.getScrollDelta(-1);
                
            case ScrollUnit.DOWN:
                return _textContainerManager.getScrollDelta(1);
                
            case ScrollUnit.PAGE_UP:
                return Math.max(minDelta, -scrollR.height);
                
            case ScrollUnit.PAGE_DOWN:
                return Math.min(maxDelta, scrollR.height);
                
            case ScrollUnit.HOME:
                return minDelta;
                
            case ScrollUnit.END:
                return maxDelta;
                
            default:
                return 0;
        }       
    }
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
    
	/**
	 *  @private
	 */
	mx_internal function createTextContainerManager():TextContainerManager
	{
		return new RichEditableTextContainerManager(
			this, staticTextContainerManagerConfiguration);
	}

	/**
	 *  @private
	 *  Uses the component's CSS styles to determine the module factory
	 *  that should creates its TextLines.
	 */
	private function getEmbeddedFontContext():IFlexModuleFactory
	{
		var fontContext:IFlexModuleFactory;
		
		var fontLookup:String = getStyle("fontLookup");
		if (fontLookup != FontLookup.DEVICE)
        {
			var font:String = getStyle("fontFamily");
			var bold:Boolean = getStyle("fontWeight") == "bold";
			var italic:Boolean = getStyle("fontStyle") == "italic";
			
            fontContext = embeddedFontRegistry.getAssociatedModuleFactory(
            	font, bold, italic, this, moduleFactory);

            // If we found the font, then it is embedded. 
            // But some fonts are not listed in info()
            // and are therefore not in the above registry.
            // So we call isFontFaceEmbedded() which gets the list
            // of embedded fonts from the player.
            if (!fontContext) 
            {
                var sm:ISystemManager;
                if (moduleFactory != null && moduleFactory is ISystemManager)
                	sm = ISystemManager(moduleFactory);
                else if (parent is IUIComponent)
                	sm = IUIComponent(parent).systemManager;

                staticTextFormat.font = font;
                staticTextFormat.bold = bold;
                staticTextFormat.italic = italic;
                
                if (sm != null && sm.isFontFaceEmbedded(staticTextFormat))
                    fontContext = sm;
            }
        }

        if (!fontContext && fontLookup == FontLookup.EMBEDDED_CFF)
        {
            // if we couldn't find the font and somebody insists it is
            // embedded, try the default moduleFactory
            fontContext = moduleFactory;
        }
        
        return fontContext;
	}

    /**
     *  @private
     *  The editingMode is set to READ_SELECT if not already READ_SELECT or
     *  READ_WRITE.
     *  When done call releaseSelectionManager().
     */
    private function getSelectionManager():ISelectionManager
    {
        priorEditingMode = editingMode;
        
        if (editingMode == EditingMode.READ_ONLY)
            editingMode = EditingMode.READ_SELECT;

    	return SelectionManager(_textContainerManager.beginInteraction());
    }

    /**
     *  @private
     */
    private function releaseSelectionManager():void
    {
        _textContainerManager.endInteraction();
        
        editingMode = priorEditingMode;
    }

    /**
     *  @private
     *  The editingMode is set to READ_WRITE.
     *  When done call releaseEditManager().
     */
    private function getEditManager():IEditManager
    {
        // This triggers a damage event if the interactionManager is
        // changed. 
                
        priorEditingMode = editingMode;
        
        if (editingMode != EditingMode.READ_WRITE)
            editingMode = EditingMode.READ_WRITE;
        
        return EditManager(_textContainerManager.beginInteraction());
    }

    /**
     *  @private
     */
    private function releaseEditManager():void
    {
        _textContainerManager.endInteraction();

        editingMode = priorEditingMode;
    }

    /**
     *  @private
     */
    private function setSelectionBasedOnScrolling(always:Boolean=true):void
    {
        // Only set the selection if there isn't already one.
        if (!always)
        {
            var done:Boolean = false;
            var sm:ISelectionManager = getSelectionManager();
            if (sm.hasSelection())
                done = true;
            releaseSelectionManager();
            
            if (done)
                return;
        }
        
        // If scrolling, the selection/insertion point is at the begining.
        // Othewise, it is at the end.
        if (_clipAndEnableScrolling)                
            setSelection(0, 0);
        else
            setSelection(int.MAX_VALUE, int.MAX_VALUE);
    }
    
    /**
     *  @private
     *  If the explicit widths and heights are not set to NaN, the 
     *  measuredWidth and measuredHeight are clamped down to these values
     *  when measure() returns to UIComponent.measureSizes().
     */
    private function measureForAutoSize():void
    {        
        var composeWidth:Number;                                       

        // Need to set a width to cause a wrap.  Use constrainedWidth,
        // explicit maxWidth or default for maxWidth, in that order.
        // Never compose over max width because the width will always be 
        // adjusted down to this and it's easy to get into an infinite 
        // measure/update display loop.            
        if (hostFormat.lineBreak == "toFit")
        {
            // Constrain the width if it's less than maxWidth.
            if (!isNaN(widthConstraint) && widthConstraint <= maxWidth)
            {
                composeWidth = widthConstraint
            }
            else
            {
                // The default maxWidth is 10000 which isn't a 
                // reasonable default for the autoSize width so use the default
                // measured width which is 160 instead.
                composeWidth = !isNaN(explicitMaxWidth) ?
                               explicitMaxWidth : 
                               UIComponent.DEFAULT_MEASURED_WIDTH;
            }
            explicitMinWidth = NaN;
        }
        else
        {             
            // Let the text determine the width.  Ignore explicit widths.
            composeWidth = NaN;
            explicitMinWidth = explicitMaxWidth = NaN;                
        }
        
        // Ignore all explicit heights.
        explicitMinHeight = explicitMaxHeight = NaN;
                                  
        // The bottom border can grow to allow all the text to fit.
        // If dimension is NaN, composer will measure text in that 
        // direction. 
        _textContainerManager.compositionWidth = composeWidth;
        _textContainerManager.compositionHeight = NaN;

        // Compose only.  The display is not updated.
        _textContainerManager.compose();

        var contentBounds:Rectangle = _textContainerManager.getContentBounds();
        
        // If it's an empty text flow, there is one line with one
        // character so the height is good for the line.
        measuredHeight = Math.ceil(contentBounds.height);

        if (_textContainerManager.getText().length > 0) 
        {
            // Text flow with a terminator (which has width).
            measuredWidth = Math.ceil(contentBounds.width);
        }
        else
        {
            // Empty text flow.  One Em wide so there
            // is a place to put the insertion cursor.
            measuredWidth = Math.ceil(contentBounds.width +
                                       getStyle("fontSize"));
       }
    }

    /**
     *  @private
     *  This method is called when anything affecting the
     *  default font, size, weight, etc. changes.
     *  It calculates the 'ascent', 'descent', and
     *  instance variables, which are used in measure().
     */
    private function calculateFontMetrics():void
    {
        if (!fontMetricsInvalid)
            return;
            
        // If the CSS styles for this component specify an embedded font,
        // embeddedFontContext will be set to the module factory that
        // should create TextLines (since they must be created in the
        // SWF where the embedded font is.)
        // Otherwise, this will be null.
        embeddedFontContext = getEmbeddedFontContext();
        
        var fontDescription:FontDescription = new FontDescription();
        
        var s:String;

        s = getStyle("cffHinting");
        if (s != null)
        	fontDescription.cffHinting = s;
        
        s = getStyle("fontFamily");
        if (s != null)
        	fontDescription.fontName = s;
        
        s = getStyle("fontLookup");
        if (s != null)
        {
        	// FTE understands only "device" and "embeddedCFF"
        	// for fontLookup. But Flex allows this style to be
        	// set to "auto", in which case we automatically
        	// determine it based on whether the CSS styles
        	// specify an embedded font.
        	if (s == "auto")
        	{
        		s = embeddedFontContext ?
        			FontLookup.EMBEDDED_CFF :
                	FontLookup.DEVICE;
        	}
        }
         
        s = getStyle("fontStyle");
        if (s != null)
        	fontDescription.fontPosture = s;
        
        s = getStyle("fontWeight");
        if (s != null)
        	fontDescription.fontWeight = s;
        
        var elementFormat:ElementFormat = new ElementFormat();
        elementFormat.fontDescription = fontDescription;
        elementFormat.fontSize = getStyle("fontSize");
        
        var textElement:TextElement = new TextElement();
        textElement.elementFormat = elementFormat;
        textElement.text = "M";
        
        var textBlock:TextBlock = new TextBlock();
        textBlock.content = textElement;
        
        var textLine:TextLine = textBlock.createTextLine(null, 1000);
        
        ascent = textLine.ascent;
        descent = textLine.descent;

        fontMetricsInvalid = false;                    
    }
    
    /**
     *  @private
     */
    private function calculateWidthInChars():Number
    {
    	var em:Number = getStyle("fontSize");
    	
    	// Without the explicit casts, if padding values are non-zero, the
    	// returned width is a very large number.
    	return getStyle("paddingLeft") +
    		   widthInChars * em +
    		   getStyle("paddingRight");
    }
    
    /**
     *  @private
     *  Calculates the height needed for heightInLines lines using the default
     *  font.
     */
    private function calculateHeightInLines():Number
    {
        var height:Number = getStyle("paddingTop") + getStyle("paddingBottom");
            
        if (heightInLines == 0)
            return height;
                        
        // Position of the baseline of first line in the container.
        value = getStyle("firstBaselineOffset");
        if (value == lineHeight)
            height += lineHeight;
        else if (value is Number)
            height += Number(value);
        else
            height += ascent;

        // Distance from baseline to baseline.  Can be +/- number or 
        // or +/- percent (in form "120%") or "undefined".  
        if (heightInLines > 1)
        {
            var value:Object = getStyle("lineHeight");     
            var lineHeight:Number =
            	TextUtil.getNumberOrPercentOf(value, getStyle("fontSize"));
                
            // Default is 120%
            if (isNaN(lineHeight))
                lineHeight = getStyle("fontSize") * 1.2;
            
            height += (heightInLines - 1) * lineHeight;
        }            
        
        // Add in descent of last line.
        height += descent;              
        
        return height;
    }
        
    /**
     *  @private
     */
    private function createEmptyTextFlow():TextFlow
    {
        var textFlow:TextFlow = new TextFlow();
        var p:ParagraphElement = new ParagraphElement();
        var span:SpanElement = new SpanElement();
        textFlow.replaceChildren(0, 0, p);
        p.replaceChildren(0, 0, span);
        return textFlow;
    }
    
    /**
     *  @private
     */
    private function createTextFlowFromMarkup(markup:Object):TextFlow
    {
        // The whiteSpaceCollapse format determines how whitespace
        // is processed when markup is imported.
        staticTextLayoutFormat.lineBreak = FormatValue.INHERIT;
        staticTextLayoutFormat.paddingLeft = FormatValue.INHERIT;
        staticTextLayoutFormat.paddingRight = FormatValue.INHERIT;
        staticTextLayoutFormat.paddingTop = FormatValue.INHERIT;
        staticTextLayoutFormat.paddingBottom = FormatValue.INHERIT;
        staticTextLayoutFormat.verticalAlign = FormatValue.INHERIT;
        staticTextLayoutFormat.whiteSpaceCollapse =
            getStyle("whiteSpaceCollapse");
        staticImportConfiguration.textFlowInitialFormat =
            staticTextLayoutFormat;

        if (markup is XML || markup is String)
        {
            // We need to wrap the markup in a <TextFlow> tag
            // unless it already has one.
            // Note that we avoid trying to convert it to XML
            // (in order to test whether the outer tag is <TextFlow>)
            // unless it contains the substring "TextFlow".
            // And if we have to do the conversion, then
            // we use the markup in XML form rather than
            // having TLF reconvert it to XML.
            var wrap:Boolean = true;
            if (markup is XML || markup.indexOf("TextFlow") != -1)
            {
                try
                {
                    var xmlMarkup:XML = XML(markup);
                    if (xmlMarkup.localName() == "TextFlow")
                    {
                        wrap = false;
                        markup = xmlMarkup;
                    }
                }
                catch(e:Error)
                {
                }
            }

            if (wrap)
            {
                if (markup is String)
                {
                    markup = 
                        '<TextFlow xmlns="http://ns.adobe.com/textLayout/2008">' +
                        markup +
                        '</TextFlow>';
                }
                else
                {
                    // It is XML.  Create a root element and add the markup
                    // as it's child.
                    var ns:Namespace = 
                        new Namespace("http://ns.adobe.com/textLayout/2008");
                                                 
                    xmlMarkup = <TextFlow />;
                    xmlMarkup.setNamespace(ns);            
                    xmlMarkup.setChildren(markup);  
                                        
                    // The namespace of the root node is not inherited by
                    // the children so it needs to be explicitly set on
                    // every element, at every level.  If this is not done
                    // the import will fail with an "Unexpected namespace"
                    // error.
                    for each (var element:XML in xmlMarkup..*::*)
                       element.setNamespace(ns);

                    markup = xmlMarkup;
                }
            }
        }
        
        return importToFlow(markup, TextFilter.TEXT_LAYOUT_FORMAT,
                            staticImportConfiguration);
    }
    
    /**
     *  @private
     */
    private function createTextFlowFromChildren(children:Array):TextFlow
    {
        var textFlow:TextFlow = new TextFlow();

        // The whiteSpaceCollapse format determines how whitespace
        // is processed when the children are set.
        staticTextLayoutFormat.lineBreak = FormatValue.INHERIT;
        staticTextLayoutFormat.paddingLeft = FormatValue.INHERIT;
        staticTextLayoutFormat.paddingRight = FormatValue.INHERIT;
        staticTextLayoutFormat.paddingTop = FormatValue.INHERIT;
        staticTextLayoutFormat.paddingBottom = FormatValue.INHERIT;
        staticTextLayoutFormat.verticalAlign = FormatValue.INHERIT;
        staticTextLayoutFormat.whiteSpaceCollapse =
            getStyle("whiteSpaceCollapse");
        textFlow.hostFormat = staticTextLayoutFormat;

        textFlow.mxmlChildren = children;

        return textFlow;
    }

    /**
     *  @private
     */
    private function createTextFlowFromContent():TextFlow
    {
    	var textFlow:TextFlow;
    	
        if (_content is TextFlow)
        {
            textFlow = TextFlow(_content);
        }
        else if (_content is Array)
        {
            textFlow = createTextFlowFromChildren(_content as Array);
        }
        else if (_content is FlowElement)
        {
            textFlow = createTextFlowFromChildren([ _content ]);
        }
        else if (_content is String || _content is XML)
        {
            textFlow = createTextFlowFromMarkup(_content);
        }
        else if (_content == null)
        {
            textFlow = createEmptyTextFlow();
        }
        else
        {
            textFlow = createTextFlowFromMarkup(_content.toString());
        }
        
        return textFlow;
    }
    
    /**
     *  @private
     *  This will throw on import error.
     */
    private function importToFlow(source:Object, 
                                  format:String = TextFilter.PLAIN_TEXT_FORMAT, 
                                  config:Configuration = null):TextFlow
    {
        var importer:ITextImporter = TextFilter.getImporter(format, config);
        
        // Throw import errors rather than return a null textFlow.
        // Alternatively, the error strings are in the Vector, importer.errors.
        importer.throwOnError = true;
        
        return importer.importToFlow(source);        
    }

    /**
     *  @private
     */
    private function textHasLineBreaks():Boolean
    {
        return text.indexOf("\n") != -1 ||
               text.indexOf("\r") != -1;
    }
    
    /**
     *  @private
     *  Is this a style associated with the SelectionFormat?
     */
    private function isSelectionFormat(styleProp:String):Boolean
    {        
        return styleProp &&
               (styleProp == "selectionColor" || 
                styleProp == "unfocusedSelectionColor" ||
                styleProp == "inactiveSelectionColor");
    }
       
    /**
     *  @private
     */
    private function updateEditingMode():void
    {
    	var newEditingMode:String = EditingMode.READ_ONLY;
    	
    	if (enabled)
    	{
    		if (_editable)
    			newEditingMode = EditingMode.READ_WRITE;
    		else if (_selectable)
    			newEditingMode = EditingMode.READ_SELECT;
    	}
    	
  		editingMode = newEditingMode;
    }

    /**
     *  Sets the selection range.  By default, the entire range is selected.
     *  If you pass negative numbers for the position, it will deselect. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function setSelection(anchorPosition:int = 0,
                                 activePosition:int = int.MAX_VALUE):void
    {
		var selectionManager:ISelectionManager = getSelectionManager();
        
        selectionManager.setSelection(anchorPosition, activePosition);        
                
        // Refresh the selection.  This does not cause a damage event.
        selectionManager.refreshSelection();
        
        releaseSelectionManager();
    }
    
    /**
     *  @copy flashx.textLayout.container.ContainerController#scrollToPosition() 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function scrollToPosition(anchorPosition:int = 0,
                                     activePosition:int = int.MAX_VALUE):void
    {
       // Scrolls so that the text position is visible in the container. 
       textContainerManager.scrollToPosition(anchorPosition, activePosition);       
    }
        
    /**
     *  Inserts the specified text as if you had typed it.
     *  If a range was selected, the new text replaces the selected text;
     *  if there was an insertion point, the new text is inserted there,
     *  otherwise the text is appended to the text that is there.
     *  An insertion point is then set after the new text.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function insertText(text:String):void
    {        
        // Make sure all properties are committed before doing the insert.
        validateNow();

        // Always use the EditManager regardless of the values of
        // selectable, editable and enabled.
        var editManager:IEditManager = getEditManager();
        
        // If no selection, then it's an append.
         if (!editManager.hasSelection())
            editManager.setSelection(int.MAX_VALUE, int.MAX_VALUE);
            
        // Our damage handler should be active.  Inserting the text invokes
        // our damage handler to invalidate the text, maybe the size, and
        // the display list.      
        editManager.insertText(text);

        // All done with edit manager.
        releaseEditManager();
    }
    
    /**
     *  Appends the specified text to the end of the TextView,
     *  as if you had clicked at the end and typed it.
     *  When TextView supports vertical scrolling,
     *  it will scroll to ensure that the last line
     *  of the inserted text is visible.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function appendText(text:String):void
    {
        // Make sure all properties are committed before doing the append.
        validateNow();

        // Always use the EditManager regardless of the values of
        // selectable, editable and enabled.
        var editManager:IEditManager = getEditManager();
        
        // An append is an insert with the selection set to the end.
        editManager.setSelection(int.MAX_VALUE, int.MAX_VALUE);

        // Our damage handler should be active.  Inserting the text invokes
        // our damage handler to invalidate the text, maybe the size, and
        // the display list.      
        editManager.insertText(text);

        // All done with edit manager.
        releaseEditManager();
    }

    /**
     *  Returns a String containing markup describing
     *  this TextView's TextFlow.
     *  This markup String has the appropriate format
     *  for setting the <code>content</code> property.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function export():XML
    {
        return XML(TextFilter.export(textFlow, TextFilter.TEXT_LAYOUT_FORMAT,
                                     ConversionType.XML_TYPE));
    }

    /**
     *  Returns an Object containing name/value pairs of text attributes
     *  for the specified range.
     *  If an attribute is not consistently set across the entire range,
     *  its value will be null.
     *  You can specify an Array containing names of the attributes
     *  that you want returned; if you don't, all attributes will be returned.
     *  If you don't specify a range, the selected range is used.
     *  For example, calling
     *  <code>getSelectionFormat()</code>
     *  might return <code>({ fontSize: 12, color: null })</code>
     *  if the selection is uniformly 12-point but has multiple colors.
     *  The supported attributes are those in the
     *  ICharacterAttributes and IParagraphAttributes interfaces.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function getSelectionFormat(names:Array = null):Object
    {
        var format:Object = {};
        
        var selectionManager:ISelectionManager = getSelectionManager();
                
        // This internal TLF object maps the names of format properties
        // to Property instances.
        // Each Property instance has a category property which tells
        // whether it is container-, paragraph-, or character-level.
        var description:Object = TextLayoutFormat.tlf_internal::description;
            
        var p:String;
        var category:String;
        
        // Based on which formats have been requested, determine which
        // of the getCommonXXXFormat() methods we need to call.

        var needContainerFormat:Boolean = false;
        var needParagraphFormat:Boolean = false;
        var needCharacterFormat:Boolean = false;

        if (!names)
        {
            names = [];
            for (p in description)
                names.push(p);
            
            needContainerFormat = true;
            needParagraphFormat = true;
            needCharacterFormat = true;
        }
        else
        {
            for each (p in names)
            {
                if (!(p in description))
                    continue;
                    
                category = description[p].category;

                if (category == Category.CONTAINER)
                    needContainerFormat = true;
                else if (category == Category.PARAGRAPH)
                    needParagraphFormat = true;
                else if (category == Category.CHARACTER)
                    needCharacterFormat = true;
            }
        }

        // Get the common formats.
        
        var containerFormat:ITextLayoutFormat;
        var paragraphFormat:ITextLayoutFormat;
        var characterFormat:ITextLayoutFormat;
        
        if (needContainerFormat)
            containerFormat = selectionManager.getCommonContainerFormat();
        
        if (needParagraphFormat)
            paragraphFormat = selectionManager.getCommonParagraphFormat();

        if (needCharacterFormat)
            characterFormat = selectionManager.getCommonCharacterFormat();

        // Extract the requested formats to return.
        for each (p in names)
        {
            if (!(p in description))
                continue;
                
            category = description[p].category;
            
            if (category == Category.CONTAINER && containerFormat)
                format[p] = containerFormat[p];
            else if (category == Category.PARAGRAPH && paragraphFormat)
                format[p] = paragraphFormat[p];
            else if (category == Category.CHARACTER && characterFormat)
                format[p] = characterFormat[p];
        }
        
        // All done with the selection manager.
        releaseSelectionManager();

        return format;
    }

    /**
     *  Applies a set of name/value pairs of text attributes
     *  to the specified range.
     *  A value of null does not get applied.
     *  If you don't specify a range, the selected range is used.
     *  For example, calling
     *  <code>setSelectionFormat({ fontSize: 12, color: 0xFF0000 })</code>
     *  will set the fontSize and color of the selection.
     *  The supported attributes are those in the
     *  ICharacterFormat and IParagraphFormat interfaces.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function setSelectionFormat(attributes:Object):void
    {
        var editManager:IEditManager = getEditManager();
        
        // Assign each specified attribute to one of three format objects,
        // depending on whether it is container-, paragraph-,
        // or character-level. Note that these can remain null.
        var containerFormat:TextLayoutFormat;
        var paragraphFormat:TextLayoutFormat;
        var characterFormat:TextLayoutFormat;

        // This internal TLF object maps the names of format properties
        // to Property instances.
        // Each Property instance has a category property which tells
        // whether it is container-, paragraph-, or character-level.
        var description:Object = TextLayoutFormat.tlf_internal::description;
        
        for (var p:String in attributes)
        {
            if (!(p in description))
                continue;
                
            var category:String = description[p].category;
            
            if (category == Category.CONTAINER)
            {
                if (!containerFormat)
                   containerFormat =  new TextLayoutFormat();
                containerFormat[p] = attributes[p];
            }
            else if (category == Category.PARAGRAPH)
            {
                if (!paragraphFormat)
                   paragraphFormat =  new TextLayoutFormat();
                paragraphFormat[p] = attributes[p];
            }
            else if (category == Category.CHARACTER)
            {
                if (!characterFormat)
                   characterFormat =  new TextLayoutFormat();
                characterFormat[p] = attributes[p];
            }
        }
        
        // Apply the three format objects to the current selection.
        editManager.applyFormat(
        	characterFormat, paragraphFormat, containerFormat);
        
        // All done with the edit manager.
        releaseEditManager();
    }

	/**
	 *  @private
	 */
    private function handlePasteOperation(op:PasteOperation):void
    {
        if (!restrict && !maxChars && !displayAsPassword)
            return;
            
        var textScrap:TextScrap = op.scrapToPaste();
        
        // If copied/cut from displayAsPassword field the pastedText
        // is '*' characters but this is correct.
        var pastedText:String = TextUtil.extractText(
            textScrap.tlf_internal::textFlow);

        // We know it's an EditManager or we wouldn't have gotten here.
        var editManager:IEditManager = getEditManager();

        // Generate a CHANGING event for the PasteOperation but not for the
        // DeleteTextOperation or the InsertTextOperation which are also part
        // of the paste.
        dispatchChangingEvent = false;
                        
        var selectionState:SelectionState = new SelectionState(
        	textFlow, op.absoluteStart, op.absoluteStart + pastedText.length);             
        editManager.deleteText(selectionState);

        // Insert the same text, the same place where the paste was done.
        // This will go thru the InsertPasteOperation and do the right
        // things with restrict, maxChars and displayAsPassword.
        selectionState = new SelectionState(
        	textFlow, op.absoluteStart, op.absoluteStart);
        editManager.insertText(pastedText, selectionState);        

        // All done with the edit manager.
        releaseEditManager();
        
        dispatchChangingEvent = true;
    }
            
    //--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  RichEditableTextContainerManager overrides focusInHandler and calls
     *  this before executing it's own focusInHandler.
     */
    mx_internal function focusInHandler(event:FocusEvent):void
    {
        //trace("focusIn handler");
            
        if (_editable)
        {
            // If no selection, give it one so that the underlying selection
            // manager is put in place if it isn't already there and editing
            // will work without doing a mouse click or mouse hover first.           
            setSelectionBasedOnScrolling(false);

            if (_imeMode != null)
            {
                IME.enabled = true;
                prevMode = IME.conversionMode;
                // When IME.conversionMode is unknown it cannot be
                // set to anything other than unknown(English)      
                try
                {
                    if (!errorCaught &&
                        IME.conversionMode != IMEConversionMode.UNKNOWN)
                    {
                        IME.conversionMode = _imeMode;
                    }
                    errorCaught = false;
                }
                catch(e:Error)
                {
                    // Once an error is thrown, focusIn is called 
                    // again after the Alert is closed, throw error 
                    // only the first time.
                    errorCaught = true;
                    var message:String = ResourceManager.getInstance().getString(
                        "controls", "unsupportedMode", [ _imeMode ]);          
                    throw new Error(message);
                }
            }            
        }
        
        if (focusManager && multiline)
            focusManager.defaultButtonEnabled = false;

    }

    /**
     *  @private
     */
    override protected function focusOutHandler(event:FocusEvent):void
    {
        // By default, we clear the undo history when a TextView loses focus.
        if (clearUndoOnFocusOut && undoManager)
            undoManager.clearAll();
                    
        if (focusManager)
            focusManager.defaultButtonEnabled = true;

        if (_imeMode != null && _editable)
        {
            // When IME.conversionMode is unknown it cannot be
            // set to anything other than unknown(English)
            // and when known it cannot be set to unknown           
            if (IME.conversionMode != IMEConversionMode.UNKNOWN 
                && prevMode != IMEConversionMode.UNKNOWN)
                IME.conversionMode = prevMode;
            IME.enabled = false;
        }
    }

    /**
     *  @private
     */ 
    override protected function keyDownHandler(event:KeyboardEvent):void
    {
        if (editingMode != EditingMode.READ_WRITE)
        	return;
        
        if (event.keyCode == Keyboard.ENTER)
        {
            if (multiline)
            {
        		getEditManager().splitParagraph();
        		releaseEditManager();
            }
            else
            {
                dispatchEvent(new FlexEvent(FlexEvent.ENTER));
            }
         }
    }
    
    /**
     *  @private
     */
    private function updateCompleteHandler(event:FlexEvent):void
    {
        // Make sure that if we did a double pass, next time around we'll
        // measure normally
        widthConstraint = NaN;
    }

    /**
     *  @private
     *  Called when the TextContainerManager dispatches a 'compositionComplete'
     *  event when it has recomposed the text into TextLines.
     */
    private function textContainerManager_compositionCompleteHandler(
                                    event:CompositionCompletionEvent):void
    {
        //trace("compositionComplete");
                
        // The text flow changed and there wasn't an editing operation
        // to dispatch the change event so do it here.  This happens if the
        // text/content is set and there are no additional editing operations. 
        // We will ignore textFlow changes that occur because the editManager is
        // being hooked up to the textFlow by the TCM.
        if (textChanged || contentChanged)
        {
            if (textFlowChanged)
            {
                var newEvent:TextOperationEvent =
                    new TextOperationEvent(TextOperationEvent.CHANGE);
                dispatchEvent(newEvent);            
            }
            
            textChanged = false;
            contentChanged = false;        
        }
        textFlowChanged = false;
        
        var dimensionChanged:Boolean = false;
        var oldContentWidth:Number = _contentWidth;

        var newContentBounds:Rectangle = 
            _textContainerManager.getContentBounds();
        var newContentWidth:Number = newContentBounds.width;
        
        // Error correction for rounding errors.  It shouldn't be so but
        // the contentWidth can be slightly larger than the requested
        // compositionWidth.
        if (newContentWidth > _textContainerManager.compositionWidth &&
            Math.round(newContentWidth) == 
            _textContainerManager.compositionWidth)
        { 
            newContentWidth = _textContainerManager.compositionWidth;
        }
            
        if (newContentWidth != oldContentWidth)
        {
            _contentWidth = newContentWidth;
            
            //trace("contentWidth", oldContentWidth, newContentWidth);

            dispatchPropertyChangeEvent(
                "contentWidth", oldContentWidth, newContentWidth);

            dimensionChanged = true;
        }
        
        var oldContentHeight:Number = _contentHeight;
        var newContentHeight:Number = newContentBounds.height;

        // Error correction for rounding errors.  It shouldn't be so but
        // the contentHeight can be slightly larger than the requested
        // compositionHeight.  
        if (newContentHeight > _textContainerManager.compositionHeight &&
            Math.round(newContentHeight) == 
            _textContainerManager.compositionHeight)
        { 
            newContentHeight = _textContainerManager.compositionHeight;
        }
            
        if (newContentHeight != oldContentHeight)
        {
            _contentHeight = newContentHeight;
            
            //trace("contentHeight", oldContentHeight, newContentHeight);
            
            dispatchPropertyChangeEvent(
                "contentHeight", oldContentHeight, newContentHeight);
                
            dimensionChanged = true;
        } 

        // If autoSize and text size changed, need to remeasure.
        if (dimensionChanged && actuallyAutoSizing)
        {
            invalidateSize();
            invalidateDisplayList();
        }
    }
    
    /**
     *  @private
     *  Called when the TextContainerManager dispatches a 'damage' event.
     *  The TextFlow could have been modified interactively or programatically.
     */
    private function textContainerManager_damageHandler(event:DamageEvent):void
    {
        //trace("damageHandler", event.damageAbsoluteStart, event.damageLength);
        
        // The text flow changed.  It could have been either/or content or
        // styles within the flow.
        textFlowChanged = true;
                
        invalidateDisplayList();
    }

    /**
     *  @private
     *  Called when the TextContainerManager dispatches a 'scroll' event
     *  as it autoscrolls.
     */
    private function textContainerManager_scrollHandler(event:Event):void
    {
        var oldHorizontalScrollPosition:Number = _horizontalScrollPosition;
        var newHorizontalScrollPosition:Number =
            _textContainerManager.horizontalScrollPosition;
            
        if (newHorizontalScrollPosition != oldHorizontalScrollPosition)
        {
            _horizontalScrollPosition = newHorizontalScrollPosition;
            
            dispatchPropertyChangeEvent("horizontalScrollPosition",
                oldHorizontalScrollPosition, newHorizontalScrollPosition);
        }
        
        var oldVerticalScrollPosition:Number = _verticalScrollPosition;
        var newVerticalScrollPosition:Number =
            _textContainerManager.verticalScrollPosition;
            
        if (newVerticalScrollPosition != oldVerticalScrollPosition)
        {
            //trace("vsp scroll", oldVerticalScrollPosition, "->", newVerticalScrollPosition);

            _verticalScrollPosition = newVerticalScrollPosition;
            
            dispatchPropertyChangeEvent("verticalScrollPosition",
                oldVerticalScrollPosition, newVerticalScrollPosition);
        }
    }

    /**
     *  @private
     *  Called when the TextContainerManager dispatches a 'selectionChange' event.
     */
    private function textContainerManager_selectionChangeHandler(
                        event:SelectionEvent):void
    {
        var oldAnchor:int = _selectionAnchorPosition;
        var oldActive:int = _selectionActivePosition;
        
        var selectionManager:ISelectionManager = getSelectionManager();
        
        _selectionAnchorPosition = selectionManager.anchorPosition;
        _selectionActivePosition = selectionManager.activePosition;
        
        releaseSelectionManager();

        // Only dispatch the event if the selection has really changed.
        var changed:Boolean = oldAnchor != _selectionAnchorPosition ||
                              oldActive != _selectionActivePosition;
                              
        
        if (changed)
        {    
            //trace("selectionChangeHandler", _selectionAnchorPosition, _selectionActivePosition);
            dispatchEvent(new FlexEvent(FlexEvent.SELECTION_CHANGE));
        }
    }

    /**
     *  @private
     *  Called when the TextContainerManager dispatches an 'operationBegin'
     *  event before an editing operation.
     */     
    private function textContainerManager_flowOperationBeginHandler(
                        event:FlowOperationEvent):void
    {
        //trace("flowOperationBegin", "generation", textFlow.generation);
        
        var op:FlowOperation = event.operation;
   
        // The text flow's generation will be incremented if the text flow
        // is modified in any way by this operation.
             
        if (op is InsertTextOperation)
        {
            var insertTextOperation:InsertTextOperation =
                InsertTextOperation(op);

            var textToInsert:String = insertTextOperation.text;

            // Note: Must process restrict first, then maxChars,
            // then displayAsPassword last.
            
            if (_restrict != null)
            {
                textToInsert = StringUtil.restrict(textToInsert, restrict);
                if (textToInsert.length == 0)
                {
                    event.preventDefault();
                    return;
                }
            }

            if (maxChars != 0)
            {
                var length1:int = text.length;
                var length2:int = textToInsert.length;
                if (length1 + length2 > maxChars)
                    textToInsert = textToInsert.substr(0, maxChars - length1);
            }

            if (_displayAsPassword)
            {
                _text = splice(_text, insertTextOperation.absoluteStart,
                               insertTextOperation.absoluteEnd, textToInsert);
                textToInsert = StringUtil.repeat(passwordChar,
                                                 textToInsert.length);
            }

            insertTextOperation.text = textToInsert;
        }
        else if (op is PasteOperation)
        {
            // Paste is implemented in operationEnd.  The basic idea is to allow 
            // the paste to go through unchanged, but group it together with a 
            // second operation that modifies text as part of the same 
            // transaction. This is vastly simpler for TLF to manage. 
        }
        else if (op is DeleteTextOperation || op is CutOperation)
        {
            var flowTextOperation:FlowTextOperation =
                FlowTextOperation(op);
                              
            // Eat 0-length deletion.  This can happen when insertion point is 
            // at start of container when a backspace is entered
            // or when the insertion point is at the end of the
            // container and a delete key is entered.
            if (flowTextOperation.absoluteStart == 
                flowTextOperation.absoluteEnd)
            {
                event.preventDefault();
                return;
            }           
            
            if (_displayAsPassword)
            {
                _text = splice(_text, flowTextOperation.absoluteStart,
                               flowTextOperation.absoluteEnd, "");
            }
        }
 
        // Dispatch a 'changing' event from the TextView
        // as notification that an editing operation is about to occur.
        if (dispatchChangingEvent)
        {
            var newEvent:TextOperationEvent =
                new TextOperationEvent(TextOperationEvent.CHANGING);
            newEvent.operation = op;
            dispatchEvent(newEvent);
            
            // If the event dispatched from this TextView is canceled,
            // cancel the one from the EditManager, which will prevent
            // the editing operation from being processed.
            if (newEvent.isDefaultPrevented())
                event.preventDefault();
        }
    }
    
    /**
     *  @private
     *  Called when the TextContainerManager dispatches an 'operationEnd' event
     *  after an editing operation.
     */
    private function textContainerManager_flowOperationEndHandler(
                        event:FlowOperationEvent):void
    {
        //trace("flowOperationEnd", "generation", textFlow.generation);
        
        // Paste is a special case.  Any mods have to be made to the text
        // which includes what was pasted.
        if (event.operation is PasteOperation)
            handlePasteOperation(PasteOperation(event.operation));

        // Dispatch a 'change' event from the TextView
        // as notification that an editing operation has occurred.
        var newEvent:TextOperationEvent =
            new TextOperationEvent(TextOperationEvent.CHANGE);
        newEvent.operation = event.operation;
        dispatchEvent(newEvent);
            
        textFlowChanged = false;            
    }

    /**
     *  @private
     *  Called when a InlineGraphicElement is resized due to having width or 
     *  height as auto or percent and the graphic has finished loading.  The
     *  size of the graphic is now known.
     */
    private function textContainerManager_inlineGraphicStatusChangeHandler (
                        event:StatusChangeEvent):void
    {
        //trace("inlineGraphicStatusChangedHandler", event.status);

        // Now that the actual size of the graphic is available need to
        // optionally remeasure and updateContainer.
        if (event.status == InlineGraphicElementStatus.READY)
        {
            if (actuallyAutoSizing)
                invalidateSize();
            
            invalidateDisplayList();
        } 
    }    
}

}
