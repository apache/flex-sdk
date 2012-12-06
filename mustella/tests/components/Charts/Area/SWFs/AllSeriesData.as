package {

	import mx.charts.*;
	import mx.charts.series.*;


	public class AllSeriesData  { 


		public static function setDefault (which:String, chart:Object):void 
		{

			var arr:Array = new Array();
			var closeSeries:AreaSeries = new AreaSeries();
			var openSeries:AreaSeries = new AreaSeries();

	
			switch(which)
			{
			case "area": 
				var a:AreaSeries = new AreaSeries();	
				a.yField = "close";
				arr.push(a);
				break;
			case "bar": 
				var b:BarSeries = new BarSeries();	
				b.xField = "close";
				arr.push(b);
				break;
			case "column":
				var c:ColumnSeries = new ColumnSeries();	
				c.yField = "close";
				arr.push(c);
				break;
			case "candlestick": 
				var d:CandlestickSeries = new CandlestickSeries();	
				d.closeField = "close";
				d.openField = "open";
				d.highField = "high";
				d.lowField = "low";
				arr.push(d);
				break;
			case "line":
				var f:LineSeries = new LineSeries();	
				f.yField = "close";
				arr.push(f);
				break;
			case "plot": 
				var g:PlotSeries = new PlotSeries();	
				g.yField = "close";
				arr.push(g);
				break;
			case "bubble":
				var g1:BubbleSeries = new BubbleSeries();	
				g1.radiusField = "low";
				g1.yField = "close";
				arr.push(g1);
				break;
			case "pie":
				var h:PieSeries = new PieSeries();	
				h.field = "close";
				arr.push(h);
				break;
			case "column_multiple": 
				var goldcol:ColumnSeries = new ColumnSeries();	
				goldcol.yField = "Gold";
				arr.push(goldcol);

				var silvercol:ColumnSeries = new ColumnSeries();	
				silvercol.yField = "Silver";
				arr.push(silvercol);

				var bronzecol:ColumnSeries = new ColumnSeries();	
				bronzecol.yField = "Bronze";
				arr.push(bronzecol);
				break;
			case "bar_multiple": 
				var goldbar:BarSeries = new BarSeries();	
				goldbar.xField = "Gold";
				arr.push(goldbar);

				var silverbar:BarSeries = new BarSeries();	
				silverbar.xField = "Silver";
				arr.push(silverbar);

				var bronzebar:BarSeries = new BarSeries();	
				bronzebar.xField = "Bronze";
				arr.push(bronzebar);
				break;
			case "pie_multiple": 
				var goldpie:PieSeries = new PieSeries();	
				goldpie.field = "Gold";
				goldpie..setStyle("labelPosition","outside");
				goldpie.nameField="Country";
				arr.push(goldpie);

				var silverpie:PieSeries = new PieSeries();	
				silverpie.field = "Silver";
				silverpie.setStyle("labelPosition","inside");
				silverpie.nameField="Country";
				arr.push(silverpie);

				var bronzepie:PieSeries = new PieSeries();	
				bronzepie.field = "Bronze";
				bronzepie..setStyle("labelPosition","callout");
				bronzepie.nameField="Country";
				arr.push(bronzepie);
				break;
			case "area_multiple":	
				closeSeries = new AreaSeries();
				openSeries = new AreaSeries();				
				closeSeries.yField = "close";
				arr.push(closeSeries);				
				
				openSeries.yField = "open";
				arr.push(openSeries);				
				break;
			
			case "area_multiple_areaset":				
				var myAreaSet:AreaSet = new AreaSet();
				var myArray: Array = new Array();
				closeSeries.yField = "close";
				myArray.push(closeSeries);
				myAreaSet.series = myArray;
				myAreaSet.type = "stacked";
				
				openSeries.yField = "open";
				myArray.push(openSeries)
				myAreaSet.series = myArray;	
				
				arr.push(myAreaSet);
				break;

				
			default:
				break;
			}
		

			chart.series = arr;

		}
		public static function setAxisFields (which:String,chart:Object):void 
		{
			var cataxis:CategoryAxis =  new CategoryAxis();
			cataxis.categoryField = "Country";
			switch(which)
			{
				case "column":
					chart.horizontalAxis = cataxis;
					break;
				case "bar":
					chart.verticalAxis = cataxis;
					break;
				default:
					break;
			}
		}


	}

}


