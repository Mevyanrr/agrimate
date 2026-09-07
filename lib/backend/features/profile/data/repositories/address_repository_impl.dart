import '../../../../core/errors/backend_exception.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/normalized_address.dart';
import '../../domain/repositories/address_repository.dart';
import '../services/address_ai_service.dart';

class AddressRepositoryImpl implements AddressRepository {
  const AddressRepositoryImpl(this._service);

  final AddressAiService _service;

  @override
  Future<Result<NormalizedAddress>> normalize(String address) async {
    try {
      return Success(await _service.parse(address));
    } on BackendException catch (error) {
      return Failure(error.message, code: error.code);
    } catch (error) {
      return Failure('Gagal memeriksa alamat: $error');
    }
  }
}
