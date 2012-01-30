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

package
{

/**
 *  @private
 *  This class is used to link additional classes into framework.swc
 *  beyond those that are found by dependecy analysis starting
 *  from the classes specified in manifest.xml.
 *  For example, Button does not have a reference to ButtonSkin,
 *  but ButtonSkin needs to be in framework.swc along with Button.
 */
internal class FrameworkClasses
{
	import mx.binding.ArrayElementWatcher; ArrayElementWatcher;
	import mx.binding.BindabilityInfo; BindabilityInfo;
	import mx.binding.EvalBindingResponder; EvalBindingResponder;
	import mx.binding.FunctionReturnWatcher; FunctionReturnWatcher;
	import mx.binding.IBindingClient; IBindingClient;
	import mx.binding.IWatcherSetupUtil; IWatcherSetupUtil;
	import mx.binding.IWatcherSetupUtil2; IWatcherSetupUtil2;
	import mx.binding.PropertyWatcher; PropertyWatcher;
	import mx.binding.RepeatableBinding; RepeatableBinding;
	import mx.binding.RepeaterComponentWatcher; RepeaterComponentWatcher;
	import mx.binding.RepeaterItemWatcher; RepeaterItemWatcher;
	import mx.binding.StaticPropertyWatcher; StaticPropertyWatcher;
	import mx.binding.XMLWatcher; XMLWatcher;
	import mx.binding.utils.BindingUtils; BindingUtils;
	import mx.binding.utils.ChangeWatcher; ChangeWatcher;
	import mx.collections.ItemWrapper; ItemWrapper;
	import mx.containers.errors.ConstraintError; ConstraintError;
	import mx.containers.utilityClasses.Flex; Flex;
	import mx.collections.ModifiedCollectionView; ModifiedCollectionView;
	import mx.containers.utilityClasses.FlexChildInfo; FlexChildInfo;
	import mx.containers.utilityClasses.IConstraintLayout; IConstraintLayout;
    import mx.containers.utilityClasses.PostScaleAdapter; PostScaleAdapter;
	import mx.controls.ButtonLabelPlacement; ButtonLabelPlacement;
	import mx.controls.MovieClipSWFLoader; MovieClipSWFLoader;
	import mx.controls.ProgressBarDirection; ProgressBarDirection;
	import mx.controls.ProgressBarLabelPlacement; ProgressBarLabelPlacement;
	import mx.controls.ProgressBarMode; ProgressBarMode;
	import mx.controls.colorPickerClasses.WebSafePalette; WebSafePalette;
	import mx.controls.menuClasses.IMenuDataDescriptor; IMenuDataDescriptor;
	import mx.controls.listClasses.IDropInListItemRenderer; IDropInListItemRenderer;
	import mx.controls.listClasses.IListItemRenderer; IListItemRenderer;
	import mx.core.BitmapAsset; BitmapAsset;
	import mx.core.ButtonAsset; ButtonAsset;
	import mx.core.ByteArrayAsset; ByteArrayAsset;
	import mx.core.ClassFactory; ClassFactory;
	import mx.core.ContainerGlobals; ContainerGlobals;
	import mx.core.ContextualClassFactory; ContextualClassFactory;
	import mx.core.CrossDomainRSLItem; CrossDomainRSLItem;
	import mx.core.DeferredInstanceFromClass; DeferredInstanceFromClass;
	import mx.core.DeferredInstanceFromFunction; DeferredInstanceFromFunction;
	import mx.core.DesignLayer; DesignLayer;
    import mx.core.EmbeddedFontRegistry; EmbeddedFontRegistry;
	import mx.core.FlexLoader; FlexLoader;
	import mx.core.FontAsset; FontAsset;
	import mx.core.IDataRenderer; IDataRenderer;
	import mx.core.IDeferredInstance; IDeferredInstance;
	import mx.core.INavigatorContent; INavigatorContent;
	import mx.core.ISelectableList; ISelectableList;
	import mx.core.ISystemCursorClient; ISystemCursorClient;
	import mx.core.ITextInput; ITextInput;
    import mx.core.InteractionMode; InteractionMode;
	import mx.core.IUID; IUID;
	import mx.core.MovieClipAsset; MovieClipAsset;
	import mx.core.MovieClipLoaderAsset; MovieClipLoaderAsset;
	import mx.core.MXMLObjectAdapter; MXMLObjectAdapter;
	import mx.core.ScrollPolicy; ScrollPolicy;
	import mx.core.SimpleApplication; SimpleApplication;
	import mx.core.SoundAsset; SoundAsset;
	import mx.core.TextFieldAsset; TextFieldAsset;
	import mx.core.TextFieldFactory; TextFieldFactory;
	import mx.effects.easing.Back; Back;
	import mx.effects.easing.Bounce; Bounce;
	import mx.effects.easing.Circular; Circular;
	import mx.effects.easing.Elastic; Elastic;
	import mx.effects.easing.Exponential; Exponential;
	import mx.events.CloseEvent; CloseEvent;
	import mx.events.DropdownEvent; DropdownEvent;
    import mx.events.IndexChangedEvent; IndexChangedEvent;
	import mx.events.ItemClickEvent; ItemClickEvent;
	import mx.events.ModuleEvent; ModuleEvent;
    import mx.events.TouchInteractionEvent; TouchInteractionEvent;
    import mx.events.TouchInteractionReason; TouchInteractionReason;
	import mx.filters.BaseFilter; BaseFilter;
	import mx.filters.BaseDimensionFilter; BaseDimensionFilter;
	import mx.filters.IBitmapFilter; IBitmapFilter;
    import mx.formatters.IFormatter; IFormatter;
	import mx.graphics.ImageSnapshot; ImageSnapshot;
	import mx.graphics.codec.PNGEncoder; PNGEncoder;
	import mx.graphics.codec.JPEGEncoder; JPEGEncoder;
    import mx.graphics.shaderClasses.ColorBurnShader; ColorBurnShader;
    import mx.graphics.shaderClasses.ColorDodgeShader; ColorDodgeShader;
    import mx.graphics.shaderClasses.ColorShader; ColorShader;
    import mx.graphics.shaderClasses.ExclusionShader; ExclusionShader;
    import mx.graphics.shaderClasses.HueShader; HueShader;
    import mx.graphics.shaderClasses.LuminosityShader; LuminosityShader;
    import mx.graphics.shaderClasses.LuminosityMaskShader; LuminosityMaskShader;
    import mx.graphics.shaderClasses.SaturationShader; SaturationShader;
    import mx.graphics.shaderClasses.SoftLightShader; SoftLightShader;
	import mx.logging.ILogger; ILogger;
	import mx.logging.Log; Log;
	import mx.logging.targets.TraceTarget; TraceTarget;
	import mx.managers.DragManager; DragManager;
	import mx.managers.HistoryManager; HistoryManager;
	import mx.managers.IHistoryManagerClient; IHistoryManagerClient;
	import mx.managers.marshalClasses.CursorManagerMarshalMixin; CursorManagerMarshalMixin;
	import mx.managers.marshalClasses.DragManagerMarshalMixin; DragManagerMarshalMixin;
	import mx.managers.marshalClasses.FocusManagerMarshalMixin; FocusManagerMarshalMixin;
	import mx.managers.marshalClasses.PopUpManagerMarshalMixin; PopUpManagerMarshalMixin;
	import mx.managers.marshalClasses.ToolTipManagerMarshalMixin; ToolTipManagerMarshalMixin;
    import mx.managers.PopUpManager; PopUpManager;
	import mx.managers.systemClasses.ActiveWindowManager; ActiveWindowManager;
	import mx.managers.systemClasses.ChildManager; ChildManager;
	import mx.managers.systemClasses.MarshallingSupport; MarshallingSupport;
	import mx.messaging.config.LoaderConfig; LoaderConfig;
	import mx.modules.IModuleInfo; IModuleInfo;
	import mx.modules.ModuleBase; ModuleBase;
	import mx.modules.ModuleManager; ModuleManager;
    import mx.preloaders.DownloadProgressBar; DownloadProgressBar;
    import mx.preloaders.SparkDownloadProgressBar; SparkDownloadProgressBar;
	import mx.printing.FlexPrintJob; FlexPrintJob;
	import mx.resources.Locale; Locale;
	import mx.rpc.IResponder; IResponder;
	import mx.skins.Border; Border;
	import mx.skins.halo.BrokenImageBorderSkin; BrokenImageBorderSkin;
	import mx.skins.halo.BusyCursor; BusyCursor;
	import mx.skins.halo.DefaultDragImage; DefaultDragImage;
	import mx.skins.halo.HaloFocusRect; HaloFocusRect;
	import mx.skins.halo.ListDropIndicator; ListDropIndicator;
	import mx.skins.halo.ToolTipBorder; ToolTipBorder;
	import mx.skins.ProgrammaticSkin; ProgrammaticSkin;
	import mx.skins.RectangularBorder; RectangularBorder;
	import mx.styles.IStyleModule; IStyleModule;
	import mx.styles.AdvancedStyleClient; AdvancedStyleClient;
	import mx.utils.ArrayUtil; ArrayUtil;
	import mx.utils.Base64Decoder; Base64Decoder;
	import mx.utils.Base64Encoder; Base64Encoder;
	import mx.utils.BitFlagUtil; BitFlagUtil;
	import mx.utils.DescribeTypeCache; DescribeTypeCache;
	import mx.utils.DescribeTypeCacheRecord; DescribeTypeCacheRecord;
	import mx.utils.DisplayUtil; DisplayUtil;
    import mx.utils.GetTimerUtil; GetTimerUtil;
    import mx.utils.HSBColor; HSBColor;
    import mx.utils.LinkedList; LinkedList;
	import mx.utils.LinkedListNode; LinkedListNode;
	import mx.utils.OnDemandEventDispatcher; OnDemandEventDispatcher;
	import mx.utils.OrderedObject; OrderedObject;
    import mx.utils.PopUpUtil; PopUpUtil;
	import mx.utils.XMLUtil; XMLUtil;
	import mx.validators.Validator; Validator;
	// Maintain alphabetical order
}

}

