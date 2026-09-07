import 'package:agrimate/backend/backend_dependencies.dart';
import 'package:agrimate/backend/core/result/result.dart';
import 'package:agrimate/dashboard/viewmodel/dashboard_vm.dart';
import 'package:agrimate/demand/view/create_demand.dart';
import 'package:agrimate/role_selection/model/role.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthenticatedHomeView extends StatefulWidget {
  const AuthenticatedHomeView({super.key, required this.role});

  final UserRole role;

  @override
  State<AuthenticatedHomeView> createState() => _AuthenticatedHomeViewState();
}

class _AuthenticatedHomeViewState extends State<AuthenticatedHomeView> {
  Future<int> _unreadCount = Future.value(0);

  @override
  void initState() {
    super.initState();
    _refreshUnreadCount();
  }

  void _refreshUnreadCount() {
    _unreadCount = BackendDependencies.create().notifications
        .getUnreadCount()
        .then(
          (result) => switch (result) {
            Success(data: final count) => count,
            Failure() => 0,
          },
        );
  }

  @override
  Widget build(BuildContext context) {
    final roleLabel = widget.role == UserRole.petani ? 'Petani' : 'Pembeli';

    return Scaffold(
      appBar: AppBar(
        title: Text('Beranda $roleLabel'),
        actions: [
          FutureBuilder<int>(
            future: _unreadCount,
            builder: (context, snapshot) {
              final count = snapshot.data ?? 0;
              return Badge(
                isLabelVisible: count > 0,
                label: Text(count > 99 ? '99+' : '$count'),
                child: IconButton(
                  tooltip: 'Notifikasi',
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () async {
                    await Navigator.pushNamed(context, '/notifications');
                    if (!mounted) return;
                    setState(_refreshUnreadCount);
                  },
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'Riwayat',
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.pushNamed(
              context,
              '/history',
              arguments: widget.role,
            ),
          ),
          if (widget.role == UserRole.pembeli)
            IconButton(
              tooltip: 'Buat kebutuhan',
              icon: const Icon(Icons.add_shopping_cart_outlined),
              onPressed: () =>
                  Navigator.pushNamed(context, '/rencana-kebutuhan-baru'),
            ),
          IconButton(
            tooltip: 'Transaksi',
            icon: const Icon(Icons.receipt_long_outlined),
            onPressed: () => Navigator.pushNamed(
              context,
              '/transaksi',
              arguments: widget.role,
            ),
          ),
          IconButton(
            tooltip: 'Profil',
            icon: const Icon(Icons.person_outline),
            onPressed: () =>
                Navigator.pushNamed(context, '/profil', arguments: widget.role),
          ),
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
      body: _DashboardBody(role: widget.role),
      floatingActionButton: widget.role == UserRole.pembeli
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateDemandView()),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Tambah Kebutuhan'),
            )
          : null,
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({required this.role});
  final UserRole role;

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (_) => DashboardViewModel()..load(),
    child: Consumer<DashboardViewModel>(
      builder: (context, vm, _) {
        if (vm.isLoading && vm.summary == null) {
          return const Center(child: CircularProgressIndicator());
        }
        if (vm.summary == null) {
          return Center(
            child: Text(vm.errorMessage ?? 'Dashboard tidak tersedia'),
          );
        }
        final summary = vm.summary!;
        final commodity = vm.referenceCommodity;
        final isFarmer = role == UserRole.petani;
        return RefreshIndicator(
          onRefresh: vm.load,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: isFarmer
                        ? Colors.green.shade50
                        : Colors.orange.shade50,
                    child: vm.profile?.photoUrl == null
                        ? Icon(
                            Icons.person,
                            color: isFarmer ? Colors.green : Colors.orange,
                          )
                        : ClipOval(
                            child: Image.network(
                              vm.profile!.photoUrl!,
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Icon(
                                Icons.person,
                                color: isFarmer ? Colors.green : Colors.orange,
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Halo, ${vm.profile?.fullName.isNotEmpty == true ? vm.profile!.fullName : 'Pengguna'} 👋',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (commodity != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Harga Acuan Produsen'),
                        Text(
                          commodity.name,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text('${_rupiah(commodity.price)} / ${commodity.unit}'),
                        Text(
                          '${commodity.priceSourceName ?? commodity.source} • ${commodity.sourcePeriod ?? '-'}',
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.45,
                children: [
                  _Metric(
                    isFarmer ? 'Supply Aktif' : 'Demand Aktif',
                    '${summary.activeForecasts}',
                  ),
                  _Metric('Potensi Match', '${summary.potentialMatches}'),
                  _Metric('Transaksi', '${summary.transactions}'),
                  _Metric(
                    isFarmer ? 'Nilai Transaksi' : 'Total Pembelian',
                    _rupiah(summary.transactionValue),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Match Terbaru',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Card(
                child: ListTile(
                  title: Text(
                    vm.latestMatch == null
                        ? 'Belum ada match'
                        : 'Kecocokan baru',
                  ),
                  subtitle: vm.latestMatch == null
                      ? null
                      : Text(
                          '${vm.latestMatch!.data['matched_quantity'] ?? '-'} kg',
                        ),
                  trailing: vm.latestMatch == null
                      ? null
                      : Chip(
                          label: Text(
                            '${vm.latestMatch!.data['status'] ?? '-'}',
                          ),
                        ),
                ),
              ),
            ],
          ),
        );
      },
    ),
  );

  static String _rupiah(num value) {
    final digits = value.round().toString();
    return 'Rp${digits.replaceAllMapped(RegExp(r'(?=(\d{3})+(?!\d))'), (_) => '.')}';
  }
}

class _Metric extends StatelessWidget {
  const _Metric(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          Text(label, textAlign: TextAlign.center),
        ],
      ),
    ),
  );
}
