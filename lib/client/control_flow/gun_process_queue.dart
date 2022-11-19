import 'package:flutter/foundation.dart';

import '../../types/gun.dart';
import 'gun_event.dart';
import 'gun_queue.dart';
import 'middleware_system.dart';

enum ProcessDupesOptionType { processDupes, dontProcessDupes }

class GunProcessQueue<T extends GunMsg, U, V> extends GunQueue<T> {
  final String name;
  late final MiddlewareSystem<T, U, V> middleware;
  late bool isProcessing;
  late final GunEvent<T, dynamic, dynamic> completed;
  late final GunEvent<bool, dynamic, dynamic> emptied;
  final ProcessDupesOptionType processDupes;

  late List<T> alreadyProcessed;

  GunProcessQueue(
      {this.name = 'GunProcessQueue',
      this.processDupes = ProcessDupesOptionType.processDupes}) {
    alreadyProcessed = [];
    isProcessing = false;
    completed = GunEvent<T, dynamic, dynamic>(name: '$name.processed');
    emptied = GunEvent<bool, dynamic, dynamic>(name: '$name.emptied');
    middleware = MiddlewareSystem<T, U, V>(name: '$name.middleware');
  }

  @override
  bool has(T item) {
    return super.has(item) || alreadyProcessed.contains(item);
  }

  Future<void> processNext([U? b, V? c]) async {
    var item = dequeue();
    final processedItem = item;

    if (item == null) {
      return;
    }

    item = await middleware.process(item, b, c);

    if (processedItem != null &&
        processDupes == ProcessDupesOptionType.dontProcessDupes) {
      alreadyProcessed.add(processedItem);
    }

    if (item != null) {
      completed.trigger(item);
    }
  }

  GunProcessQueue<T, U, V> enqueueMany(final List<T> items) {
    super.enqueueMany(items);
    return this;
  }

  Future<void> process() async {
    if (isProcessing) {
      return;
    }

    if (count() == 0) {
      return;
    }

    isProcessing = true;
    while (count() > 0) {
      try {
        await processNext();
      } catch (e) {
        if (kDebugMode) {
          print('Process Queue error: ${e.toString()}');
        }
      }
    }

    emptied.trigger(true);

    isProcessing = false;
  }
}
