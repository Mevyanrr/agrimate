import 'package:agrimate/backend/backend_dependencies.dart';
import 'package:agrimate/role_selection/model/role.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthenticatedHomeView extends StatelessWidget {
  const AuthenticatedHomeView({super.key, required this.role});

  final UserRole role;

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final roleLabel = role == UserRole.petani ? 'Petani' : 'Pembeli';

    return Scaffold(
      appBar: AppBar(
        title: Text('Beranda $roleLabel'),
        actions: [
          IconButton(
            tooltip: 'Keluar',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await BackendDependencies.create().authRepository.signOut();
              if (!context.mounted) return;
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/role-selection',
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.verified_user_outlined, size: 64),
              const SizedBox(height: 16),
              Text(
                'Login berhasil sebagai $roleLabel',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                user?.phone ?? user?.email ?? '',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
