import 'package:resqpet/di/repositories.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'logout_controller.g.dart';

@riverpod
class LogoutController extends _$LogoutController {

  @override
  bool build() {
    return true;
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider)
      .logout();
  }
}