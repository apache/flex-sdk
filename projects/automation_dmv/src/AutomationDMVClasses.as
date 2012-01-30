////////////////////////////////////////////////////////////////////////////////
//
//  Licensed to the Apache Software Foundation (ASF) under one or more
//  contributor license agreements.  See the NOTICE file distributed with
//  this work for additional information regarding copyright ownership.
//  The ASF licenses this file to You under the Apache License, Version 2.0
//  (the "License"); you may not use this file except in compliance with
//  the License.  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
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
