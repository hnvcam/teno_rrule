import 'dart:collection';

/// Simple FIFO cache to control the size of cached items.
class SimpleMemCache<T> {
  final Map<Object, T> _cache = {};
  final Queue<Object> _cacheOrder = Queue();
  late int _size;

  SimpleMemCache([int size = 12]) {
    assert(size > 0);
    _size = size;
  }

  int get size => _size;

  set size(int newSize) {
    assert(newSize > 0);
    _size = newSize;
  }

  T getOrBuild(Object key, T Function() builder) {
    if (_cache.containsKey(key)) {
      // print('cache hit');
      return _cache[key]!;
    }
    while (_cacheOrder.length >= _size) {
      final removeKey = _cacheOrder.removeFirst();
      _cache.remove(removeKey);
    }
    // print('cache miss $key');
    T newValue = builder();
    _cache[key] = newValue;
    _cacheOrder.add(key);
    return newValue;
  }
}
