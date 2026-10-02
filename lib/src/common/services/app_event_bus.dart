import 'dart:async';
import 'package:flutter/foundation.dart';

/// Base class for all app-wide reactive events.
abstract class AppEvent {
  final DateTime timestamp = DateTime.now();
}

/// Emitted when a financial transaction completes that alters account balances.
class BalanceChangedEvent extends AppEvent {
  final String? sourceModule;
  final String? currencyCode;
  final double? amount;

  BalanceChangedEvent({
    this.sourceModule,
    this.currencyCode,
    this.amount,
  });

  @override
  String toString() => 'BalanceChangedEvent(source: $sourceModule, currency: $currencyCode, amount: $amount)';
}

/// Emitted when KYC tier is upgraded or documents are submitted/reviewed.
class KycStatusChangedEvent extends AppEvent {
  final int? newLevel;
  final String? status;

  KycStatusChangedEvent({this.newLevel, this.status});

  @override
  String toString() => 'KycStatusChangedEvent(level: $newLevel, status: $status)';
}

/// Emitted when the user creates, deletes, or modifies a wallet.
class WalletListChangedEvent extends AppEvent {
  final String? action;
  final String? currencyCode;

  WalletListChangedEvent({this.action, this.currencyCode});

  @override
  String toString() => 'WalletListChangedEvent(action: $action, currency: $currencyCode)';
}

/// Emitted when user personal profile or settings change.
class ProfileUpdatedEvent extends AppEvent {}

/// Emitted when a push notification or in-app message is received.
class NotificationReceivedEvent extends AppEvent {
  final Map<String, dynamic>? payload;
  NotificationReceivedEvent({this.payload});
}

/// AppEventBus — Centralized event bus for inter-module reactivity.
/// Allows decoupled controllers to react to cross-cutting financial and system events.
class AppEventBus {
  AppEventBus._internal();
  static final AppEventBus _instance = AppEventBus._internal();
  static AppEventBus get instance => _instance;

  final StreamController<AppEvent> _controller = StreamController<AppEvent>.broadcast();

  /// Emits an event to all active subscribers.
  static void emit(AppEvent event) {
    if (kDebugMode) {
      debugPrint('⚡ [AppEventBus] Emitted: $event');
    }
    _instance._controller.add(event);
  }

  /// Listen to all events of type [T].
  static Stream<T> on<T extends AppEvent>() {
    return _instance._controller.stream.where((event) => event is T).cast<T>();
  }

  /// Dispose the event controller (usually on app shutdown/reset).
  void dispose() {
    _controller.close();
  }
}
