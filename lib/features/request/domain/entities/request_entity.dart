// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:equatable/equatable.dart';

// {
//   "id": 1,
//   "descricao": "Eu preciso me casar",
//   "status": "PENDENTE",
//   "publica": false,
//   "dataCriacao": "2026-01-15T04:12:40.379787901",
//   "dataResposta": null,
//   "clienteId": 1,
//   "clienteNome": "Joao",
//   "clienteEmail": null,
//   "clienteTelefone": null,
//   "advogadoId": 1,
//   "advogadoNome": "Artur"
// }

class RequestEntity extends Equatable {
  final int id;
  final String description;
  final bool public;
  final String status;
  final int lawyerId;
  final String lawyerName;
  final int clientId;
  final String clientName;
  final String clientEmail;
  final String clientPhone;
  final DateTime createdAt;
  final DateTime? responseDateTime;

  const RequestEntity({
    required this.id,
    required this.description,
    required this.public,
    required this.status,
    required this.lawyerId,
    required this.lawyerName,
    required this.clientId,
    required this.clientName,
    required this.clientEmail,
    required this.clientPhone,
    required this.createdAt,
    this.responseDateTime,
  });

  RequestEntity copyWith({
    int? id,
    String? description,
    bool? public,
    String? status,
    int? lawyerId,
    String? lawyerName,
    int? clientId,
    String? clientName,
    String? clientEmail,
    String? clientPhone,
    DateTime? createdAt,
    DateTime? responseDateTime,
  }) {
    return RequestEntity(
      id: id ?? this.id,
      description: description ?? this.description,
      public: public ?? this.public,
      status: status ?? this.status,
      lawyerId: lawyerId ?? this.lawyerId,
      lawyerName: lawyerName ?? this.lawyerName,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      clientEmail: clientEmail ?? this.clientEmail,
      clientPhone: clientPhone ?? this.clientPhone,
      createdAt: createdAt ?? this.createdAt,
      responseDateTime: responseDateTime ?? this.responseDateTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'public': public,
      'status': status,
      'lawyerId': lawyerId,
      'lawyerName': lawyerName,
      'clientId': clientId,
      'clientName': clientName,
      'clientEmail': clientEmail,
      'clientPhone': clientPhone,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'responseDateTime': responseDateTime?.millisecondsSinceEpoch,
    };
  }

  @override
  String toString() {
    return '''RequestEntity(id: $id, description: $description, public: $public, status: $status, lawyerId: $lawyerId, lawyerName: $lawyerName, clientId: $clientId, clientName: $clientName, clientEmail: $clientEmail, clientPhone: $clientPhone, createdAt: $createdAt, responseDateTime: $responseDateTime)''';
  }

  @override
  List<Object?> get props {
    return [
      id,
      description,
      public,
      status,
      lawyerId,
      lawyerName,
      clientId,
      clientName,
      clientEmail,
      clientPhone,
      createdAt,
      responseDateTime,
    ];
  }
}
