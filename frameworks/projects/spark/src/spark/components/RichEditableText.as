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

package mx.components
{

import flash.display.Graphics;
import flash.events.Event;
import flash.geom.Rectangle;
import flash.text.engine.ElementFormat;
import flash.text.engine.FontDescription;
import flash.text.engine.TextBlock;
import flash.text.engine.TextElement;
import flash.text.engine.TextLine;
import flash.ui.Keyboard;

import flashx.textLayout.compose.IFlowComposer;
import flashx.textLayout.compose.StandardFlowComposer;
import flashx.textLayout.container.DisplayObjectContainerController;
import flashx.textLayout.container.IContainerController;
import flashx.textLayout.conversion.ImportExportConfiguration;
import flashx.textLayout.conversion.ITextImporter;
import flashx.textLayout.conversion.TextFilter;
import flashx.textLayout.conversion.ConversionType;
import flashx.textLayout.edit.EditManager;
import flashx.textLayout.edit.ISelectionManager;
import flashx.textLayout.elements.Configuration;
import flashx.textLayout.elements.FlowElement;
import flashx.textLayout.elements.ParagraphElement;
import flashx.textLayout.elements.SpanElement;
import flashx.textLayout.elements.TextFlow;
import flashx.textLayout.events.CompositionCompletionEvent;
import flashx.textLayout.events.FlowOperationEvent;
import flashx.textLayout.events.SelectionEvent;
import flashx.textLayout.formats.CharacterFormat;
import flashx.textLayout.formats.ContainerFormat;
import flashx.textLayout.formats.ICharacterFormat;
import flashx.textLayout.formats.IContainerFormat;
import flashx.textLayout.formats.IParagraphFormat;
import flashx.textLayout.formats.ParagraphFormat;
import flashx.textLayout.operations.ApplyFormatOperation;
import flashx.textLayout.operations.FlowOperation;
import flashx.textLayout.operations.SplitParagraphOperation;

import mx.core.IViewport;
import mx.core.UIComponent;
import mx.events.FlexEvent;
import mx.events.TextOperationEvent;
import mx.utils.TextUtil;

//--------------------------------------
//  Events
//--------------------------------------

/**
 *  Dispached after the <code>selectionAnchorPosition</code> and/or
 *  <code>selectionActivePosition</code> properties have changed.
 *  due to a user interaction.
 */
[Event(name="selectionChange", type="mx.events.FlexEvent")]

/**
 *  Dispatched before a user editing operation occurs.
 *  You can alter the operation, or cancel the event
 *  to prevent the operation from being processed.
 */
[Event(name="changing", type="mx.events.TextOperationEvent")]

/**
 *  Dispatched after a user editing operation is complete.
 */
[Event(name="change", type="mx.events.TextOperationEvent")]

/**
 *  Dispatched when the user pressed the Enter key.
 */
[Event(name="enter", type="mx.events.FlexEvent")]

//--------------------------------------
//  Styles
//--------------------------------------

include "../styles/metadata/BasicContainerFormatTextStyles.as"
include "../styles/metadata/AdvancedContainerFormatTextStyles.as"
include "../styles/metadata/BasicParagraphFormatTextStyles.as"
include "../styles/metadata/AdvancedParagraphFormatTextStyles.as"
include "../styles/metadata/BasicCharacterFormatTextStyles.as"
include "../styles/metadata/AdvancedCharacterFormatTextStyles.as"

//--------------------------------------
//  Other metadata
//--------------------------------------

[DefaultProperty("content")]

[IconFile("TextView.png")]

/**
 *  Displays text. 
 *  
 *  <p>TextView has more functionality than TextBox and TextGraphic. In addition to the text rendering 
 *  capabilities of TextGraphic, TextView also supports hyperlinks, scrolling, selecting, and editing.</p>
 *  
 *  <p>The TextView class is similar to the mx.controls.TextArea control, except that it does 
 *  not have chrome.</p>
 *  
 *  <p>The TextView class does not support drawing a background, border, or scrollbars. To do that,
 *  you combine it with other components.</p>
 *  
 *  <p>Because TextView extends UIComponent, it can take focus and allows user interaction such as selection.</p>
 *  
 *  @see mx.graphics.TextBox
 *  @see mx.graphics.TextGraphic
 *
 *  @includeExample examples/TextViewExample.mxml
 */
public class TextView extends UIComponent implements IViewport
{
    include "../core/Version.as";
        
    //--------------------------------------------------------------------------
    //
    //  Class variables
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  Used for determining whitespace processing during import.
     */
    private static var staticCharacterFormat:CharacterFormat =
        new CharacterFormat();
    
    /**
     *  @private
     *  Used for determining whitespace processing during import.
     */
    private static var staticConfiguration:Configuration =
        new Configuration();
    
    /**
     *  @private
     *  Used for determining whitespace processing during import.
     */
    private static var staticImportExportConfiguration:ImportExportConfiguration;

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor. 
     */
    public function TextView()
    {
        // Initialize staticImportExportConfiguration at instance-creation
        // time rather than at static initialization time, to avoid
        // any class-initialization-order problems.
        if (!staticImportExportConfiguration)
        {
            staticImportExportConfiguration =
                ImportExportConfiguration.defaultConfiguration;
            
            ImportExportConfiguration.restoreDefaults();
        }

        super();

        _content = textFlow = createEmptyTextFlow();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    private var textFlow:TextFlow;
            
    /**
     *  @private
     *  This object is determined by the CSS styles of the TextGraphic
     *  and is updated by createTextFlow() when the hostFormatsInvalid flag
     *  is true.
     */
    private var hostCharacterFormat:CharacterFormat = new CharacterFormat();

    /**
     *  @private
     *  This object is determined by the CSS styles of the TextGraphic
     *  and is updated by createTextFlow() when the hostFormatsInvalid flag
     *  is true.
     */
    private var hostParagraphFormat:ParagraphFormat = new ParagraphFormat();

    /**
     *  @private
     *  This object is determined by the CSS styles of the TextGraphic
     *  and is updated by createTextFlow() when the hostFormatsInvalid flag
     *  is true.
     */
    private var hostContainerFormat:ContainerFormat = new ContainerFormat();

    /**
     *  @private
     *  This flag indicates whether hostCharacterFormat, hostParagraphFormat,
     *  and hostContainerFormat need to be recalculated from the CSS styles
     *  of the TextGraphic. It is set true by stylesInitialized() and also
     *  when styleChanged() is called with a null argument, indicating that
     *  multiple styles have changed.
     */
    private var hostFormatsInvalid:Boolean = false;

    /**
     *  @private
     */
    private var stylesChanged:Boolean = false;
    
    /**
     *  @private
     */
    private var fontMetricsInvalid:Boolean = false;
    
    /**
     *  @private
     */
    private var textInvalid:Boolean = false;
        
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
     */
    private var charWidth:Number;

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  clipContent
    //----------------------------------
        
    /**
     *  @private
     */
    private var _clipContent:Boolean = true;
    
    /**
     *  @copy mx.layout.LayoutBase#clipContent
     */
    public function get clipContent():Boolean 
    {
        return _clipContent;
    }
    
    /**
     *  @private
     */
    public function set clipContent(value:Boolean):void 
    {
        if (value == _clipContent) 
            return;
    
        _clipContent = value;
        // TBD implement this
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
     *  Documentation is not currently available.
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
     */
    public function get contentWidth():Number
    {
        return _contentWidth;
    }

    //----------------------------------
    //  heightInLines
    //----------------------------------

    /**
     *  @private
     */
    private var _heightInLines:int = 10;

    /**
     *  @private
     */
    private var heightInLinesChanged:Boolean = false;
    
    /**
     *  The height of the control, in lines.
     *  
     *  <p>TextView's measure() method does not determine the measured size from the text to be displayed, 
     *  because a TextView often starts out with no text. Instead it uses this property, and the widthInChars property 
     *  to determine its measuredWidth and measuredHeight. These are 
     *  similar to the cols and rows of an HTML TextArea.</p>
     */
    public function get heightInLines():int
    {
        return _heightInLines;
    }

    /**
     *  @private
     */
    public function set heightInLines(value:int):void
    {
        if (value == _heightInLines)
            return;

        _heightInLines = value;
        heightInLinesChanged = true;

        invalidateSize();
        invalidateDisplayList();
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
    //  horizontal ScrollPositionDelta
    //----------------------------------

    /**
     *  @copy mx.layout.LayoutBase#horizontalScrollPositionDelta
     */
    public function horizontalScrollPositionDelta(unit:uint):Number
    {
        // TBD: replace provisional implementation
        var scrollR:Rectangle = scrollRect;
        if (!scrollR)
            return 0;
            
        var maxDelta:Number = contentWidth - scrollR.width - scrollR.x;
        var minDelta:Number = -scrollR.x; 
            
        switch (unit)
        {
            case Keyboard.UP:
                return (scrollR.x <= 0) ? 0 : -1;
                
            case Keyboard.DOWN:
                return (scrollR.x >= maxDelta) ? 0 : 1;
                
            case Keyboard.PAGE_UP:
                return Math.max(minDelta, -scrollR.width);
                
            case Keyboard.PAGE_DOWN:
                return Math.min(maxDelta, scrollR.width);
                
            case Keyboard.HOME: 
                return minDelta;
                
            case Keyboard.END: 
                return maxDelta;
                
            default:
                return 0;
        }       
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
    //  selectionActivePosition
    //----------------------------------

    /**
     *  @private
     */
    private var _selectionActivePosition:int = -1;

    /**
     *  The active position of the selection.
     *  The "active" point is the end of the selection
     *  which is changed when the selection is extended.
     *  The active position may be either the start
     *  or the end of the selection. 
     *
     *  @default -1
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

    /**
     *  The anchor position of the selection.
     *  The "anchor" point is the stable end of the selection
     *  when the selection is extended.
     *  The anchor position may be either the start
     *  or the end of the selection.
     *
     *  @default -1
     */
    public function get selectionAnchorPosition():int
    {
        return _selectionAnchorPosition;
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

    /**
     *  The text String displayed by this TextView.
     */
    public function get text():String 
    {
        if (textInvalid)
        {
            _text = TextUtil.extractText(textFlow);
            textInvalid = false;
        }

        return _text;
    }
    
    /**
     *  @private
     */
    public function set text(value:String):void
    {
        // Setting 'text' temporarily causes 'content' to become null.
        // Later, after the 'text' has been committed into the TextFlow,
        // getting 'content' will return the TextFlow.
        _content = null;
        contentChanged = false;
        
        _text = value;
        textChanged = true;
        
        invalidateSize();
        invalidateDisplayList();
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
        
    //----------------------------------
    //  verticalScrollPositionDelta
    //----------------------------------

    /**
     *  @copy mx.layout.LayoutBase#horizontalScrollPositionDelta
     */
    public function verticalScrollPositionDelta(unit:uint):Number
    {
        // TBD: replace provisional implementation
        var scrollR:Rectangle = scrollRect;
        if (!scrollR)
            return 0;
            
        var maxDelta:Number = contentHeight - scrollR.height - scrollR.y;
        var minDelta:Number = -scrollR.y; 
            
        switch (unit)
        {
            case Keyboard.UP:
                return (scrollR.y <= 0) ? 0 : -1;
                
            case Keyboard.DOWN:
                return (scrollR.y >= maxDelta) ? 0 : 1;
                
            case Keyboard.PAGE_UP:
                return Math.max(minDelta, -scrollR.height);
                
            case Keyboard.PAGE_DOWN:
                return Math.min(maxDelta, scrollR.height);
                
            case Keyboard.HOME: 
                return minDelta;
                
            case Keyboard.END: 
                return maxDelta;
                
            default:
                return 0;
        }       
    }
    
    //----------------------------------
    //  widthInChars
    //----------------------------------

    /**
     *  @private
     */
    private var _widthInChars:int = 20;

    /**
     *  @private
     */
    private var widthInCharsChanged:Boolean = true;
        
    /**
     *  The default width for the TextInput, measured in characters.
     *  The width of the "0" character is used for the calculation,
     *  since in most fonts the digits all have the same width.
     *  So if you set this property to 5, it will be wide enough
     *  to let the user enter 5 digits.
     *
     *  @default
     */
    public function get widthInChars():int 
    {
        return _widthInChars;
    }
    
    /**
     *  @private
     */
    public function set widthInChars(value:int):void
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

        var flowComposer:IFlowComposer = textFlow.flowComposer;
        if (!flowComposer || flowComposer.numControllers == 0)
            return;
        
        var containerController:IContainerController =
            flowComposer.getControllerAt(0);

        if (horizontalScrollPositionChanged)
        {
            containerController.horizontalScrollPosition =
                _horizontalScrollPosition;
            horizontalScrollPositionChanged = false;
        }

        if (verticalScrollPositionChanged)
        {
            containerController.verticalScrollPosition =
                _verticalScrollPosition;
            verticalScrollPositionChanged = false;
        }
    }

    /**
     *  @private
     */
    override protected function measure():void 
    {
        super.measure();

        // Recalculate the ascent, descent, and charWidth
        // if these might have changed.
        if (fontMetricsInvalid)
        {
            calculateFontMetrics();

            fontMetricsInvalid = false;
        }

        measuredWidth = Math.round(getStyle("paddingLeft") +
                        widthInChars * charWidth +
                        getStyle("paddingRight"));
         
        measuredHeight = Math.round(getStyle("paddingTop") +
                         heightInLines * (ascent + descent) +
                         getStyle("paddingBottom"));

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

        /*
        var g:Graphics = graphics;
        g.clear();
        g.lineStyle(NaN);
        g.beginFill(0xEEEEEE, 1.0);
        g.drawRect(0, 0, unscaledWidth, unscaledHeight);
        g.endFill();
        */

        var flowComposer:IFlowComposer;
        
        // Regenerate TextLines if necessary.
        if (textChanged || contentChanged || stylesChanged)
        {
            // Eliminate detritus from the previous TextFlow.
            if (textFlow && textFlow.flowComposer &&
                textFlow.flowComposer.numControllers)
            {
                textFlow.flowComposer.removeControllerAt(0);
            }
            
            // If the text was changed, clear the selection.
            if (textChanged || contentChanged)
                if (textFlow.interactionManager)
                    textFlow.interactionManager.setSelection(-1, -1);
            
            // Create a new TextFlow for the current text.
            _content = textFlow = createTextFlow();
                        
            // Tell it where to create its TextLines.
            flowComposer = new StandardFlowComposer();
            flowComposer.addController(
                new DisplayObjectContainerController(this));
            textFlow.flowComposer = flowComposer;
            
            // Give it an EditManager to make it editable.
            textFlow.interactionManager = new TextViewEditManager();

            // Listen to events from the TextFlow and its EditManager.
            addListeners(textFlow);
            
            textChanged = false;
            contentChanged = false;
            stylesChanged = false;
        }

        // Tell the TextFlow to generate TextLines within the
        // rectangle (0, 0, unscaledWidth, unscaledHeight).
        flowComposer = textFlow.flowComposer;
        var containerController:IContainerController =
            flowComposer.getControllerAt(0);
        containerController.setCompositionSize(unscaledWidth, unscaledHeight);
        flowComposer.updateAllContainers();
    }

    /**
     *  @inheritDoc
     */
    override public function stylesInitialized():void
    {
        super.stylesInitialized();

        fontMetricsInvalid = true;
        hostFormatsInvalid = true;
        stylesChanged = true;
    }

    /**
     *  @inheritDoc
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
            hostFormatsInvalid = true;
        else
            setHostFormat(styleProp);

        stylesChanged = true;
    }

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  This method is called when anything affecting the
     *  default font, size, weight, etc. changes.
     *  It calculates the 'ascent', 'descent', and 'charWidth'
     *  instance variables, which are used in measure().
     */
    private function calculateFontMetrics():void
    {
        var fontDescription:FontDescription = new FontDescription();
        fontDescription.fontName = getStyle("fontFamily");
        
        var elementFormat:ElementFormat = new ElementFormat();
        elementFormat.fontDescription = fontDescription;
        elementFormat.fontSize = getStyle("fontSize");
        
        var textElement:TextElement = new TextElement();
        textElement.elementFormat = elementFormat;
        textElement.text = "0";
        
        var textBlock:TextBlock = new TextBlock();
        textBlock.content = textElement;
        
        var textLine:TextLine = textBlock.createTextLine(null, 1000);
        
        ascent = textLine.ascent;
        descent = textLine.descent;
        charWidth = textLine.textWidth;
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
    private function setHostFormat(styleProp:String):void
    {
        var value:* = getStyle(styleProp);
        if (styleProp == "tabStops" && value === undefined)
            value = [];

        var kind:String = TextUtil.FORMAT_MAP[styleProp];

        if (kind == TextUtil.CONTAINER)
            hostContainerFormat[styleProp] = value;
        
        else if (kind == TextUtil.PARAGRAPH)
            hostParagraphFormat[styleProp] = value;
        
        else if (kind == TextUtil.CHARACTER)
            hostCharacterFormat[styleProp] = value;
    }

    /**
     *  @private
     */
    private function createTextFlowFromMarkup(markup:Object):TextFlow
    {
        // The whiteSpaceCollapse format determines how whitespace
        // is processed when markup is imported.
		staticCharacterFormat.whiteSpaceCollapse =
            getStyle("whiteSpaceCollapse");
		staticConfiguration.textFlowInitialCharacterFormat =
            staticCharacterFormat;
		staticImportExportConfiguration.textFlowConfiguration =
            staticConfiguration; 

        if (markup is String)
        {
            markup = '<TextFlow xmlns="http://ns.adobe.com/textLayout/2008">' +
                     markup +
                     '</TextFlow>';
        }
        
        return TextFilter.importToFlow(markup, TextFilter.TEXT_LAYOUT_FORMAT,
                                       staticImportExportConfiguration);
    }
    
    /**
     *  @private
     */
    private function createTextFlowFromChildren(children:Array):TextFlow
    {
        var textFlow:TextFlow = new TextFlow();

        // The whiteSpaceCollapse format determines how whitespace
        // is processed when the children are set.
        staticCharacterFormat.whiteSpaceCollapse =
            getStyle("whiteSpaceCollapse");
        textFlow.hostCharacterFormat = staticCharacterFormat;

        textFlow.mxmlChildren = children;

        return textFlow;
    }

    /**
     *  @private
     *  Keep this method in sync with the same method in TextGraphic.
     */
    private function createTextFlow():TextFlow
    {
        if (contentChanged)
        {
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
                throw new Error("invalid content");
            }
            textInvalid = true;
            dispatchEvent(new Event("textInvalid"));
        }
        else if (textChanged)
        {
            var t:String = _text;
            if (t != null && t != "")
            {
                textFlow = TextFilter.importToFlow(t, TextFilter.PLAIN_TEXT_FORMAT);
            }
            else
            {
                textFlow = createEmptyTextFlow();
            }
        }

        if (hostFormatsInvalid)
        {
            for each (var p:String in TextUtil.ALL_FORMAT_NAMES)
            {
                setHostFormat(p);
            }
            hostFormatsInvalid = false;
        }

        textFlow.hostCharacterFormat = hostCharacterFormat;
        textFlow.hostParagraphFormat = hostParagraphFormat;
        textFlow.hostContainerFormat = hostContainerFormat;

        return textFlow;
    }

    /**
     *  @private
     */
    private function addListeners(textFlow:TextFlow):void
    {
        textFlow.addEventListener(
            CompositionCompletionEvent.COMPOSITION_COMPLETE,
            textFlow_compositionCompleteHandler);
        
        textFlow.addEventListener(Event.SCROLL, textFlow_scrollHandler);

        textFlow.addEventListener(
            SelectionEvent.SELECTION_CHANGE,
            textFlow_selectionChangeHandler);

        textFlow.addEventListener(
            FlowOperationEvent.FLOW_OPERATION_BEGIN,
            textFlow_flowOperationBeginHandler);

        textFlow.addEventListener(
            FlowOperationEvent.FLOW_OPERATION_END,
            textFlow_flowOperationEndHandler);
    }

    /**
     *  Sets the selection range.
     */
    public function setSelection(anchorPosition:int = 0,
                                 activePosition:int = int.MAX_VALUE):void
    {
        textFlow.interactionManager.setSelection(anchorPosition,
                                                 activePosition);
        textFlow.flowComposer.updateAllContainers();
    }
    
    /**
     *  Inserts the specified text as if you had typed it.
     *  If a range was selected, the new text replaces the selected text;
     *  if there was an insertion point, the new text is inserted there.
     *  An insertion point is then set after the new text.
     */
    public function insertText(text:String):void
    {
        EditManager(textFlow.interactionManager).insertText(text);
    }
    
    /**
     *  Appends the specified text to the end of the TextView,
     *  as if you had clicked at the end and typed it.
     *  When TextView supports vertical scrolling,
     *  it will scroll to ensure that the last line
     *  of the inserted text is visible.
     */
    public function appendText(text:String):void
    {
        textFlow.interactionManager.setSelection(int.MAX_VALUE, int.MAX_VALUE);
        EditManager(textFlow.interactionManager).insertText(text);
    }

    /**
     *  Returns a String containing markup describing
     *  this TextView's TextFlow.
     *  This markup String has the appropriate format
     *  for setting the <code>content</code> property.
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
     */
    public function getSelectionFormat(names:Array = null):Object
    {
        var selectionManager:ISelectionManager = textFlow.interactionManager;
                
        var p:String;
        var kind:String;
        
        var needContainerFormat:Boolean = false;
        var needParagraphFormat:Boolean = false;
        var needCharacterFormat:Boolean = false;

        if (!names)
        {
            names = TextUtil.ALL_FORMAT_NAMES;
            
            needContainerFormat = true;
            needParagraphFormat = true;
            needCharacterFormat = true;
        }
        else
        {
            for each (p in names)
            {
                kind = TextUtil.FORMAT_MAP[p];

                if (kind == TextUtil.CONTAINER)
                    needContainerFormat = true;
                else if (kind == TextUtil.PARAGRAPH)
                    needParagraphFormat = true;
                else if (kind == TextUtil.CHARACTER)
                    needCharacterFormat = true;
            }
        }
        
        var containerFormat:IContainerFormat;
        var paragraphFormat:IParagraphFormat;
        var characterFormat:ICharacterFormat;
        
        if (needContainerFormat)
        {
            containerFormat =
                selectionManager.getCommonContainerFormat();
        }
        
        if (needParagraphFormat)
        {
            paragraphFormat =
                selectionManager.getCommonParagraphFormat();
        }

        if (needCharacterFormat)
        {
            characterFormat =
                selectionManager.getCommonCharacterFormat();
        }

        var format:Object = {};
        
        for each (p in names)
        {
            kind = TextUtil.FORMAT_MAP[p];
            
            if (kind == TextUtil.CONTAINER)
                format[p] = containerFormat[p];
            else if (kind == TextUtil.PARAGRAPH)
                format[p] = paragraphFormat[p];
            else if (kind == TextUtil.CHARACTER)
                format[p] = characterFormat[p];
        }
        
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
     */
    public function setSelectionFormat(attributes:Object):void
    {
        var containerFormat:ContainerFormat;
        var paragraphFormat:ParagraphFormat;
        var characterFormat:CharacterFormat;
        
        for (var p:String in attributes)
        {
            var kind:String = TextUtil.FORMAT_MAP[p];
            
            if (kind == TextUtil.CONTAINER)
            {
                if (!containerFormat)
                   containerFormat =  new ContainerFormat();
                containerFormat[p] = attributes[p];
            }
            else if (kind == TextUtil.PARAGRAPH)
            {
                if (!paragraphFormat)
                   paragraphFormat =  new ParagraphFormat();
                paragraphFormat[p] = attributes[p];
            }
            else if (kind == TextUtil.CHARACTER)
            {
                if (!characterFormat)
                   characterFormat =  new CharacterFormat();
                characterFormat[p] = attributes[p];
            }
        }
        
        var editManager:TextViewEditManager =
            TextViewEditManager(textFlow.interactionManager);

        var applyFormatOperation:ApplyFormatOperation =
            new ApplyFormatOperation(editManager.selectionState,
            characterFormat, paragraphFormat, containerFormat);
        
        editManager.execute(applyFormatOperation);
    }

    //--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  Called when the TextFlow dispatches a 'compositionComplete' event
     *  when it has recomposed the text into TextLines.
     */
    private function textFlow_compositionCompleteHandler(
                                    event:CompositionCompletionEvent):void
    {
        var containerController:IContainerController =
            textFlow.flowComposer.getControllerAt(0);

        var oldContentWidth:Number = _contentWidth;
        var newContentWidth:Number = containerController.contentWidth;
        if (newContentWidth != oldContentWidth)
        {
            _contentWidth = newContentWidth;
            
            dispatchPropertyChangeEvent(
                "contentWidth", oldContentWidth, newContentWidth);
        }
        
        var oldContentHeight:Number = _contentHeight;
        var newContentHeight:Number = containerController.contentHeight;
        if (newContentHeight != oldContentHeight)
        {
            _contentHeight = newContentHeight;
            
            dispatchPropertyChangeEvent(
                "contentHeight", oldContentHeight, newContentHeight);
        }
    }
    
    /**
     *  @private
     *  Called when the TextFlow dispatches a 'scroll' event
     *  as it autoscrolls.
     */
    private function textFlow_scrollHandler(event:Event):void
    {
        var containerController:IContainerController =
            textFlow.flowComposer.getControllerAt(0);

        var oldHorizontalScrollPosition:Number = _horizontalScrollPosition;
        var newHorizontalScrollPosition:Number =
            containerController.horizontalScrollPosition;
        if (newHorizontalScrollPosition != oldHorizontalScrollPosition)
        {
            _horizontalScrollPosition = newHorizontalScrollPosition;
            
            dispatchPropertyChangeEvent("horizontalScrollPosition",
                oldHorizontalScrollPosition, newHorizontalScrollPosition);
        }
        
        var oldVerticalScrollPosition:Number = _verticalScrollPosition;
        var newVerticalScrollPosition:Number =
            containerController.verticalScrollPosition;
        if (newVerticalScrollPosition != oldVerticalScrollPosition)
        {
            _verticalScrollPosition = newVerticalScrollPosition;
            
            dispatchPropertyChangeEvent("verticalScrollPosition",
                oldVerticalScrollPosition, newVerticalScrollPosition);
        }
    }

    /**
     *  @private
     *  Called when the TextFlow dispatches a 'selectionChange' event.
     */
    private function textFlow_selectionChangeHandler(
                        event:SelectionEvent):void
    {
        _selectionAnchorPosition = textFlow.interactionManager.anchorPosition;
        _selectionActivePosition = textFlow.interactionManager.activePosition;
        
        dispatchEvent(new FlexEvent(FlexEvent.SELECTION_CHANGE));
    }
    
    /**
     *  @private
     *  Called when the TextFlow dispatches an 'operationEnd' event
     *  before an editing operation.
     */
    private function textFlow_flowOperationBeginHandler(
                        event:FlowOperationEvent):void
    {
        //trace("operationBegin");
        
        var op:FlowOperation = event.operation;

        // If the user presses the Enter key in a single-line TextView,
        // we cancel the paragraph-splitting operation and instead
        // simply dispatch an 'enter' event.
        if (op is SplitParagraphOperation && !multiline)
        {
            event.preventDefault();
            dispatchEvent(new FlexEvent(FlexEvent.ENTER));
        }
        
        // Otherwise, we dispatch a 'changing' event from the TextView
        // as notification that an editing operation is about to occur.
        else
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
     *  Called when the TextFlow dispatches an 'operationEnd' event
     *  after an editing operation.
     */
    private function textFlow_flowOperationEndHandler(
                        event:FlowOperationEvent):void
    {
        //trace("operationEnd");

        // Since the text may have changed, set a flag which will
        // cause the 'text' getter to call extractText() to extract
        // the text by walking the TextFlow.
        textInvalid = true;
        dispatchEvent(new Event("textInvalid"));

        // Dispatch a 'change' event from the TextView
        // as notification that an editing operation has occurred.
        var newEvent:TextOperationEvent =
            new TextOperationEvent(TextOperationEvent.CHANGE);
        newEvent.operation = event.operation;
        dispatchEvent(newEvent);
    }
}

}

////////////////////////////////////////////////////////////////////////////////
//
//  Helper class: TextViewEditManager
//
////////////////////////////////////////////////////////////////////////////////

import flashx.textLayout.edit.EditManager;
import flashx.textLayout.operations.FlowOperation;

class TextViewEditManager extends EditManager
{
    public function TextViewEditManager()
    {
        super();
    }

    public function execute(flowOperation:FlowOperation):void
    {
        doOperation(flowOperation);
    }
}
