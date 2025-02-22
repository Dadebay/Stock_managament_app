import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String orderID;
  final String clientAddress;
  final String clientName;
  final String clientNumber;
  final String coupon;
  final String date;
  final String discount;
  final String note;
  final String package;
  final String status;
  final String sumCost;
  final String sumPrice;
  final String products;

  OrderModel({
    required this.orderID,
    required this.clientAddress,
    required this.clientName,
    required this.clientNumber,
    required this.coupon,
    required this.date,
    required this.discount,
    required this.note,
    required this.package,
    required this.status,
    required this.sumCost,
    required this.sumPrice,
    required this.products,
  });

  factory OrderModel.fromJson(DocumentSnapshot json) {
    return OrderModel(
      orderID: json.id,
      clientAddress: json['client_address'] ?? '',
      clientName: json['client_name'] ?? '',
      clientNumber: json['client_number'] ?? '',
      coupon: json['coupon']?.toString() ?? '',
      date: json['date'] ?? '',
      discount: json['discount']?.toString() ?? '',
      note: json['note'] ?? '',
      package: json['package'] ?? '',
      products: json['product_count']?.toString() ?? '',
      status: json['status'] ?? '',
      sumCost: json['sum_cost']?.toString() ?? '',
      sumPrice: json['sum_price']?.toString() ?? '',
    );
  }
}
