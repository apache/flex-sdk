

package {

	import mx.charts.*;
	import mx.charts.series.*;


	public class AllSeriesDisabledDaysData  { 


		public static function setDefault (which:String, chart:Object):void {

			var arr:Array = new Array();

	
			if (which == "area") { 
				var a:AreaSeries = new AreaSeries();	
				a.yField = "close";
				a.xField = "date";
				arr.push(a);
			} else if (which == "bar") { 
				var b:BarSeries = new BarSeries();	
				b.xField = "close";
				b.yField = "date";
				arr.push(b);
			} else if (which == "column") { 
				var c:ColumnSeries = new ColumnSeries();	
				c.yField = "close";
				c.xField = "date";				
				arr.push(c);
			} else if (which == "candle") { 
				var d:CandlestickSeries = new CandlestickSeries();	
				d.closeField = "close";
				d.openField = "open";
				d.highField = "high";
				d.lowField = "low";
				d.xField = "date";
				arr.push(d);
			} else if (which == "hloc") { 
				var e:HLOCSeries = new HLOCSeries();	
				e.closeField = "close";
				e.openField = "open";
				e.highField = "high";
				e.lowField = "low";
				e.xField = "date";
				arr.push(e);
			} else if (which == "line") { 
				var f:LineSeries = new LineSeries();	
				f.yField = "close";
				f.xField = "date";
				arr.push(f);
			} else if (which == "plot") { 
				var g:PlotSeries = new PlotSeries();	
				g.yField = "close";
				g.xField = "date";
				arr.push(g);
			} else if (which == "bubble") { 
				var g1:BubbleSeries = new BubbleSeries();	
				g1.radiusField = "low";
				g1.yField = "close";
				g1.xField = "date";
				arr.push(g1);
			} else if (which == "pie") { 
				var h:PieSeries = new PieSeries();	
				h.field = "close";				
				arr.push(h);
			}

			chart.series = arr;

		}


	}

}


