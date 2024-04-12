class ProductModel {
  final String? brandName;
  final String? category;
  final int? cost;
  final int? gramm;
  final String? image;
  final String? location;
  final String? material;
  final String? name;

  final int? quantity;

  final String? sellPrice;
  final String? note;
  final String? package;
  final String? documentID;

  ProductModel({
    this.documentID,
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

  // factory ProductModel.fromJson(Map<dynamic, dynamic> json) {
  //   return ProductModel(
  //     brandName: json['brand'] ?? '',
  //     category: json['category'] ?? '',
  //     cost: json['cost'] ?? -1,
  //     gramm: json['gramm'] ?? -1,
  //     image: json['image'] ?? '',
  //     material: json['material'] ?? '',
  //     location: json['location'] ?? '',
  //     name: json['name'] ?? '',
  //     note: json['note'] ?? '',
  //     package: json['package'] ?? '',
  //     quantity: json['quantity'] ?? -1,
  //     sellPrice: json['sell_price'] ?? '',
  //   );
  // }
}
