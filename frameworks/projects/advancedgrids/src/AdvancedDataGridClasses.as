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
internal class AdvancedDataGridClasses
{
	// Maintain alphabetical order
	import mx.accessibility.AdvancedDataGridAccImpl; AdvancedDataGridAccImpl;
	import mx.collections.DefaultSummaryCalculator; DefaultSummaryCalculator;
	import mx.collections.Grouping; Grouping;
	import mx.collections.GroupingCollection; GroupingCollection;
	import mx.collections.GroupingCollection2; GroupingCollection2;
	import mx.collections.GroupingField; GroupingField;
	import mx.collections.HierarchicalCollectionView; HierarchicalCollectionView;
	import mx.collections.HierarchicalCollectionViewCursor; HierarchicalCollectionViewCursor;
	import mx.collections.HierarchicalData; HierarchicalData;
	import mx.collections.ISummaryCalculator; ISummaryCalculator;
	import mx.collections.LeafNodeCursor; LeafNodeCursor;
	import mx.collections.SummaryField; SummaryField;
	import mx.collections.SummaryField2; SummaryField2;
	import mx.collections.SummaryObject; SummaryObject;
	import mx.collections.SummaryRow; SummaryRow;
    import mx.controls.AdvancedDataGrid; AdvancedDataGrid;
    import mx.controls.advancedDataGridClasses.AdvancedDataGridBaseSelectionData; AdvancedDataGridBaseSelectionData;
    import mx.controls.advancedDataGridClasses.AdvancedDataGridBaseSelectionPending; AdvancedDataGridBaseSelectionPending;
    import mx.controls.advancedDataGridClasses.AdvancedDataGridColumn; AdvancedDataGridColumn;
    import mx.controls.advancedDataGridClasses.AdvancedDataGridColumnGroup; AdvancedDataGridColumnGroup;
	import mx.controls.advancedDataGridClasses.AdvancedDataGridGroupItemRenderer; AdvancedDataGridGroupItemRenderer;
    import mx.controls.advancedDataGridClasses.AdvancedDataGridHeaderRenderer; AdvancedDataGridHeaderRenderer;
    import mx.skins.halo.AdvancedDataGridHeaderHorizontalSeparator; AdvancedDataGridHeaderHorizontalSeparator;
    import mx.controls.advancedDataGridClasses.AdvancedDataGridItemRenderer; AdvancedDataGridItemRenderer;
	import mx.controls.advancedDataGridClasses.AdvancedDataGridRendererDescription; AdvancedDataGridRendererDescription;
	import mx.controls.advancedDataGridClasses.AdvancedDataGridRendererProvider; AdvancedDataGridRendererProvider;
    import mx.controls.advancedDataGridClasses.AdvancedDataGridSortItemRenderer; AdvancedDataGridSortItemRenderer;
	import mx.controls.advancedDataGridClasses.SortInfo; SortInfo;
	import mx.printing.PrintAdvancedDataGrid; PrintAdvancedDataGrid;
	import mx.printing.PrintOLAPDataGrid; PrintOLAPDataGrid;
}

}