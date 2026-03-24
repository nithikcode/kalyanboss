import 'package:kalyanboss/features/auth/domain/entities/user_entity.dart';
import 'package:kalyanboss/utils/helpers/customJsonParser.dart';
class UserModel {
  final String id;
  final String userName;
  final String fullName;
  final String city;
  final String state;
  final String language;
  final String mobile;
  final int wallet;
  final bool verified;
  final bool otpVerified;
  final String token;
  final bool status;
  final bool isShow;
  final String branchName;
  final String bankName;
  final String accountHolderName;
  final String accountNo;
  final String ifscCode;
  final String referralCode;
  final String upiId;
  final String upiNumber;
  final bool betting;
  final bool transfer;
  final String fcm;
  final bool personalNotification;
  final bool mainNotification;
  final bool starlineNotification;
  final bool galidisawarNotification;
  final String? transactionBlockedUntil;
  final bool transactionPermanentlyBlocked;
  final bool chatBlocked;
  final int coins;
  final String? lastCoinRefill;
  final int spinAttempts;
  final String? lastSpinRefill;
  final String? createdAt;
  final String? updatedAt;
  final bool authentication;
  final String? lastLogin;

  UserModel({
    required this.id, required this.userName, required this.fullName, required this.city,
    required this.state, required this.language, required this.mobile, required this.wallet,
    required this.verified, required this.otpVerified, required this.token, required this.status,
    required this.isShow, required this.branchName, required this.bankName, required this.accountHolderName,
    required this.accountNo, required this.ifscCode, required this.referralCode, required this.upiId,
    required this.upiNumber, required this.betting, required this.transfer, required this.fcm,
    required this.personalNotification, required this.mainNotification, required this.starlineNotification,
    required this.galidisawarNotification, this.transactionBlockedUntil, required this.transactionPermanentlyBlocked,
    required this.chatBlocked, required this.coins, this.lastCoinRefill, required this.spinAttempts,
    this.lastSpinRefill, this.createdAt, this.updatedAt, required this.authentication, this.lastLogin,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json.parse<String>('_id') ?? '',
      userName: json.parse<String>('user_name') ?? '',
      fullName: json.parse<String>('full_name') ?? '',
      city: json.parse<String>('city') ?? '',
      state: json.parse<String>('state') ?? '',
      language: json.parse<String>('language') ?? 'en',
      mobile: json.parse<String>('mobile') ?? '',
      wallet: json.parse<int>('wallet') ?? 0,
      verified: json.parse<bool>('verified') ?? false,
      otpVerified: json.parse<bool>('otp_verified') ?? false,
      token: json.parse<String>('token') ?? '',
      status: json.parse<bool>('status') ?? false,
      isShow: json.parse<bool>('is_show') ?? false,
      branchName: json.parse<String>('branch_name') ?? '',
      bankName: json.parse<String>('bank_name') ?? '',
      accountHolderName: json.parse<String>('account_holder_name') ?? '',
      accountNo: json.parse<String>('account_no') ?? '',
      ifscCode: json.parse<String>('ifsc_code') ?? '',
      referralCode: json.parse<String>('referral_code') ?? '',
      upiId: json.parse<String>('upi_id') ?? '',
      upiNumber: json.parse<String>('upi_number') ?? '',
      betting: json.parse<bool>('betting') ?? false,
      transfer: json.parse<bool>('transfer') ?? false,
      fcm: json.parse<String>('fcm') ?? '',
      personalNotification: json.parse<bool>('personal_notification') ?? false,
      mainNotification: json.parse<bool>('main_notification') ?? false,
      starlineNotification: json.parse<bool>('starline_notification') ?? false,
      galidisawarNotification: json.parse<bool>('galidisawar_notification') ?? false,
      transactionBlockedUntil: json.parse<String>('transaction_blocked_until'),
      transactionPermanentlyBlocked: json.parse<bool>('transaction_permanently_blocked') ?? false,
      chatBlocked: json.parse<bool>('chat_blocked') ?? false,
      coins: json.parse<int>('coins') ?? 0,
      lastCoinRefill: json.parse<String>('last_coin_refill'),
      spinAttempts: json.parse<int>('spin_attempts') ?? 0,
      lastSpinRefill: json.parse<String>('last_spin_refill'),
      createdAt: json.parse<String>('createdAt'),
      updatedAt: json.parse<String>('updatedAt'),
      authentication: json.parse<bool>('authentication') ?? false,
      lastLogin: json.parse<String>('last_login'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user_name': userName,
      'full_name': fullName,
      'city': city,
      'state': state,
      'language': language,
      'mobile': mobile,
      'wallet': wallet,
      'verified': verified,
      'otp_verified': otpVerified,
      'token': token,
      'status': status,
      'is_show': isShow,
      'branch_name': branchName,
      'bank_name': bankName,
      'account_holder_name': accountHolderName,
      'account_no': accountNo,
      'ifsc_code': ifscCode,
      'referral_code': referralCode,
      'upi_id': upiId,
      'upi_number': upiNumber,
      'betting': betting,
      'transfer': transfer,
      'fcm': fcm,
      'personal_notification': personalNotification,
      'main_notification': mainNotification,
      'starline_notification': starlineNotification,
      'galidisawar_notification': galidisawarNotification,
      'transaction_blocked_until': transactionBlockedUntil,
      'transaction_permanently_blocked': transactionPermanentlyBlocked,
      'chat_blocked': chatBlocked,
      'coins': coins,
      'last_coin_refill': lastCoinRefill,
      'spin_attempts': spinAttempts,
      'last_spin_refill': lastSpinRefill,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'authentication': authentication,
      'last_login': lastLogin,
    };
  }
}

extension UserModelMapper on UserModel {
  UserEntity toEntity() {
    return UserEntity(
      id: id,
      userName: userName,
      fullName: fullName,
      city: city,
      state: state,
      language: language,
      mobile: mobile,
      wallet: wallet,
      verified: verified,
      otpVerified: otpVerified,
      token: token,
      status: status,
      isShow: isShow,
      branchName: branchName,
      bankName: bankName,
      accountHolderName: accountHolderName,
      accountNo: accountNo,
      ifscCode: ifscCode,
      referralCode: referralCode,
      upiId: upiId,
      upiNumber: upiNumber,
      betting: betting,
      transfer: transfer,
      fcm: fcm,
      personalNotification: personalNotification,
      mainNotification: mainNotification,
      starlineNotification: starlineNotification,
      galidisawarNotification: galidisawarNotification,
      transactionBlockedUntil: transactionBlockedUntil != null ? DateTime.tryParse(transactionBlockedUntil!) : null,
      transactionPermanentlyBlocked: transactionPermanentlyBlocked,
      chatBlocked: chatBlocked,
      coins: coins,
      lastCoinRefill: lastCoinRefill != null ? DateTime.tryParse(lastCoinRefill!) : null,
      spinAttempts: spinAttempts,
      lastSpinRefill: lastSpinRefill != null ? DateTime.tryParse(lastSpinRefill!) : null,
      createdAt: createdAt != null ? DateTime.tryParse(createdAt!) : null,
      updatedAt: updatedAt != null ? DateTime.tryParse(updatedAt!) : null,
      authentication: authentication,
      lastLogin: lastLogin != null ? DateTime.tryParse(lastLogin!) : null,
    );
  }
}