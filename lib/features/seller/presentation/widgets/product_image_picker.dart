import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:taillorbook/app/theme/app_colors.dart';

import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/constants/app_enums.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../services/imgbb_service.dart';
import '../../../../state/seller/seller_providers.dart';

/// Sélecteur d'image produit : choix galerie/caméra, prévisualisation locale,
/// upload immédiat vers ImgBB avec retour visuel, badge de succès et erreur
/// réessayable. Notifie le parent avec l'URL publique ([onUploaded]).
///
/// En mode édition, [initialUrl] affiche l'image existante (elle est
/// remplacée dès qu'une nouvelle image est téléversée).
class ProductImagePicker extends ConsumerStatefulWidget {
  const ProductImagePicker({
    super.key,
    required this.onUploaded,
    this.initialUrl,
  });

  /// Appelé avec l'URL ImgBB publique après un upload réussi.
  final ValueChanged<String> onUploaded;

  /// Image existante (édition d'un produit).
  final String? initialUrl;

  @override
  ConsumerState<ProductImagePicker> createState() => _ProductImagePickerState();
}

class _ProductImagePickerState extends ConsumerState<ProductImagePicker> {
  Uint8List? _previewBytes;
  String? _uploadedUrl;
  bool _uploading = false;
  String? _error;

  bool get _hasExistingImage =>
      _uploadedUrl != null ||
      (_previewBytes == null && (widget.initialUrl?.isNotEmpty ?? false));

  Future<void> _pick(ImageSource source) async {
    if (_uploading) return;
    setState(() => _error = null);

    final XFile? picked;
    try {
      picked = await ImagePicker().pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1600,
      );
    } catch (_) {
      if (!mounted) return;
      context.showAppSnack(
        "Impossible d'accéder à la galerie ou à la caméra.",
        AppSnackType.error,
      );
      return;
    }
    if (picked == null) return;

    final Uint8List bytes;
    try {
      bytes = await picked.readAsBytes();
    } catch (_) {
      if (!mounted) return;
      context.showAppSnack(
        'Impossible de lire le fichier image sélectionné.',
        AppSnackType.error,
      );
      return;
    }

    setState(() {
      _previewBytes = bytes;
      _uploadedUrl = null;
      _uploading = true;
    });

    final ImageUploadResult result = await ref
        .read(imgbbServiceProvider)
        .uploadImageBytes(bytes, fileName: picked.name);

    if (!mounted) return;

    if (result.success && result.url != null) {
      setState(() {
        _uploading = false;
        _uploadedUrl = result.url;
      });
      widget.onUploaded(result.url!);
      context.showAppSnack('Image envoyée avec succès.', AppSnackType.success);
    } else {
      setState(() {
        _uploading = false;
        _error = result.error ?? "Échec de l'envoi de l'image.";
      });
      context.showAppSnack(_error!, AppSnackType.error);
    }
  }

  void _showSourceChoice() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const SizedBox(height: AppSpacing.sm),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Choisir dans la galerie'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _pick(ImageSource.gallery);
                },
              ),
              if (!kIsWeb)
                ListTile(
                  leading: const Icon(Icons.photo_camera_outlined),
                  title: const Text('Prendre une photo'),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _pick(ImageSource.camera);
                  },
                ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = context.appColorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Photo du produit', style: AppTypography.titleMedium()),
        const SizedBox(height: 6),
        Text(
          'Ajoutez une image claire (16 Mo maximum). '
          "L'image est hébergée sur ImgBB.",
          style: AppTypography.bodySmall(),
        ),
        const SizedBox(height: AppSpacing.md),
        AspectRatio(
          aspectRatio: 4 / 3,
          child: InkWell(
            onTap: _uploading ? null : _showSourceChoice,
            borderRadius: AppRadius.rLg,
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: AppRadius.rLg,
                border: Border.all(
                  color: _error != null ? colorScheme.error : colorScheme.outline,
                  width: _error != null ? 1.5 : 1,
                ),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  if (_previewBytes != null)
                    Image.memory(_previewBytes!, fit: BoxFit.cover)
                  else if (_hasExistingImage)
                    CachedNetworkImage(
                      imageUrl: _uploadedUrl ?? widget.initialUrl!,
                      fit: BoxFit.cover,
                      placeholder: (BuildContext context, String url) =>
                          const Center(
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.2),
                        ),
                      ),
                      errorWidget:
                          (BuildContext context, String url, Object error) =>
                              const _PickerPlaceholder(),
                    )
                  else
                    const _PickerPlaceholder(),
                  if (_uploading)
                    Container(
                      color: Colors.black38,
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          const SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.6,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Envoi vers ImgBB…',
                            style: AppTypography.titleSmall(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  if (!_uploading && _uploadedUrl != null)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  if (!_uploading && _hasExistingImage)
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: AppRadius.rFull,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            const Icon(
                              Icons.swap_horiz_rounded,
                              size: 15,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'Remplacer',
                              style: AppTypography.labelSmall(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        if (_error != null) ...<Widget>[
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: <Widget>[
              Icon(Icons.error_outline_rounded, size: 17, color: colorScheme.error),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _error!,
                  style: AppTypography.labelMedium(color: colorScheme.error),
                ),
              ),
              TextButton(
                onPressed: _uploading ? null : _showSourceChoice,
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

/// Contenu par défaut du cadre (aucune image sélectionnée).
class _PickerPlaceholder extends StatelessWidget {
  const _PickerPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 54,
            height: 54,
            decoration: const BoxDecoration(
              color: AppColors.primarySoft,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.add_a_photo_outlined,
              size: 26,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Ajouter une photo',
            style: AppTypography.titleSmall(color: AppColors.primary),
          ),
          const SizedBox(height: 2),
          Text(
            "Touchez pour choisir une image",
            style: AppTypography.labelSmall(),
          ),
        ],
      ),
    );
  }
}