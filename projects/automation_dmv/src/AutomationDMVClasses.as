////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2009 Adobe Systems Incorporated
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
 *  In some projects, this class is used to link additional classes
 *  into the SWC beyond those that are found by dependency analysis
 *  starting from the classes specified in manifest.xml.
 *  This project has no manifest file (because there are no MXML tags
 *  corresponding to any classes in it) so all the classes linked into
 *  the SWC are found by a dependency analysis starting from the classes
 *  listed here.
 */
internal class AutomationDMVClasses
{
	
	import mx.automation.delegates.advancedDataGrid.AdvancedDataGridAutomationImpl;AdvancedDataGridAutomationImpl;
	import mx.automation.delegates.advancedDataGrid.AdvancedDataGridBaseExAutomationImpl;AdvancedDataGridBaseExAutomationImpl;
	import mx.automation.delegates.advancedDataGrid.AdvancedDataGridItemRendererAutomationImpl;AdvancedDataGridItemRendererAutomationImpl;
	import mx.automation.delegates.advancedDataGrid.AdvancedDataGridGroupItemRendererAutomationImpl;AdvancedDataGridGroupItemRendererAutomationImpl;
	import mx.automation.delegates.advancedDataGrid.AdvancedListBaseAutomationImpl;AdvancedListBaseAutomationImpl;
	import mx.automation.delegates.advancedDataGrid.AdvancedListBaseContentHolderAutomationImpl;AdvancedListBaseContentHolderAutomationImpl;
	import mx.automation.delegates.advancedDataGrid.OLAPDataGridAutomationImpl;OLAPDataGridAutomationImpl;
	import mx.automation.delegates.advancedDataGrid.OLAPDataGridGroupRendererAutomationImpl;OLAPDataGridGroupRendererAutomationImpl;


	import mx.automation.delegates.charts.AreaSeriesAutomationImpl; AreaSeriesAutomationImpl;
	import mx.automation.delegates.charts.AxisRendererAutomationImpl; AxisRendererAutomationImpl;
	import mx.automation.delegates.charts.BarSeriesAutomationImpl; BarSeriesAutomationImpl;
	import mx.automation.delegates.charts.BubbleSeriesAutomationImpl; BubbleSeriesAutomationImpl;
	import mx.automation.delegates.charts.CartesianChartAutomationImpl; CartesianChartAutomationImpl;
	import mx.automation.delegates.charts.ChartBaseAutomationImpl; ChartBaseAutomationImpl;
	import mx.automation.delegates.charts.ColumnSeriesAutomationImpl; ColumnSeriesAutomationImpl;
	import mx.automation.delegates.charts.HLOCSeriesBaseAutomationImpl; HLOCSeriesBaseAutomationImpl;
	import mx.automation.delegates.charts.LegendAutomationImpl; LegendAutomationImpl;
	import mx.automation.delegates.charts.LegendItemAutomationImpl; LegendItemAutomationImpl;
	import mx.automation.delegates.charts.LineSeriesAutomationImpl; LineSeriesAutomationImpl;
	import mx.automation.delegates.charts.PieSeriesAutomationImpl; PieSeriesAutomationImpl;
	import mx.automation.delegates.charts.PlotSeriesAutomationImpl; PlotSeriesAutomationImpl;
	import mx.automation.delegates.charts.SeriesAutomationImpl; SeriesAutomationImpl;
	// Maintain alphabetical order
}

}
