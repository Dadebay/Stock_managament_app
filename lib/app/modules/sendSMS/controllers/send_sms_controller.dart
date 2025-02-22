import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class Client {
  String name;
  final String number;
  final String address;
  final String date;
  int orderCount;
  double sumPrice;

  Client({
    required this.address,
    required this.date,
    required this.orderCount,
    required this.name,
    required this.number,
    required this.sumPrice,
  });
}

class SendSMSController extends GetxController {
  RxList clients = [].obs;
  RxBool loadData = false.obs;
  getAllClients() async {
    loadData.value = true;
    clients.clear();
    await FirebaseFirestore.instance.collection('clients').orderBy('date', descending: true).get().then((value) async {
      for (var element in value.docs) {
        Client clinet = Client(
            address: element['address'],
            orderCount: int.parse(element['order_count'].toString()),
            name: element['name'],
            date: element['date'],
            number: element['number'],
            sumPrice: double.parse(element['sum_price'].toString()));

        clients
            .add({'name': clinet.name, 'number': clinet.number, 'date': clinet.date, 'address': clinet.address, 'order_count': clinet.orderCount, "docID": element.id, 'sum_price': clinet.sumPrice});
      }
    });
    loadData.value = false;
  }
}
