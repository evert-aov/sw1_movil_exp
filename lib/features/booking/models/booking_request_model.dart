/// El importe y el método de cobro se resuelven exclusivamente en el servidor.
class BookingRequestModel {
  final String experienceId;
  final int quantity;
  const BookingRequestModel({required this.experienceId, this.quantity = 1});

  Map<String, dynamic> toJson() => <String, dynamic>{
    'experience_id': experienceId,
    'quantity': quantity,
  };
}
