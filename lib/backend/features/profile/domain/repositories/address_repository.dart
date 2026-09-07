import '../../../../core/result/result.dart';
import '../entities/normalized_address.dart';

abstract interface class AddressRepository {
  Future<Result<NormalizedAddress>> normalize(String address);
}
