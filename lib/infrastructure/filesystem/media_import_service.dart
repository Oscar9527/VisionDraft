import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class MediaImportService {
  const MediaImportService();

  static const _imageTypeGroup = XTypeGroup(
    label: 'images',
    extensions: ['png', 'jpg', 'jpeg', 'webp', 'bmp'],
  );
  static const _textTypeGroup = XTypeGroup(
    label: 'script_text',
    extensions: ['txt', 'md'],
  );
  static const _archiveTypeGroup = XTypeGroup(
    label: 'visiondraft_archive',
    extensions: ['zip', 'vdraftzip'],
  );

  Future<String?> pickImageFile() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final picker = ImagePicker();
      final file = await picker.pickImage(source: ImageSource.gallery);
      return file?.path;
    }

    final file = await openFile(
      acceptedTypeGroups: const [_imageTypeGroup],
      confirmButtonText: '选择图片',
    );
    return file?.path;
  }

  Future<String?> pickTextFile() async {
    final file = await openFile(
      acceptedTypeGroups: const [_textTypeGroup],
      confirmButtonText: '选择文本',
    );
    return file?.path;
  }

  Future<String?> pickProjectArchive() async {
    final file = await openFile(
      acceptedTypeGroups: const [_archiveTypeGroup],
      confirmButtonText: '选择项目包',
    );
    return file?.path;
  }

  Future<File?> fileFromPath(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      return null;
    }
    return file;
  }
}
