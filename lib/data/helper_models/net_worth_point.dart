// Ein Datenpunkt im Vermögensentwicklungs-Diagramm (Saldo am Ende des Tages).
class NetWorthPoint {
  final DateTime date;
  final double netWorth;

  const NetWorthPoint({
    required this.date,
    required this.netWorth,
  });
}
