import 'package:jusconnect/features/request/domain/entities/request_entity.dart';

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

class RequestModel extends RequestEntity {
  const RequestModel({
    required super.id,
    required super.description,
    required super.public,
    required super.status,
    super.lawyerId,
    super.lawyerName,
    required super.clientId,
    required super.clientName,
    required super.clientEmail,
    required super.clientPhone,
    required super.createdAt,
    super.responseDateTime,
  });

  factory RequestModel.fromJson(Map<String, dynamic> json) {
    return RequestModel(
      id: json['id'] as int,
      description: json['descricao'] as String,
      public: json['publica'] as bool,
      status: json['status'] as String,
      lawyerId: json['advogadoId'] as int?,
      lawyerName: json['advogadoNome'] as String?,
      clientId: json['clienteId'] as int,
      clientName: json['clienteNome'] as String,
      clientEmail: json['clienteEmail'] as String? ?? '',
      clientPhone: json['clienteTelefone'] as String? ?? '',
      createdAt: DateTime.parse(json['dataCriacao'] as String),
      responseDateTime: json['dataResposta'] != null
          ? DateTime.parse(json['dataResposta'] as String)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'advogadoId': lawyerId,
      'descricao': description,
      'publica': public,
    };
  }

  RequestEntity toEntity() {
    return this;
  }
}
