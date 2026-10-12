enum SyncOperation {
  create,
  update,
  delete,
}

enum SyncStatus {
  pending,
  syncing,
  synced,
  failed,
}

class SyncOutboxItem {
  final String id;
  final String entityType; // 'book', 'session', 'note'
  final String entityId;
  final SyncOperation operation;
  final String payloadJson;
  final int retryCount;
  final SyncStatus status;
  final String? lastError;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SyncOutboxItem({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.operation,
    required this.payloadJson,
    this.retryCount = 0,
    this.status = SyncStatus.pending,
    this.lastError,
    required this.createdAt,
    required this.updatedAt,
  });

  SyncOutboxItem copyWith({
    String? id,
    String? entityType,
    String? entityId,
    SyncOperation? operation,
    String? payloadJson,
    int? retryCount,
    SyncStatus? status,
    String? lastError,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SyncOutboxItem(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      operation: operation ?? this.operation,
      payloadJson: payloadJson ?? this.payloadJson,
      retryCount: retryCount ?? this.retryCount,
      status: status ?? this.status,
      lastError: lastError ?? this.lastError,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'entityType': entityType,
      'entityId': entityId,
      'operation': operation.name,
      'payloadJson': payloadJson,
      'retryCount': retryCount,
      'status': status.name,
      'lastError': lastError,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory SyncOutboxItem.fromJson(Map<String, dynamic> json) {
    return SyncOutboxItem(
      id: json['id'] as String,
      entityType: json['entityType'] as String,
      entityId: json['entityId'] as String,
      operation: SyncOperation.values.firstWhere(
        (o) => o.name == json['operation'],
        orElse: () => SyncOperation.create,
      ),
      payloadJson: json['payloadJson'] as String,
      retryCount: json['retryCount'] as int? ?? 0,
      status: SyncStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => SyncStatus.pending,
      ),
      lastError: json['lastError'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
