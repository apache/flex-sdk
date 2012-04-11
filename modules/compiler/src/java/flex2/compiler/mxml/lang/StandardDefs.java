/*
 *
 *  Licensed to the Apache Software Foundation (ASF) under one or more
 *  contributor license agreements.  See the NOTICE file distributed with
 *  this work for additional information regarding copyright ownership.
 *  The ASF licenses this file to You under the Apache License, Version 2.0
 *  (the "License"); you may not use this file except in compliance with
 *  the License.  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 */

package flex2.compiler.mxml.lang;

import flex2.compiler.mxml.dom.MethodNode;
import flex2.compiler.mxml.dom.Node;
import flex2.compiler.mxml.dom.OperationNode;
import flex2.compiler.mxml.reflect.Type;
import flex2.compiler.util.NameFormatter;

import java.util.*;

/**
 * MXML standard (i.e., framework-independent) AS support classes,
 * packages, import sets, etc.  NOTE: definition names (interface*,
 * class*) are generally stored here in internal format, usable for
 * typetable lookups.  Use NameFormatter.toDot() to convert to source
 * code format.  (Note: an exception is lists of import names, in dot
 * format already.)
 * 
 * A few select constants are interned, primarily because they are
 * utilized during AST generation.
 */
public abstract class StandardDefs
{
    private static StandardDefs STANDARD_DEFS_MXML_2006;

    private StandardDefs()
    {
    }

    public static StandardDefs getStandardDefs(String frameworkType)
    {
        if (STANDARD_DEFS_MXML_2006 == null)
            STANDARD_DEFS_MXML_2006 = new StandardDefs2006();

        return STANDARD_DEFS_MXML_2006;
    }

    public abstract String getBindingPackage();
    public abstract String getContainerPackage();
    public abstract String getCorePackage();
    public abstract String getControlsPackage();
    public abstract String getDataPackage();
    public abstract String getDataUtilsPackage();
    public abstract String getEffectsPackage();
    public abstract String getEventsPackage();
    public abstract String getManagersPackage();
    public abstract String getMessagingConfigPackage();
    public abstract String getModulesPackage();
    public abstract String getPreloadersPackage();
    public abstract String getResourcesPackage();
    public abstract String getRPCPackage();
    public abstract String getRPCXMLPackage();
    public abstract String getStatesPackage();
    public abstract String getStylesPackage();
    public abstract String getUtilsPackage();

    public abstract String getBindablePropertyTemplate();
    public abstract String getClassDefTemplate();
    public abstract String getClassDefLibTemplate();
    public abstract String getEmbedClassTemplate();
    public abstract String getFontFaceRulesTemplate();
    public abstract String getInterfaceDefTemplate();
    public abstract String getManagedPropertyTemplate();
    public abstract String getSkinClassTemplate();
    public abstract String getStyleDefTemplate();
    public abstract String getStyleLibraryTemplate();
    public abstract String getStyleModuleTemplate();
    public abstract String getWatcherSetupUtilTemplate();

    //--------------------------------------------------------------------------
    //
	//  SWCs
    //
    //--------------------------------------------------------------------------

	public static final String SWC_AIRGLOBAL = "airglobal.swc";
    public static final String SWC_AVMPLUS = "avmplus.swc";
    public static final String SWC_PLAYERGLOBAL = "playerglobal.swc";


    //--------------------------------------------------------------------------
    //
    //  Packages
    //
    //--------------------------------------------------------------------------    

    public static final String PACKAGE___AS3___VEC = "__AS3__.vec";

    // flash.*
    public static final String PACKAGE_FLASH_ACCESSIBILITY = "flash.accessibility";
    public static final String PACKAGE_FLASH_DATA = "flash.data";
    public static final String PACKAGE_FLASH_DEBUGGER = "flash.debugger";
    public static final String PACKAGE_FLASH_DESKTOP = "flash.desktop";
    public static final String PACKAGE_FLASH_DISPLAY = "flash.display";
    public static final String PACKAGE_FLASH_ERRORS = "flash.errors";
    public static final String PACKAGE_FLASH_EVENTS = "flash.events";
    public static final String PACKAGE_FLASH_EXTERNAL = "flash.external";
    public static final String PACKAGE_FLASH_FILESYSTEM = "flash.filesystem";
    public static final String PACKAGE_FLASH_FILTERS = "flash.filters";
    public static final String PACKAGE_FLASH_GEOM = "flash.geom";
    public static final String PACKAGE_FLASH_HTML = "flash.html";
    public static final String PACKAGE_FLASH_HTML_SCRIPT = "flash.html.script";
    public static final String PACKAGE_FLASH_MEDIA = "flash.media";
    public static final String PACKAGE_FLASH_NET = "flash.net";
    public static final String PACKAGE_FLASH_PRINTING = "flash.printing";
    public static final String PACKAGE_FLASH_PROFILER = "flash.profiler";
    public static final String PACKAGE_FLASH_SYSTEM = "flash.system";
    public static final String PACKAGE_FLASH_TEXT = "flash.text";
    public static final String PACKAGE_FLASH_UI = "flash.ui";
    public static final String PACKAGE_FLASH_UTILS = "flash.utils".intern();
    public static final String PACKAGE_FLASH_XML = "flash.xml";

    // flashx.textLayout.*
    public static final String PACKAGE_FLASH_TEXTLAYOUT_COMPOSE = "flashx.textLayout.compose";
    
    // mx.*
    private static final String PACKAGE_MX_BINDING = "mx.binding".intern();
    private static final String PACKAGE_MX_CONTAINERS = "mx.containers";
    private static final String PACKAGE_MX_CONTROLS = "mx.controls";
    private static final String PACKAGE_MX_CORE = "mx.core".intern();
    private static final String PACKAGE_MX_DATA = "mx.data";
    private static final String PACKAGE_MX_DATA_UTILS = "mx.data.utils";
    private static final String PACKAGE_MX_EFFECTS = "mx.effects";
    private static final String PACKAGE_MX_EVENTS = "mx.events";
    public static final String PACKAGE_MX_FILTERS = "mx.filters";
    private static final String PACKAGE_MX_MANAGERS = "mx.managers";
    private static final String PACKAGE_MX_MESSAGING_CONFIG = "mx.messaging.config";
    private static final String PACKAGE_MX_MODULES = "mx.modules";
    private static final String PACKAGE_MX_PRELOADERS = "mx.preloaders";
    private static final String PACKAGE_MX_RESOURCES = "mx.resources";
    private static final String PACKAGE_MX_RPC = "mx.rpc";    //    TODO to FramewkDefs? RpcDefs?
    private static final String PACKAGE_MX_RPC_XML = "mx.rpc.xml";    //    TODO to FramewkDefs? RpcDefs?
    private static final String PACKAGE_MX_STATES = "mx.states".intern();
    private static final String PACKAGE_MX_STYLES = "mx.styles".intern();
    private static final String PACKAGE_MX_UTILS = "mx.utils".intern();

    // spark.*
    private static final String PACKAGE_SPARK_COMPONENTS = "spark.components";
    private static final String PACKAGE_SPARK_CORE = "spark.core";
    private static final String PACKAGE_SPARK_PRIMITIVES = "spark.primitives";
    private static final String PACKAGE_TEXT_ELEMENTS = "flashx.textLayout.elements";
    private static final String PACKAGE_TEXT_FORMATS = "flashx.textLayout.formats";

    //--------------------------------------------------------------------------
    //
    //  Namespaces
    //
    //--------------------------------------------------------------------------    

    public static final String NAMESPACE_MX_INTERNAL_LOCALNAME = "mx_internal".intern();
    public static final String NAMESPACE_MX_INTERNAL_URI = "http://www.adobe.com/2006/flex/mx/internal";

    public final String NAMESPACE_MX_INTERNAL = getCorePackage() + ":" + NAMESPACE_MX_INTERNAL_LOCALNAME;
    public final String NAMESPACE_MX_INTERNAL_DOT = getCorePackage() + "." + NAMESPACE_MX_INTERNAL_LOCALNAME;

    //--------------------------------------------------------------------------
    //
    //  Interfaces
    //
    //--------------------------------------------------------------------------    

    // Interface name with dot
    public final String INTERFACE_IFLEXMODULE_DOT = NameFormatter.toDot(getCorePackage(), "IFlexModule");
    public final String INTERFACE_IFLEXMODULEFACTORY_DOT = NameFormatter.toDot(getCorePackage(), "IFlexModuleFactory");
    public final String INTERFACE_IBINDINGCLIENT_DOT = NameFormatter.toDot(getBindingPackage(), "IBindingClient");
    public final String INTERFACE_ISTYLEMANAGER2_DOT = NameFormatter.toDot(getStylesPackage(), "IStyleManager2");

    // Interface name with colon
    // flashx.textLayout
    public static final String INTERFACE_FLASH_TEXTLAYOUT_ISWFCONTEXT = NameFormatter.toColon(PACKAGE_FLASH_TEXTLAYOUT_COMPOSE, "ISWFContext");
    
    public final String INTERFACE_ICHILDLIST = NameFormatter.toColon(getCorePackage(), "IChildList");
    public final String INTERFACE_ICONTAINER = NameFormatter.toColon(getCorePackage(), "IContainer");
    public final String INTERFACE_IDEFERREDINSTANCE = NameFormatter.toColon(getCorePackage(), "IDeferredInstance");
    public final String INTERFACE_IDEFERREDINSTANTIATIONUICOMPONENT = NameFormatter.toColon(getCorePackage(), "IDeferredInstantiationUIComponent");
    public final String INTERFACE_IEVENTDISPATCHER = NameFormatter.toColon(PACKAGE_FLASH_EVENTS, "IEventDispatcher");
    public final String INTERFACE_IGRAPHICELEMENT = NameFormatter.toColon(PACKAGE_SPARK_CORE, "IGraphicElement");
    public final String INTERFACE_IFACTORY = NameFormatter.toColon(getCorePackage(), "IFactory");
    public final String INTERFACE_IFLEXDISPLAYOBJECT = NameFormatter.toColon(getCorePackage(), "IFlexDisplayObject");
    public final String INTERFACE_IFLEXMODULE = NameFormatter.toColon(getCorePackage(), "IFlexModule");
    public final String INTERFACE_IFOCUSMANAGERCONTAINER = NameFormatter.toColon(getManagersPackage(), "IFocusManagerContainer");
    public final String INTERFACE_IINVALIDATING = NameFormatter.toColon(getCorePackage(), "IInvalidating");
    public final String INTERFACE_ILAYOUTMANAGERCLIENT = NameFormatter.toColon(getManagersPackage(), "ILayoutManagerClient");
    public final String INTERFACE_IMANAGED = NameFormatter.toColon(getDataPackage(), "IManaged");
    public final String INTERFACE_IMODULEINFO = NameFormatter.toColon(getModulesPackage(), "IModuleInfo");
    public final String INTERFACE_IMXMLOBJECT = NameFormatter.toColon(getCorePackage(), "IMXMLObject");
    public final String INTERFACE_INAVIGATORCONTENT = NameFormatter.toColon(getCorePackage(), "INavigatorContent");
    public final String INTERFACE_IOVERRIDE = NameFormatter.toColon(getStatesPackage(), "IOverride");
    public final String INTERFACE_IPROPERTYCHANGENOTIFIER = NameFormatter.toColon(getCorePackage(), "IPropertyChangeNotifier");
    public final String INTERFACE_IRAWCHILDRENCONTAINER = NameFormatter.toColon(getCorePackage(), "IRawChildrenContainer");
    public final String INTERFACE_ISIMPLESTYLECLIENT = NameFormatter.toColon(getStylesPackage(), "ISimpleStyleClient");
    public final String INTERFACE_ISTATECLIENT2 = NameFormatter.toColon(getCorePackage(), "IStateClient2");
    public final String INTERFACE_ISTYLECLIENT = NameFormatter.toColon(getStylesPackage(), "IStyleClient");
    public final String INTERFACE_ISYSTEMMANAGER = NameFormatter.toColon(getManagersPackage(), "ISystemManager");
    public final String INTERFACE_ITRANSIENTDEFERREDINSTANCE = NameFormatter.toColon(getCorePackage(), "ITransientDeferredInstance");
    public final String INTERFACE_IUICOMPONENT = NameFormatter.toColon(getCorePackage(), "IUIComponent");
    public final String INTERFACE_IVISUALELEMENT = NameFormatter.toColon(getCorePackage(), "IVisualElement");
    public final String INTERFACE_IVISUALELEMENTCONTAINER = NameFormatter.toColon(getCorePackage(), "IVisualElementContainer");

    // Interface without the package name
    public static final String INTERFACE_IMODULE_NO_PACKAGE = "IModule";
    
    //--------------------------------------------------------------------------
    //
    //  Classes
    //
    //--------------------------------------------------------------------------    

    // Class name with dot    
	public final String CLASS_CROSSDOMAINRSLITEM_DOT = NameFormatter.toDot(getCorePackage(), "CrossDomainRSLItem");
    public final String CLASS_EMBEDDEDFONTREGISTRY_DOT = NameFormatter.toDot(getCorePackage(), "EmbeddedFontRegistry");
    public final String CLASS_FLEXVERSION_DOT = NameFormatter.toDot(getCorePackage(), "FlexVersion");
    public final String CLASS_EFFECTMANAGER_DOT = NameFormatter.toDot(getEffectsPackage(), "EffectManager");
    public final String CLASS_PROPERTYCHANGEEVENT_DOT = NameFormatter.toDot(getEventsPackage(), "PropertyChangeEvent").intern();
    public final String CLASS_REQUEST_DOT = NameFormatter.toDot(getEventsPackage(), "Request").intern();
    public final String CLASS_RESOURCEBUNDLE_DOT = NameFormatter.toDot(getResourcesPackage(), "ResourceBundle");
    public final String CLASS_RESOURCEMANAGER_DOT = NameFormatter.toDot(getResourcesPackage(), "ResourceManager");
    public final String CLASS_REPEATER_DOT = NameFormatter.toDot(getCorePackage(), "Repeater");
    public final String CLASS_STYLEMANAGER_DOT = NameFormatter.toDot(getStylesPackage(), "StyleManager");
    public final String CLASS_STYLEMANAGERIMPL_DOT = NameFormatter.toDot(getStylesPackage(), "StyleManagerImpl");
    public final String CLASS_SYSTEMMANAGERCHILDMANAGER_DOT = NameFormatter.toDot(getManagersPackage(), "systemClasses.ChildManager");
    public final String CLASS_TEXTFIELDFACTORY_DOT = NameFormatter.toDot(getCorePackage(), "TextFieldFactory");
    public final String CLASS_SINGLETON_DOT = NameFormatter.toDot(getCorePackage(), "Singleton");

    // Class name with colon
    public final String CLASS_ABSTRACTSERVICE = NameFormatter.toColon(getRPCPackage(), "AbstractService");
    public final String CLASS_ACCORDION = NameFormatter.toColon(getContainerPackage(), "Accordion");
    public final String CLASS_ADDITEMS = NameFormatter.toColon(PACKAGE_MX_STATES, "AddItems");
    public final String CLASS_APPLICATIONDOMAIN = NameFormatter.toColon(PACKAGE_FLASH_SYSTEM, "ApplicationDomain");
    public final String CLASS_BINDINGMANAGER = NameFormatter.toColon(getBindingPackage(), "BindingManager");
    public final String CLASS_CLASSFACTORY = NameFormatter.toColon(getCorePackage(), "ClassFactory");
    public final String CLASS_CSSSTYLEDECLARATION = NameFormatter.toColon(getStylesPackage(), "CSSStyleDeclaration");
    public final String CLASS_DEFERREDINSTANCEFROMCLASS = NameFormatter.toColon(getCorePackage(), "DeferredInstanceFromClass");
    public final String CLASS_DEFERREDINSTANCEFROMFUNCTION = NameFormatter.toColon(getCorePackage(), "DeferredInstanceFromFunction");
    public final String CLASS_DOWNLOADPROGRESSBAR = NameFormatter.toColon(getPreloadersPackage(), "DownloadProgressBar");
    public final String CLASS_EFFECT = NameFormatter.toColon(getEffectsPackage(), "Effect");
    public final String CLASS_EVENT = NameFormatter.toColon(PACKAGE_FLASH_EVENTS, "Event");
    public final String CLASS_EVENTDISPATCHER = NameFormatter.toColon(PACKAGE_FLASH_EVENTS, "EventDispatcher");
    public final String CLASS_FLEXEVENT = NameFormatter.toColon(getEventsPackage(), "FlexEvent");
    public final String CLASS_FLEXSPRITE = NameFormatter.toColon(getCorePackage(), "FlexSprite");
    public final String CLASS_SPARK_RADIOBUTTONGROUP = NameFormatter.toColon(PACKAGE_SPARK_COMPONENTS, "RadioButtonGroup");
	public final String CLASS_ITEMSCOMPONENT = NameFormatter.toColon(PACKAGE_SPARK_COMPONENTS, "SkinnableContainer");
    public final String CLASS_LOADERCONFIG = NameFormatter.toColon(getMessagingConfigPackage(), "LoaderConfig");
    public final String CLASS_MANAGED = NameFormatter.toColon(getDataUtilsPackage(), "Managed");
    public final String CLASS_MODULEEVENT = NameFormatter.toColon(getModulesPackage(), "ModuleEvent");
    public final String CLASS_MODULEMANAGER = NameFormatter.toColon(getModulesPackage(), "ModuleManager");
    public final String CLASS_NAMESPACEUTIL = NameFormatter.toColon(getRPCXMLPackage(), "NamespaceUtil");
    public final String CLASS_OBJECTPROXY = NameFormatter.toColon(getUtilsPackage(), "ObjectProxy");
    public final String CLASS_PRELOADER = NameFormatter.toColon(getPreloadersPackage(), "Preloader");
    public final String CLASS_PROPERTYCHANGEEVENT = NameFormatter.toColon(getEventsPackage(), "PropertyChangeEvent");
    public final String CLASS_RADIOBUTTONGROUP = NameFormatter.toColon(getControlsPackage(), "RadioButtonGroup");
    public final String CLASS_REPEATER = NameFormatter.toColon(getCorePackage(), "Repeater");
    public final String CLASS_SETEVENTHANDLER = NameFormatter.toColon(getStatesPackage(), "SetEventHandler");
    public final String CLASS_SETPROPERTY = NameFormatter.toColon(getStatesPackage(), "SetProperty");
    public final String CLASS_SETSTYLE = NameFormatter.toColon(getStatesPackage(), "SetStyle");
    public final String CLASS_STATE = NameFormatter.toColon(getStatesPackage(), "State");
    public final String CLASS_STYLEEVENT = NameFormatter.toColon(getEventsPackage(), "StyleEvent");
    public final String CLASS_STYLEMANAGER = NameFormatter.toColon(getStylesPackage(), "StyleManager");
    public final String CLASS_SYSTEMCHILDRENLIST = NameFormatter.toColon(getManagersPackage(), "SystemChildrenList");
    public final String CLASS_SYSTEMMANAGER = NameFormatter.toColon(getManagersPackage(), "SystemManager");
    public final String CLASS_SYSTEMRAWCHILDRENLIST = NameFormatter.toColon(getManagersPackage(), "SystemRawChildrenList");
    public final String CLASS_UICOMPONENT = NameFormatter.toColon(getCorePackage(), "UIComponent");    //    TODO only needed for states - remove
    public final String CLASS_UICOMPONENTDESCRIPTOR = NameFormatter.toColon(getCorePackage(), "UIComponentDescriptor");
    public final String CLASS_UIDUTIL = NameFormatter.toColon(getUtilsPackage(), "UIDUtil");
    public final String CLASS_VIEWSTACK = NameFormatter.toColon(getContainerPackage(), "ViewStack");
    public final String CLASS_XMLUTIL = NameFormatter.toColon(getUtilsPackage(), "XMLUtil");

    public static final String CLASS_APPLICATION = NameFormatter.toColon(PACKAGE_MX_CORE, "Application");
    public static final String CLASS_ARRAY = "Array";
    public static final String CLASS_VECTOR = NameFormatter.toDot(PACKAGE___AS3___VEC, "Vector");
    public static final String CLASS_VECTOR_SHORTNAME = "Vector";
	public static final String CLASS_XML = "XML";
    public static final String CLASS_XMLLIST = "XMLList";
    public static final String CLASS_XMLNODE = NameFormatter.toColon(PACKAGE_FLASH_XML, "XMLNode");

    // Spark Components
    public static final String CLASS_SPARK_APPLICATION = NameFormatter.toColon(PACKAGE_SPARK_COMPONENTS, "Application");
    public static final String CLASS_SPARK_SPRITEVISUALELEMENT = NameFormatter.toColon(PACKAGE_SPARK_CORE, "SpriteVisualElement");
    public static final String CLASS_TEXT_DIV = NameFormatter.toColon(PACKAGE_TEXT_ELEMENTS, "DivElement");
    public static final String CLASS_TEXT_IMG = NameFormatter.toColon(PACKAGE_TEXT_ELEMENTS, "InlineGraphicElement");
    public static final String CLASS_TEXT_LINK = NameFormatter.toColon(PACKAGE_TEXT_ELEMENTS, "LinkElement");
    public static final String CLASS_TEXT_LAYOUT_FORMAT = NameFormatter.toColon(PACKAGE_TEXT_FORMATS, "TextLayoutFormat");
    public static final String CLASS_TEXT_RICHTEXT = NameFormatter.toColon(PACKAGE_SPARK_COMPONENTS, "RichText");
    public static final String CLASS_TEXT_PARAGRAPH = NameFormatter.toColon(PACKAGE_TEXT_ELEMENTS, "ParagraphElement");
    public static final String CLASS_TEXT_SPAN = NameFormatter.toColon(PACKAGE_TEXT_ELEMENTS, "SpanElement");
    public static final String CLASS_TEXT_TAB = NameFormatter.toColon(PACKAGE_TEXT_ELEMENTS, "TabElement");
    public static final String CLASS_TEXT_TCY = NameFormatter.toColon(PACKAGE_TEXT_ELEMENTS, "TCYElement");
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------    

    public static final String PROP_CURRENTSTATE = "currentState";
    public static final String PROP_EXCLUDE_STATES = "excludeFrom";
    public static final String PROP_FORMAT = "format";
    public static final String PROP_CLASSFACTORY_GENERATOR = "generator";
    public static final String PROP_ID = "id";
    public static final String PROP_FIXED = "fixed";
    public static final String PROP_TYPE = "type";
    public static final String PROP_INCLUDE_STATES = "includeIn";
    public static final String PROP_ITEM_CREATION_POLICY = "itemCreationPolicy";
    public static final String PROP_ITEM_DESTRUCTION_POLICY = "itemDestructionPolicy";
    public static final String PROP_STATE_NAME = "name";
    public static final String PROP_STATE_GROUPS = "stateGroups";
    public static final String PROP_SOURCE = "source";
    public static final String PROP_CLASSFACTORY_PROPERTIES = "properties";
    public static final String PROP_UICOMPONENT_STATES = "states";
    // intern, because it's used as an identifier.
    public static final String PROP_CONTAINER_CHILDREPEATERS = "childRepeaters".intern();


    //--------------------------------------------------------------------------
    //
    //  Metadata
    //
    //--------------------------------------------------------------------------    

    //    TODO still lots of string constants for these in TypeTable
    public static final String MD_ACCESSIBILITYCLASS = "AccessibilityClass";
    public static final String MD_ARRAYELEMENTTYPE = "ArrayElementType";
    public static final String MD_BINDABLE = "Bindable";
    public static final String MD_CHANGEEVENT = "ChangeEvent";
    public static final String MD_COLLAPSEWHITESPACE = "CollapseWhiteSpace";
    public static final String MD_DEFAULTPROPERTY = "DefaultProperty";
    public static final String MD_DEPRECATED = "Deprecated";
    public static final String MD_EFFECT = "Effect";
    public static final String MD_EMBED = "Embed";
    public static final String MD_EVENT = "Event";
    public static final String MD_FRAME = "Frame";
    public static final String MD_HOSTCOMPONENT = "HostComponent";
    public static final String MD_ICONFILE = "IconFile";
    /*
     * TODO: Remove [IMXMLObject] metadata support once third party libraries
     * (e.g. TLF) have a non-framework dependent swc to link against IMXMLObject
     */
    public static final String MD_IMXMLOBJECT = "IMXMLObject";
    public static final String MD_INSPECTABLE = "Inspectable";
    public static final String MD_INSTANCETYPE = "InstanceType";
    public static final String MD_MANAGED = "Managed";
    public static final String MD_MIXIN = "Mixin";
    public static final String MD_NONCOMMITTINGCHANGEEVENT = "NonCommittingChangeEvent";
    public static final String MD_PERCENTPROXY = "PercentProxy";
    public static final String MD_REMOTECLASS = "RemoteClass";
    public static final String MD_REQUIRESLICENSE = "RequiresLicense";
    public static final String MD_RESOURCEBUNDLE = "ResourceBundle";
    public static final String MD_RICHTEXTCONTENT = "RichTextContent";
    public static final String MD_STYLE = "Style";
    public static final String MD_SWF = "SWF";
    public static final String MD_TRANSIENT = "Transient";
    public static final String MD_SKINSTATE = "SkinState";
    public static final String MD_EXCLUDE = "Exclude";
    public static final String MD_SKINPART = "SkinPart";
    public static final String MD_ALTERNATIVE = "Alternative";
    public static final String MD_DISCOURAGEDFORPROFILE = "DiscouragedForProfile";
    
    
    //    metadata param names
    public static final String MDPARAM_BINDABLE_EVENT = "event";
    public static final String MDPARAM_TYPE = "type";
    public static final String MDPARAM_DESTINATION = "destination";
    public static final String MDPARAM_MODE = "mode";

    //    metadata param values
    public static final String MDPARAM_STYLE_FORMAT_COLOR = "Color";
    public static final String MDPARAM_INSPECTABLE_FORMAT_COLOR = "Color";
    public static final String MDPARAM_PROPERTY_CHANGE = "propertyChange";

    public static final String MDPARAM_MANAGED_MODE_HIERARCHICAL = "hierarchical";
    public static final String MDPARAM_MANAGED_MODE_ASSOCIATION = "association";
    public static final String MDPARAM_MANAGED_MODE_MANUAL = "manual";

    
    public static final String[] DefaultAS3Metadata = new String[] {StandardDefs.MD_BINDABLE,
                                                                    StandardDefs.MD_MANAGED,
                                                                    StandardDefs.MD_CHANGEEVENT,
                                                                    StandardDefs.MD_NONCOMMITTINGCHANGEEVENT,
                                                                    StandardDefs.MD_TRANSIENT};

    //--------------------------------------------------------------------------
    //
    //  Graphics
    //
    //--------------------------------------------------------------------------    

    public static final String GRAPHICS_MASK = "mask";
    public static final String GRAPHICS_DEFINITION_NAME = "name";

    //--------------------------------------------------------------------------
    //
    //  Keywords
    //
    //--------------------------------------------------------------------------    

    public static final String NULL = "null";
    public static final String UNDEFINED = "undefined";


    //--------------------------------------------------------------------------
    //
    //  Velocity Templates
    //
    //--------------------------------------------------------------------------    

    
    /**
     * implicit imports - not MXML support, but auto-imported to facilitate user script code.
     */
    public static final Set<String> implicitImports = new HashSet<String>();
    static
    {
        implicitImports.add(NameFormatter.toDotStar(PACKAGE_FLASH_ACCESSIBILITY));
        implicitImports.add(NameFormatter.toDotStar(PACKAGE_FLASH_DEBUGGER));
        implicitImports.add(NameFormatter.toDotStar(PACKAGE_FLASH_DISPLAY));
        implicitImports.add(NameFormatter.toDotStar(PACKAGE_FLASH_ERRORS));
        implicitImports.add(NameFormatter.toDotStar(PACKAGE_FLASH_EVENTS));
        implicitImports.add(NameFormatter.toDotStar(PACKAGE_FLASH_EXTERNAL));
        implicitImports.add(NameFormatter.toDotStar(PACKAGE_FLASH_FILTERS));
        implicitImports.add(NameFormatter.toDotStar(PACKAGE_FLASH_GEOM));
        implicitImports.add(NameFormatter.toDotStar(PACKAGE_FLASH_MEDIA));
        implicitImports.add(NameFormatter.toDotStar(PACKAGE_FLASH_NET));
        implicitImports.add(NameFormatter.toDotStar(PACKAGE_FLASH_PRINTING));
        implicitImports.add(NameFormatter.toDotStar(PACKAGE_FLASH_PROFILER));
        implicitImports.add(NameFormatter.toDotStar(PACKAGE_FLASH_SYSTEM));
        implicitImports.add(NameFormatter.toDotStar(PACKAGE_FLASH_TEXT));
        implicitImports.add(NameFormatter.toDotStar(PACKAGE_FLASH_UI));
        implicitImports.add(NameFormatter.toDotStar(PACKAGE_FLASH_UTILS));
        implicitImports.add(NameFormatter.toDotStar(PACKAGE_FLASH_XML));
    }

    /**
     * A list of Spark "text" components that require special whitespace
     * handling. This is part of a workaround for SDK-22601, SDK-23160 and
     * SDK-24611.
     */
    public static final HashSet<String> SPARK_TEXT_TAGS = new HashSet<String>(13);
    static
    {
        SPARK_TEXT_TAGS.add("RichEditableText");
        SPARK_TEXT_TAGS.add("RichText");
        SPARK_TEXT_TAGS.add("TextArea");
        SPARK_TEXT_TAGS.add("TextInput");
        SPARK_TEXT_TAGS.add("a");
        SPARK_TEXT_TAGS.add("br");
        SPARK_TEXT_TAGS.add("div");
        SPARK_TEXT_TAGS.add("img");
        SPARK_TEXT_TAGS.add("p");
        SPARK_TEXT_TAGS.add("span");
        SPARK_TEXT_TAGS.add("tcy");
        SPARK_TEXT_TAGS.add("tab");
        SPARK_TEXT_TAGS.add("TextFlow");
    }

    /**
     * A list of Spark "text" component properties that can be assigned text
     * content. This is part of a workaround to avoid SDK-23972.
     */
    public static final HashSet<String> SPARK_TEXT_CONTENT_PROPERTIES = new HashSet<String>(3);
    static
    {
        SPARK_TEXT_CONTENT_PROPERTIES.add("content");
        SPARK_TEXT_CONTENT_PROPERTIES.add("mxmlChildren");
        SPARK_TEXT_CONTENT_PROPERTIES.add("text");
    }

    /**
     * The text attribute can be used to set a Spark "text" components's content
     * directly. This is part of a workaround for SDK-24699.
     */
    public static final String SPARK_TEXT_ATTRIBUTE = "text";


    public static final String[] splitPackageMxFilters;
    static
    {
        splitPackageMxFilters = NameFormatter.toDotStar(PACKAGE_MX_FILTERS).split("\\.");

        for (int i = 0; i < splitPackageMxFilters.length; i++)
        {
            splitPackageMxFilters[i] = splitPackageMxFilters[i].intern();
        }
    }

    public static final Map<String, String[]> splitImplicitImports = new HashMap<String, String[]>();
    static
    {
        for (String implicitImport : implicitImports)
        {
            String[] splitImplicitImport = implicitImport.split("\\.");

            for (int i = 0; i < splitImplicitImport.length; i++)
            {
                splitImplicitImport[i] = splitImplicitImport[i].intern();
            }

            splitImplicitImports.put(implicitImport, splitImplicitImport);
        }
    }

    /**
     * implicit imports that exist only in AIR
     */
    public static final Set<String> airOnlyImplicitImports = new HashSet<String>();
    static
    {
        airOnlyImplicitImports.add(NameFormatter.toDotStar(PACKAGE_FLASH_DATA));
        airOnlyImplicitImports.add(NameFormatter.toDotStar(PACKAGE_FLASH_DESKTOP));
        airOnlyImplicitImports.add(NameFormatter.toDotStar(PACKAGE_FLASH_FILESYSTEM));
        airOnlyImplicitImports.add(NameFormatter.toDotStar(PACKAGE_FLASH_HTML));
        airOnlyImplicitImports.add(NameFormatter.toDotStar(PACKAGE_FLASH_HTML_SCRIPT));
    }

    public static final Map<String, String[]> splitAirOnlyImplicitImports = new HashMap<String, String[]>();
    static
    {
        for (String airOnlyImplicitImport : airOnlyImplicitImports)
        {
            String[] splitAirOnlyImplicitImport = airOnlyImplicitImport.split("\\.");

            for (int i = 0; i < splitAirOnlyImplicitImport.length; i++)
            {
                splitAirOnlyImplicitImport[i] = splitAirOnlyImplicitImport[i].intern();
            }

            splitAirOnlyImplicitImports.put(airOnlyImplicitImport, splitAirOnlyImplicitImport);
        }
    }

    private Set<String> standardMxmlImports;

    /**
     * standard (framework-independent) MXML support imports
     */
    public final Set<String> getStandardMxmlImports()
    {
        if (standardMxmlImports == null)
        {
            standardMxmlImports = new HashSet<String>();
            standardMxmlImports.add(NameFormatter.toDotStar(getStylesPackage()));
            standardMxmlImports.add(NameFormatter.toDotStar(getBindingPackage()));

            standardMxmlImports.add(NameFormatter.toDot(NAMESPACE_MX_INTERNAL));

            standardMxmlImports.add(NameFormatter.toDot(INTERFACE_IDEFERREDINSTANCE));    //    TODO make these conditional on use
            standardMxmlImports.add(NameFormatter.toDot(INTERFACE_IFACTORY));    //    TODO make these conditional on use
            standardMxmlImports.add(INTERFACE_IFLEXMODULEFACTORY_DOT);
            standardMxmlImports.add(NameFormatter.toDot(INTERFACE_IPROPERTYCHANGENOTIFIER));

            standardMxmlImports.add(NameFormatter.toDot(CLASS_CLASSFACTORY));
            standardMxmlImports.add(NameFormatter.toDot(CLASS_DEFERREDINSTANCEFROMCLASS));
            standardMxmlImports.add(NameFormatter.toDot(CLASS_DEFERREDINSTANCEFROMFUNCTION));
        }

        return standardMxmlImports;
    }

    private Map<String, String[]> splitStandardMxmlImports;
    public final Map<String, String[]> getSplitStandardMxmlImports()
    {
        if (splitStandardMxmlImports == null)
        {
            splitStandardMxmlImports = new HashMap<String, String[]>();
            for (String standardMxmlImport : getStandardMxmlImports())
            {
                String[] splitStandardMxmlImport = standardMxmlImport.split("\\.");
    
                for (int i = 0; i < splitStandardMxmlImport.length; i++)
                {
                    splitStandardMxmlImport[i] = splitStandardMxmlImport[i].intern();
                }
    
                splitStandardMxmlImports.put(standardMxmlImport, splitStandardMxmlImport);
            }
        }

        return splitStandardMxmlImports;
    }

    private String[] watcherImports;
    public String[] getImports()
    {
        if (watcherImports == null)
        {
            watcherImports = new String[] {
                getCorePackage() + ".IFlexModuleFactory",
                getBindingPackage() + ".ArrayElementWatcher",
                getBindingPackage() + ".FunctionReturnWatcher",
                getBindingPackage() + ".IWatcherSetupUtil2",
                getBindingPackage() + ".PropertyWatcher",
                getBindingPackage() + ".RepeaterComponentWatcher",
                getBindingPackage() + ".RepeaterItemWatcher",
                getBindingPackage() + ".StaticPropertyWatcher",
                getBindingPackage() + ".XMLWatcher",
                getBindingPackage() + ".Watcher"
            };
        }

        return watcherImports;
    }

    /**
     * AS3 reserved words, illegal as var names
     * NOTE: this list is hand-assembled from the constants in macromedia.asc.parser.Tokens and needs to be updated
     * manually until/unless we develop an API for getting is-reserved-word directly from the ASC scanner.
     * Note also that "get" and "set" do not appear, as they seem to be legal AS3 variable names.
     */
    private static final Set<String> as3ReservedWords = new HashSet<String>();
    static
    {
        as3ReservedWords.add("as");
        as3ReservedWords.add("break");
        as3ReservedWords.add("case");
        as3ReservedWords.add("catch");
        as3ReservedWords.add("class");
        as3ReservedWords.add("continue");
        as3ReservedWords.add("default");
        as3ReservedWords.add("do");
        as3ReservedWords.add("else");
        as3ReservedWords.add("extends");
        as3ReservedWords.add("false");
        as3ReservedWords.add("final");
        as3ReservedWords.add("finally");
        as3ReservedWords.add("for");
        as3ReservedWords.add("function");
        as3ReservedWords.add("goto");
        as3ReservedWords.add("if");
        as3ReservedWords.add("implements");
        as3ReservedWords.add("import");
        as3ReservedWords.add("in");
        as3ReservedWords.add("include");
        as3ReservedWords.add("instanceof");
        as3ReservedWords.add("interface");
        as3ReservedWords.add("is");
        as3ReservedWords.add("namespace");
        as3ReservedWords.add("new");
        as3ReservedWords.add("null");
        as3ReservedWords.add("package");
        as3ReservedWords.add("private");
        as3ReservedWords.add("protected");
        as3ReservedWords.add("public");
        as3ReservedWords.add("return");
        as3ReservedWords.add("static");
        as3ReservedWords.add("super");
        as3ReservedWords.add("switch");
        as3ReservedWords.add("synchronized");
        as3ReservedWords.add("this");
        as3ReservedWords.add("throw");
        as3ReservedWords.add("transient");
        as3ReservedWords.add("true");
        as3ReservedWords.add("try");
        as3ReservedWords.add("typeof");
        as3ReservedWords.add("use");
        as3ReservedWords.add("var");
        as3ReservedWords.add("void");
        as3ReservedWords.add("volatile");
        as3ReservedWords.add("while");
        as3ReservedWords.add("with");
    }

    /**
     * true iff passed string is a reserved word
     */
    public static final boolean isReservedWord(String s)
    {
        return as3ReservedWords.contains(s);
    }

    /**
     *
     */
    private static final Set<String> as3BuiltInTypeNames = new HashSet<String>();
    static
    {
        as3BuiltInTypeNames.add("String");
        as3BuiltInTypeNames.add("Boolean");
        as3BuiltInTypeNames.add("Number");
        as3BuiltInTypeNames.add("int");
        as3BuiltInTypeNames.add("uint");
        as3BuiltInTypeNames.add("Function");
        as3BuiltInTypeNames.add("Class");
        as3BuiltInTypeNames.add(CLASS_ARRAY);
        as3BuiltInTypeNames.add("Object");
        as3BuiltInTypeNames.add("XML");
        as3BuiltInTypeNames.add("XMLList");
        as3BuiltInTypeNames.add("RegExp");
        as3BuiltInTypeNames.add(CLASS_VECTOR);
    }
	
	public static boolean isApplication(Type type)
    {
        assert type != null;
        return type.isAssignableTo(CLASS_APPLICATION) || 
               type.isAssignableTo(CLASS_SPARK_APPLICATION);
    }

    /**
     * true iff passed string is the name of a built-in type
     */
    public static final boolean isBuiltInTypeName(String s)
    {
        return as3BuiltInTypeNames.contains(s);
    }

    /**
     *  Properties of a main application that are proxies for the
     *  Flash Player's Stage properties.
     */
    private static final Set<String> stageProperties = new HashSet<String>();
    static
    {
        stageProperties.add("colorCorrection");
    }
    
    public static final boolean isStageProperty(String s)
    {
        return stageProperties.contains(s);
    }

    /**
     * mappings from some MXML 1.5 tags to the corresponding MXML 2.0 vanilla faceless component tag names
     * Note: here, instead of FrameworkDefs, because the target tag names could be mapped to any classes, in or out of our framework.
     */
    private static final Map<Class, String> compatTagMappings = new HashMap<Class, String>();
    static
    {
        compatTagMappings.put(OperationNode.class, "WebServiceOperation");
        compatTagMappings.put(MethodNode.class, "RemoteObjectOperation");
    }

    /**
     * returns converted tag name for nodes representing migrated MXML 1.5 tags, original node name otherwise
     */
    public final String getConvertedTagName(Node node)
    {
        String name = compatTagMappings.get(node.getClass());
        return name != null ? name : node.getLocalPart();
    }

    /**
     * TODO formalize the type relationship between IContainer and (I)Repeater
     */
    public boolean isContainer(Type type)
    {
        assert type != null;
        return type.isAssignableTo(INTERFACE_ICONTAINER) || type.isAssignableTo(CLASS_REPEATER);
    }

    /**
     *
     */
    public boolean isNavigatorContent(Type type)
    {
        assert type != null;
        return type.isAssignableTo(INTERFACE_INAVIGATORCONTENT) || type.isAssignableTo(CLASS_REPEATER);
    }

    /**
    *
    */
   public boolean isIFlexModule(Type type)
   {
       assert type != null;
       return type.isAssignableTo(INTERFACE_IFLEXMODULE);
   }

    /**
     *
     */
    public boolean isIUIComponent(Type type)
    {
        assert type != null;
        return type.isAssignableTo(INTERFACE_IUICOMPONENT);
    }

    /**
     * 
     */
    public boolean isItemsComponent(Type type)
    {
        assert type != null;
        return type.isAssignableTo(CLASS_ITEMSCOMPONENT);
    }

    /**
     *
     */
    public boolean isHaloNavigator(Type type)
    {
        assert type != null;
        return type.isAssignableTo(CLASS_ACCORDION) || type.isAssignableTo(CLASS_VIEWSTACK);
    }

	/**
	 *
	 */
	public boolean isSparkGraphic(Type type)
	{
		assert type != null;
		return type.isAssignableTo(INTERFACE_IGRAPHICELEMENT);
	}

    /**
     * 
     */
    public boolean isSimpleStyleComponent(Type type)
    {
        assert type != null;
        return type.isAssignableTo(INTERFACE_ISIMPLESTYLECLIENT);
    }

    /**
     * Note that we trigger factory coercions only on IFactory type equality, *not* assignability
     */
    public boolean isIFactory(Type type)
    {
        assert type != null;
        return type.getName().equals(INTERFACE_IFACTORY);
    }

    /**
     * Note that we trigger DI coercions only on IDeferredInstance or ITransientDeferredInstance 
     * type equality, *not* assignability
     */
    public boolean isIDeferredInstance(Type type)
    {
        assert type != null;
        return (type.getName().equals(INTERFACE_IDEFERREDINSTANCE) || 
        	    type.getName().equals(INTERFACE_ITRANSIENTDEFERREDINSTANCE));
    }

    /**
     * Note that we trigger DI coercions only on ITransientDeferredInstance type equality, *not* assignability
     */
    public boolean isITransientDeferredInstance(Type type)
    {
        assert type != null;
        return type.getName().equals(INTERFACE_ITRANSIENTDEFERREDINSTANCE);
    }

    /**
     *
     */
    public boolean isInstanceGenerator(Type type)
    {
        assert type != null;
        return isIFactory(type) || isIDeferredInstance(type);
    }

    /**
     *
     */
    public boolean isRepeater(Type type)
    {
        assert type != null;
        return type.isAssignableTo(CLASS_REPEATER);
    }
    
    /**
     * Used when filtering and processing of state nodes.
     */
    public boolean isState(String cls)
    {
        return CLASS_STATE.equals(cls);
    }
    
    /**
     * for use before MXML type load
     * TODO once mxml core types have been factored out of frameworks.swc, ideally we can fail fast if they aren't available
     */
    public boolean isRepeater(String cls)
    {
        return CLASS_REPEATER.equals(cls);
    }

    /**
     *
     */
    public final String getXmlBackingClassName(boolean e4x)
    {
        return e4x ? CLASS_XML : CLASS_XMLNODE;
    }

    /**
     * Note: the assert is because IDeferredInstantiationUIComponent is expected to go away in an upcoming framework
     * scrub. The backstop is to avoid asserting when the core framework interfaces are entirely absent.
     * TODO post-scrub, this should be modified to check whatever subinterface of IUIComponent defines id.
     */
    public final boolean isIUIComponentWithIdProperty(Type type)
    {
        assert (type.getTypeTable().getType(INTERFACE_IDEFERREDINSTANTIATIONUICOMPONENT) != null) ==
                (type.getTypeTable().getType(INTERFACE_IUICOMPONENT) != null)
                : "interface " + INTERFACE_IDEFERREDINSTANTIATIONUICOMPONENT + " not found in core framework interface set";

        return type.isAssignableTo(INTERFACE_IDEFERREDINSTANTIATIONUICOMPONENT);
    }

    /**
     * MXML 2006 specific standard definitions.
     */
    public static class StandardDefs2006 extends StandardDefs
    {
        private static final String BINDABLE_PROPERTY_TEMPLATE = "BindableProperty.vm";
        private static final String CLASSDEF_TEMPLATE = "ClassDef.vm";
        private static final String CLASSDEF_LIB_TEMPLATE = "ClassDefLib.vm";
        private static final String EMBED_CLASS_TEMPLATE = "EmbedClass.vm";
        private static final String FONTFACERULES_TEMPLATE = "FontFaceRules.vm";
        private static final String INTERFACE_DEF_TEMPLATE = "InterfaceDef.vm"; 
        private static final String MANAGED_PROPERTY_TEMPLATE = "ManagedProperty.vm";
        private static final String SKINCLASS_TEMPLATE = "SkinClass.vm";
        private static final String STYLEDEF_TEMPLATE = "StyleDef.vm";
        private static final String STYLE_LIBRARY_TEMPLATE = "StyleLibrary.vm";
        private static final String STYLE_MODULE_TEMPLATE = "StyleModule.vm";
        private static final String WATCHER_SETUP_UTIL_TEMPLATE = "WatcherSetupUtil.vm";

        private StandardDefs2006()
        {
            super();
        }

        public String getBindingPackage()
        {
            return PACKAGE_MX_BINDING;
        }

        public String getContainerPackage()
        {
            return PACKAGE_MX_CONTAINERS;
        }

        public String getCorePackage()
        {
            return PACKAGE_MX_CORE;
        }

        public String getControlsPackage()
        {
            return PACKAGE_MX_CONTROLS;
        }

        public String getDataPackage()
        {
            return PACKAGE_MX_DATA;
        }

        public String getDataUtilsPackage()
        {
            return PACKAGE_MX_DATA_UTILS;
        }

        public String getEffectsPackage()
        {
            return PACKAGE_MX_EFFECTS;
        }

        public String getEventsPackage()
        {
            return PACKAGE_MX_EVENTS;
        }

        public String getManagersPackage()
        {
            return StandardDefs.PACKAGE_MX_MANAGERS;
        }

        public String getMessagingConfigPackage()
        {
            return StandardDefs.PACKAGE_MX_MESSAGING_CONFIG;
        }

        public String getModulesPackage()
        {
            return StandardDefs.PACKAGE_MX_MODULES;
        }

        public String getPreloadersPackage()
        {
            return StandardDefs.PACKAGE_MX_PRELOADERS;
        }

        public String getResourcesPackage()
        {
            return StandardDefs.PACKAGE_MX_RESOURCES;
        }

        public String getRPCPackage()
        {
            return StandardDefs.PACKAGE_MX_RPC;
        }

        public String getRPCXMLPackage()
        {
            return StandardDefs.PACKAGE_MX_RPC_XML;
        }

        public String getStatesPackage()
        {
            return StandardDefs.PACKAGE_MX_STATES;
        }

        public String getStylesPackage()
        {
            return StandardDefs.PACKAGE_MX_STYLES;
        }

        public String getUtilsPackage()
        {
            return PACKAGE_MX_UTILS;
        }

        //----------------------------------------------------------------------
        //
        // Velocity Templates
        //
        //----------------------------------------------------------------------

        public String getBindablePropertyTemplate()
        {
            return BINDABLE_PROPERTY_TEMPLATE;
        }

        public String getClassDefTemplate()
        {
            return CLASSDEF_TEMPLATE;
        }

        public String getClassDefLibTemplate()
        {
            return CLASSDEF_LIB_TEMPLATE;
        }

        public String getEmbedClassTemplate()
        {
            return EMBED_CLASS_TEMPLATE;
        }

        public String getFontFaceRulesTemplate()
        {
            return FONTFACERULES_TEMPLATE;
        }

        public String getInterfaceDefTemplate()
        {
            return INTERFACE_DEF_TEMPLATE;
        }

        public String getManagedPropertyTemplate()
        {
            return MANAGED_PROPERTY_TEMPLATE;
        }

        public String getSkinClassTemplate()
        {
            return SKINCLASS_TEMPLATE;
        }

        public String getStyleDefTemplate()
        {
            return STYLEDEF_TEMPLATE;
        }

        public String getStyleLibraryTemplate()
        {
            return STYLE_LIBRARY_TEMPLATE;
        }

        public String getStyleModuleTemplate()
        {
            return STYLE_MODULE_TEMPLATE;
        }

        public String getWatcherSetupUtilTemplate()
        {
            return WATCHER_SETUP_UTIL_TEMPLATE;
        }
    }
}
