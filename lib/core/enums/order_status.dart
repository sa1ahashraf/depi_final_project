enum OrderStatus {
  pending,
  accepted,
  rejected,
  preparing,
  ready,
  completed,
  cancelled;

  String get value => name;

  bool get isFinal =>
      this == OrderStatus.rejected ||
      this == OrderStatus.completed ||
      this == OrderStatus.cancelled;
}
