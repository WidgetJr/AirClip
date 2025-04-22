// Flutter SDK
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Flutter packages
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:image_clipboard/image_clipboard.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Internal app imports
import 'package:airclip/utils/clipboard_utils.dart';
import 'package:airclip/services/clipboard_service.dart';
import 'package:airclip/services/clipboard_watcher.dart';
import 'package:airclip/services/device_service.dart';
import 'package:airclip/viewmodels/clipboard_history_viewmodel.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  ClipboardService? _clipboardService;
  ClipboardWatcher? _clipboardWatcher;

  @override
  void initState() {
    super.initState();
    final user = Supabase.instance.client.auth.currentUser;
    final historyVM = context.read<ClipboardHistoryViewModel>();

    historyVM.loadHistory();

    if (user != null) {
      DeviceIdService.getDeviceId().then((deviceId) {
        _clipboardService = ClipboardService(
          deviceId: deviceId,
          userId: user.id,
        );

        _clipboardService!.init().then((_) {
          _clipboardService!.clipStream.listen((remoteData) async {
            try {
              if (remoteData.startsWith('[img]')) {
                final imageUrl = remoteData.substring(5);

                try {
                  final file = await downloadImageToTempFile(imageUrl);
                  await copyImageToClipboard(file);

                  historyVM.addEntry(imageUrl, isImage: true);

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Image synced to clipboard'),
                      ),
                    );
                  }
                } catch (e) {
                  print('Error processing synced image: $e');
                  historyVM.setError('Error pasting synced image: $e');
                }
              } else {
                await Clipboard.setData(ClipboardData(text: remoteData));
                historyVM.addEntry(remoteData, isImage: false);

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Text synced to clipboard')),
                  );
                }
              }
            } catch (e) {
              historyVM.setError('Clipboard error: $e');
            }
          });
        });

        _clipboardWatcher = ClipboardWatcher(
          onTextChange: (copiedText) {
            _clipboardService!.sendClip(copiedText);
          },
          onImagePaste: (imageFile) {
            _clipboardService!.sendImage(imageFile);
          },
        );

        _clipboardWatcher!.start();
      });
    }
  }

  @override
  void dispose() {
    _clipboardWatcher?.stop();
    _clipboardService?.dispose();
    super.dispose();
  }

  void _signOut() async {
    await Supabase.instance.client.auth.signOut();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final fullName = user?.userMetadata?['full_name'] ?? 'Welcome!';
    final historyVM = context.watch<ClipboardHistoryViewModel>();
    final clipboardHistory = historyVM.clipboardHistory;
    final error = historyVM.error;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF0B0E1A),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'AirClip',
                          style: TextStyle(
                            fontSize: 30,
                            color: Color(0xFF00E5FF),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'BETA',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      fullName,
                      style: const TextStyle(
                        fontSize: 18,
                        height: 1.3,
                        color: Colors.white70,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.logout),
                  tooltip: 'Log out',
                  onPressed: _signOut,
                  color: Colors.red,
                ),
              ],
            ),
          ),
        ),
      ),

      body: Column(
        children: [
          if (error != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                error,
                style: const TextStyle(color: Colors.redAccent),
              ),
            ),
          Expanded(
            child:
                clipboardHistory.isEmpty
                    ? const Center(
                      child: Text(
                        'Clipboard history will appear here...',
                        style: TextStyle(fontSize: 18, color: Colors.white54),
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: clipboardHistory.length,
                      itemBuilder: (context, index) {
                        final entry = clipboardHistory[index];
                        final isImage = entry.isImage;
                        final content = entry.content;

                        final preview =
                            !isImage && content.length > 40
                                ? '${content.substring(0, 40)}...'
                                : content;

                        return Card(
                          color: const Color(0xFF0B0E1A),
                          child: ExpansionTile(
                            title: Row(
                              children: [
                                Icon(
                                  isImage ? Icons.image : Icons.content_copy,
                                  color: const Color(0xFF00E5FF),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    preview,
                                    style: const TextStyle(color: Colors.white),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (isImage)
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          content,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  const Text(
                                                    'Error loading image',
                                                    style: TextStyle(
                                                      color: Colors.redAccent,
                                                    ),
                                                  ),
                                        ),
                                      )
                                    else
                                      Text(
                                        content,
                                        style: const TextStyle(
                                          color: Colors.white70,
                                        ),
                                      ),
                                    const SizedBox(height: 8),

                                    if (isImage)
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: ElevatedButton.icon(
                                          icon: const Icon(Icons.paste),
                                          label: const Text(
                                            'Copy Image into Clipboard',
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(
                                              0xFF00E5FF,
                                            ),
                                            foregroundColor: Colors.black,
                                          ),
                                          onPressed: () async {
                                            try {
                                              final response = await http.get(
                                                Uri.parse(content),
                                              );
                                              final tempDir =
                                                  await getTemporaryDirectory();
                                              final file = File(
                                                '${tempDir.path}/manual_clip.png',
                                              );
                                              await file.writeAsBytes(
                                                response.bodyBytes,
                                              );

                                              final imageClipboard =
                                                  ImageClipboard();
                                              await imageClipboard.copyImage(
                                                file.path,
                                              );

                                              if (context.mounted) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'Image copied to clipboard',
                                                    ),
                                                  ),
                                                );
                                              }
                                            } catch (e) {
                                              print('Error copyng image: $e');
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'Error copying image',
                                                    ),
                                                  ),
                                                );
                                              }
                                            }
                                          },
                                        ),
                                      ),

                                    const SizedBox(height: 8),

                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFF00E5FF,
                                          ),
                                          foregroundColor: Colors.black,
                                        ),
                                        icon: const Icon(Icons.copy),
                                        label: const Text('Copy'),
                                        onPressed: () async {
                                          await Clipboard.setData(
                                            ClipboardData(text: content),
                                          );
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  isImage
                                                      ? 'Image copied to clipboard'
                                                      : 'Text copied to clipboard',
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
