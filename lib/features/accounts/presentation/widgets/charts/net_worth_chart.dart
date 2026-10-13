import 'dart:math' show max, min;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../core/utils/currency_helper.dart';
import '../../../../../core/utils/dialogs/show_info_dialog.dart';
import '../../../../../core/utils/net_worth_calculator.dart';
import '../../../../../data/enums/net_worth_period_type.dart';
import '../../../../../data/helper_models/net_worth_booking.dart';
import '../../../../../data/helper_models/net_worth_point.dart';
import '../../../../../data/models/account.dart';
import '../../../../../data/repositories/net_worth_repository.dart';
import '../../../../../l10n/app_localizations.dart';

// Diagramm der Vermögensentwicklung (Saldo) auf der Kontoliste.
class NetWorthChart extends StatefulWidget {
  final List<Account> accounts;

  const NetWorthChart({
    super.key,
    required this.accounts,
  });

  @override
  State<NetWorthChart> createState() => _NetWorthChartState();
}

class _NetWorthChartState extends State<NetWorthChart> with AutomaticKeepAliveClientMixin {
  static const String _periodPreferenceKey = 'net_worth_chart_period';
  static const Color _lineColor = Colors.cyanAccent;

  final NetWorthRepository _netWorthRepository = NetWorthRepository();

  NetWorthPeriodType _selectedPeriod = NetWorthPeriodType.oneYear;
  List<NetWorthBooking>? _bookings;
  List<NetWorthPoint> _points = [];
  DateTime _startDate = DateTime.now();
  bool _hasError = false;
  int _loadRequestId = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadSelectedPeriod();
    _loadBookings();
  }

  @override
  void didUpdateWidget(covariant NetWorthChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Haben sich Kontostände geändert, wurden Buchungen erstellt, bearbeitet oder gelöscht.
    if (_accountsSignature(oldWidget.accounts) != _accountsSignature(widget.accounts)) {
      _loadBookings();
    }
  }

  String _accountsSignature(List<Account> accounts) {
    return accounts.map((account) => '${account.id}:${account.balance}:${account.accountType.index}').join('|');
  }

  Future<void> _loadSelectedPeriod() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final int? periodIndex = prefs.getInt(_periodPreferenceKey);
      if (periodIndex != null && periodIndex >= 0 && periodIndex < NetWorthPeriodType.values.length && mounted) {
        setState(() {
          _selectedPeriod = NetWorthPeriodType.values[periodIndex];
          _calculatePoints();
        });
      }
    } catch (_) {
      // Ohne gespeicherte Auswahl wird der Standardzeitraum verwendet.
    }
  }

  Future<void> _saveSelectedPeriod() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_periodPreferenceKey, _selectedPeriod.index);
    } catch (_) {
      // Speichern ist nur eine Komfortfunktion.
    }
  }

  Future<void> _loadBookings() async {
    final int requestId = ++_loadRequestId;
    try {
      final List<NetWorthBooking> bookings = await _netWorthRepository.loadBookedBookings();
      if (!mounted || requestId != _loadRequestId) {
        return;
      }
      setState(() {
        _bookings = bookings;
        _hasError = false;
        _calculatePoints();
      });
    } catch (_) {
      if (!mounted || requestId != _loadRequestId) {
        return;
      }
      setState(() {
        _hasError = true;
      });
    }
  }

  void _calculatePoints() {
    if (_bookings == null) {
      return;
    }
    final DateTime today = DateTime.now();
    final DateTime? firstBookingDate = _bookings!.isEmpty
        ? null
        : _bookings!.map((booking) => booking.bookingDate).reduce((a, b) => a.isBefore(b) ? a : b);
    _startDate = _selectedPeriod.getStartDate(today, firstBookingDate);
    _points = NetWorthCalculator.calculateHistory(
      accounts: widget.accounts,
      bookings: _bookings!,
      startDate: _startDate,
      endDate: today,
    );
  }

  void _onPeriodChanged(NetWorthPeriodType period) {
    setState(() {
      _selectedPeriod = period;
      _calculatePoints();
    });
    _saveSelectedPeriod();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final t = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 14.0, 16.0, 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(t),
            const SizedBox(height: 20.0),
            SizedBox(
              height: 170.0,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildChartArea(t),
              ),
            ),
            const SizedBox(height: 12.0),
            _buildPeriodSelector(t),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations t) {
    final bool hasPoints = _points.length >= 2;
    final double change = hasPoints ? _points.last.netWorth - _points.first.netWorth : 0.0;
    final double startValue = hasPoints ? _points.first.netWorth : 0.0;
    final bool isPositive = change >= 0;
    final Color changeColor = isPositive ? Colors.green : Colors.redAccent;
    final String sign = change > 0 ? '+' : (change < 0 ? '−' : '');
    final String locale = Localizations.localeOf(context).toString();

    String? percentText;
    if (hasPoints && startValue > 0) {
      final double percent = change / startValue * 100;
      percentText = '$sign${NumberFormat('#,##0.0', locale).format(percent.abs())} %';
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Row(
            children: [
              Flexible(
                child: Text(
                  t.translate('net_worth_development'),
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 6.0),
                child: GestureDetector(
                  onTap: () async {
                    await showInfoDialog(context, 'net_worth_dialog_title', 'net_worth_dialog_content');
                  },
                  child: const Icon(
                    Icons.info_outline_rounded,
                    color: Colors.grey,
                    size: 18.0,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (hasPoints)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                    color: changeColor,
                    size: 18.0,
                  ),
                  const SizedBox(width: 4.0),
                  Text(
                    '$sign${CurrencyHelper.instance.formatCurrency(change.abs(), context)}',
                    style: TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                      color: changeColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2.0),
              Text(
                percentText == null ? t.translate('net_worth_change_in_period') : '$percentText ${t.translate('net_worth_change_in_period')}',
                style: const TextStyle(
                  fontSize: 12.0,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildChartArea(AppLocalizations t) {
    if (_hasError) {
      return Center(
        key: const ValueKey('error'),
        child: Text(
          t.translate('database_error'),
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.grey),
        ),
      );
    }
    if (_bookings == null || _points.length < 2) {
      return const Center(
        key: ValueKey('loading'),
        child: SizedBox(
          width: 24.0,
          height: 24.0,
          child: CircularProgressIndicator(strokeWidth: 2.0),
        ),
      );
    }
    return KeyedSubtree(
      key: const ValueKey('chart'),
      child: _buildLineChart(),
    );
  }

  Widget _buildLineChart() {
    final String locale = Localizations.localeOf(context).toString();
    final int totalDays = max(1, NetWorthCalculator.daysBetween(_startDate, _points.last.date));

    final List<FlSpot> spots = _points
        .map((point) => FlSpot(
              NetWorthCalculator.daysBetween(_startDate, point.date).toDouble(),
              point.netWorth,
            ))
        .toList();

    final double minValue = _points.map((point) => point.netWorth).reduce(min);
    final double maxValue = _points.map((point) => point.netWorth).reduce(max);
    final double range = maxValue - minValue;
    final double padding = range == 0 ? max(maxValue.abs() * 0.1, 10.0) : range * 0.12;
    final double minY = minValue - padding;
    final double maxY = maxValue + padding;
    final double leftInterval = (maxY - minY) / 3;

    final DateFormat bottomFormat = totalDays <= 200 ? DateFormat.MMMd(locale) : DateFormat('MMM yy', locale);
    final DateFormat tooltipFormat = DateFormat.yMMMd(locale);

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: totalDays.toDouble(),
        minY: minY,
        maxY: maxY,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            preventCurveOverShooting: true,
            curveSmoothness: 0.2,
            color: _lineColor,
            barWidth: 2.0,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  _lineColor.withValues(alpha: 0.25),
                  _lineColor.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ],
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            if (minY < 0 && maxY > 0)
              HorizontalLine(
                y: 0,
                color: Colors.grey.withValues(alpha: 0.6),
                strokeWidth: 1.0,
                dashArray: [4, 4],
              ),
          ],
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: leftInterval,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.grey.withValues(alpha: 0.15),
            strokeWidth: 1.0,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 64.0,
              interval: leftInterval,
              getTitlesWidget: (value, meta) {
                // Ränder nicht beschriften, damit sich die Werte nicht mit dem Puffer überlappen.
                if (value == meta.min || value == meta.max) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: Text(
                    _formatAxisAmount(value, locale),
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11.0, color: Colors.grey),
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 26.0,
              interval: totalDays / 3,
              getTitlesWidget: (value, meta) {
                final DateTime date = DateTime(_startDate.year, _startDate.month, _startDate.day + value.round());
                return SideTitleWidget(
                  meta: meta,
                  fitInside: SideTitleFitInsideData.fromTitleMeta(meta),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Text(
                      bottomFormat.format(date),
                      style: const TextStyle(fontSize: 11.0, fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        lineTouchData: LineTouchData(
          enabled: true,
          handleBuiltInTouches: true,
          getTouchedSpotIndicator: (barData, spotIndexes) {
            return spotIndexes
                .map((index) => TouchedSpotIndicatorData(
                      FlLine(color: Colors.grey, strokeWidth: 1.0, dashArray: [4, 4]),
                      FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                          radius: 4.5,
                          color: _lineColor,
                          strokeWidth: 2.0,
                          strokeColor: Colors.grey.shade900,
                        ),
                      ),
                    ))
                .toList();
          },
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => Colors.grey.shade800,
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            tooltipPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final NetWorthPoint point = _points[spot.spotIndex];
                return LineTooltipItem(
                  '${tooltipFormat.format(point.date)}\n',
                  const TextStyle(color: Colors.white70, fontSize: 11.0),
                  children: [
                    TextSpan(
                      text: CurrencyHelper.instance.formatCurrency(point.netWorth, context),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                );
              }).toList();
            },
          ),
        ),
      ),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
    );
  }

  // Achsenbeschriftung kompakt halten, z.B. "12.500 €" oder "1,2 Mio. €".
  String _formatAxisAmount(double value, String locale) {
    if (value.abs() >= 100000) {
      return NumberFormat.compactSimpleCurrency(
        locale: locale,
        name: CurrencyHelper.instance.currencyCode,
      ).format(value);
    }
    return CurrencyHelper.instance.formatCurrency(value, context, decimalDigits: 0);
  }

  Widget _buildPeriodSelector(AppLocalizations t) {
    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<NetWorthPeriodType>(
        segments: NetWorthPeriodType.values
            .map((period) => ButtonSegment<NetWorthPeriodType>(
                  value: period,
                  label: Text(
                    t.translate(period.translationKey),
                    style: const TextStyle(fontSize: 12.0),
                  ),
                ))
            .toList(),
        selected: {_selectedPeriod},
        onSelectionChanged: (selection) => _onPeriodChanged(selection.first),
        showSelectedIcon: false,
        style: ButtonStyle(
          padding: WidgetStateProperty.all(EdgeInsets.zero),
          visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          minimumSize: WidgetStateProperty.all(const Size(0, 34)),
          shape: WidgetStateProperty.all(
            const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
          ),
        ),
      ),
    );
  }
}
