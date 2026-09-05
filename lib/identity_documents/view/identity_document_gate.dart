import 'package:agrimate/backend/backend_dependencies.dart';
import 'package:agrimate/backend/core/result/result.dart';
import 'package:agrimate/backend/features/identity_verification/domain/entities/identity_verification.dart';
import 'package:agrimate/identity_documents/view/identity_document_upload.dart';
import 'package:agrimate/role_selection/model/role.dart';
import 'package:flutter/material.dart';

class IdentityDocumentGate extends StatefulWidget {
  const IdentityDocumentGate({
    super.key,
    required this.role,
    required this.child,
  });

  final UserRole role;
  final Widget child;

  @override
  State<IdentityDocumentGate> createState() => _IdentityDocumentGateState();
}

class _IdentityDocumentGateState extends State<IdentityDocumentGate> {
  late Future<Result<IdentityVerification?>> _documents;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _documents = BackendDependencies.create().identityVerificationRepository
        .getMine();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Result<IdentityVerification?>>(
      future: _documents,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return switch (snapshot.data!) {
          Failure(message: final message) => Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(message, textAlign: TextAlign.center),
              ),
            ),
          ),
          Success(data: final documents)
              when documents?.isComplete(
                    requiresNpwp: widget.role == UserRole.pembeli,
                  ) ??
                  false =>
            widget.child,
          Success() => IdentityDocumentUploadView(
            role: widget.role,
            onCompleted: () => setState(_reload),
          ),
        };
      },
    );
  }
}
