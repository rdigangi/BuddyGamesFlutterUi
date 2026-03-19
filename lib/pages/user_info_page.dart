import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../services/auth_api_service.dart';

class UserInfoPage extends StatefulWidget {
  const UserInfoPage({super.key});

  @override
  State<UserInfoPage> createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  late Future<MeResult> _meFuture;
  String _preferredRole = 'Versatile';
  bool _isPreferencesSaved = false;
  bool _isUploadingProfileImage = false;
  String? _profileImageUrlOverride;

  @override
  void initState() {
    super.initState();
    _reloadMe();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Informazioni utente')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildProfileAvatar(),
              const SizedBox(height: 24),
              _buildAccordionSections(),
            ],
          ),
        ),
      ),
    );
  }

  void _reloadMe() {
    _meFuture = AuthApiService.instance.getMe();
  }

  Widget _buildProfileAvatar() {
    return FutureBuilder<MeResult>(
      future: _meFuture,
      builder: (context, snapshot) {
        final me = snapshot.data?.data;
        final avatarUrl = _profileImageUrlOverride ?? me?.profileImageUrl;

        return Center(
          child: Stack(
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(48),
                onTap: _isUploadingProfileImage ? null : _onAvatarTap,
                child: CircleAvatar(
                  radius: 48,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest,
                  backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty)
                      ? NetworkImage(avatarUrl)
                      : null,
                  child: (avatarUrl == null || avatarUrl.isEmpty)
                      ? const Icon(Icons.person_outline, size: 48)
                      : null,
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(6),
                  child: _isUploadingProfileImage
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        )
                      : Icon(
                          Icons.camera_alt_outlined,
                          color: Theme.of(context).colorScheme.onPrimary,
                          size: 16,
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _onAvatarTap() async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['jpg', 'jpeg', 'png', 'webp', 'gif'],
      withData: true,
    );

    if (!mounted || picked == null || picked.files.isEmpty) return;

    final file = picked.files.single;
    final bytes = file.bytes;
    if (bytes == null || bytes.isEmpty) {
      _showMessage('Impossibile leggere il file selezionato');
      return;
    }

    const maxSizeInBytes = 5 * 1024 * 1024;
    if (bytes.lengthInBytes > maxSizeInBytes) {
      _showMessage('File troppo grande: massimo 5MB');
      return;
    }

    final extension = _fileExtension(file.name);
    final mimeType = _mimeTypeFromExtension(extension);
    if (mimeType == null) {
      _showMessage('Formato non supportato. Usa JPEG, PNG, WEBP o GIF');
      return;
    }

    setState(() {
      _isUploadingProfileImage = true;
    });

    final uploadResult = await AuthApiService.instance.uploadProfileImage(
      bytes: bytes,
      fileName: file.name,
      mimeType: mimeType,
    );

    if (!mounted) return;

    setState(() {
      _isUploadingProfileImage = false;
      if (uploadResult.isSuccess) {
        _profileImageUrlOverride = uploadResult.profileImageUrl;
        _reloadMe();
      }
    });

    _showMessage(uploadResult.message);
  }

  String _fileExtension(String fileName) {
    final dotIndex = fileName.lastIndexOf('.');
    if (dotIndex < 0 || dotIndex == fileName.length - 1) return '';
    return fileName.substring(dotIndex + 1).toLowerCase();
  }

  String? _mimeTypeFromExtension(String extension) {
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'gif':
        return 'image/gif';
      default:
        return null;
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildAccordionSections() {
    return ExpansionPanelList.radio(
      expandedHeaderPadding: EdgeInsets.zero,
      initialOpenPanelValue: 1,
      children: [
        ExpansionPanelRadio(
          value: 1,
          headerBuilder: (context, isExpanded) {
            return const ListTile(title: Text('Informazioni di base'));
          },
          canTapOnHeader: true,
          body: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: FutureBuilder<MeResult>(
              future: _meFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final result = snapshot.data;
                if (result == null ||
                    !result.isSuccess ||
                    result.data == null) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      result?.message ?? 'Impossibile caricare i dati utente',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  );
                }

                final me = result.data!;
                return Column(
                  children: [
                    _buildInfoRow(label: 'Nome', value: me.nome),
                    const SizedBox(height: 10),
                    _buildInfoRow(label: 'Cognome', value: me.cognome),
                    const SizedBox(height: 10),
                    _buildInfoRow(label: 'Mail', value: me.email),
                  ],
                );
              },
            ),
          ),
        ),
        ExpansionPanelRadio(
          value: 2,
          headerBuilder: (context, isExpanded) {
            return const ListTile(title: Text('Preferenze'));
          },
          canTapOnHeader: true,
          body: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                Row(
                  children: [
                    const Expanded(
                      flex: 2,
                      child: Text(
                        'Ruolo preferito',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 5,
                      child: DropdownButtonFormField<String>(
                        initialValue: _preferredRole,
                        items: const [
                          DropdownMenuItem(
                            value: 'Difesa',
                            child: Text('Difesa'),
                          ),
                          DropdownMenuItem(
                            value: 'Attacco',
                            child: Text('Attacco'),
                          ),
                          DropdownMenuItem(
                            value: 'Versatile',
                            child: Text('Versatile'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            _preferredRole = value;
                            _isPreferencesSaved = false;
                          });
                        },
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton(
                    onPressed: () {
                      setState(() {
                        _isPreferencesSaved = true;
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Preferenze salvate (mock): ruolo $_preferredRole',
                          ),
                        ),
                      );
                    },
                    child: const Text('Salva'),
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: _isPreferencesSaved
                        ? Row(
                            key: const ValueKey('saved-state'),
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: 18,
                                color: Theme.of(context).colorScheme.tertiary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Preferenze salvate',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.tertiary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          )
                        : const SizedBox(key: ValueKey('saved-state-empty')),
                  ),
                ),
              ],
            ),
          ),
        ),
        ExpansionPanelRadio(
          value: 3,
          headerBuilder: (context, isExpanded) {
            return const ListTile(title: Text('Statistiche'));
          },
          canTapOnHeader: true,
          body: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Text box',
                hintText: 'Placeholder sezione 3',
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow({required String label, required String value}) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 5,
          child: TextFormField(
            initialValue: value,
            enabled: false,
            readOnly: true,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
        ),
      ],
    );
  }
}
