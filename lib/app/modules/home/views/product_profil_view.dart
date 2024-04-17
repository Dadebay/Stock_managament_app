import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stock_managament_app/app/data/models/product_model.dart';
import 'package:stock_managament_app/app/modules/home/controllers/home_controller.dart';
import 'package:stock_managament_app/constants/buttons/agree_button_view.dart';
import 'package:stock_managament_app/constants/constants.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stock_managament_app/constants/custom_app_bar.dart';
import 'package:stock_managament_app/constants/custom_text_field.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:stock_managament_app/constants/widgets.dart';

class ProductProfilView extends StatefulWidget {
  final ProductModel product;

  const ProductProfilView({super.key, required this.product});

  @override
  State<ProductProfilView> createState() => _ProductProfilViewState();
}

class _ProductProfilViewState extends State<ProductProfilView> {
  List<TextEditingController> textControllers = List.generate(9, (_) => TextEditingController());
  List<FocusNode> focusNodes = List.generate(9, (_) => FocusNode());
  List<bool> readOnlyStates = List.generate(9, (_) => false);
  List<String> fieldLabels = ['Product Name', 'Category', 'Brand', 'Gramm', 'Material', 'Sell Price', 'Location', 'Quantity'];
  String imageURL = "";
  final HomeController _homeController = Get.put(HomeController());
  void changeData() {
    imageURL = widget.product.image!;
    updateFieldIfNotEmpty(widget.product.name, 0);
    updateFieldIfNotEmpty(widget.product.category, 1);
    updateFieldIfNotEmpty(widget.product.brandName, 2);
    updateFieldIfNotEmpty(widget.product.gramm.toString(), 3);
    updateFieldIfNotEmpty(widget.product.material.toString(), 4);
    updateFieldIfNotEmpty(widget.product.sellPrice.toString(), 5);
    updateFieldIfNotEmpty(widget.product.location.toString(), 6);
    updateFieldIfNotEmpty(widget.product.quantity.toString(), 7);
  }

  void updateFieldIfNotEmpty(String? value, int index) {
    if (value!.isNotEmpty) {
      textControllers[index].text = value;
    } else {
      readOnlyStates[index] = true;
    }

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    changeData();
  }

  File? _photo;
  final ImagePicker _picker = ImagePicker();
  Future imgFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _photo = File(pickedFile.path);
        showImageUploadDialog();
      }
    });
  }

  Future imgFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null) {
        _photo = File(pickedFile.path);
        showImageUploadDialog();
      }
    });
  }

  Future uploadFile() async {
    if (_photo == null) return;
    try {
      DateTime now = DateTime.now();
      final storageRef = FirebaseStorage.instance.ref().child('images/$now.png');
      List<int> imageBytes = _photo!.readAsBytesSync();
      String base64Image = base64Encode(imageBytes);
      await storageRef.putString(base64Image, format: PutStringFormat.base64, metadata: SettableMetadata(contentType: 'image/png')).then((p0) async {
        showSnackBar("copySucces", "uploadImageProcessDone", Colors.green);
        var dowurl = await storageRef.getDownloadURL();
        String url = dowurl.toString();
        FirebaseFirestore.instance.collection('products').doc(widget.product.documentID).update({'image': url});
        imageURL = url;
        setState(() {});
        _homeController.collectionReference.get();
        Get.back();
      });
    } catch (e) {
      Get.back();
      showSnackBar("Error", e.toString(), Colors.red);
    }
  }

  showImageUploadDialog() {
    Get.defaultDialog(
      title: 'selectedImage'.tr,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _photo != null
              ? ClipRRect(
                  borderRadius: borderRadius20,
                  child: Image.file(
                    _photo!,
                    width: 300,
                    height: 300,
                    fit: BoxFit.fill,
                  ),
                )
              : Container(
                  decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(50)),
                  width: 100,
                  height: 100,
                  child: Icon(
                    Icons.camera_alt,
                    color: Colors.grey[800],
                  ),
                ),
          AgreeButton(
            onTap: () {
              uploadFile();
            },
            text: "uploadImage",
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(backArrow: true, actionIcon: false, name: widget.product.name!),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.w),
          child: Column(
            children: [
              Container(
                width: Get.size.width,
                height: Get.size.height / 3,
                decoration: const BoxDecoration(color: Colors.grey, borderRadius: borderRadius25),
                child: CachedNetworkImage(
                  fadeInCurve: Curves.ease,
                  imageUrl: imageURL,
                  useOldImageOnUrlChange: true,
                  imageBuilder: (context, imageProvider) => Container(
                    width: Get.size.width,
                    decoration: BoxDecoration(
                      borderRadius: borderRadius25,
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  errorWidget: (context, url, error) => Center(
                    child: Text('noImage'.tr),
                  ),
                ),
              ),
              textFields(context)
            ],
          ),
        ),
      ),
    );
  }

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            decoration: const BoxDecoration(color: Colors.white),
            child: Wrap(
              children: <Widget>[
                ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: const Text('Gallery'),
                    onTap: () {
                      imgFromGallery();

                      Navigator.of(context).pop();
                    }),
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('Camera'),
                  onTap: () {
                    imgFromCamera();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );
        });
  }

  Column textFields(BuildContext context) {
    return Column(
      children: [
        CustomTextField(
            readOnly: readOnlyStates[0],
            labelName: 'productName',
            maxline: 3,
            borderRadius: true,
            controller: textControllers[0],
            focusNode: focusNodes[0],
            requestfocusNode: focusNodes[1],
            unFocus: true),
        CustomTextField(
            readOnly: readOnlyStates[1], labelName: 'category', borderRadius: true, controller: textControllers[1], focusNode: focusNodes[1], requestfocusNode: focusNodes[2], unFocus: true),
        CustomTextField(readOnly: readOnlyStates[2], labelName: 'brand', borderRadius: true, controller: textControllers[2], focusNode: focusNodes[2], requestfocusNode: focusNodes[3], unFocus: true),
        CustomTextField(readOnly: readOnlyStates[3], labelName: 'gramm', borderRadius: true, controller: textControllers[3], focusNode: focusNodes[3], requestfocusNode: focusNodes[4], unFocus: true),
        CustomTextField(
            readOnly: readOnlyStates[4], labelName: 'material', borderRadius: true, controller: textControllers[4], focusNode: focusNodes[4], requestfocusNode: focusNodes[5], unFocus: true),
        CustomTextField(readOnly: readOnlyStates[5], labelName: 'price', borderRadius: true, controller: textControllers[5], focusNode: focusNodes[5], requestfocusNode: focusNodes[6], unFocus: true),
        CustomTextField(
            readOnly: readOnlyStates[6], labelName: 'location', borderRadius: true, controller: textControllers[6], focusNode: focusNodes[6], requestfocusNode: focusNodes[7], unFocus: true),
        CustomTextField(
            readOnly: readOnlyStates[7], labelName: 'quantity', borderRadius: true, controller: textControllers[7], focusNode: focusNodes[7], requestfocusNode: focusNodes[1], unFocus: true),
        widget.product.image!.isEmpty || widget.product.image == ''
            ? AgreeButton(
                onTap: () {
                  _showPicker(context);
                },
                text: "uploadImage",
              )
            : const SizedBox.shrink(),
        AgreeButton(
          onTap: () async {
            for (var element in readOnlyStates) {
              if (element == true) {
                await FirebaseFirestore.instance.collection('products').doc(widget.product.documentID).update({
                  "name": textControllers[0].text,
                  "category": textControllers[1].text,
                  "brand": textControllers[2].text,
                  "gramm": int.parse(textControllers[3].text.toString()),
                  "material": textControllers[4].text,
                  "sell_price": textControllers[5].text,
                  "location": textControllers[6].text,
                  "quantity": int.parse(textControllers[7].text.toString()),
                }).then((value) {
                  showSnackBar("copySucces", "changesUpdated", Colors.green);
                  return value;
                });
              }
            }
          },
          text: "agree",
        ),
        SizedBox(
          height: 30.h,
        )
      ],
    );
  }
}
