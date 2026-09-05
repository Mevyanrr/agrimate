import 'package:agrimate/backend/backend_dependencies.dart';
import 'package:agrimate/backend/core/result/result.dart';
import 'package:agrimate/role_selection/model/role.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class IdentityDocumentUploadView extends StatefulWidget {
  const IdentityDocumentUploadView({
    super.key,
    required this.role,
    required this.onCompleted,
  });

  final UserRole role;
  final VoidCallback onCompleted;

  @override
  State<IdentityDocumentUploadView> createState() =>
      _IdentityDocumentUploadViewState();
}

class _IdentityDocumentUploadViewState
    extends State<IdentityDocumentUploadView> {
  PlatformFile? _ktp;
  PlatformFile? _npwp;
  bool _isLoading = false;

  bool get _requiresNpwp => widget.role == UserRole.pembeli;

  Future<void> _pick({required bool isKtp}) async {
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: const ['jpg', 'jpeg', 'png', 'pdf'],
    );
    if (file == null || !mounted) return;
    setState(() => isKtp ? _ktp = file : _npwp = file);
  }

  Future<void> _submit() async {
    if (_ktp == null) {
      _showError('KTP wajib diunggah.');
      return;
    }
    if (_requiresNpwp && _npwp == null) {
      _showError('NPWP wajib diunggah untuk pembeli.');
      return;
    }

    setState(() => _isLoading = true);
    final repository =
        BackendDependencies.create().identityVerificationRepository;
    final ktpBytes = await _ktp!.readAsBytes();
    final result = _requiresNpwp
        ? await repository.submitBuyer(
            ktpBytes: ktpBytes,
            ktpFileName: _ktp!.name,
            npwpBytes: await _npwp!.readAsBytes(),
            npwpFileName: _npwp!.name,
          )
        : await repository.submitFarmer(
            ktpBytes: ktpBytes,
            ktpFileName: _ktp!.name,
          );

    if (!mounted) return;
    setState(() => _isLoading = false);
    switch (result) {
      case Success():
        widget.onCompleted();
      case Failure(message: final message):
        _showError(message);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dokumen Identitas')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Unggah dokumen sebelum menggunakan fitur transaksi Agrimate.',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 24),
          _DocumentPicker(
            label: 'KTP (wajib)',
            fileName: _ktp?.name,
            onPressed: () => _pick(isKtp: true),
          ),
          const SizedBox(height: 16),
          _DocumentPicker(
            label: _requiresNpwp ? 'NPWP (wajib)' : 'NPWP (opsional)',
            fileName: _npwp?.name,
            onPressed: () => _pick(isKtp: false),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _isLoading ? null : _submit,
            child: _isLoading
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Simpan dan Lanjutkan'),
          ),
          const SizedBox(height: 12),
          const Text(
            'Format: JPG, PNG, atau PDF. Dokumen hanya digunakan sebagai persyaratan onboarding.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _DocumentPicker extends StatelessWidget {
  const _DocumentPicker({
    required this.label,
    required this.fileName,
    required this.onPressed,
  });

  final String label;
  final String? fileName;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.upload_file),
      label: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(fileName == null ? label : '$label\n$fileName'),
      ),
    );
  }
}
