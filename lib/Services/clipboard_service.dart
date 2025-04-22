// Dart core
import 'dart:async';
import 'dart:io';

// External packages
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class ClipboardService {
  final SupabaseClient _client;
  final String deviceId;
  final String userId;

  late final RealtimeChannel _channel;
  final _clipStreamController = StreamController<String>.broadcast();
  Stream<String> get clipStream => _clipStreamController.stream;

  ClipboardService({
    required this.deviceId,
    required this.userId,
    SupabaseClient? client,
  }) : _client = client ?? Supabase.instance.client;

  Future<void> init() async {
    _channel =
        _client.channel('public:clipboard')
          ..onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'clipboard',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'user_id',
              value: userId,
            ),
            callback: (payload) {
              final newRow = payload.newRecord;
              if (newRow['device_id'] != deviceId) {
                final content = newRow['content'] as String?;
                if (content != null) {
                  _clipStreamController.add(content);
                }
              }
            },
          )
          ..subscribe();
  }

  Future<void> sendClip(String content) async {
    await _client.from('clipboard').insert({
      'user_id': userId,
      'device_id': deviceId,
      'content': content,
      'timestamp': DateTime.now().toUtc().toIso8601String(),
    });
  }

  Future<void> sendImage(File imageFile) async {
    final fileName = '${const Uuid().v4()}.png';

    await _client.storage
        .from('images')
        .upload('clipboard/$fileName', imageFile);

    final signedUrl = _client.storage
        .from('images')
        .getPublicUrl('clipboard/$fileName');

    await sendClip('[img]$signedUrl');
  }

  void dispose() {
    _client.removeChannel(_channel);
    _clipStreamController.close();
  }
}
