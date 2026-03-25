import 'package:kalyanboss/features/auth/domain/entities/setting_entity.dart';
import 'package:kalyanboss/utils/helpers/customJsonParser.dart';

class SettingModel {
  final String? status;
  final SettingDataModel? data;

  SettingModel({this.status, this.data});

  factory SettingModel.fromJson(Map<String, dynamic> json) => SettingModel(
    status: json.parse<String>('status'),
    data: json.parseNested('data', (map) => SettingDataModel.fromJson(map)),
  );

  SettingEntity toEntity() => SettingEntity(
    status: status ?? "",
    data: data?.toEntity(),
  );
}

class SettingDataModel {
  final String? id;
  final String? name;
  final MinMaxModel? deposit;
  final MinMaxModel? withdraw;
  final MinMaxModel? transfer;
  final MinMaxModel? betting;
  final Map<String, bool>? withdrawOffDay;
  final Map<String, dynamic>? rates;
  final Map<String, dynamic>? featureFlags;
  final AviatorModel? aviator;
  final String? merchantUpi;
  final String? merchantQrUpi;
  final String? withdrawOffText;
  final String? withdrawOpen;
  final String? withdrawClose;
  final String? appLink;
  final bool? maintainence;
  final String? maintainenceMsg;
  final NotificationConfigModel? notificationConfig;

  SettingDataModel({
    this.id, this.name, this.deposit, this.withdraw, this.transfer, this.betting,
    this.withdrawOffDay, this.rates, this.featureFlags, this.aviator,
    this.merchantUpi, this.merchantQrUpi, this.withdrawOffText, this.withdrawOpen,
    this.withdrawClose, this.appLink, this.maintainence, this.maintainenceMsg,
    this.notificationConfig,
  });

  factory SettingDataModel.fromJson(Map<String, dynamic> json) => SettingDataModel(
    id: json.parse<String>('_id'),
    name: json.parse<String>('name'),
    deposit: json.parseNested('deposit', (m) => MinMaxModel.fromJson(m)),
    withdraw: json.parseNested('withdraw', (m) => MinMaxModel.fromJson(m)),
    transfer: json.parseNested('transfer', (m) => MinMaxModel.fromJson(m)),
    betting: json.parseNested('betting', (m) => MinMaxModel.fromJson(m)),
    withdrawOffDay: (json['withdrawl_off_day'] as Map?)?.cast<String, bool>(),
    rates: json['rates'] as Map<String, dynamic>?,
    featureFlags: json['feature_flags'] as Map<String, dynamic>?,
    aviator: json.parseNested('aviator', (m) => AviatorModel.fromJson(m)),
    merchantUpi: json.parse<String>('merchant_upi'),
    merchantQrUpi: json.parse<String>('merchant_qr_upi'),
    withdrawOffText: json.parse<String>('withdraw_off_text'),
    withdrawOpen: json.parse<String>('withdraw_open'),
    withdrawClose: json.parse<String>('withdraw_close'),
    appLink: json.parse<String>('app_link'),
    maintainence: json.parse<bool>('maintainence'),
    maintainenceMsg: json.parse<String>('maintainence_msg'),
    notificationConfig: json.parseNested('notification_config', (m) => NotificationConfigModel.fromJson(m)),
  );

  // --- THE COMPLETED MAPPING ---
  SettingDataEntity toEntity() => SettingDataEntity(
    id: id ?? "",
    name: name ?? "",
    deposit: deposit?.toEntity(),
    withdraw: withdraw?.toEntity(),
    transfer: transfer?.toEntity(),
    betting: betting?.toEntity(),
    withdrawalOffDays: withdrawOffDay ?? {},
    rates: RatesEntity(
      main: (rates?['main'] as Map?)?.cast<String, String>() ?? {},
      starline: (rates?['starline'] as Map?)?.cast<String, String>() ?? {},
      galidisawar: (rates?['galidisawar'] as Map?)?.cast<String, String>() ?? {},
      roulette: (rates?['roulette'] as Map?)?.cast<String, String>() ?? {},
    ),
    featureFlags: FeatureFlagsEntity(
      withdrawOncePerDay: featureFlags?['withdraw_once_per_day'] ?? false,
    ),
    aviator: aviator?.toEntity(),
    merchantUpi: merchantUpi ?? "",
    merchantQrUpi: merchantQrUpi ?? "",
    withdrawOffText: withdrawOffText ?? "",
    withdrawText: "", // Map other fields if needed
    depositText: "",
    withdrawOpen: withdrawOpen ?? "",
    withdrawClose: withdrawClose ?? "",
    appLink: appLink ?? "",
    maintainence: maintainence ?? false,
    maintainenceMsg: maintainenceMsg ?? "",
    notificationConfig: notificationConfig?.toEntity(),
  );
}

// Model sub-classes with toEntity() helpers
class MinMaxModel {
  final int? min; final int? max;
  MinMaxModel({this.min, this.max});
  factory MinMaxModel.fromJson(Map<String, dynamic> json) => MinMaxModel(min: json.parse<int>('min'), max: json.parse<int>('max'));
  MinMaxEntity toEntity() => MinMaxEntity(min: min ?? 0, max: max ?? 0);
}

class AviatorModel {
  final bool? active; final bool? maintenance; final int? minBet; final int? maxBet;
  AviatorModel({this.active, this.maintenance, this.minBet, this.maxBet});
  factory AviatorModel.fromJson(Map<String, dynamic> json) => AviatorModel(
    active: json.parse<bool>('active'),
    maintenance: json.parse<bool>('maintenance'),
    minBet: json.parse<int>('minBet'),
    maxBet: json.parse<int>('maxBet'),
  );
  AviatorEntity toEntity() => AviatorEntity(active: active ?? false, maintenance: maintenance ?? false, minBet: minBet ?? 0, maxBet: maxBet ?? 0, );
}

class NotificationConfigModel {
  final Map<String, dynamic>? result;
  NotificationConfigModel({this.result});
  factory NotificationConfigModel.fromJson(Map<String, dynamic> json) => NotificationConfigModel(result: json['result_declared_notification']);
  NotificationConfigEntity toEntity() => NotificationConfigEntity(resultDeclared: _mapDetail(result));
  NotificationDetailEntity? _mapDetail(Map<String, dynamic>? m) => m == null ? null : NotificationDetailEntity(
      titleEnabled: m['title_enabled'] ?? false, titleText: m['title_text'] ?? "",
      messageEnabled: m['message_enabled'] ?? false, messageText: m['message_text'] ?? "",
  );
}