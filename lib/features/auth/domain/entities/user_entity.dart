import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
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
  final DateTime? transactionBlockedUntil;
  final bool transactionPermanentlyBlocked;
  final bool chatBlocked;
  final int coins;
  final DateTime? lastCoinRefill;
  final int spinAttempts;
  final DateTime? lastSpinRefill;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool authentication;
  final DateTime? lastLogin;

  const UserEntity({
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

  @override
  List<Object?> get props => [id, mobile, token, wallet, coins, otpVerified, lastLogin, wallet, bankName];
}