// import 'package:razorpay_flutter/razorpay_flutter.dart';
//
// /// Singleton service to manage Razorpay instance
// /// Prevents multiple instances that cause iOS 17.5.1 crashes
// class RazorpayService {
//   static RazorpayService? _instance;
//   static Razorpay? _razorpay;
//
//   // Private constructor
//   RazorpayService._();
//
//   /// Get singleton instance
//   static RazorpayService get instance {
//     _instance ??= RazorpayService._();
//     return _instance!;
//   }
//
//   /// Get or create Razorpay instance (only created once)
//   Razorpay get razorpay {
//     _razorpay ??= Razorpay();
//     return _razorpay!;
//   }
//
//   /// Dispose the Razorpay instance (call this when app is closing)
//   void dispose() {
//     _razorpay?.clear();
//     _razorpay = null;
//   }
//
//   /// Reset instance (use only in edge cases like logout)
//   void reset() {
//     _razorpay?.clear();
//     _razorpay = null;
//     _instance = null;
//   }
// }