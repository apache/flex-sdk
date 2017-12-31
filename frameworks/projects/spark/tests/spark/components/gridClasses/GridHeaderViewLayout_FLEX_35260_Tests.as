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

package spark.components.gridClasses {
    import flash.events.Event;
    import flash.events.EventDispatcher;

    import flash.geom.Matrix;
    import flash.geom.Point;
    import flash.geom.Rectangle;

    import mx.collections.ArrayCollection;

    import org.flexunit.assertThat;

    import org.flexunit.asserts.assertEquals;
    import org.flexunit.asserts.assertTrue;
    import org.flexunit.async.Async;
    import org.flexunit.runners.Parameterized;
    import org.fluint.uiImpersonation.UIImpersonator;

    import spark.components.DataGrid;
    import spark.components.GridColumnHeaderGroup;

    /*
     Example for two-column table (with no horizontal scroll):

     [pt]: GridColumnHeaderGroup padding top
     [pl]: GridColumnHeaderGroup padding left
     [lch]: still part of last column header, but beyond last column width

     b0: top-left corner of the data grid. Also, first column starts at this x-coordinate
     b1: first column ends at this x-coordinate (but the first header usually doesn't, due to [pl])
     b2: second column ends at this x-coordinate (but the second header usually doesn't, due to [pl])
     ...
     bx: last column ends at this x-coordinate

     c0: first column header starts at this x-coordinate
     c1: first column header ends at this x-coordinate, separator starts at this x-coordinate, and
         second column header (if it exists) starts at this x-coordinate + separator.width
     c1: second column header ends at this x-coordinate, next separator (if it exists) starts at
     this x-coordinate, and third column header (if it exists) starts at this x-coordinate + separator.width
     ...
     cx: last column header ends at this x-coordinate; last column separator starts at this x-coordinate

     d: table ends at this x-axis coordinate
     e: top-left corner of header. If [pt] and [pl] are 0, this coincides with b0
     f: b0ttom-left corner of header. If [pb] and [pl] are 0, this coincides with g0

     g0: header ends and grid starts at this y-coordinate
     g1: first column ends at this x-coordinate and second column (if it exists) begins at this x-coordinate
     g2: second column ends at this x-coordinate and third column (if it exists) begins at this x-coordinate
     ...
     gx: last column ends at this x-coordinate

     i: bottom-right point of last column header and x-coordinate at end of data grid

     And for each point we generate the 8 adjacent points:
     (x+1, y), (x+1, y+1), (x+1, y-1),
     (x-1, y), (x-1, y+1), (x-1, y-1),
     (x, y-1), (x, y-1). For easier comprehension we mark them
     using cardinal points: N, NE, E, SE, S, SW, W, NW.
     ...and we check various boundaries against all of them

     a (0, 0)
     ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
     ░░░░░b0═══c0══════b1═══c1════════════════════════════b2══c2═════════d░░░░░░░
     ░░░░░║                              [pt]                            ║░░░░░░░
     ░░░░░║    e▓▓▓▓▓▓▓▓▓▓▓▓║▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓║▓▓▓▓▓▓▓▓▓▓║░░░░░░░
     ░░░░░║[pl]║▓▓▓INDEX▓▓▓▓║▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓NAME▓▓▓▓▓▓▓▓▓▓▓▓▓║▓▓▓[lch]▓▓║░░░░░░░
     ░░░░░║    f▓▓▓▓▓▓▓▓▓▓▓▓║▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓║▓▓▓▓▓▓▓▓▓▓║░░░░░░░
     ░░░░░║                              [pb]                            ║░░░░░░░
     ░░░░░g0═══════════g1═════════════════════════════════g2═════════════i░░░░░░░
     ░░░░░║     01     ║     John                         ║              ║░░░░░░░
     ░░░░░║     02     ║     Jane                         ║              ║░░░░░░░
     ░░░░░║     03     ║     Judy                         ║              ║░░░░░░░
     ░░░░░║     04     ║     James                        ║              ║░░░░░░░
     ░░░░░╚════════════╩══════════════════════════════════╩══════════════╝░░░░░░░
     ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
     ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
     */

    [RunWith("org.flexunit.runners.Parameterized")]
    public class GridHeaderViewLayout_FLEX_35260_Tests
    {
        private static var foo:Parameterized;
        private static const N:Matrix = new Matrix(1, 0, 0, 1, 0, -1);
        private static const NE:Matrix = new Matrix(1, 0, 0, 1, 1, -1);
        private static const E:Matrix = new Matrix(1, 0, 0, 1, 1, 0);
        private static const SE:Matrix = new Matrix(1, 0, 0, 1, 1, 1);
        private static const S:Matrix = new Matrix(1, 0, 0, 1, 0, 1);
        private static const SW:Matrix = new Matrix(1, 0, 0, 1, -1, 1);
        private static const W:Matrix = new Matrix(1, 0, 0, 1, -1, 0);
        private static const NW:Matrix = new Matrix(1, 0, 0, 1, -1, -1);
        private static const ITSELF:Matrix = new Matrix(1, 0, 0, 1, 0, 0); //the point, unmodified
        private static const directions:Array = [ITSELF, N, NE, E, SE, S, SW, W, NW];

        private static const ENTIRE_HEADER_RECTANGLE:String = "visibleHeaderRectangle"; //includes padding
        private static const FIXED_HEADER_VIEW_RECTANGLE:String = "fixedHeaderViewRectangle";

        private static const NO_ENTER_FRAMES_TO_ALLOW:int = 2;

        private static var _dataGrid:DataGrid;
        private static const _finishNotifier:EventDispatcher = new EventDispatcher();

        private var _keyRectangles:Array;
        private var _keyPoints:Array;
        private var _dimensions:Array;
        private var _noEnterFramesRemaining:int = NaN;

        //@TODO add cases with fixed columns
        //@TODO can the grid itself have padding?
        //@TODO test with a columnGap as well
        public static var allDimensions:Array = [
            /*x, y, width, header padding left, header padding top, header padding bottom, [column widths] */
            [[/*x=*/    0, /*y=*/   0, /*width=*/   300, /*paddingLeft=*/   5, /*paddingTop=*/  0, /*paddingBottom=*/   0, /*columnWidths=*/[25, 150]]],
            [[/*x=*/   10, /*y=*/   0, /*width=*/   300, /*paddingLeft=*/   5, /*paddingTop=*/  0, /*paddingBottom=*/   5, /*columnWidths=*/[25, 150]]],
            [[/*x=*/    0, /*y=*/   0, /*width=*/   200, /*paddingLeft=*/   5, /*paddingTop=*/  0, /*paddingBottom=*/   0, /*columnWidths=*/[80, 150]]], //horizontal scroll
            [[/*x=*/    0, /*y=*/   0, /*width=*/   100, /*paddingLeft=*/   0, /*paddingTop=*/  0, /*paddingBottom=*/   0, /*columnWidths=*/[10, 110, 15]]], //horizontal scroll
            [[/*x=*/   -5, /*y=*/-100, /*width=*/   200, /*paddingLeft=*/  25, /*paddingTop=*/ 12, /*paddingBottom=*/   5, /*columnWidths=*/[100, 150]]] //horizontal scroll
        ];


        [BeforeClass]
        public static function setUpBeforeClass():void
        {
            _dataGrid = new DataGrid();
            _dataGrid.setStyle("borderVisible", false); //to not deal with the complications of Scroller.minViewportInset
            UIImpersonator.addChild(_dataGrid);
        }

        [AfterClass]
        public static function tearDownAfterClass():void
        {
            UIImpersonator.removeAllChildren();

            _dataGrid = null;
        }

        [Before]
        public function setUp():void
        {

        }

        [After]
        public function tearDown():void
        {
            _keyRectangles = null;
            _keyPoints = null;
            _dimensions = null;
        }


        [Test(dataProvider="allDimensions", async, timeout=3000)]
        public function test_ltr(dimensions:Array):void
        {
            //given
            _dataGrid.width = getWidth(dimensions);
            _dataGrid.x = getX(dimensions);
            _dataGrid.y = getY(dimensions);

            _dataGrid.columnHeaderGroup.setStyle("paddingLeft", getHeaderPaddingLeft(dimensions));
            _dataGrid.columnHeaderGroup.setStyle("paddingTop", getHeaderPaddingTop(dimensions));
            _dataGrid.columnHeaderGroup.setStyle("paddingBottom", getHeaderPaddingBottom(dimensions));

            var gridColumns:Array = [];
            for (var i:int = 0; i < getColumnWidths(dimensions).length; i++)
            {
                var column:GridColumn = new GridColumn();
                column.width = getColumnWidth(dimensions, i);
                gridColumns.push(column);
            }
            _dataGrid.columns = new ArrayCollection(gridColumns);

            _dataGrid.columnHeaderGroup.invalidateDisplayList();
            _dataGrid.columnHeaderGroup.validateNow();
            _dataGrid.grid.validateNow();
            _dataGrid.validateNow();

            _dimensions = dimensions;
            _keyPoints = generateKeyPoints(_dataGrid);
            _keyRectangles = generateKeyRectangles();

            _noEnterFramesRemaining = NO_ENTER_FRAMES_TO_ALLOW;
            UIImpersonator.testDisplay.addEventListener(Event.ENTER_FRAME, onEnterFrame);
            Async.handleEvent(this, _finishNotifier, Event.COMPLETE, doTests, 3000);
        }

        private function doTests(event:Event, passThroughData:Object):void
        {
            //then
            //first, make sure that the dataGrid was rendered correctly
            assertThat("The dataGrid has not yet been correctly rendered on stage", getActualHeaderHeight(_dataGrid) > 0);

            //test the assumption about the center column header view location
            var centerGridViewLocation:Point = GridHeaderLayout(_dataGrid.columnHeaderGroup.layout).centerGridColumnHeaderView.localToGlobal(new Point(0, 0));
            assertTrue("The location of the centerGridColumnHeaderView does not reflect the columnHeaderGroup's padding rules! It's located at the global coordinates " +
                    centerGridViewLocation + ", but it should be at " + _keyPoints["e"],
                    centerGridViewLocation.equals(_keyPoints["e"]));

            forEachPointAndScrollLocation(assertAssumptionsAboutPoint);
        }

        private function forEachPointAndScrollLocation(assertThat_:Function):void
        {
            _dataGrid.columnHeaderGroup.invalidateDisplayList();
            _dataGrid.columnHeaderGroup.validateNow();
            _dataGrid.grid.validateNow();
            _dataGrid.validateNow();

            var maxScroll:Number = Math.max(1, getTotalColumnWidths(_dimensions) - getWidth(_dimensions) - getHeaderPaddingLeft(_dimensions));
            for (var i:int = 0; i < maxScroll; i++)
            {
                _dataGrid.grid.horizontalScrollPosition = i;
                _dataGrid.columnHeaderGroup.invalidateDisplayList();
                _dataGrid.columnHeaderGroup.validateNow();
                _dataGrid.grid.validateNow();
                _dataGrid.validateNow();

                for (var pointName:String in _keyPoints)
                {
                    for (var j:int = 0; j < directions.length; j++)
                    {
                        assertThat_(getAdjacentPoint(_keyPoints[pointName], directions[j]), pointName, directions[j]);
                        _dataGrid.columnHeaderGroup.invalidateDisplayList();
                        _dataGrid.columnHeaderGroup.validateNow();
                        _dataGrid.grid.validateNow();
                        _dataGrid.validateNow();
                    }
                }
            }
        }

        private function assertAssumptionsAboutPoint(point:Point, pointName:String, currentTransformation:Matrix):void
        {
            assertThatHeaderContainsPointOrNot(point, pointName, currentTransformation);
            assertThatCoordinatesOverHeaderViewOrNot(point, pointName, currentTransformation);
            assertThatHeaderIndexIsCorrect(point, pointName, currentTransformation);
            assertThatColumnIndexIsCorrect(point, pointName, currentTransformation);
        }

        private function assertThatHeaderContainsPointOrNot(point:Point, pointName:String, currentTransformation:Matrix):void
        {
                    //when
            var headerShouldContainThisPoint:Boolean = getHeaderShouldContainPointAssumption(point);
            var doesHeaderContainThisPoint:Boolean = _sut.containsGlobalCoordinates(point);
            const errorMessageHeaderContainsPoint:String = getHeaderContainsPointErrorMessage(pointName, currentTransformation, point, headerShouldContainThisPoint, doesHeaderContainThisPoint);

            //then
            assertEquals(errorMessageHeaderContainsPoint, headerShouldContainThisPoint, doesHeaderContainThisPoint);
        }

        private function assertThatCoordinatesOverHeaderViewOrNot(point:Point, pointName:String, currentTransformation:Matrix):void
        {
            //when
            const visibleHeaderViewRectangle:Rectangle = getVisibleHeaderViewRectangle(getCurrentHScrollPosition());
            var shouldBeContainedInMainHeaderView:Boolean = getMainHeaderViewContainsPointAssumption(visibleHeaderViewRectangle, point);
            var shouldBeContainedInFixedHeaderView:Boolean = getFixedHeaderViewContainsPointAssumption(point);
                    const shouldBeContainedInAHeaderView:Boolean = shouldBeContainedInMainHeaderView || shouldBeContainedInFixedHeaderView;
            var actuallyContainedInAHeaderView:Boolean = _sut.areCoordinatesOverAHeaderView(point);
            const errorMessageHeaderViewContainsPoint:String = getHeaderViewContainsPointErrorMessage(pointName, currentTransformation, point, shouldBeContainedInAHeaderView, actuallyContainedInAHeaderView, visibleHeaderViewRectangle);

                    //then
                    assertEquals(errorMessageHeaderViewContainsPoint, shouldBeContainedInAHeaderView, actuallyContainedInAHeaderView);
                }

        private function assertThatHeaderIndexIsCorrect(point:Point, pointName:String, currentTransformation:Matrix):void
        {
            //when
            const visibleColumnHeaderRectangles:Array = getVisibleColumnHeaderRectangles(getCurrentHScrollPosition());
            var expectedHeaderIndex:int = getHeaderIndexAssumption(point, visibleColumnHeaderRectangles);
            var actualHeaderIndex:int = getHeaderIndexAtGlobalPoint(point);
            const errorMessageHeaderIndex:String = getHeaderIndexErrorMessage(pointName, currentTransformation, point, expectedHeaderIndex, actualHeaderIndex, visibleColumnHeaderRectangles);

            //then
            assertEquals(errorMessageHeaderIndex, expectedHeaderIndex, actualHeaderIndex);
        }

        private function assertThatColumnIndexIsCorrect(point:Point, pointName:String, currentTransformation:Matrix):void
        {
            //when
            const visibleColumnRectangles:Array = getAllColumnRectangles(getCurrentHScrollPosition());
            var expectedColumnIndex:int = getColumnIndexAssumption(visibleColumnRectangles, point);
            var actualColumnIndex:int = getColumnIndexAtGlobalPoint(point);
            const errorMessageColumnIndex:String = getColumnIndexErrorMessage(pointName, currentTransformation, point, expectedColumnIndex, actualColumnIndex, visibleColumnRectangles);

            //then
            assertEquals(errorMessageColumnIndex, expectedColumnIndex, actualColumnIndex);
        }

        private function getHeaderIndexErrorMessage(pointName:String, direction:Matrix, transformedPoint:Point, expectedColumnHeaderIndex:int, actualColumnHeaderIndex:int, visibleColumnHeaderRectangles:Array):String
        {
            return "The point " + pointName + " transformed with Matrix " + direction + " (resulting in " + transformedPoint + ") should be "
                    + (expectedColumnHeaderIndex == -1 ? "outside any column header bounds" : "inside the column header with index " + expectedColumnHeaderIndex)
                    + " but was mistakenly found to be "
                    + (actualColumnHeaderIndex == -1 ? "outside any column header bounds" : "inside the column header with index " + actualColumnHeaderIndex)
                    + " given a horizontalScrollPosition of " + getCurrentHScrollPosition()
                    + "\n DEBUG INFO: visibleColumnHeaderRectangles=" + visibleColumnHeaderRectangles;
        }

        private function getColumnIndexErrorMessage(pointName:String, direction:Matrix, transformedPoint:Point, expectedColumnHeaderIndex:int, actualColumnHeaderIndex:int, visibleColumnRectangles:Array):String
        {
            return "The point " + pointName + " transformed with Matrix " + direction + " (resulting in " + transformedPoint + ") should have its x value "
                    + (expectedColumnHeaderIndex == -1 ? "outside any column bounds" : "inside the column with index " + expectedColumnHeaderIndex)
                    + " but was mistakenly found to be "
                    + (actualColumnHeaderIndex == -1 ? "outside any column bounds" : "inside the column with index " + actualColumnHeaderIndex)
                    + " given a horizontalScrollPosition of " + getCurrentHScrollPosition()
                    + "\n DEBUG INFO: columnRectangles=" + visibleColumnRectangles;
        }

        private function getHeaderContainsPointErrorMessage(pointName:String, direction:Matrix, transformedPoint:Point, shouldBeContainedInHeader:Boolean, isActuallyContainedInHeader:Boolean):String
        {
            return "The point " + pointName + " transformed with Matrix " + direction + " (resulting in " + transformedPoint + ") should be "
                    + (shouldBeContainedInHeader ? "within " : "outside ") + "the header bounds"
                    + " but was mistakenly found to be "
                    + (isActuallyContainedInHeader ? "within" : "outside")
                    + " given a horizontalScrollPosition of " + getCurrentHScrollPosition()
                    + "\n DEBUG INFO: header rectangle=" + entireHeaderRectangle;
        }

        private function getHeaderViewContainsPointErrorMessage(pointName:String, direction:Matrix, transformedPoint:Point, shouldBeContainedInAHeaderView:Boolean, isActuallyContainedByAHeaderView:Boolean, visibleHeaderViewRectangle:Rectangle):String
        {
            return "The point " + pointName + " transformed with Matrix " + direction + " (resulting in " + transformedPoint + ") should be "
                    + (shouldBeContainedInAHeaderView ? "within " : "outside ") + "a header view"
                    + " but was mistakenly found to be "
                    + (isActuallyContainedByAHeaderView ? "within" : "outside")
                    + " given a horizontalScrollPosition of " + getCurrentHScrollPosition()
                    + "\n DEBUG INFO: rectangles of visible header views = " + fixedHeaderViewRectangle + "; " + visibleHeaderViewRectangle;
        }

        private function getHeaderIndexAtGlobalPoint(globalPoint:Point):int
        {
            var localPoint:Point = _sut.globalToLocal(globalPoint);
            return _sut.getHeaderIndexAt(localPoint.x, localPoint.y);
        }

        private function getColumnIndexAtGlobalPoint(globalPoint:Point):int
        {
            var localPoint:Point = _dataGrid.grid.globalToLocal(globalPoint);
            return _dataGrid.grid.getColumnIndexAt(localPoint.x, localPoint.y);
        }

        private function getHeaderShouldContainPointAssumption(point:Point):Boolean
        {
            return rectangleContainsPoint(entireHeaderRectangle, point);
        }

        private function getFixedHeaderViewContainsPointAssumption(point:Point):Boolean
        {
            return rectangleContainsPoint(fixedHeaderViewRectangle, point);
        }

        private function getMainHeaderViewContainsPointAssumption(visibleHeaderViewRectangle:Rectangle, point:Point):Boolean
        {
            return rectangleContainsPoint(visibleHeaderViewRectangle, point);
        }

        private function getHeaderIndexAssumption(point:Point, visibleColumnHeaderRectangles:Array):int
        {
            return getIndexOfRectangleWhichContainsPoint(point, visibleColumnHeaderRectangles);
        }

        private function getColumnIndexAssumption(visibleColumnRectangles:Array, point:Point):int
        {
            return getIndexOfRectangleWhichContainsPoint(point, visibleColumnRectangles);
        }

        private function getIndexOfRectangleWhichContainsPoint(point:Point, rectangles:Array):int
        {
            for (var i:int = 0; i < rectangles.length; i++)
            {
                if(rectangleContainsPoint(rectangles[i], point))
                    return i;
            }

            return -1;
        }

        private function rectangleContainsPoint(rectangle:Rectangle, point:Point):Boolean
        {
            return rectangle.containsPoint(point);
        }

        private function getAdjacentPoint(point:Point, direction:Matrix):Point
        {
            return direction.transformPoint(point);
        }

        private function generateKeyPoints(grid:DataGrid):Array
        {
            var keyPoints:Array = [];

            keyPoints["a"] = new Point(0, 0);
            keyPoints["b0"] = new Point(getX(_dimensions), getY(_dimensions));
            generateColumnIntermediates(keyPoints, _dimensions, "b0");
            keyPoints["c0"] = new Point(getX(_dimensions) + getHeaderPaddingLeft(_dimensions), getY(_dimensions));
            generateColumnIntermediates(keyPoints, _dimensions, "c0");
            keyPoints["d"] = new Point(getX(_dimensions) + getWidth(_dimensions), getY(_dimensions));
            keyPoints["e"] = new Point(Point(keyPoints["c0"]).x, getY(_dimensions) + getHeaderPaddingTop(_dimensions));
            keyPoints["f"] = new Point(Point(keyPoints["c0"]).x, getY(_dimensions) + getActualHeaderHeight(grid) - getHeaderPaddingBottom(_dimensions));
            keyPoints["g0"] = new Point(getX(_dimensions), getY(_dimensions) + getActualHeaderHeight(grid));
            generateColumnIntermediates(keyPoints, _dimensions, "g0");
            keyPoints["i"] = new Point(getX(_dimensions) + getWidth(_dimensions), Point(keyPoints["g0"]).y);
            return keyPoints;
        }

        private function generateColumnIntermediates(keyPoints:Array, dimensions:Array, initialPointName:String):void
        {
            const initialPoint:Point = keyPoints[initialPointName];
            const y:Number = initialPoint.y;
            var currentX:Number = initialPoint.x;
            const initialPointFirstCharacter:String = initialPointName.charAt(0);
            for (var i:int = 0; i < getColumnWidths(dimensions).length; i++)
            {
                currentX += getColumnWidth(dimensions, i);
                keyPoints[initialPointFirstCharacter + (i+1)] = new Point(currentX, y);
            }
        }

        private function generateKeyRectangles():Array
        {
            var keyRectangles:Array = [];

            keyRectangles[ENTIRE_HEADER_RECTANGLE] = generateVisibleHeaderRectangle();
            keyRectangles[FIXED_HEADER_VIEW_RECTANGLE] = generateFixedHeaderViewRectangle();

            return keyRectangles;
        }

        private function generateFixedHeaderViewRectangle():Rectangle
        {
            //this is the GridColumnHeaderGroup.centerGridColumnHeaderView, which is holds the non-fixed columns; padding excluded
            const topLeftCorner:Point = _keyPoints["e"];
            return new Rectangle(topLeftCorner.x, topLeftCorner.y, 0, 0);
        }

        private function generateVisibleHeaderRectangle():Rectangle
        {
            const topLeftCorner:Point = _keyPoints["b0"];
            const bottomRightCorner:Point = _keyPoints["i"];
            return new Rectangle(topLeftCorner.x, topLeftCorner.y, bottomRightCorner.x - topLeftCorner.x, bottomRightCorner.y - topLeftCorner.y);
        }


        private function getActualHeaderHeight(grid:DataGrid):Number
        {
            //Note that we're assuming the grid is on stage and validated by this point!
            return grid.columnHeaderGroup.height;
        }

        private function getCurrentHScrollPosition():Number
        {
            return _dataGrid.grid.horizontalScrollPosition;
        }


        private function getVisibleHeaderViewRectangle(hScrollPosition:Number = 0):Rectangle
        {
            //this is the GridColumnHeaderGroup.centerGridColumnHeaderView, which holds the non-fixed columns; padding excluded
            const topLeftCorner:Point = _keyPoints["e"];
            return new Rectangle(topLeftCorner.x, topLeftCorner.y,
                    getHeaderWidthFromKeyPoints(_keyPoints) - getHeaderPaddingLeft(_dimensions),
                    getHeaderHeightFromKeyPoints(_keyPoints) - getHeaderPaddingTop(_dimensions) - getHeaderPaddingBottom(_dimensions));
        }

        private function getVisibleColumnHeaderRectangles(hScrollPosition:Number = 0):Array
        {
            var headerRectangles:Array = [];

            const headerPaddingTop:Number = getHeaderPaddingTop(_dimensions);
            const headerPaddingBottom:Number = getHeaderPaddingBottom(_dimensions);
            const headerHeight:Number = getHeaderHeightFromKeyPoints(_keyPoints) - headerPaddingTop - headerPaddingBottom;
            const numColumns:uint = getColumnWidths(_dimensions).length;
            const headerPaddingLeft:Number = getHeaderPaddingLeft(_dimensions);
            const headerWidth:Number = getWidth(_dimensions) - headerPaddingLeft;
            const e:Point = _keyPoints["e"];
            const visibleRectangle:Rectangle = new Rectangle(e.x, e.y, headerWidth, 100);
            var totalColumnWidths:Number = getTotalColumnWidths(_dimensions);
            var columnHeaderY:Number = NaN;

            //create the header rectangles from the first visible point on the left until the end
            for (var i:int = 0; i < numColumns; i++)
            {
                var topLeft:Point = _keyPoints["c" + i];
                var topRight:Point = _keyPoints["c" + (i+1)];
                var topLeftX:Number = topLeft.x - hScrollPosition;
                var topRightX:Number = topRight.x - hScrollPosition;

                if(isNaN(columnHeaderY))
                    columnHeaderY = topLeft.y + headerPaddingTop;

                var endsBeforeVisibleRectangle:Boolean = topRightX < visibleRectangle.x;
                var startsAfterVisibleRectangle:Boolean = topLeftX >= visibleRectangle.x + visibleRectangle.width;

                if(!(endsBeforeVisibleRectangle || startsAfterVisibleRectangle))
                {
                    const startingX:Number = Math.max(topLeftX, visibleRectangle.x);
                    const rightEdge:Number = Math.min(topRightX, visibleRectangle.x + visibleRectangle.width);
                    const width:Number = rightEdge - startingX;
                    headerRectangles.push(new Rectangle(startingX, columnHeaderY, width, headerHeight));
                }
            }

            assertThat("no example has 0 columns, so we expect this Array to have at least one item.", headerRectangles.length > 0);

            //correct last header rectangle to extend to grid boundaries if the total width of all the columns is smaller
            //than the grid's width. It is one of the issues which prompted this unit test in the first place.
            if(totalColumnWidths <= headerWidth)
            {
                var lastHeaderRectangle:Rectangle = headerRectangles[headerRectangles.length - 1];
                lastHeaderRectangle.width = Point(_keyPoints["d"]).x - lastHeaderRectangle.x;
            }

            return headerRectangles;
        }


        //Note that the height and y of the rectangles needs to be all-encompassing until FLEX-35280 is fixed
        private function getAllColumnRectangles(hScrollPosition:Number = 0):Array
        {
            var columnRectangles:Array = [];
            const numColumns:uint = getColumnWidths(_dimensions).length;

            for (var i:int = 0; i < numColumns; i++)
            {
                var topLeft:Point = _keyPoints["g" + i];
                var topRight:Point = _keyPoints["g" + (i+1)];

                columnRectangles.push(new Rectangle(topLeft.x, -10000, topRight.x - topLeft.x, Number.MAX_VALUE));
            }

            return columnRectangles;
        }

        /* key rectangles getters */

        private function get entireHeaderRectangle():Rectangle //includes padding
        {
            return _keyRectangles[ENTIRE_HEADER_RECTANGLE] as Rectangle;
        }

        private function get fixedHeaderViewRectangle():Rectangle
        {
            return _keyRectangles[FIXED_HEADER_VIEW_RECTANGLE] as Rectangle;
        }

        /* key points getters */

        private function getColumnWidthFromKeyPoints(keyPoints:Array, columnIndex:int):Number
        {
            //we're assuming columnIndex has a valid value
            return Point(keyPoints["c" + (columnIndex + 1)]).x - Point(keyPoints["c" + columnIndex]).x;
        }

        private function getHeaderHeightFromKeyPoints(keyPoints:Array):Number
        {
            return Point(keyPoints["i"]).y - Point(keyPoints["d"]).y;
        }

        private function getHeaderWidthFromKeyPoints(keyPoints:Array):Number
        {
            return Point(keyPoints["d"]).x - Point(keyPoints["b0"]).x;
        }

        /* dimensions getters */

        private function getX(dimensions:Array):Number
        {
            return dimensions[0];
        }

        private function getY(dimensions:Array):Number
        {
            return dimensions[1];
        }

        private function getWidth(dimensions:Array):Number
        {
            return dimensions[2];
        }

        private function getHeaderPaddingLeft(dimensions:Array):Number
        {
            return dimensions[3];
        }

        private function getHeaderPaddingTop(dimensions:Array):Number
        {
            return dimensions[4];
        }

        private function getHeaderPaddingBottom(dimensions:Array):Number
        {
            return dimensions[5];
        }

        private function getColumnWidths(dimensions:Array):Array
        {
            return dimensions[6];
        }

        private function getColumnWidth(dimensions:Array, columnIndex:int):Number
        {
            return getColumnWidths(dimensions)[columnIndex];
        }

        private function getTotalColumnWidths(dimensions:Array):Number
        {
            var sum:Number = 0;
            getColumnWidths(dimensions).forEach(function (item:*, index:int, arr:Array):void {sum += item;});
            return sum;
        }


        private function onEnterFrame(event:Event):void
        {
            if(!--_noEnterFramesRemaining)
            {
                UIImpersonator.testDisplay.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
                _finishNotifier.dispatchEvent(new Event(Event.COMPLETE));
            }
        }

        private function get _sut():GridColumnHeaderGroup
        {
            return _dataGrid.columnHeaderGroup;
        }
    }
}