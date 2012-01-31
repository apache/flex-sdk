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

package spark.components
{

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
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
import flashx.textLayout.container.TextContainerManager;
import flashx.textLayout.conversion.ConversionType;
import flashx.textLayout.conversion.ITextExporter;
import flashx.textLayout.conversion.ITextImporter;
import flashx.textLayout.conversion.TextConverter;
import flashx.textLayout.edit.EditManager;
import flashx.textLayout.edit.EditingMode;
import flashx.textLayout.edit.IEditManager;
import flashx.textLayout.edit.ISelectionManager;
import flashx.textLayout.edit.SelectionManager;
import flashx.textLayout.edit.SelectionState;
import flashx.textLayout.elements.Configuration;
import flashx.textLayout.elements.InlineGraphicElementStatus;
import flashx.textLayout.elements.TextFlow;
import flashx.textLayout.events.CompositionCompleteEvent;
import flashx.textLayout.events.DamageEvent;
import flashx.textLayout.events.FlowOperationEvent;
import flashx.textLayout.events.SelectionEvent;
import flashx.textLayout.events.StatusChangeEvent;
import flashx.textLayout.formats.BlockProgression;
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
import flashx.undo.IOperation;
import flashx.undo.IUndoManager;

import mx.core.IEmbeddedFontRegistry;
import mx.core.IFlexModuleFactory;
import mx.core.IIMESupport;
import mx.core.IUIComponent;
import mx.core.Singleton;
import mx.core.UIComponent;
import mx.core.mx_internal;
import mx.events.FlexEvent;
import mx.managers.IFocusManager;
import mx.managers.IFocusManagerComponent;
import mx.managers.ISystemManager;
import mx.resources.ResourceManager;
import mx.utils.ObjectUtil;
import mx.utils.StringUtil;

import spark.components.TextSelectionHighlighting;
import spark.core.CSSTextLayoutFormat;
import spark.core.IViewport;
import spark.core.NavigationUnit;
import spark.events.TextOperationEvent;
import spark.components.supportClasses.RichEditableTextContainerManager;
import spark.components.supportClasses.RichEditableTextEditManager;
import spark.utils.TextUtil;

use namespace mx_internal;
use namespace tlf_internal;

//--------------------------------------
//  Events
//--------------------------------------

/**
 *  Dispached after the <code>selectionAnchorPosition</code> and/or
 *  <code>selectionActivePosition</code> properties have changed
 *  for any reason.
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
 *  Dispatched when the user presses the Enter key,
 *  if the <code>multiline</code> property is false.
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

include "../styles/metadata/BasicInheritingTextStyles.as"
include "../styles/metadata/BasicNonInheritingTextStyles.as"
include "../styles/metadata/AdvancedInheritingTextStyles.as"
include "../styles/metadata/AdvancedNonInheritingTextStyles.as"
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
[DefaultTriggerEvent("change")]

/**
 *  RichEditableText is a low-level UIComponent for displaying,
 *  scrolling, selecting, and editing richly-formatted text.
 *
 *  <p>The rich text can contain clickable hyperlinks and inline graphics
 *  that are either embedded or loaded from URLs.</p>
 *
 *  <p>RichEditableText does not have scrollbars, but it implements
 *  the IViewport interface for programmatic scrolling so that it
 *  can be controlled by a Scroller, which does provide scrollbars.
 *  It also supports vertical scrolling with the mouse wheel.</p>
 *
 *  <p>It does not include any user interface for changing
 *  the formatting of the text.
 *  But it offers APIs which can do this programmatically;
 *  these make it possible, for example, for you to create 
 *  a Bold button that makes the selected text bold.</p>
 *
 *  <p>This class is used in the skins of the Spark versions
 *  of TextInput and TextArea.
 *  (TextInput does not expose its ability to handle rich text,
 *  but TextArea does.)
 *  By default, RichEditableText has a transparent background,
 *  and it does not support drawing a border.</p>
 *
 *  <p>RichEditableText, which is new with Flex 4,
 *  makes use of the new Text Layout Framework (TLF) library,
 *  which in turn builds on the new Flash Text Engine (FTE)
 *  in Flash Player 10.
 *  In combination, these layers provide text editing with
 *  high-quality international typography and layout.</p>
 *
 *  <p>The Spark architecture provides three text "primitives" -- 
 *  Label, RichText, and RichEditableText --
 *  as part of its pay-only-for-what-you-need philosophy.
 *  Label is the fastest and most lightweight
 *  because it uses only FTE, not TLF,
 *  but it is limited in its capabilities: no rich text,
 *  no scrolling, no selection, and no editing.
 *  RichText adds the ability to display rich text
 *  with complex layout, but is still completely non-interactive.
 *  RichEditableText is the slowest and heaviest,
 *  but offers most of what TLF can do.
 *  You should use the fastest text primitive that meets your needs.</p>
 *
 *  <p>RichEditableText is similar to the UITextField class
 *  used in MX components. This class did not use FTE or TLF
 *  but rather extended the older TextField class in the Player.</p>
 *
 *  <p>The most important differences to understand are:
 *  <ul>
 *    <li>RichEditableText offers better typography, better support
 *        for international languages, and better text layout.</li>
 *    <li>RichEditableText has an object-oriented model of rich text,
 *        while UITextField does not.</li>
 *    <li>RichEditableText has better support for displaying
 *        large amounts of text.</li>
 *    <li>RichEditableText requires that fonts be embedded
 *        differently than UITextField.
 *        Consult the documentation regarding how to use the
 *        <code>embedAsCFF</code> attribute when you embed a font.</li>
 *  </ul></p>
 *
 *  <p>RichEditableText uses TLF's object-oriented model of rich text,
 *  in which text layout elements such as divisions, paragraphs, spans,
 *  hyperlinks, and images are represented at runtime by ActionScript
 *  objects which can be programmatically accessed and manipulated.
 *  The central object in TLF for representing rich text is a
 *  TextFlow, so you specify rich text for RichEditableText to display
 *  by setting its <code>textFlow</code> property to a TextFlow instance.
 *  Please see the description of the <code>textFlow</code>
 *  property for information about how to create one,
 *  such as by importing TLF markup.
 *  If you don't need to display text that has multiple formats,
 *  simply set the <code>text</code> property to a "plain text" String.
 *  See the description of the <code>text</code> and <code>textFlow</code>
 *  properties for information about how they interact;
 *  for example, you can set one and get the other.</p>
 *
 *  <p>At compile time, you can simply put TLF markup tags inside
 *  the RichEditableText tag, as in
 *  <pre>
 *  &lt;s:RichEditableText&gt;Hello &lt;s:span fontWeight="bold"&gt;World!&lt;/s:span&gt;&lt;/s:RichEditableText&gt;
 *  </pre>
 *  In this case, the MXML compiler sets the <code>content</code>
 *  property, causing a TextFlow to be automatically created
 *  from the FlowElements that you specify.</p>
 *
 *  <p>The default text formatting is determined by CSS styles
 *  such as <code>fontFamily</code>, <code>fontSize</code>.
 *  Any formatting information in the TextFlow overrides
 *  the default formatting provided by the CSS styles.</p>
 *
 *  <p>You can control the spacing between lines with the
 *  <code>lineHeight</code> style and the spacing between
 *  paragraphs with the <code>paragraphSpaceBefore</code>
 *  and <code>paragraphSpaceAfter</code> styles.
 *  You can align or justify the text using the <code>textAlign</code>
 *  and <code>textAlignLast</code> styles.
 *  You can inset the text from the component's edges using the
 *  <code>paddingLeft</code>, <code>paddingTop</code>, 
 *  <code>paddingRight</code>, and <code>paddingBottom</code> styles.</p>
 *
 *  <p>By default, a RichEditableText "autosizes": it starts out very
 *  small if it has no text, grows in width up to
 *  <code>maxWidth</code> as you type,
 *  and grows in height when you press Enter to start a new line.</p>
 *
 *  <p>The <code>widthInChars</code> and <code>heightInChars</code>
 *  properties provide a convenient way to specify the width and height
 *  in a way that scales with the font size.
 *  Of course, you can also specify an explicit width or height in pixels,
 *  or use a percent width and height, or use constraints such as
 *  <code>left</code> and <code>right</code>
 *  or <code>top</code> and <code>bottom</code>.</p>
 *
 *  <p>When you specify some kind of width -- whether an explicit or
 *  percent width, a <code>maxWidth</code> or <code>left</code>
 *  and <code>right</code> constraints -- the text wraps at the right
 *  edge of the component and the text becomes vertically scrollable
 *  when there is more text than fits.
 *  If you set the <code>lineBreak</code> style to <code>"explicit"</code>,
 *  new lines will start only at explicit lines breaks, such as
 *  if you use CR (<code>"\r"</code>), LF (<code>"\n"</code>),
 *  or CR+LF (<code>"\r\n"</code>) in <code>text</code>
 *  or if you use <code>&lt;p&gt;</code> and <code>&lt;br/&gt;</code>
 *  in TLF markup.
 *  In that case, the text becomes horizontally scrollable
 *  if any lines are wider than the control.</p>
 *
 *  <p>You can use the <code>maxChars</code> property to limit the number
 *  of character that the user can enter, and the <code>restrict</code>
 *  to limit which characters the user can enter.</p>
 *
 *  <p>The <code>multiline</code> property determines what happens
 *  when you press the Enter key.
 *  If it is <code>true</code>, the Enter key starts a new paragraph.
 *  If it is <code>false</code>, it causes a <code>FlexEvent.ENTER</code>
 *  event to be dispatched.</p>
 *
 *  <p>If you don't want the text to be editable,
 *  set the <code>editable</code> property to <code>false</code>.
 *  If you don't even want it to be selectable,
 *  set the <code>selectable</code> property to <code>false</code>.</p>
 *
 *  <p>Because RichEditableText uses TLF,
 *  it supports displaying left-to-right (LTR) text such as French,
 *  right-to-left (RTL) text such as Arabic, and bidirectional text
 *  such as a French phrase inside of an Arabic one.
 *  If the predominant text direction is right-to-left,
 *  set the <code>direction</code> style to <code>"rtl"</code>.
 *  The <code>textAlign</code> style defaults to <code>"start"</code>,
 *  which makes the text left-aligned when <code>direction</code>
 *  is <code>"ltr"</code> and right-aligned when <code>direction</code>
 *  is <code>"rtl"</code>.
 *  To get the opposite alignment,
 *  set <code>textAlign</code> to <code>"end"</code>.</p>
 *
 *  <p>Also as a result of using TLF, the RichEditableText supports
 *  unlimited undo/redo within one editing session.
 *  An editing session starts when the component gets keyboard focus
 *  and ends when it loses focus.</p>
 *
 *  <p>RichEditableText uses TLF's TextContainerManager class
 *  to handle its text display, scrolling, selection, and editing.</p>
 *
 *  @see spark.components.Label
 *  @see spark.components.RichText
 *
 *  @includeExample examples/RichEditableTextExample.mxml
 *  @includeExample examples/externalTextFlow.xml -noswf
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class RichEditableText extends UIComponent
    implements IViewport, IFocusManagerComponent, IIMESupport
{
    include "../core/Version.as";
        
    //--------------------------------------------------------------------------
    //
    //  Class initialization
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  This method initializes the static vars of this class.
     *  Rather than calling it at static initialization time,
     *  we call it in the constructor to do the class initialization
     *  when the first instance is created.
     *  (It does an immediate return if it has already run.)
     *  By doing so, we avoid any static initialization issues
     *  related to whether this class or the TLF classes
     *  that it uses are initialized first.
     */
    private static function initClass():void
    {
        if (classInitialized)
            return;

        staticConfiguration = 
            Configuration(TextContainerManager.defaultConfiguration).clone();
        staticConfiguration.manageEnterKey = false; // default is true
        staticConfiguration.manageTabKey = false;   // default is false

        staticPlainTextImporter =
            TextConverter.getImporter(TextConverter.PLAIN_TEXT_FORMAT,
            staticConfiguration);
        
        // Throw import errors rather than return a null textFlow.
        // Alternatively, the error strings are in the Vector, importer.errors.
        staticPlainTextImporter.throwOnError = true;
    
        staticPlainTextExporter =
            TextConverter.getExporter(TextConverter.PLAIN_TEXT_FORMAT);
            
        // Used for embedded fonts.         
        staticTextFormat = new TextFormat();
        
        classInitialized = true;
    } 
    
    //--------------------------------------------------------------------------
    //
    //  Class variables
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    private static var classInitialized:Boolean = false;

    /**
     *  @private
     *  Create a single Configuration used by all Text instances.  
     *  It tells the TextContainerManager that we don't want it 
     *  to handle the ENTER key, because we need the ENTER key to behave 
     *  differently based on the 'multiline' property.
     */
    private static var staticConfiguration:Configuration;

    /**
     *  @private
     *  This TLF object is used to import a 'text' String
     *  containing linebreaks to create a multiparagraph TextFlow.
     */
    private static var staticPlainTextImporter:ITextImporter;

    /**
     *  @private
     *  This TLF object is used to export a TextFlow as plain 'text',
     *  by walking the leaf FlowElements in the TextFlow.
     */
    private static var staticPlainTextExporter:ITextExporter;
        
    /**
     *  @private
     *  Used in getEmbeddedFontContext().
     */
    private static var staticTextFormat:TextFormat;
        
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
        
        initClass();
        
        // Use the setter.
        text = "";

        // Create the TLF TextContainerManager, using this component
        // as the DisplayObjectContainer for its TextLines.
        // This TextContainerManager instance persists for the lifetime
        // of the component.
        _textContainerManager = createTextContainerManager();

        // Add event listeners on this component.

        // The focusInHandler is called by the TCMContainer focusInHandler.
        // The focusOutHandler is called by the TCMContainer focusOutHandler.
        // The keyDownHandler is called by the TCMContainer keyDownHandler.
                        
        // Add event listeners on its TextContainerManager.
        
        _textContainerManager.addEventListener(
            CompositionCompleteEvent.COMPOSITION_COMPLETE,
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
     *  This object determines the default text formatting used
     *  by this component, based on its CSS styles.
     *  It is set to null by stylesInitialized() and styleChanged(),
     *  and recreated whenever necessary in commitProperties().
     */
    private var hostFormat:ITextLayoutFormat;

    /**
     *  @private
     *  It is set to NaN by stylesInitialized() and styleChanged(),
     *  and recreated whenever necessary in calculateFontMetrics().
     */
    private var ascent:Number = NaN;
    
    /**
     *  @private
     *  It is set to NaN by stylesInitialized() and styleChanged(),
     *  and recreated whenever necessary in calculateFontMetrics().
     */
    private var descent:Number = NaN;

    /**
     *  @private
     *  Source of text: one of "text", "textFlow" or "content".
     */
    private var source:String = "text";

    /**
     *  @private
     *  Holds the last recorded value of the textFlow generation.  Used to
     *  determine whether to return immediately from damage event if there 
     *  have been no changes.
     */
    private var lastGeneration:uint = 0;    // 0 means not set
        
    /**
     *  @private
     *  True if TextOperationEvent.CHANGING and TextOperationEvent.CHANGE 
     *  events should be dispatched.
     */
    private var dispatchChangeAndChangingEvents:Boolean = true;

    /**
     *  @private
     */
    mx_internal var ignoreDamageEvent:Boolean = false;

    /**
     *  @private
     */
    mx_internal var ignoreSelectionChangeEvent:Boolean = false;

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
     *  Holds the last recorded value of the module factory used to create the 
     *  font.
     */
    mx_internal var embeddedFontContext:IFlexModuleFactory;

    /**
     *  @private
     *  True if we've seen a MOUSE_DOWN event and haven't seen the 
     *  corresponding MOUSE_UP event.
     */
    private var mouseDown:Boolean = false;

    /**
     *  @private
     */    
    private var errorCaught:Boolean = false;
    
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
     *  Cache the height constraint as set by the layout in setLayoutBoundsSize()
     *  so that text reflow can be calculated during a subsequent measure pass.
     */
    private var heightConstraint:Number = NaN;
    
    /**
     *  @private
     *  If the selection was via the selectRange() or selectAll() api, remember
     *  that until the next selection is set, either interactively or via the
     *  API.
     */
    private var hasProgrammaticSelectionRange:Boolean = false;
   
    /**
     *  @private
     *  True if this component sizes itself based on its actual
     *  contents.
     */
    mx_internal var autoSize:Boolean = false;

    /**
     *  @private
     *  True if need to scroll after updating the container.
     */
    mx_internal var scrollAfterUpdate:Boolean = false;
                
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

    //----------------------------------
    // explicitHeight
    //----------------------------------

    /**
     *  @private
     */
    override public function set explicitHeight(value:Number):void
    {
        super.explicitHeight = value;
        
        heightConstraint = NaN;

        // Because of autoSizing, the size and display might be impacted.
        invalidateSize();
        invalidateDisplayList();
    }

    //----------------------------------
    // explicitWidth
    //----------------------------------

    /**
     *  @private
     */
    override public function set explicitWidth(value:Number):void
    {
        super.explicitWidth = value;

        // Because of autoSizing, the size and display might be impacted.
        invalidateSize();
        invalidateDisplayList();
    }

    //----------------------------------
    // percentHeight
    //----------------------------------

    /**
     *  @private
     */
    override public function set percentHeight(value:Number):void
    {
        super.percentHeight = value;
        
        heightConstraint = NaN;
        
        // If we were autoSizing and now we are not we need to remeasure.
        invalidateSize();
        invalidateDisplayList();
    }

    //----------------------------------
    // percentWidth
    //----------------------------------

    /**
     *  @private
     */
    override public function set percentWidth(value:Number):void
    {
        super.percentWidth = value;

        // If we were autoSizing and now we are not we need to remeasure.
        invalidateSize();
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
        
        invalidateProperties();
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
     *  The height of the text.
	 *
	 *  <p>Due to the fact that the Text Layout Framework
	 *  virtualizes TextLines for performance,
	 *  this height will initially be an estimate
	 *  if the component cannot display all of the text.
	 *  If you scroll to the end of the text,
	 *  all the TextLines will get composed
	 *  and the <code>contentHeight</code> will be exact.</p>
	 *
	 *  <p>To scroll over the text vertically, vary the 
     *  <code>verticalScrollPosition</code> between 0 and
     *  <code>contentHeight - height</code>.</p>
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
     *  The width of the text.
	 *
	 *  <p>Due to the fact that the Text Layout Framework
	 *  virtualizes TextLines for performance,
	 *  this width will initially be an estimate
	 *  if the component cannot display all of the text.
	 *  If you scroll to the end of the text,
	 *  all the TextLines will get composed
	 *  and the <code>contentWidth</code> will be exact.</p>
	 *
     *  <p>To scroll over the text horizontally, vary the 
     *  <code>horizontalScrollPosition</code> between 0 and
     *  <code>contentWidth - width</code>.</p>  
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
     *  The number of pixels by which the text is scrolled horizontally.
	 *
     *  <p>To scroll over the text horizontally, vary the 
     *  <code>horizontalScrollPosition</code> between 0 and
     *  <code>contentWidth - width</code>.</p>
	 *
	 *  @default 0
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
        // Convert NaN to 0 to keep TCM happy.
        if (isNaN(value))
            value = 0;
 
        if (value == _horizontalScrollPosition)
            return;

        _horizontalScrollPosition = value;
        horizontalScrollPositionChanged = true;

        invalidateProperties();

        // Note:  TLF takes care of updating the container when the scroll
        // position is set so there is no need for us to invalidate the 
        // display list.
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
     *  The number of pixels by which the text is scrolled vertically.
	 *
	 *  <p>To scroll over the text vertically, vary the 
     *  <code>verticalScrollPosition</code> between 0 and
     *  <code>contentHeight - height</code>.</p>
	 *
	 *  @default 0
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
        // Convert NaN to 0 to keep TCM happy.
        if (isNaN(value))
            value = 0;
            
        if (value == _verticalScrollPosition)
            return;

        _verticalScrollPosition = value;
        verticalScrollPositionChanged = true;

        invalidateProperties();
        
        // Note:  TLF takes care of updating the container when the scroll
        // position is set so there is no need for us to invalidate the 
        // display list.
    }
        
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

        
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
	 *  This property is intended for use in MXML at compile time;
	 *  to get or set rich text content at runtime,
	 *  please use the <code>textFlow</code> property instead.
	 *
	 *  <p>The <code>content</code> property is the default property
	 *  for RichEditableText, so that you can write MXML such as
	 *  <pre>
	 *  &lt;s:RichEditableText&gt;Hello &lt;s:span fontWeight="bold"/&gt;World&lt;/s:span&gt;&lt;/s:RichEditableText&gt;
	 *  </pre>
	 *  and have the String and SpanElement that you specify
	 *  as the content be used to create a TextFlow.</p>
	 *
	 *  <p>This property is typed as Object because you can set it to
	 *  to a String, a FlowElement, or an Array of Strings and FlowElements.
	 *  In the example above, you are specifying the content
	 *  to be a 2-element Array whose first element is the String
	 *  "Hello" and whose second element is a SpanElement with the text
	 *  "World" in boldface.</p>
	 * 
	 *  <p>No matter how you specify the content, it gets converted
	 *  into a TextFlow, and when you get this property, you will get
	 *  the resulting TextFlow.</p>
	 * 
	 *  <p>Adobe recommends using <code>textFlow</code> property
	 *  to get and set rich text content at runtime,
	 *  because it is strongly typed as a TextFlow
	 *  rather than as an Object.
	 *  A TextFlow is the canonical representation
	 *  for rich text content in the Text Layout Framework.</p>
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	public function get content():Object
	{
		return textFlow;
	}
	
	/**
	 *  @private
	 */   
    public function set content(value:Object):void
    {
        // Treat setting the 'content' to null
        // as if 'text' were being set to the empty String
        // (which is the default state).
        if (value == null)
        {
            text = "";
            return;
        }
        
        if (value == _content)
            return;
        
        _content = value;
        contentChanged = true;
        source = "content";
        
        // Of 'text', 'textFlow', and 'content', the last one set wins.
        textChanged = false;
        textFlowChanged = false;
        
        // The other two are now invalid and must be recalculated when needed.
        _text = null;
        _textFlow = null;
                
        invalidateProperties();
        invalidateSize();
        invalidateDisplayList();
        
        dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));                                   
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
     *  @copy flash.text.TextField#displayAsPassword
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
     *  A flag indicating whether the user is allowed
	 *  to edit the text in this control.
	 *
	 *  <p>If <code>true</code>, the mouse cursor will change to an i-beam
     *  when over the bounds of this control.
     *  If <code>false</code>, the mouse cursor will remain an arrow.</p>
     *
     *  <p>If this property is <code>true</code>,
	 *  the <code>selectable</code> property is ignored.</p>
     *
     *  @default true
     *
     *  @see spark.components.RichEditableText#selectable
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
        // Note: this could be called before all properties are committed.

        if (enabledChanged || editableChanged || selectableChanged)
        {
            updateEditingMode();

            enabledChanged = false;
            editableChanged = false;
            selectableChanged = false;
        }
           
        return _textContainerManager.editingMode;
    }
    
    /**
     *  @private
     */
    private function set editingMode(value:String):void
    {
        _textContainerManager.editingMode = value;
    }

    //----------------------------------
    //  enableIME
    //----------------------------------

    /**
     *  A flag that indicates whether the IME should
     *  be enabled when the component receives focus.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get enableIME():Boolean
    {
        return editable;
    }

    //----------------------------------
    //  heightInLines
    //----------------------------------

    /**
     *  @private
     */
    private var _heightInLines:Number = NaN;

    /**
     *  @private
     */
    private var heightInLinesChanged:Boolean = false;
    
    /**
     *  The default height of the control, measured in lines.
	 *
     *  <p>The control's formatting styles, such as <code>fontSize</code>
	 *  and <code>lineHeight</code>, are used to calculate the line height
	 *  in pixels.</p>
	 *
	 *  <p>You would, for example, set this property to 5 if you want
	 *  the height of the RichEditableText to be sufficient
	 *  to display five lines of text.</p>
	 *
	 *  <p>If this property is <code>NaN</code> (the default),
	 *  then the component's default height will be determined
	 *  from the text to be displayed.</p>
     *  
	 *  <p>This property will be ignored if you specify an explicit height,
	 *  a percent height, or both <code>top</code> and <code>bottom</code>
	 *  constraints.</p>
     *
     *  <p>RichEditableText's <code>measure()</code> method uses
	 *  <code>widthInChars</code> and <code>heightInLines</code>
     *  to determine the <code>measuredWidth</code>
	 *  and <code>measuredHeight</code>. 
     *  These are similar to the <code>cols</code> and <code>rows</code>
	 *  of an HTML TextArea.</p>
	 *
	 *  <p>Since both <code>widthInChars</code> and <code>heightInLines</code>
	 *  default to <code>NaN</code>, RichTextEditable "autosizes" by default:
	 *  it starts out very small if it has no text, grows in width as you
	 *  type, and grows in height when you press Enter to start a new line.</p>
	 *
	 *  @default NaN
	 *
	 *  @see spark.components.RichEditableText#widthInChars
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

        heightConstraint = NaN;
        
        invalidateProperties();
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
     *  @see flash.system.IMEConversionMode
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
    //  maxChars
    //----------------------------------

    /**
     *  @private
     */
    private var _maxChars:int = 0;

    /**
     *  @copy flash.text.TextField#maxChars
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
	 *
     *  <p>If <code>true</code>, the Enter key starts a new paragraph.
     *  If <code>false</code>, the Enter key doesn't affect the text
     *  but causes the RichEditableText to dispatch an <code>"enter"</code> 
     *  event.</p>
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
     *  @copy flash.text.TextField#restrict
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
     *  A flag indicating whether the content is selectable
     *  with the mouse, or with the keyboard when the control
     *  has the keyboard focus.
	 *
     *  <p>Making the text selectable lets you copy text from the control.</p>
	 *
	 *  <p>This property is ignored if the <code>editable</code>
	 *  property is <code>true</code>.</p>
     *
     *  @default true
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
     *  A character position, relative to the beginning of the
	 *  <code>text</code> String, specifying the end of the selection
     *  that moves when the selection is extended with the arrow keys.
     *
     *  <p>The active position may be either the start
     *  or the end of the selection.</p>
	 *
	 *  <p>For example, if you drag-select from position 12 to position 8,
	 *  then <code>selectionAnchorPosition</code> will be 12
	 *  and <code>selectionActivePosition</code> will be 8,
	 *  and when you press Left-Arrow <code>selectionActivePosition</code>
	 *  will become 7.</p>
	 *
	 *  <p>A value of -1 indicates "not set".</p>
     *
     *  @default -1
	 *
	 *  @see spark.components.RichEditableText#selectionAnchorPosition
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
     *  A character position, relative to the beginning of the
	 *  <code>text</code> String, specifying the end of the selection
     *  that stays fixed when the selection is extended with the arrow keys.
	 *
     *  <p>The anchor position may be either the start
     *  or the end of the selection.</p>
	 *
	 *  <p>For example, if you drag-select from position 12 to position 8,
	 *  then <code>selectionAnchorPosition</code> will be 12
	 *  and <code>selectionActivePosition</code> will be 8,
	 *  and when you press Left-Arrow <code>selectionActivePosition</code>
	 *  will become 7.</p>
	 *
	 *  <p>A value of -1 indicates "not set".</p>
     *
     *  @default -1
	 *
	 *  @see spark.components.RichEditableText#selectionActivePosition
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
    //  selectionHighlighting
    //----------------------------------

    /**
     *  @private
     */
    private var _selectionHighlighting:String =
        TextSelectionHighlighting.WHEN_FOCUSED;

    /**
     *  @private
     *  To indicate either selection highlighting or selection styles have
     *  changed.
     */
    private var selectionFormatsChanged:Boolean = false;

    /**
     *  Determines when the text selection is highlighted.
     *  
     *  <p>The allowed values are specified by the
     *  spark.components.TextSelectionHighlighting class.
     *  Possible values are <code>TextSelectionHighlighting.WHEN_FOCUSED</code>,
     *  <code>TextSelectionHighlighting.WHEN_ACTIVE</code>,
     *  and <code>TextSelectionHighlighting.ALWAYS</code>.</p>
     *
     *  <p><code>WHEN_FOCUSED</code> means show the text selection
	 *  only when the component has keyboard focus.</p>
     *  
     *  <p><code>WHEN_ACTIVE</code> means show the text selection whenever
     *  the component's window is active, even if the component
     *  doesn't have the keyboard focus.</p>
     *
     *  <p><code>ALWAYS</code> means show the text selection,
	 *  even if the component doesn't have the keyboard focus
	 *  or if the component's window isn't the active window.</p>
     *  
     *  @default TextSelectionHighlighting.WHEN_FOCUSED
     *  
     *  @see mx.components.TextSelectionHighlighting
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get selectionHighlighting():String 
    {
        return _selectionHighlighting;
    }
    
    /**
     *  @private
     */
    public function set selectionHighlighting(value:String):void
    {
        if (value == _selectionHighlighting)
            return;
            
        _selectionHighlighting = value;
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

    [Bindable("change")]

    /**
     *  The text String displayed by this component.
	 *
	 *  <p>Setting this property affects the <code>textFlow</code> property
     *  and vice versa.</p>
     *
     *  <p>If you set the <code>text</code> to a String such as
	 *  <code>"Hello World"</code> and get the <code>textFlow</code>,
	 *  it will be a TextFlow containing a single ParagraphElement
	 *  with a single SpanElement.</p>
     *
     *  <p>If the text contains explicit line breaks --
     *  CR ("\r"), LF ("\n"), or CR+LF ("\r\n") --
     *  then the content will be set to a TextFlow
     *  which contains multiple paragraphs, each with one span.</p>
     *
     *  <p>If you set the <code>textFlow</code> and get the <code>text</code>,
	 *  the text in each paragraph will be separated by a single
     *  LF ("\n").</p>
     *
     *  <p>Setting this property also affects the properties
     *  specifying the control's scroll position and the text selection.
     *  It resets the <code>horizontalScrollPosition</code>
	 *  and <code>verticalScrollPosition</code> to 0,
     *  and it sets the <code>selectionAnchorPosition</code>
	 *  and <code>selectionActivePosition</code>
     *  to -1 to clear the selection.</p>
     *
     *  @default ""
     *
     *  @see spark.components.RichEditableText#textFlow
     *  @see spark.components.RichEditableText#horizontalScrollPosition
     *  @see spark.components.RichEditableText#verticalScrollPosition
     *  @see spark.components.RichEditableText#selectionAnchorPosition
     *  @see spark.components.RichEditableText#selectionActivePosition
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get text():String 
    {
        // Extracting the plaintext from a TextFlow is somewhat expensive,
        // as it involves iterating over the leaf FlowElements in the TextFlow.
        // Therefore we do this extraction only when necessary, namely when
        // you first set the 'content' or the 'textFlow'
        // (or mutate the TextFlow), and then get the 'text'.
        if (_text == null)
        {
            // If 'content' was last set,
            // we have to first turn that into a TextFlow.
            if (_content != null)
                _textFlow = createTextFlowFromContent(_content);
                    
            // Once we have a TextFlow, we can export its plain text.
            _text = staticPlainTextExporter.export(
                _textFlow, ConversionType.STRING_TYPE) as String;
        }

        return _text;
    }
    
    /**
     *  @private
     *  This will create a TextFlow with a single paragraph with a single span 
     *  with exactly the text specified.  If there is whitespace and line 
     *  breaks in the text, they will remain, regardless of the settings of
     *  the lineBreak and whiteSpaceCollapse styles.
     */
    public function set text(value:String):void
    {
        // Treat setting the 'text' to null
        // as if it were set to the empty String
        // (which is the default state).
        if (value == null)
            value = "";

        // If value is the same as _text, make sure if was not produced from
        // setting 'textFlow' or 'content'.  For example, if you set a TextFlow 
        // corresponding to "Hello <span color="OxFF0000">World</span>"
        // and then get the 'text', it will be the String "Hello World"
        // But if you then set the 'text' to "Hello World"
        // this represents a change: the "World" should no longer be red.
        //
        // Note: this is needed to stop two-binding from recursing.
        if (source == "text" && text == value)
            return;

        _text = value;
        textChanged = true;
        source = "text";
        
        // Of 'text', 'textFlow', and 'content', the last one set wins.
        textFlowChanged = false;
        contentChanged = false;
        
        // The other two are now invalid and must be recalculated when needed.
        _textFlow = null;
        _content = null;
        
        invalidateProperties();
        invalidateSize();
        invalidateDisplayList();
        
        dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));                                   
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
    //  textFlow
    //----------------------------------
    
    /**
     *  @private
     *  Storage for the textFlow property.
     */
    private var _textFlow:TextFlow;
    
    /**
     *  @private
     */
    private var textFlowChanged:Boolean = false;
    
    /**
     *  The TextFlow representing the rich text displayed by this component.
     * 
     *  <p>A TextFlow is the most important class
     *  in the Text Layout Framework (TLF).
     *  It is the root of a tree of FlowElements
     *  representing rich text content.</p>
	 *
	 *  <p>You normally create a TextFlow from TLF markup
	 *  using the <code>TextFlowUtil.importFromString()</code>
	 *  or <code>TextFlowUtil.importFromXML()</code> methods.
	 *  Alternately, you can use TLF's TextConverter class
	 *  (which can import a subset of HTML) or build a TextFlow
	 *  using methods like <code>addChild()</code> on TextFlow.</p>
     *
	 *  <p>Setting this property affects the <code>text</code> property
     *  and vice versa.</p>
     *
     *  <p>If you set the <code>textFlow</code> and get the <code>text</code>,
	 *  the text in each paragraph will be separated by a single
     *  LF ("\n").</p>
     *
     *  <p>If you set the <code>text</code> to a String such as
	 *  <code>"Hello World"</code> and get the <code>textFlow</code>,
	 *  it will be a TextFlow containing a single ParagraphElement
	 *  with a single SpanElement.</p>
     *
     *  <p>If the text contains explicit line breaks --
     *  CR ("\r"), LF ("\n"), or CR+LF ("\r\n") --
     *  then the content will be set to a TextFlow
     *  which contains multiple paragraphs, each with one span.</p>
     *
     *  <p>Setting this property also affects the properties
     *  specifying the control's scroll position and the text selection.
     *  It resets the <code>horizontalScrollPosition</code>
	 *  and <code>verticalScrollPosition</code> to 0,
     *  and it sets the <code>selectionAnchorPosition</code>
	 *  and <code>selectionActivePosition</code>
     *  to -1 to clear the selection.</p>
	 *
	 *  <p>To turn a TextFlow object into TLF markup,
	 *  use the <code>TextFlowUtil.export()</code> markup.</p>
	 *
	 *  <p>A single TextFlow cannot be shared by multiple instances
	 *  of RichEditableText.
	 *  To display the same text in a second instance, you must create
	 *  a second TextFlow, either by using <code>TextFlowUtil.export()</code>
	 *  and <code>TextFlowUtil.importFromXML()</code> or by using
	 *  the <code>deepCopy()</code> method on TextFlow.</p>
	 *
	 *  @see spark.utils.TextFlowUtil#importFromString()
	 *  @see spark.utils.TextFlowUtil#importFromXML()
     *  @see spark.components.RichEditableText#text
     *  @see spark.components.RichEditableText#horizontalScrollPosition
     *  @see spark.components.RichEditableText#verticalScrollPosition
     *  @see spark.components.RichEditableText#selectionAnchorPosition
     *  @see spark.components.RichEditableText#selectionActivePosition
     */
    public function get textFlow():TextFlow
    {
        // Note: this could be called before all properties are committed.
        
        // We might not have a valid _textFlow for two reasons:
        // either because the 'text' was set (which is the state
        // after construction) or because the 'content' was set.
        if (!_textFlow)
        {
            if (_content != null)
            {
                _textFlow = createTextFlowFromContent(_content);
                _content = null;
            }
            else
            {
                _textFlow = staticPlainTextImporter.importToFlow(_text);
            }
        }
        
        // Make sure the interactionManager is added to this textFlow.           
        if (textChanged || contentChanged || textFlowChanged)
        {
            _textContainerManager.setTextFlow(_textFlow);
            textChanged = contentChanged = textFlowChanged = false;
        }
        
        // If not read-only, make sure the textFlow has a composer in
        // place so that it can be modified by the caller if desired.
        if (editingMode != EditingMode.READ_ONLY)
        {
            _textContainerManager.beginInteraction();
            _textContainerManager.endInteraction();
        }
        
        return _textFlow;
    }
    
    /**
	 *  @private
	 */
	public function set textFlow(value:TextFlow):void
    {
        // Treat setting the 'textFlow' to null
        // as if 'text' were being set to the empty String
        // (which is the default state).
        if (value == null)
        {
            text = "";
            return;
        }
        
        if (value == _textFlow)
            return;
            
        _textFlow = value;
        textFlowChanged = true;
        source = "textFlow";
        
        // Of 'text', 'textFlow', and 'content', the last one set wins.
        textChanged = false;
        contentChanged = false;
        
        // The other two are now invalid and must be recalculated when needed.
        _text = null
        _content = null;
        
        invalidateProperties();
        invalidateSize();
        invalidateDisplayList();

        dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));                                   
    }

    //----------------------------------
    //  widthInChars
    //----------------------------------

    /**
     *  @private
     *  These are measured in ems.
     */
    private var _widthInChars:Number = NaN;

    /**
     *  @private
     */
    private var widthInCharsChanged:Boolean = true;
        
    /**
     *  The default width of the control, measured in em units.
	 *
	 *  <p>An em is a unit of typographic measurement
	 *  equal to the point size.
	 *  It is not necessarily exactly the width of the "M" character,
	 *  but in many fonts the "M" is about one em wide.
     *  The control's <code>fontSize</code> style is used,
	 *  to calculate the em unit in pixels.</p>
	 *
	 *  <p>You would, for example, set this property to 20 if you want
	 *  the width of the RichEditableText to be sufficient
	 *  to display about 20 characters of text.</p>
	 *
	 *  <p>If this property is <code>NaN</code> (the default),
	 *  then the component's default width will be determined
	 *  from the text to be displayed.</p>
	 *
	 *  <p>This property will be ignored if you specify an explicit width,
	 *  a percent width, or both <code>left</code> and <code>right</code>
	 *  constraints.</p>
	 *
     *  <p>RichEditableText's <code>measure()</code> method uses
	 *  <code>widthInChars</code> and <code>heightInLines</code>
     *  to determine the <code>measuredWidth</code>
	 *  and <code>measuredHeight</code>. 
     *  These are similar to the <code>cols</code> and <code>rows</code>
	 *  of an HTML TextArea.</p>
	 *
	 *  <p>Since both <code>widthInChars</code> and <code>heightInLines</code>
	 *  default to <code>NaN</code>, RichTextEditable "autosizes" by default:
	 *  it starts out very samll if it has no text, grows in width as you
	 *  type, and grows in height when you press Enter to start a new line.</p>
	 *
	 *  @default NaN
	 *
	 *  @see spark.primitives.heightInLines
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
        
        invalidateProperties();
        invalidateSize();
        invalidateDisplayList();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden Methods: UIComponent
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    override public function parentChanged(p:DisplayObjectContainer):void
    {
        if (focusManager)
        {
            focusManager.removeEventListener(FlexEvent.FLEX_WINDOW_ACTIVATE, 
                _textContainerManager.activateHandler)
            focusManager.removeEventListener(FlexEvent.FLEX_WINDOW_DEACTIVATE, 
                _textContainerManager.deactivateHandler)
        }

        super.parentChanged(p);

        if (focusManager)
        {
            addActivateHandlers();
        }
        else
        {
            // if no focusmanager yet, add capture phase to detect when it
            // gets added
            if (systemManager)
                systemManager.getSandboxRoot().addEventListener(FlexEvent.ADD_FOCUS_MANAGER, 
                    addFocusManagerHandler, true, 0, true)
            else
                // no systemManager yet?  Check again when added to stage
                addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
        }

    }

    /**
     *  @private
     */
    override public function removeChild(child:DisplayObject):DisplayObject
    {
        // not sure why this happens but it does if you just change
        // the embeddedFont context
        if (!child.parent)
            return child;

        if (child.parent == this)
            return super.removeChild(child);

        return child.parent.removeChild(child);
    }

    /**
     *  @private
     */
    override protected function commitProperties():void
    {
        super.commitProperties();

        if (!hostFormat)
        {
            // If the CSS styles for this component specify an embedded font,
            // embeddedFontContext will be set to the module factory that
            // should create TextLines (since they must be created in the
            // SWF where the embedded font is.)
            // Otherwise, this will be null.
            embeddedFontContext = getEmbeddedFontContext();

            _textContainerManager.textLineCreator = 
                ITextLineCreator(embeddedFontContext);                       

            _textContainerManager.hostFormat =
            hostFormat = new CSSTextLayoutFormat(this);
            // Note: CSSTextLayoutFormat has special processing
            // for the fontLookup style. If it is "auto",
            // the fontLookup format is set to either
            // "device" or "embedded" depending on whether
            // embeddedFontContext is null or non-null.
        }
        
        if (selectionFormatsChanged)
        {
            _textContainerManager.invalidateSelectionFormats();
            
            selectionFormatsChanged = false;
        }

        // If fontMetrics changed, recalculate the ascent, and descent.
        if (isNaN(ascent) || isNaN(descent))
            calculateFontMetrics();    
    
        // EditingMode needs to be current before attempting to set a
        // selection below.
        if (enabledChanged || selectableChanged || editableChanged)
        {
            updateEditingMode();
            
            enabledChanged = false;
            editableChanged = false;
            selectableChanged = false;          
        }

        // Only one of textChanged, textFlowChanged, and contentChanged
        // will be true; the other two will be false because each setter
        // guarantees this.

        if (textChanged)
        {
            // If the text has linebreaks (CR, LF, or CF+LF)
            // create a multi-paragraph TextFlow from it
            // and use the TextFlowTextLineFactory to render it.
            // Otherwise the StringTextLineFactory will put
            // all of the lines into a single paragraph
            // and FTE performance will degrade on a large paragraph.
            
            // If we have focus, then we need to immediately create a 
            // TextFlow so the interaction manager will be created and 
            // editing/selection can be done without having to mouse click 
            // or mouse hover over this field.  Normally this is done in our 
            // focusIn handler by making sure there is a selection.  Test this
            // by clicking an arrow in the NumericStepper and then entering
            // a number without clicking on the input field first.    
                        
            if (_text.indexOf("\n") != -1 || _text.indexOf("\r") != -1 ||
                getFocus() == this)
            {
                _textFlow = staticPlainTextImporter.importToFlow(_text);
                _textContainerManager.setTextFlow(_textFlow);
            }
            else
            {
                _textContainerManager.setText(_text);
            }
        }
        else if (textFlowChanged)
        {
            _textContainerManager.setTextFlow(_textFlow);
        }
        else if (contentChanged)
        {
            _textFlow = createTextFlowFromContent(_content);
            _textContainerManager.setTextFlow(_textFlow);

            // Content converted to textFlow.
            _content = null;
        }                        
         
        if (textChanged || textFlowChanged || contentChanged)
        {
            lastGeneration = _textFlow ? _textFlow.generation : 0;
            
            // If the text, textFlow or content changed, there is no selection.
            // If we already have focus, set the selection to 0,0 so there is
            // an insertion point.  Since the text was changed programatically
            // the caller should set the selection to the desired position.
            if (getFocus() == this && editingMode != EditingMode.READ_ONLY)
            {
                var selectionManager:ISelectionManager = getSelectionManager();
                selectionManager.selectRange(0, 0);        
                if (!selectionManager.focused)
                    selectionManager.focusInHandler(null);
                releaseSelectionManager();            
            }
                
            // Handle the case where the initial text, textFlow or content 
            // is displayed as a password.
            if (displayAsPassword)
                displayAsPasswordChanged = true;

            textChanged = false;
            textFlowChanged = false;
            contentChanged = false;             
        }
        
        // If displayAsPassword changed, it only applies to the display, 
        // not the underlying text.
        if (displayAsPasswordChanged)
        {
            var oldAnchorPosition:int = _selectionAnchorPosition;
            var oldActivePosition:int = _selectionActivePosition;
            
            // If there is any text, convert it to the passwordChar.
            if (displayAsPassword)
            {
                // Make sure _text is set with the actual text before we
                // change the displayed text.
                _text = text;
                
                // Paragraph terminators are lost during this substitution.
                var textToDisplay:String = StringUtil.repeat(
                    passwordChar, _text.length);
                    
                _textContainerManager.setText(textToDisplay);                            
            }
            else
            {
                // Text was displayed as password.  Now display as plain text.
                _textContainerManager.setText(_text);
            }
            
            if (editingMode != EditingMode.READ_ONLY)
            {
                // Must preserve the selection, if there was one.
                selectionManager = getSelectionManager();
                
                // The visible selection will be refreshed during the update.
                selectionManager.selectRange(oldAnchorPosition, oldActivePosition);        
                                     
                releaseSelectionManager(); 
            }           
            
            displayAsPasswordChanged = false;
        }
                                                    
        if (clipAndEnableScrollingChanged)
        {
            // The TLF code seems to check for !off.
            _textContainerManager.horizontalScrollPolicy = "auto";
            _textContainerManager.verticalScrollPolicy = "auto";
            
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
     */
    override protected function canSkipMeasurement():Boolean
    {
        autoSize = false;
        return super.canSkipMeasurement();
    }

    /**
     *  @private
     */
    override protected function measure():void 
    {
        super.measure();
                 
        // ScrollerLayout.measure() has heuristics for figuring out whether to
        // use the actual content size or the preferred size when there are
        // automatic scroll bars.  Force it to use the preferredSizes until
        // the content sizes have been updated to accurate values.  This
        // comes into play when remeasuring to reduce either the width/height.
        _contentWidth = 0;
        _contentHeight = 0;

        // percentWidth and/or percentHeight will come back in as constraints
        // on the remeasure if we're autoSizing.
                          
        // TODO:(cframpto) implement blockProgression rl for autoSize
            
        if (isMeasureFixed()) 
        {            
            autoSize = false;

            // Go large.  For performance reasons, want to avoid a scrollRect 
            // whenever possible in drawBackgroundAndSetScrollRect().  This is
            // particularly true for 1 line TextInput components.
            if (!isNaN(widthConstraint))
            {
                measuredWidth = widthConstraint;
            }
            else
            {                
                measuredWidth = !isNaN(explicitWidth) ? explicitWidth :
                                Math.ceil(calculateWidthInChars());
            }
            
            if (!isNaN(heightConstraint))
            {            
                measuredHeight = heightConstraint;
            }
            else
            {
                measuredHeight = !isNaN(explicitHeight) ? explicitHeight :
                                 Math.ceil(calculateHeightInLines());
            }
        }
        else
        {
            var composeWidth:Number;
            var composeHeight:Number;
            
            var bounds:Rectangle;
                                             
            // If we're here, then at one or both of the width and height can
            // grow to fit the text.  It is important to figure out whether
            // or not autoSize should be allowed to continue.  If in
            // updateDisplayList(), autoSize is true, then the 
            // compositionHeight is NaN to allow the text to grow.          
            autoSize = true;

            if (!isNaN(widthConstraint) || !isNaN(explicitWidth) || 
                !isNaN(widthInChars))
            {
                // width specified but no height
                // if no text, start at one line high and grow
                
                if (!isNaN(widthConstraint))
                    composeWidth = widthConstraint;
                else if (!isNaN(explicitWidth))                    
                    composeWidth = explicitWidth;
                else
                    composeWidth = Math.ceil(calculateWidthInChars());

                // The composeWidth may be adjusted for minWidth/maxWidth
                // except if we're using the explicitWidth.  
                bounds = measureTextSize(composeWidth);
                
                measuredWidth = _textContainerManager.compositionWidth;
                measuredHeight = Math.ceil(bounds.height);
            }
            else if (!isNaN(heightConstraint) || !isNaN(explicitHeight) || 
                     !isNaN(_heightInLines))
            {
                // if no text, 1 char wide with specified height and grow
                
                composeWidth = 
                    hostFormat.lineBreak == "toFit" ? maxWidth : NaN;
                
                if (!isNaN(heightConstraint))
                    composeHeight = heightConstraint;
                else if (!isNaN(explicitHeight))
                    composeHeight = explicitHeight;
                else
                    composeHeight = calculateHeightInLines();

                // The composeWidth may be adjusted for minWidth/maxWidth.
                bounds = measureTextSize(composeWidth);
                
                // Have we already hit the limit with the existing text?  If we
                // are beyond the composeHeight we can assume we've maxed out on
                // the compose width as well.
                if (bounds.height > composeHeight)
                {
                    measuredWidth = _textContainerManager.compositionWidth;
                    measuredHeight = composeHeight;
                    autoSize = false;
                }
                else
                {
                    measuredWidth = Math.ceil(bounds.width);               
                    measuredHeight = composeHeight;
                }
            }
            else
            {
                // If toFit line breaks and no text, start at explicitMaxWidth
                // or default to maxWidth.
                // If explicit line breaks and no text, width is NaN

                composeWidth = 
                    hostFormat.lineBreak == "toFit" ? maxWidth : NaN;

                // The composeWidth may be adjusted for minWidth/maxWidth.
                bounds = measureTextSize(composeWidth);

                measuredWidth = Math.ceil(bounds.width);
                measuredHeight = Math.ceil(bounds.height);
            }

            // Clamp the height, except if we're using the explicitHeight.
            if (isNaN(explicitHeight))
            {            
                if (!isNaN(explicitMinHeight) && measuredHeight < explicitMinHeight)
                    measuredHeight = explicitMinHeight;
        
                // Reached max height so can't grow anymore.
                if (!isNaN(explicitMaxHeight) && measuredHeight > explicitMaxHeight)
                {
                    measuredHeight = explicitMaxHeight;
                    autoSize = false;
                }
            }
            
            // Make sure we weren't previously scrolled. 
            if (autoSize)
             {
                _textContainerManager.horizontalScrollPosition = 0;
                _textContainerManager.verticalScrollPosition = 0;                
             }               
             
             invalidateDisplayList();     
        }
                                                            
        //trace("measure", measuredWidth, measuredHeight, "autoSize", autoSize);
    }

    /**
     *  @private
     */
    override protected function updateDisplayList(unscaledWidth:Number,
                                                  unscaledHeight:Number):void 
    {
        //trace("updateDisplayList", unscaledWidth, unscaledHeight, "autoSize", autoSize);
        
        // Check if the auto-size text is constrained in some way and needs
        // to be remeasured.  If one of the dimension changes, the text may
        // compose differently and have a different size which the layout 
        // manager needs to know.
        if (autoSize && remeasureText(unscaledWidth, unscaledHeight))
            return;

        super.updateDisplayList(unscaledWidth, unscaledHeight);

        // If we're autoSizing we're telling the layout manager one set of
        // values and TLF another set of values so there is room for the text
        // to grow.
        
        // TODO:(cframpto) compositionWidth can be NaN when 
        // autoSize for blockProgression=="rl" is implemented
        if (!autoSize)
        {
            _textContainerManager.compositionWidth = unscaledWidth;
            _textContainerManager.compositionHeight = unscaledHeight;
        }
            
        _textContainerManager.updateContainer();
        
        // Because our EditManager override of updateAllControllers() does
        // not call the composer's flowComposer.updateAllControllers() 
        // immediately, when an editing operation occurs, scrollToRange() in 
        // EditManager.finalizeDo() may be a no-op and will need to be done 
        // after the container is really updated.
        if (scrollAfterUpdate)
        {
            _textContainerManager.scrollToRange(_selectionAnchorPosition, 
                                                _selectionActivePosition);
            scrollAfterUpdate = false;                                                
        }
                                                
        widthConstraint = NaN;
        heightConstraint = NaN;                   
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
        
        ascent = NaN;
        descent = NaN;
        hostFormat = null;
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
            ascent = NaN;
            descent = NaN;
        }

        // If null or "styleName" is passed it indicates that
        // multiple styles may have changed.  Otherwise it is a single style
        // so mark whether it is the selectionFormat that changed or the
        // hostFormat that changed.
        if (styleProp == null || styleProp == "styleName")
        {
            hostFormat = null;
            selectionFormatsChanged = true;
        }
        else if (styleProp == "focusedTextSelectionColor" || 
                 styleProp == "unfocusedTextSelectionColor" ||
                 styleProp == "inactiveTextSelectionColor")
        {
            selectionFormatsChanged = true;
        }
        else
        {
            hostFormat = null;
        }

        // Need to create new format(s).
        invalidateProperties();
    }

    /**
     *  @private
     */
    override public function setFocus():void
    {
        // We are about to set focus on this component.  If it is due to
        // a programmatic focus change we have to programatically do what the
        // mouseOverHandler and the mouseDownHandler do so that the user can 
        // type in this component without using the mouse first.  We need to
        // put a textFlow with a composer in place.
        if (editingMode != EditingMode.READ_ONLY &&
            _textContainerManager.composeState != 
            TextContainerManager.COMPOSE_COMPOSER)   
        {
            _textContainerManager.beginInteraction();
            _textContainerManager.endInteraction();
        }
                    
        super.setFocus();
     }
          
    /**
     *  @private
     */
    override public function drawFocus(isFocused:Boolean):void
    {
        if (isFocused)
        {
            // For some composite components, the focused object may not
            // be "this". If so, we don't want to draw the focus.  This
            // replaces the parentDrawsFocus variable used in halo.
            var fm:IFocusManager = focusManager;
            if (fm && fm.getFocus() != this)
                return;
        }
        
        super.drawFocus(isFocused);
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
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function getHorizontalScrollPositionDelta(navigationUnit:uint):Number
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
            
        switch (navigationUnit)
        {
            case NavigationUnit.LEFT:
                return (scrollR.left <= 0) ? 0 : Math.max(minDelta, -em);
                
            case NavigationUnit.RIGHT:
                return (scrollR.right >= contentWidth) ? 0 : Math.min(maxDelta, em);
                
            case NavigationUnit.PAGE_LEFT:
                return Math.max(minDelta, -scrollR.width);
                
            case NavigationUnit.PAGE_RIGHT:
                return Math.min(maxDelta, scrollR.width);
                
            case NavigationUnit.HOME: 
                return minDelta;
                
            case NavigationUnit.END: 
                return maxDelta;
                
            default:
                return 0;
        }
    }
    
    //----------------------------------
    //  verticalScrollPositionDelta
    //----------------------------------

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function getVerticalScrollPositionDelta(navigationUnit:uint):Number
    {
        var scrollR:Rectangle = scrollRect;
        if (!scrollR)
            return 0;

        // maxDelta is the horizontalScrollPosition delta required 
        // to scroll to the END and minDelta scrolls to HOME. 
        var maxDelta:Number = contentHeight - scrollR.bottom;
        var minDelta:Number = -scrollR.top;
                
        switch (navigationUnit)
        {
            case NavigationUnit.UP:
                return _textContainerManager.getScrollDelta(-1);
                
            case NavigationUnit.DOWN:
                return _textContainerManager.getScrollDelta(1);
                
            case NavigationUnit.PAGE_UP:
                return Math.max(minDelta, -scrollR.height);
                
            case NavigationUnit.PAGE_DOWN:
                return Math.min(maxDelta, scrollR.height);
                
            case NavigationUnit.HOME:
                return minDelta;
                
            case NavigationUnit.END:
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
     *  Inserts the specified text into the RichEditableText
	 *  as if you had typed it.
	 *
     *  <p>If a range was selected, the new text replaces the selected text.
     *  If there was an insertion point, the new text is inserted there.</p>
	 *
     *  <p>An insertion point is then set after the new text.
	 *  If necessary, the text will scroll to ensure
     *  that the insertion point is visible.</p>
	 *
	 *  @param text The text to be inserted.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function insertText(text:String):void
    {      
        handleInsertText(text);  
    }
    
    /**
     *  Appends the specified text to the end of the RichEditableText,
     *  as if you had clicked at the end and typed.
	 *
     *  <p>An insertion point is then set after the new text.
	 *  If necessary, the text will scroll to ensure
     *  that the insertion point is visible.</p>
	 *
	 *  @param text The text to be appended.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function appendText(text:String):void
    {
        handleInsertText(text, true);
    }

    /**
     *  @copy flashx.textLayout.container.ContainerController#scrollToRange() 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function scrollToRange(anchorPosition:int, activePosition:int):void
    {
        // Make sure the properties are commited and the text is composed.
        validateNow();

        // Scrolls so that the text position is visible in the container. 
        textContainerManager.scrollToRange(anchorPosition, activePosition);       
    }
        
    /**
     *  Selects a specified range of characters.
	 *
	 *  <p>If either position is negative, it will deselect the text range.</p>
	 *
	 *  @param anchorPosition The character position specifying the end
	 *  of the selection that stays fixed when the selection is extended.
	 *
	 *  @param activePosition The character position specifying the end
	 *  of the selection that moves when the selection is extended.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function selectRange(anchorPosition:int,
                                activePosition:int):void
    {
        // Make sure all properties are committed before doing the operation.
        validateNow();

        var selectionManager:ISelectionManager = getSelectionManager();
        
        selectionManager.selectRange(anchorPosition, activePosition);        
                
        // Refresh the selection.  This does not cause a damage event.
        selectionManager.refreshSelection();
        
        releaseSelectionManager();

        // Remember if the current selection is a range which was set
        // programatically.
        hasProgrammaticSelectionRange = (anchorPosition != activePosition);
    }
    
    /**
     *  Selects all of the text.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function selectAll():void
    {
        selectRange(0, int.MAX_VALUE);
    }

    /**
     *  Returns a TextLayoutFormat object specifying the formats
	 *  for the specified range of characters.
	 *
     *  <p>If a format is not consistently set across the entire range,
     *  its value will be <code>undefined</code>.</p>
	 *
     *  <p>You can specify a Vector of Strings containing the names of the
	 *  formats that you care about; if you don't, all formats
	 *  will be computed.</p>
	 *  
     *  <p>If you don't specify a range, the selected range is used.</p>
	 *
	 *  @param requestedFormats A Vector of Strings specifying the the names
	 *  of the requested formats, or <code>null</code> to request all formats.
	 *
	 *  @param anchorPosition A character position specifying
	 *  the fixed end of the selection.
	 *
	 *  @param activePosition A character position specifying
	 *   the movable end of the selection.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function getFormatOfRange(requestedFormats:Vector.<String> = null,
                                     anchorPosition:int = -1,
                                     activePosition:int = -1):TextLayoutFormat
    {
        var format:TextLayoutFormat = new TextLayoutFormat();
 
         // Make sure all properties are committed before doing the operation.
        validateNow();

        var selectionManager:ISelectionManager = getSelectionManager();
                
        // This internal TLF object maps the names of format properties
        // to Property instances.
        // Each Property instance has a category property which tells
        // whether it is container-, paragraph-, or character-level.
        var description:Object = TextLayoutFormat.description;
            
        var p:String;
        var category:String;
        
        // Based on which formats have been requested, determine which
        // of the getCommonXXXFormat() methods we need to call.

        var needContainerFormat:Boolean = false;
        var needParagraphFormat:Boolean = false;
        var needCharacterFormat:Boolean = false;

        if (!requestedFormats)
        {
            requestedFormats = new Vector.<String>;
            for (p in description)
                requestedFormats.push(p);
            
            needContainerFormat = true;
            needParagraphFormat = true;
            needCharacterFormat = true;
        }
        else
        {
            for each (p in requestedFormats)
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
        
        // Unfortunatley getCommonContainerFormat() works only on the curent
        // selection, so if another selection is requested, we have to 
        // temporarily change the current selection and then restore it when
        // we are done.
        var oldAnchorPosition:int;
        var oldActivePosition:int;
        if (anchorPosition != -1 && activePosition != -1)
        {
            oldAnchorPosition = _selectionAnchorPosition;
            oldActivePosition = _selectionActivePosition;
            
            ignoreSelectionChangeEvent = true;            
            selectionManager.selectRange(anchorPosition, activePosition);        
        }                       
                               
        if (needContainerFormat)
            containerFormat = selectionManager.getCommonContainerFormat();
        
        if (needParagraphFormat)
            paragraphFormat = selectionManager.getCommonParagraphFormat();

        if (needCharacterFormat)
            characterFormat = selectionManager.getCommonCharacterFormat();

        if (anchorPosition != -1 && activePosition != -1)
        {
            selectionManager.selectRange(oldAnchorPosition, oldActivePosition);
            ignoreSelectionChangeEvent = false;            
        }        
        
        // Extract the requested formats to return.
        for each (p in requestedFormats)
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
     *  Applies the specified format to the specified range.
	 *
	 *  <p>The supported formats are those in TextFormatLayout.
     *  A value of <code>undefined</code> does not get applied.
	 *  If you don't specify a range, the selected range is used.</p>
	 *
     *  <p>For example, calling
	 *  <pre>
     *  var textLayoutFormat:TextLayoutFormat = new TextLayoutFormat();
     *  textLayoutFormat.fontSize = 12;
     *  textLayoutFormat.color = 0xFF0000;
     *  setFormatOfRange(textLayoutFormat);
	 *  </pre>
     *  will set the fontSize and color of the selection.</p>
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function setFormatOfRange(format:TextLayoutFormat,
                                     anchorPosition:int=-1,
                                     activePosition:int=-1):void
    {
         // Make sure all properties are committed before doing the operation.
        validateNow();
        
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
        var description:Object = TextLayoutFormat.description;
        
        for (var p:String in description) 
        {
            if (format[p] === undefined)
                continue;
                                
            var category:String = description[p].category;
            
            if (category == Category.CONTAINER)
            {
                if (!containerFormat)
                   containerFormat =  new TextLayoutFormat();
                containerFormat[p] = format[p];
            }
            else if (category == Category.PARAGRAPH)
            {
                if (!paragraphFormat)
                   paragraphFormat =  new TextLayoutFormat();
                paragraphFormat[p] = format[p];
            }
            else if (category == Category.CHARACTER)
            {
                if (!characterFormat)
                   characterFormat =  new TextLayoutFormat();
                characterFormat[p] = format[p];
            }
        }

        var selectionState:SelectionState =
            anchorPosition == -1 || activePosition == -1 ? null :                       
            new SelectionState(editManager.textFlow, 
                               anchorPosition, 
                               activePosition);

        // Apply the three format objects to the current selection if
        // selectionState is null, else the specified selection.
        editManager.applyFormat(
            characterFormat, paragraphFormat, containerFormat, selectionState);
        
        // All done with the edit manager.
        releaseEditManager(editManager);
    }

    /**
     *  @private
     */
    mx_internal function createTextContainerManager():TextContainerManager
    {
        return new RichEditableTextContainerManager(this, staticConfiguration);
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
     *  When done call releaseEditManager().  Should only be used by API calls.
     */
    private function getEditManager():IEditManager
    {
        // This triggers a damage event if the interactionManager is
        // changed. 
                
        priorEditingMode = editingMode;
        
        if (editingMode != EditingMode.READ_WRITE)
            editingMode = EditingMode.READ_WRITE;
        
        var editManager:IEditManager =
            EditManager(_textContainerManager.beginInteraction());
            
        // Combine all the edits from one API call into one operation so it 
        // can be undone as a single operation.  It will also prevent this from
        // possibibly being combined with the last operation.
        editManager.beginCompositeOperation(); 
        
        return editManager;           
    }

    /**
     *  @private
     *  Should only be used by API calls.
     */
    private function releaseEditManager(editManager:IEditManager):void
    {
        editManager.endCompositeOperation();
                    
        _textContainerManager.endInteraction();

        editingMode = priorEditingMode;
    }
        
    /**
     *  @private
     *  Return true if there is a width and height to use for the measure.
     */
    mx_internal function isMeasureFixed():Boolean
    {
        if (!hostFormat || hostFormat.blockProgression != BlockProgression.TB)
            return true;
            
        // Is there some sort of width and some sort of height?
        return  (!isNaN(explicitWidth) || !isNaN(_widthInChars) ||
                 !isNaN(widthConstraint)) &&
                (!isNaN(explicitHeight) || !isNaN(_heightInLines) ||
                 !isNaN(heightConstraint));
    }
           
    /**
     *  @private
     *  Returns the bounds of the measured text.  The initial composeWidth may
     *  be adjusted for minWidth or maxWidth.  The value used for the compose
     *  is in _textContainerManager.compositionWidth.
     */
    private function measureTextSize(composeWidth:Number):Rectangle
    {             
        var clampWidth:Boolean = isNaN(explicitWidth);
               
        // Don't want to trigger a another remeasure when we compose the text.
        ignoreDamageEvent = true;

        // Up the composeWidth if it isn't at least minWidth so we get an 
        // accurate measurement.
        if (clampWidth &&
            !isNaN(explicitMinWidth) && composeWidth < explicitMinWidth)
        {
            composeWidth = explicitMinWidth;
        }
        
        // The bottom border can grow to allow all the text to fit.
        _textContainerManager.compositionWidth = composeWidth;
        _textContainerManager.compositionHeight = NaN;

        // Compose only.  The display should not be updated.
        _textContainerManager.compose();

        var bounds:Rectangle = _textContainerManager.getContentBounds();        

        // Remeasure if the composed width was restricted by max width.
        // Typical this is done in validateSize() after returing from measure() 
        // but it impacts our calculations so we need to do it now.
        if (clampWidth && bounds.width > maxWidth)
        {
            _textContainerManager.compositionWidth = composeWidth;
            _textContainerManager.compose();
            bounds = _textContainerManager.getContentBounds();
        }
            
        // If it's an empty text flow, there is one line with one
        // character so the height is good for the line but we
        // need to give it some width.
        
         if (_textContainerManager.getText().length == 0) 
        {
            // Empty text flow.  One Em wide so there
            // is a place to put the insertion cursor.
            bounds.width = bounds.width + getStyle("fontSize");
       }
       
       ignoreDamageEvent = false;
       
       //trace("measureTextSize", composeWidth, "->", bounds.width, bounds.height);
        
       return bounds;
    }

            
    /**
     *  @private
     *  If auto-sizing text, it may need to be remeasured if it is constrained
     *  by the layout manager.  Changing one dimension may change the size of
     *  the measured text and the layout manager needs to know this.
     */
    private function remeasureText(width:Number, height:Number):Boolean
    {   
        // Neither dimensions changed.  If auto-sizing we're still auto-sizing.
        if (width == measuredWidth && height == measuredHeight)
            return false;
             
        // Either constraints are preventing auto-sizing or we need to
        // remeasure which will reset autoSize.
        autoSize = false;
        
        if (width != measuredWidth)
        {
            // Do we have a constrained width and an explicit height?
            // If so, the sizes are set so no need to remeasure now.
            if (!isNaN(explicitHeight) || !isNaN(_heightInLines))
                return false;
                        
            // Is there no width?
            if (width == 0) 
                return false;
                                       
            // No reflow for explicit lineBreak
            if (hostFormat.lineBreak == "explicit")
                return false;

            widthConstraint = width;
        } 
        
        if (height != measuredHeight)
        {        
            // Do we have a constrained height and an explicit width?
            // If so, the sizes are set so no need to remeasure now.
            if (!isNaN(explicitWidth) || !isNaN(_widthInChars))
                return false;

            // Is there no height?
            if (height == 0)
                return false;

            heightConstraint = height;
        }                       

        // Width or height is different than what was measured.  Since we're
        // auto-sizing, need to remeasure, so the layout manager leaves the
        // correct amount of space for the component.
        invalidateSize();
            
        return true;            
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
                s = _textContainerManager.textLineCreator ?
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
    }
    
    /**
     *  @private
     */
    private function calculateWidthInChars():Number
    {
        var em:Number = getStyle("fontSize");

        var effectiveWidthInChars:int;
                
        // If both height and width are NaN use 10 chars.  Otherwise if only 
        // width is NaN, use 1.                
        if (isNaN(_widthInChars))
           effectiveWidthInChars = isNaN(_heightInLines) ? 10 : 1;
        else
           effectiveWidthInChars = _widthInChars;
           
        // Without the explicit casts, if padding values are non-zero, the
        // returned width is a very large number.
        return getStyle("paddingLeft") +
               effectiveWidthInChars * em +
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
        
        if (_heightInLines == 0)
            return height;
        
        var effectiveHeightInLines:int;
        
        // If both height and width are NaN use 10 lines.  Otherwise if 
        // only height is NaN, use 1.
        if (isNaN(_heightInLines))
            effectiveHeightInLines = isNaN(_widthInChars) ? 10 : 1;   
        else
            effectiveHeightInLines = _heightInLines;
            
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
        if (effectiveHeightInLines > 1)
        {
            var value:Object = getStyle("lineHeight");     
            var lineHeight:Number =
                TextUtil.getNumberOrPercentOf(value, getStyle("fontSize"));
                
            // Default is 120%
            if (isNaN(lineHeight))
                lineHeight = getStyle("fontSize") * 1.2;
            
            height += (effectiveHeightInLines - 1) * lineHeight;
        }            
        
        // Add in descent of last line.
        height += descent;              
        
        return height;
    }
        
    /**
     *  @private
     */
    private function createTextFlowFromContent(content:Object):TextFlow
    {
        var textFlow:TextFlow ;
        
        if (content is TextFlow)
        {
            textFlow = content as TextFlow;
        }
        else if (content is Array)
        {
            textFlow = new TextFlow();
			textFlow.whiteSpaceCollapse = getStyle("whiteSpaceCollapse");
            textFlow.mxmlChildren = content as Array;
			textFlow.whiteSpaceCollapse = undefined;
        }
        else
        {
            textFlow = new TextFlow();
			textFlow.whiteSpaceCollapse = getStyle("whiteSpaceCollapse");
            textFlow.mxmlChildren = [ content ];
			textFlow.whiteSpaceCollapse = undefined;
        }
        
        return textFlow;
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
     *  @private
     * 
     *  This is used when text is either inserted or appended via the API.
     */
    private function handleInsertText(text:String, isAppend:Boolean=false):void
    {
        // Make sure all properties are committed and events dispatched
        // before doing the append.
        validateNow();

        // Always use the EditManager regardless of the values of
        // selectable, editable and enabled.
        var editManager:IEditManager = getEditManager();
        
        // An append is an insert with the selection set to the end.
        // If no selection, then it's an append.
         if (isAppend || !editManager.hasSelection())
            editManager.selectRange(int.MAX_VALUE, int.MAX_VALUE);

        dispatchChangeAndChangingEvents = false;
 
        // Insert the text.  It will be composed but the display will not be
        // updated because of our override of 
        // EditManager.updateAllControllers().
        editManager.insertText(text);

        // Make the insertion happen now rather than on the next frame.
        editManager.flushPendingOperations();
        
        dispatchChangeAndChangingEvents = true;
        
        // All done with edit manager.
        releaseEditManager(editManager);        

        dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));                                   
    }

    /**
     *  @private
     */
    private function handlePasteOperation(op:PasteOperation):void
    {
        if (!restrict && !maxChars && !displayAsPassword)
            return;

        // If copied/cut from displayAsPassword field the pastedText
        // is '*' characters but this is correct.
        var pastedText:String = TextUtil.extractText(op.textScrap.textFlow);

        // We know it's an EditManager or we wouldn't have gotten here.
        var editManager:IEditManager = 
            EditManager(_textContainerManager.beginInteraction());

        // Generate a CHANGING event for the PasteOperation but not for the
        // DeleteTextOperation or the InsertTextOperation which are also part
        // of the paste.
        dispatchChangeAndChangingEvents = false;

        var selectionState:SelectionState = new SelectionState(
            op.textFlow, op.absoluteStart, 
            op.absoluteStart + pastedText.length);             
        editManager.deleteText(selectionState);

        // Insert the same text, the same place where the paste was done.
        // This will go thru the InsertPasteOperation and do the right
        // things with restrict, maxChars and displayAsPassword.
        selectionState = new SelectionState(
            op.textFlow, op.absoluteStart, op.absoluteStart);
        editManager.insertText(pastedText, selectionState);        

        // All done with the edit manager.
        _textContainerManager.endInteraction();
        
        dispatchChangeAndChangingEvents = true;
    }
            
    //--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  find the right time to listen to the focusmanager
     */
    private function addedToStageHandler(event:Event):void
    {
        if (event.target == this)
        {
            removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
            callLater(addActivateHandlers);
        }    
    }

    /**
     *  @private
     *  add listeners to focusManager
     */
    private function addActivateHandlers():void
    {
        focusManager.addEventListener(FlexEvent.FLEX_WINDOW_ACTIVATE, 
            _textContainerManager.activateHandler, false, 0, true)
        focusManager.addEventListener(FlexEvent.FLEX_WINDOW_DEACTIVATE, 
            _textContainerManager.deactivateHandler, false, 0, true)
    }

    /**
     *  @private
     *  Called when a FocusManager is added to an IFocusManagerContainer.
     *  We need to check that it belongs
     *  to us before listening to it.
     *  Because we listen to sandboxroot, you cannot assume the type of
     *  the event.
     */
    private function addFocusManagerHandler(event:Event):void
    {
        if (focusManager == event.target["focusManager"])
        {
            systemManager.getSandboxRoot().removeEventListener(FlexEvent.ADD_FOCUS_MANAGER, 
                    addFocusManagerHandler, true)
            addActivateHandlers();
        }
    }

    /**
     *  @private
     *  RichEditableTextContainerManager overrides focusInHandler and calls
     *  this before executing its own focusInHandler.
     */
    mx_internal function focusInHandler(event:FocusEvent):void
    {
        // When TCM is simulating a focusIn event, event will be null.
        // Ignore these and wait for the actual focus in event.
        if (event == null)
            return;
             
        //trace("focusIn handler");

        var fm:IFocusManager = focusManager;
        if (fm && editingMode == EditingMode.READ_WRITE)
            fm.showFocusIndicator = true;
        
        // showFocusIndicator must be set before this is called.
        super.focusInHandler(event);
        
        if (editingMode == EditingMode.READ_WRITE)
        {
            // If the focusIn was because of a mouseDown event, let TLF
            // handle the selection.  Otherwise it was because we tabbed in
            // or we programatically set the focus.
            if (!mouseDown)
            {
                var selectionManager:ISelectionManager = 
                    _textContainerManager.beginInteraction();       
    
                if (multiline)
                {
                    if (!selectionManager.hasSelection())
                        selectionManager.selectRange(0, 0);
                } 
                else if (!hasProgrammaticSelectionRange)
                {
                    selectionManager.selectAll();
                }
                
                selectionManager.refreshSelection();
                
                _textContainerManager.endInteraction();       
            }
            
            if (_imeMode != null)
            {
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
     *  RichEditableTextContainerManager overrides focusOutHandler and calls
     *  this before executing its own focusOutHandler.
     */
    mx_internal function focusOutHandler(event:FocusEvent):void
    {
        //trace("focusOut handler");

        super.focusOutHandler(event);

        // By default, we clear the undo history when a RichEditableText loses 
        // focus.
        if (clearUndoOnFocusOut && undoManager)
            undoManager.clearAll();
                    
        if (focusManager)
            focusManager.defaultButtonEnabled = true;


        dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));                           
    }

    /**
     *  @private
     *  RichEditableTextContainerManager overrides keyDownHandler and calls
     *  this before executing its own keyDownHandler.
     */ 
    mx_internal function keyDownHandler(event:KeyboardEvent):void
    {
        if (editingMode != EditingMode.READ_WRITE)
            return;
        
        if (event.keyCode == Keyboard.ENTER)
        {            
            // We always handle the 'enter' key since we would have to recreate
            // the container manager to change the configuration if multiline 
            // changes.            
            if (multiline)
            {
                var editManager:IEditManager = 
                    EditManager(_textContainerManager.beginInteraction());
                
                if (editManager.hasSelection())
                    editManager.splitParagraph();
                
                _textContainerManager.endInteraction();
            }
            else
            { 
                dispatchEvent(new FlexEvent(FlexEvent.ENTER));
            }

            event.preventDefault();
         }
    }

    /**
     *  @private
     */
    mx_internal function mouseDownHandler(event:MouseEvent):void
    {
        mouseDown = true;
            
        // Need to get called even if mouse events are dispatched
        // outside of this component.  For example, when the user does
        // a mouse down in RET, drags the mouse outside of the 
        /// component, and then releases the mouse.
        systemManager.getSandboxRoot().addEventListener(
                          MouseEvent.MOUSE_UP, 
                          systemManager_mouseUpHandler, true /*useCapture*/);
    }
        
    /**
     *  @private
     */
    private function systemManager_mouseUpHandler(event:MouseEvent):void
    {
        mouseDown = false;
        
        systemManager.getSandboxRoot().removeEventListener(
                         MouseEvent.MOUSE_UP, 
                         systemManager_mouseUpHandler, true /*useCapture*/);
    }

    /**
     *  @private
     *  Called when the TextContainerManager dispatches a 'compositionComplete'
     *  event when it has recomposed the text into TextLines.
     */
    private function textContainerManager_compositionCompleteHandler(
                                    event:CompositionCompleteEvent):void
    {
        //trace("compositionComplete");
                
        var oldContentWidth:Number = _contentWidth;

        var newContentBounds:Rectangle = 
            _textContainerManager.getContentBounds();
        var newContentWidth:Number = newContentBounds.width;
        
        // TODO:(cframpto) handle blockProgression == RL
        
        // TODO:(cframpto) Figure out if we still need these checks.
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

            // If there is a scroller, this triggers the scroller layout.
            dispatchPropertyChangeEvent(
                "contentWidth", oldContentWidth, newContentWidth);
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
            
            // If there is a scroller, this triggers the scroller layout.
            dispatchPropertyChangeEvent(
                "contentHeight", oldContentHeight, newContentHeight);
        } 
    }
    
    /**
     *  @private
     *  Called when the TextContainerManager dispatches a 'damage' event.
     *  The TextFlow could have been modified interactively or programatically.
     */
    private function textContainerManager_damageHandler(event:DamageEvent):void
    {
        // The following textContainerManager functions can trigger a damage
        // event:
        //    setText/setTextFlow
        //    set hostFormat
        //    set compositionWidth/compositionHeight
        //    set horizontalScrollPosition/veriticalScrollPosition
        //    set textLineCreator
        //    updateContainer or compose: always if TextFlowFactory, sometimes 
        //        if flowComposer

        // If no changes, don't recompose/update.  The TextFlowFactory 
        // createTextLines dispatches damage events every time the textFlow
        // is composed, even if there are no changes. 
        if (_textFlow && _textFlow.generation == lastGeneration)
            return;

        if (ignoreDamageEvent || event.damageLength == 0)
            return;

        //trace("damageHandler", id, event.damageAbsoluteStart, event.damageLength);

        // If there are pending changes, don't wipe them out.  We have
        // not gotten to commitProperties() yet.
        if (textChanged || textFlowChanged || contentChanged)
            return;
                               
        // In this case we always maintain _text with the underlying text and
        // display the appropriate number of passwordChars.  If there are any
        // interactive editing operations _text is updated during the operation.
        if (displayAsPassword)
            return;
                        
        // Invalidate _text and _content.
        _text = null;
        _content = null;        
        _textFlow = _textContainerManager.getTextFlow();

        lastGeneration = _textFlow.generation;
        
        // We don't need to call invalidateProperties()
        // because the hostFormat and the _textFlow are still valid.
        
        // We don't need to call invalidateSize() for isMeasureFixed()
        // because the width and height are still valid.  For the other cases,
        // our override of EditManager.updateAllContainers(), will invalidate
        // the size, if the content size has actually changed.
            
        // Style change by changing textFlow directly could change size.
        if (_textContainerManager.hostFormat != _textFlow.hostFormat)
            invalidateSize();
            
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
            //trace("hsp scroll", oldHorizontalScrollPosition, "->", newHorizontalScrollPosition);

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
        if (ignoreSelectionChangeEvent)
            return;
            
        var oldAnchor:int = _selectionAnchorPosition;
        var oldActive:int = _selectionActivePosition;
        
        var selectionManager:ISelectionManager = 
            _textContainerManager.beginInteraction();
        
        _selectionAnchorPosition = selectionManager.anchorPosition;
        _selectionActivePosition = selectionManager.activePosition;
        
        _textContainerManager.endInteraction();

        // Selection changed so reset.
        hasProgrammaticSelectionRange = false;
        
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

            // The text deleted by this operation.  If we're doing our
            // own manipulation of the textFlow we have to take the deleted
            // text into account as well as the inserted text.
            var delSelOp:SelectionState = 
                insertTextOperation.deleteSelectionState;

            var delLen:int = (delSelOp == null) ? 0 :
                             delSelOp.absoluteEnd - delSelOp.absoluteStart;
                
            if (maxChars != 0)
            {
                var length1:int = text.length - delLen;
                var length2:int = textToInsert.length;
                if (length1 + length2 > maxChars)
                    textToInsert = textToInsert.substr(0, maxChars - length1);
            }

            if (_displayAsPassword)
            {
                // Remove deleted text.
                if (delLen > 0)
                {
                    _text = splice(_text, delSelOp.absoluteStart, 
                                   delSelOp.absoluteEnd, "");                                    
                }
                
                // Add in the inserted text.
                _text = splice(_text, insertTextOperation.absoluteStart,
                               insertTextOperation.absoluteEnd, textToInsert);
                
                // Display the passwordChar rather than the actual text.
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
 
        // Dispatch a 'changing' event from the RichEditableText
        // as notification that an editing operation is about to occur.
        if (dispatchChangeAndChangingEvents)
        {
            var newEvent:TextOperationEvent =
                new TextOperationEvent(TextOperationEvent.CHANGING);
            newEvent.operation = op;
            dispatchEvent(newEvent);
            
            // If the event dispatched from this RichEditableText is canceled,
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

        // Dispatch a 'change' event from the RichEditableText
        // as notification that an editing operation has occurred.
        if (dispatchChangeAndChangingEvents)
        {
            var newEvent:TextOperationEvent =
                new TextOperationEvent(TextOperationEvent.CHANGE);
            newEvent.operation = event.operation;
            dispatchEvent(newEvent);
        }
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
            if (autoSize)
                invalidateSize();
            
            invalidateDisplayList();
        } 
    }    
}

}
