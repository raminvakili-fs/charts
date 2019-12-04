import 'dart:math';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:charts_flutter/flutter.dart';
import 'package:flutter/material.dart';

import 'custom_renderer.dart';

class SimpleLineChart extends StatefulWidget {
  @override
  _SimpleLineChartState createState() => _SimpleLineChartState();
}

class _SimpleLineChartState extends State<SimpleLineChart> {
  int _lastY = 1;
  int _lastValue = 20;
  bool _pause = false;
  DateTime _time;
  Map<String, num> _measures;

  bool _finishStream = false;

  charts.CustomLineRendererConfig<DateTime> _lineRendererConfig = charts.CustomLineRendererConfig(
    includeArea: false,
    includeLine: true,
    includePoints: true,
    stacked: false,
    roundEndCaps: true,
    // dashPattern: [1, 0],
    radiusPx: 2,
    strokeWidthPx: 2.0,
  );

  List<charts.Series<TimeSeriesSales, DateTime>> seriesData = List<charts.Series<TimeSeriesSales, DateTime>>();
  List<charts.Series<TimeSeriesSales, DateTime>> seriesData2 = List<charts.Series<TimeSeriesSales, DateTime>>();

  final dataXY = [
    TimeSeriesSales(DateTime(2017, 10, 1), 20, 'rect1', 0, false),
  ];

  @override
  void dispose() {
    super.dispose();
    _finishStream = true;
  }


  @override
  void initState() {
    dataStream = createDataTimesStream();

    dataStream.listen((data) {
      setState(() {

        dataXY.last.shape = dataXY.last.isFlag ? 'flag' : 'circle';
        dataXY.last.radius = 0;

        data.radius = 10;
        data.shape = 'ripple';

        dataXY.add(data);

        if (!_pause) {
          seriesData = _createSampleData(dataXY);
        }
      });
    });

    super.initState();
  }

  static List<charts.Series<TimeSeriesSales, DateTime>> _createSampleData(List<TimeSeriesSales> data) {
    List<TimeSeriesSales> data2 = [TimeSeriesSales(data.first.time, data.last.sales,'rect', 0, false), TimeSeriesSales(data.last.time, data.last.sales,'rect', 0, false)];

    return [
      charts.Series<TimeSeriesSales, DateTime>(
        id: 'Barrier',
        colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
        domainFn: (TimeSeriesSales sales, _) => sales.time,
        measureFn: (TimeSeriesSales sales, _) => sales.sales,
        data: data2,
      ),
      charts.Series<TimeSeriesSales, DateTime>(
        id: 'Sample Data',
        colorFn: (_, __) => charts.MaterialPalette.black,
        domainFn: (TimeSeriesSales sales, _) => sales.time,
        measureFn: (TimeSeriesSales sales, _) => sales.sales,
        radiusPxFn: (TimeSeriesSales sales, _) => sales.radius,
        data: data,
      )// Accessor function that associates each datum with a symbol renderer.
        ..setAttribute(
            charts.pointSymbolRendererFnKey, (int index) => data[index].shape)
      // Default symbol renderer ID for data that have no defined shape.
        ..setAttribute(charts.pointSymbolRendererIdKey, 'rect'),
    ];
  }

  Stream<TimeSeriesSales> createDataTimesStream() async* {
    while (true) {
      await Future.delayed(Duration(seconds: 2));

      i++;

      if (_finishStream){
        break;
      }

      _lastValue = Random().nextBool() ? _lastValue + Random().nextInt(5) : _lastValue - Random().nextInt(5);


      yield TimeSeriesSales(DateTime(2017, 10, ++_lastY), _lastValue, (i % 5 == 0) ? 'flag' : 'rect', 0, (i % 5 == 0));
    }
  }

  Stream<TimeSeriesSales> dataStream;
int i = 0;
  _onSelectionChanged(charts.SelectionModel model) {
    if(model.hasDatumSelection) {
      setState(() {
        textSelected = "${i++}";
      });
      debugPrint(textSelected);
    }
  }

  String textSelected = "";

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            width: MediaQuery.of(context).size.width,
            child: buildTimeSeriesChart(),
          ),
        ),
        SizedBox(height: 32.0),
        Text(_measures == null ? '' : _measures.toString())
      ],
    );
  }

  charts.CustomTimeSeriesChart buildTimeSeriesChart() {
    return charts.CustomTimeSeriesChart(
      seriesData,
      animate: true,
      animationDuration: Duration(milliseconds: 1000),
      // domainAxis: charts.EndPointsTimeAxisSpec(),
      defaultRenderer: _lineRendererConfig,

      behaviors: [
        charts.PanAndZoomBehavior(panningCompletedCallback: (){

        }),
        charts.SeriesLegend(position: charts.BehaviorPosition.bottom),
        charts.SlidingViewport(),
        charts.LinePointHighlighter(
          showHorizontalFollowLine: charts.LinePointHighlighterFollowLineType.nearest,
          showVerticalFollowLine: charts.LinePointHighlighterFollowLineType.nearest,
          dashPattern: [1],
          symbolRenderer: charts.RectSymbolRenderer(isSolid: false),
          drawFollowLinesAcrossChart: true,
        ),

        LinePointHighlighter(
            symbolRenderer: CustomCircleSymbolRenderer(text: textSelected)
        )
      ],
      selectionModels: [
        charts.SelectionModelConfig(
          type: charts.SelectionModelType.info,
          changedListener: _onSelectionChanged,
        ),
      ],
    ) ;
  }
}

class TimeSeriesSales {
  final DateTime time;
  final int sales;
  String shape;
  double radius;

  final bool isFlag;

  TimeSeriesSales(this.time, this.sales, this.shape, this.radius, this.isFlag);
}
