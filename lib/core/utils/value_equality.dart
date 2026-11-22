/// Wertgleichheit für unveränderliche Klassen wie Bloc-Events und -States.
///
/// Zwei Objekte sind gleich, wenn sie denselben Typ und dieselben [props] haben.
mixin ValueEquality {
  List<Object?> get props;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType || other is! ValueEquality) {
      return false;
    }
    final otherProps = other.props;
    if (props.length != otherProps.length) {
      return false;
    }
    for (var i = 0; i < props.length; i++) {
      if (props[i] != otherProps[i]) {
        return false;
      }
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(runtimeType, Object.hashAll(props));
}
