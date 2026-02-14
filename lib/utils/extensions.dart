/// Iterable extension providing an indexed map helper.
extension IterableMapIndexed<T> on Iterable<T> {
  Iterable<R> mapIndexed<R>(R Function(int index, T element) fn) sync* {
    int i = 0;
    for (final e in this) {
      yield fn(i++, e);
    }
  }
}