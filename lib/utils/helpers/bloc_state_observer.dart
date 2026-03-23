import 'package:flutter_bloc/flutter_bloc.dart';

import 'helpers.dart';

class BlocStateObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    createLog('Bloc: ${bloc.runtimeType}, Change: $change');
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    createLog('Bloc: ${bloc.runtimeType}, Transition: $transition');
  }
}
