import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../utils/helpers/app_route_observer.dart';
import '../utils/helpers/helpers.dart';
import '../utils/widgets/custom_dialog.dart';

typedef VoidCallback = void Function(ConnectivityResult status);





class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  final List<void Function(ConnectivityResult status)> _onStatusChanged = [];

  ConnectivityResult _lastStatus = ConnectivityResult.none;
  ConnectivityResult get lastStatus => _lastStatus;

  bool _isDialogVisible = false;

  /// Initialize connectivity listener
  void initialize() {
    createLog("[ConnectivityService] Initializing connectivity listener...");

    _subscription ??= _connectivity.onConnectivityChanged.listen((statusList) {
      final status = statusList.isNotEmpty ? statusList.first : ConnectivityResult.none;
      createLog("[ConnectivityService] Connectivity changed: $status");

      final prevStatus = _lastStatus;
      _lastStatus = status;

      if (status == ConnectivityResult.none) {
        createLog("[ConnectivityService] No Internet detected, showing dialog...");
        _showNoInternetDialog();
      } else if (prevStatus == ConnectivityResult.none && status != ConnectivityResult.none) {
        createLog("[ConnectivityService] Internet restored, hiding dialog...");
        _hideNoInternetDialog();
        // Fluttertoast.showToast(msg: "✅ Internet Restored");
      }

      // Notify all registered listeners
      for (var callback in _onStatusChanged) {
        try {
          callback(status);
        } catch (e, st) {
          createLog("[ConnectivityService] Error in listener: $e\n$st");
        }
      }
    });
  }

  /// Show dialog on current route
  void _showNoInternetDialog() {
    if (_isDialogVisible) {
      createLog("[ConnectivityService] Dialog already visible, skipping.");
      return;
    }

    final currentContext = appRouteObserver.navigator?.context;
    createLog("[ConnectivityService] Current route context: $currentContext");

    if (currentContext == null) {
      createLog("[ConnectivityService] Context is null, cannot show dialog.");
      return;
    }

    _isDialogVisible = true;

    showDialog(
      context: currentContext,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (ctx) {
        createLog("[ConnectivityService] Showing No Internet dialog.");
       return CustomAlertDialog(


          title: 'No Internet',

          actions: [
            TextButton(
              onPressed: () {
                // initialize();
                Navigator.pop(currentContext);
              },
              child: const Text("Retry"),
            ),
          ],

          parentContext: currentContext,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min, // Essential for Column inside AlertDialog
              children: [
                // Reduce animation height slightly to save space
                Lottie.asset('assets/lotties/no_internet.json', height: 180),
                const SizedBox(height: 10),
                const Text(
                  "Please check your internet connection and try again.",
                  textAlign: TextAlign.center,
                )
              ],
            ),
          ),
        );
      },
    );
  }

  /// Hide dialog on current route
  void _hideNoInternetDialog() {
    if (!_isDialogVisible) {
      createLog("[ConnectivityService] Dialog not visible, nothing to hide.");
      return;
    }

    final currentContext = appRouteObserver.navigator?.context;
    createLog("[ConnectivityService] Current route context for hiding: $currentContext");

    if (currentContext != null) {
      if (Navigator.canPop(currentContext)) {
        Navigator.of(currentContext, rootNavigator: true).pop();
        createLog("[ConnectivityService] Dialog hidden successfully.");
      }
    }

    _isDialogVisible = false;
  }


  /// Register a callback when connectivity changes
  void addStatusListener(void Function(ConnectivityResult status) callback) {
    _onStatusChanged.add(callback);
    createLog("[ConnectivityService] Listener added. Total: ${_onStatusChanged.length}");
  }

  /// Remove a registered callback
  void removeStatusListener(void Function(ConnectivityResult status) callback) {
    _onStatusChanged.remove(callback);
    createLog("[ConnectivityService] Listener removed. Total: ${_onStatusChanged.length}");
  }

  /// Dispose subscription
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    createLog("[ConnectivityService] Subscription disposed.");
  }
}




