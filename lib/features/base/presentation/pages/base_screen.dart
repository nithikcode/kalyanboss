import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kalyanboss/config/constants.dart';
import 'package:kalyanboss/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:kalyanboss/features/base/presentation/bloc/base_bloc.dart';
import 'package:kalyanboss/features/game/presentation/screens/bet_history_screen.dart';
import 'package:kalyanboss/features/game/presentation/screens/game_screen.dart';
import 'package:kalyanboss/features/game/presentation/screens/transaction_history_screen.dart';


class BaseScreen extends StatelessWidget {
  const BaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BaseBloc, BaseState>(
      builder: (context, baseState) {
        return Scaffold(
          // IndexedStack ensures initState() only runs ONCE per screen
          body: IndexedStack(
            index: baseState.currentIndex,
            children: [
              const TransactionHistoryScreen(),
              const BetHistoryScreen(),
              _buildHomeContent(context),
              const GameScreen(),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(

            selectedFontSize: 12,
            selectedItemColor: Colors.black,
            type: BottomNavigationBarType.fixed,
            currentIndex: baseState.currentIndex,
            onTap: (index) {

              context.read<BaseBloc>().add(TabChangedEvent(index));
            },
            items: [
              BottomNavigationBarItem(icon: SvgPicture.asset(AppLogos.transaction,), label: "Transactions"),
              BottomNavigationBarItem(icon: SvgPicture.asset(AppLogos.calendar), label: "Bet History"),
              BottomNavigationBarItem(icon: SvgPicture.asset(AppLogos.profile), label: "Profile"),
              BottomNavigationBarItem(icon: SvgPicture.asset(AppLogos.home), label: "Markets"),
            ],
          ),
        );
      },
    );
  }

  // Helper to keep the existing Auth/Profile logic
  Widget _buildHomeContent(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<AuthBloc>().add(FetchProfileEvent());
        await context.read<AuthBloc>().stream.firstWhere(
              (state) => state.userEntity?.maybeWhen(
            loading: () => false,
            orElse: () => true,
          ) ?? false,
        );
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          return state.userEntity!.when(
            initial: () => const Center(child: Text("Initializing...")),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (message, __) => _buildScrollableError(context, message),
            refreshing: (user) => _buildProfileUI(context, user),
            success: (user) {
              if (user.status == false) return _buildBlockedUI(context);
              return _buildProfileUI(context, user);
            },
          );
        },
      ),
    );
  }

  Widget _buildProfileUI(BuildContext context, dynamic user) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Welcome, ${user?.fullName ?? 'User'}", style: const TextStyle(fontSize: 20)),
              Text("Wallet: ₹${user?.wallet ?? '0'}", style: const TextStyle(fontSize: 18, color: Colors.green)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => context.read<AuthBloc>().add(LogoutEvent()),
                child: const Text("Logout"),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScrollableError(BuildContext context, String message) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.8,
          child: InkWell(
            onTap: () {
              context.read<AuthBloc>().add(LogoutEvent());
            },
              child: Center(child: Text("Error: $message"))),
        ),
      ],
    );
  }

  Widget _buildBlockedUI(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.8,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.block, color: Colors.red, size: 80),
                const SizedBox(height: 16),
                const Text("Account Deactivated", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const Text("Please contact support.", textAlign: TextAlign.center),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => context.read<AuthBloc>().add(LogoutEvent()),
                  child: const Text("Go to Login"),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}