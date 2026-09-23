import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

import '../config/environment/app_env.dart';

/// Résultat d'un upload d'image vers ImgBB.
///
/// Toujours instancié (jamais d'exception propagée) : [success] indique le
/// résultat, [url] contient l'URL publique ImgBB en cas de succès et [error]
/// un message français prêt à afficher en cas d'échec.
class ImageUploadResult {
  const ImageUploadResult.success({required this.url})
      : success = true,
        error = null;

  const ImageUploadResult.failure(this.error)
      : success = false,
        url = null;

  final bool success;
  final String? url;
  final String? error;
}

/// Service dédié à l'hébergement des images produits sur ImgBB.
///
/// Responsabilités :
/// - recevoir l'image (fichier ou octets) ;
/// - vérifier la configuration et la taille ;
/// - envoyer la requête multipart vers l'API ImgBB ;
/// - gérer timeout, erreurs réseau et réponses invalides ;
/// - renvoyer un [ImageUploadResult] exploitable (URL publique à stocker
///   dans le champ `imageUrl` de Firestore).
///
/// La clé API provient de la compilation (`--dart-define=IMGBB_API_KEY=...`)
/// via [AppEnv] — jamais écrite en dur. Un constructeur `apiKey`/`dio`
/// permet l'injection pour les tests.
class ImgbbService {
  ImgbbService({Dio? dio, String? apiKey})
      : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 15),
                sendTimeout: const Duration(seconds: 30),
                receiveTimeout: const Duration(seconds: 30),
              ),
            ),
        _apiKeyOverride = apiKey;

  static const String _uploadEndpoint = 'https://api.imgbb.com/1/upload';

  /// Limite prudente en dessous de la limite officielle d'ImgBB (32 Mo).
  static const int maxImageBytes = 16 * 1024 * 1024;

  final Dio _dio;
  final String? _apiKeyOverride;

  String get _apiKey => (_apiKeyOverride ?? AppEnv.imgbbApiKey).trim();

  /// `true` si une clé API est disponible (configuration de compilation).
  bool get isConfigured => _apiKey.isNotEmpty;

  /// Lit un fichier sélectionné ([XFile]) puis le téléverse.
  Future<ImageUploadResult> uploadImageFile(XFile file) async {
    final Uint8List bytes;
    try {
      bytes = await file.readAsBytes();
    } catch (_) {
      return const ImageUploadResult.failure(
        'Impossible de lire le fichier image sélectionné.',
      );
    }
    return uploadImageBytes(bytes, fileName: file.name);
  }

  /// Téléverse des octets d'image vers ImgBB.
  Future<ImageUploadResult> uploadImageBytes(
    Uint8List bytes, {
    required String fileName,
  }) async {
    if (!isConfigured) {
      return const ImageUploadResult.failure(
        'Clé API ImgBB non configurée. Relancez l\'application avec '
        '--dart-define=IMGBB_API_KEY=votre_cle (voir .env.example).',
      );
    }
    if (bytes.isEmpty) {
      return const ImageUploadResult.failure(
        'Le fichier image sélectionné est vide.',
      );
    }
    if (bytes.length > maxImageBytes) {
      return const ImageUploadResult.failure(
        'Image trop volumineuse (16 Mo maximum). Choisissez une image plus légère.',
      );
    }

    try {
      final FormData formData = FormData.fromMap(<String, dynamic>{
        'image': MultipartFile.fromBytes(bytes, filename: fileName),
      });

      final Response<Map<String, dynamic>> response =
          await _dio.post<Map<String, dynamic>>(
        _uploadEndpoint,
        queryParameters: <String, dynamic>{'key': _apiKey},
        data: formData,
      );

      return _parseResponse(response.data);
    } on DioException catch (error) {
      return _mapDioError(error);
    } catch (_) {
      return const ImageUploadResult.failure(
        'Une erreur inattendue est survenue pendant l\'envoi de l\'image. Réessayez.',
      );
    }
  }

  // ----------------------------------------------------------------- parsing

  /// Extrait l'URL publique de la réponse ImgBB : `display_url` (i.ibb.co)
  /// est prioritaire, avec repli sur `image.url` puis `url` (page ImgBB).
  ImageUploadResult _parseResponse(Map<String, dynamic>? body) {
    if (body == null) {
      return const ImageUploadResult.failure(
        'Réponse invalide reçue d\'ImgBB. Réessayez.',
      );
    }

    if (body['success'] == true) {
      final Object? data = body['data'];
      if (data is Map<String, dynamic>) {
        final Object? displayUrl = data['display_url'];
        if (displayUrl is String && displayUrl.isNotEmpty) {
          return ImageUploadResult.success(url: displayUrl);
        }
        final Object? image = data['image'];
        if (image is Map) {
          final Object? imageUrl = image['url'];
          if (imageUrl is String && imageUrl.isNotEmpty) {
            return ImageUploadResult.success(url: imageUrl);
          }
        }
        final Object? url = data['url'];
        if (url is String && url.isNotEmpty) {
          return ImageUploadResult.success(url: url);
        }
      }
      return const ImageUploadResult.failure(
        'Réponse ImgBB inattendue (URL introuvable). Réessayez.',
      );
    }

    final Object? error = body['error'];
    if (error is Map) {
      final Object? message = error['message'];
      if (message is String && message.isNotEmpty) {
        return ImageUploadResult.failure(
          'ImgBB a refusé l\'image : $message',
        );
      }
    }
    return const ImageUploadResult.failure(
      'ImgBB a refusé l\'envoi de l\'image. Réessayez.',
    );
  }

  /// Traduction des erreurs [DioException] en messages explicites.
  ImageUploadResult _mapDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ImageUploadResult.failure(
          'Délai dépassé lors de l\'envoi de l\'image. Vérifiez votre connexion puis réessayez.',
        );
      case DioExceptionType.connectionError:
        return const ImageUploadResult.failure(
          'Connexion internet indisponible. Vérifiez votre réseau puis réessayez.',
        );
      case DioExceptionType.badResponse:
        final Object? body = error.response?.data;
        if (body is Map<String, dynamic>) {
          // Laisse ImgBB expliquer le refus (clé invalide, fichier refusé...).
          return _parseResponse(body);
        }
        return ImageUploadResult.failure(
          'ImgBB a renvoyé une erreur (code ${error.response?.statusCode ?? 'inconnu'}).',
        );
      case DioExceptionType.cancel:
        return const ImageUploadResult.failure(
          'Envoi de l\'image annulé.',
        );
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return const ImageUploadResult.failure(
          'Impossible de joindre ImgBB. Vérifiez votre connexion puis réessayez.',
        );
      case DioExceptionType.transformTimeout:
        
        throw UnimplementedError();
    }
  }
}