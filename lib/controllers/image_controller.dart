import 'package:resqpet/di/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'image_controller.g.dart';

@riverpod
Future<List<String>> getImagesFromCloud(Ref ref, List<String> paths) async {
  final storageService = ref.read(cloudStorageServiceProvider);

  final List<String> urls = [];

  try {
    for(final path in paths) {
      urls.add(await storageService.getDownloadURL(path));
    }
  } catch(_) { }

  return urls;
}