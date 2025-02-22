import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String? documentID;
  final String? date;
  final String? brandName;
  final String? category;
  final String? cost;
  final String? gramm;
  final String? image;
  final String? location;
  final String? material;
  final String? name;
  final int? quantity;
  final String? sellPrice;
  final String? note;
  final String? package;

  ProductModel({
    this.documentID,
    this.date,
    this.brandName,
    this.category,
    this.cost,
    this.gramm,
    this.image,
    this.location,
    this.material,
    this.name,
    this.note,
    this.package,
    this.quantity,
    this.sellPrice,
  });

  factory ProductModel.fromDocument(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ProductModel(
      documentID: doc.id,
      brandName: data['brand'].toString(),
      category: data['category'].toString(),
      cost: data['cost'].toString(),
      date: data['date'].toString(),
      gramm: data['gramm'].toString(),
      image: data['image'].toString(),
      location: data['location'].toString(),
      material: data['material'].toString(),
      name: data['name'].toString(),
      note: data['note'].toString(),
      package: data['package'].toString(),
      quantity: data['quantity'].toString().isNotEmpty ? int.parse(data['quantity'].toString()) : 0,
      sellPrice: data['sell_price'].toString(),
    );
  }
}
