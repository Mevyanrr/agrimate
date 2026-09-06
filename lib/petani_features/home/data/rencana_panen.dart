
abstract class RencanaRepository {
  Future<bool> saveDraft(Map<String, dynamic> data);

  Future<bool> submitRencana(Map<String, dynamic> data);
}

class RencanaRepositoryImpl implements RencanaRepository {
  @override
  Future<bool> saveDraft(Map<String, dynamic> data) async {

    await Future.delayed(const Duration(milliseconds: 250));
    return true;
  }

  @override
  Future<bool> submitRencana(Map<String, dynamic> data) async {

    await Future.delayed(const Duration(milliseconds: 600));
    return true;
  }
}