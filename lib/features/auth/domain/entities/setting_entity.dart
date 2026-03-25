import 'package:equatable/equatable.dart';

class SettingEntity extends Equatable {
  final String status;
  final SettingDataEntity? data;

  const SettingEntity({this.status = "", this.data});

  @override
  List<Object?> get props => [status, data];
}

class SettingDataEntity extends Equatable {
  final String id;
  final String name;
  final MinMaxEntity? deposit;
  final MinMaxEntity? withdraw;
  final MinMaxEntity? transfer;
  final MinMaxEntity? betting;
  final Map<String, bool> withdrawalOffDays;
  final RatesEntity? rates;
  final FeatureFlagsEntity? featureFlags;
  final AviatorEntity? aviator;
  final String merchantUpi;
  final String merchantQrUpi;
  final String withdrawOffText;
  final String withdrawText;
  final String depositText;
  final String withdrawOpen;
  final String withdrawClose;
  final String appLink;
  final bool maintainence;
  final String maintainenceMsg;
  final NotificationConfigEntity? notificationConfig;

  const SettingDataEntity({
    required this.id, required this.name, this.deposit, this.withdraw,
    this.transfer, this.betting, required this.withdrawalOffDays,
    this.rates, this.featureFlags, this.aviator, required this.merchantUpi,
    required this.merchantQrUpi, required this.withdrawOffText,
    required this.withdrawText, required this.depositText,
    required this.withdrawOpen, required this.withdrawClose,
    required this.appLink, required this.maintainence,
    required this.maintainenceMsg, this.notificationConfig,
  });

  @override
  List<Object?> get props => [id, name, maintainence, rates, aviator];
}

// Sub-Entities
class MinMaxEntity extends Equatable {
  final int min; final int max;
  const MinMaxEntity({required this.min, required this.max});
  @override List<Object?> get props => [min, max];
}

class RatesEntity extends Equatable {
  final Map<String, String> main;
  final Map<String, String> starline;
  final Map<String, String> galidisawar;
  final Map<String, String> roulette;

  const RatesEntity({required this.main, required this.starline, required this.galidisawar, required this.roulette});
  @override List<Object?> get props => [main, starline, galidisawar, roulette];
}

class FeatureFlagsEntity extends Equatable {
  final bool withdrawOncePerDay;
  const FeatureFlagsEntity({required this.withdrawOncePerDay});
  @override List<Object?> get props => [withdrawOncePerDay];
}

class AviatorEntity extends Equatable {
  final bool active; final bool maintenance; final int minBet; final int maxBet;
  const AviatorEntity({required this.active, required this.maintenance, required this.minBet, required this.maxBet});
  @override List<Object?> get props => [active, maintenance, minBet, maxBet];
}

class NotificationConfigEntity extends Equatable {
  final NotificationDetailEntity? resultDeclared;
  final NotificationDetailEntity? openReminder;
  final NotificationDetailEntity? closeReminder;
  const NotificationConfigEntity({this.resultDeclared, this.openReminder, this.closeReminder});
  @override List<Object?> get props => [resultDeclared, openReminder, closeReminder];
}

class NotificationDetailEntity extends Equatable {
  final bool titleEnabled; final String titleText; final bool messageEnabled; final String messageText;
  const NotificationDetailEntity({required this.titleEnabled, required this.titleText, required this.messageEnabled, required this.messageText});
  @override List<Object?> get props => [titleEnabled, titleText, messageEnabled, messageText];
}