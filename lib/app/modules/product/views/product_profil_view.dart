import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kartal/kartal.dart';
import 'package:stock_managament_app/app/data/models/product_model.dart';
import 'package:stock_managament_app/app/modules/home/controllers/home_controller.dart';
import 'package:stock_managament_app/constants/buttons/agree_button_view.dart';
import 'package:stock_managament_app/constants/customWidget/constants.dart';
import 'package:stock_managament_app/constants/customWidget/custom_app_bar.dart';
import 'package:stock_managament_app/constants/customWidget/custom_text_field.dart';
import 'package:stock_managament_app/constants/customWidget/widgets.dart';

class ProductProfilView extends StatefulWidget {
  const ProductProfilView({super.key, required this.product});

  final ProductModel product;

  @override
  State<ProductProfilView> createState() => _ProductProfilViewState();
}

class _ProductProfilViewState extends State<ProductProfilView> {
  List<FocusNode> focusNodes = List.generate(10, (_) => FocusNode());
  String imageURL = "";
  List<bool> readOnlyStates = List.generate(10, (_) => false);
  List<TextEditingController> textControllers = List.generate(10, (_) => TextEditingController());

  final HomeController _homeController = Get.put(HomeController());
  File? _photo;
  final ImagePicker _picker = ImagePicker();

  void changeData(final ProductModel productModel) {
    imageURL = productModel.image!;
    updateFieldIfNotEmpty(productModel.name, 0);
    updateFieldIfNotEmpty(productModel.category, 1);
    updateFieldIfNotEmpty(productModel.brandName, 2);
    updateFieldIfNotEmpty(productModel.gramm.toString(), 3);
    updateFieldIfNotEmpty(productModel.material.toString(), 4);
    updateFieldIfNotEmpty('${productModel.sellPrice}', 5);
    updateFieldIfNotEmpty(productModel.location.toString(), 6);
    updateFieldIfNotEmpty(productModel.quantity.toString(), 7);
    updateFieldIfNotEmpty(productModel.note.toString(), 8);
  }

  void updateFieldIfNotEmpty(String? value, int index) {
    if (value!.isNotEmpty) {
      textControllers[index].text = value;
    } else {
      readOnlyStates[index] = true;
    }
  }

  Future<void> uploadFile(File photo) async {
    try {
      _homeController.agreeButton.value = true;
      DateTime now = DateTime.now();
      final storageRef = FirebaseStorage.instance.ref().child('images/$now.png');
      List<int> imageBytes = photo.readAsBytesSync();
      String base64Image = base64Encode(imageBytes);

      await storageRef.putString(base64Image, format: PutStringFormat.base64, metadata: SettableMetadata(contentType: 'image/png'));

      var downloadURL = await storageRef.getDownloadURL();
      String url = downloadURL.toString();

      await FirebaseFirestore.instance.collection('products').doc(widget.product.documentID).update({'image': url});
      imageURL = url;
      setState(() {});
      _homeController.agreeButton.value = false;
      Get.back();
      _homeController.getData();
      showSnackBar("copySucces", "uploadImageProcessDone", Colors.green);
    } catch (e) {
      Get.back();
      showSnackBar("Error", e.toString(), Colors.red);
    }
  }

  void showImageUploadDialog({required File? photo, required Function() onTap}) {
    Get.defaultDialog(
      title: 'selectedImage'.tr,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          photo != null
              ? ClipRRect(
                  borderRadius: borderRadius20,
                  child: Image.file(
                    photo,
                    width: 300.w,
                    height: 300.h,
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
          const SizedBox(height: 20),
          AgreeButton(
            onTap: onTap,
            text: "uploadImage",
          ),
        ],
      ),
    );
  }

  void pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source, imageQuality: 50);
    if (pickedFile != null) {
      Get.back();
      setState(() {
        _photo = File(pickedFile.path);
        showImageUploadDialog(
          photo: _photo,
          onTap: () {
            uploadFile(_photo!);
          },
        );
      });
    }
  }

  void _showPicker(BuildContext context) {
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
                onTap: () => pickImage(ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () => pickImage(ImageSource.camera),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<dynamic> changeTextFieldWithData(String name, int indexTile, String changeName) {
    return Get.defaultDialog(
        contentPadding: EdgeInsets.zero,
        title: changeName.tr,
        content: SizedBox(
          height: Get.height / 1.5,
          width: Get.width,
          child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection(name).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.separated(
                    itemCount: snapshot.data!.docs.length,
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (BuildContext context, int indexx) {
                      return ListTile(
                          onTap: () {
                            textControllers[indexTile].text = snapshot.data!.docs[indexx]['name'];
                            Get.back();
                          },
                          title: Text(snapshot.data!.docs[indexx]['name']));
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return const Divider(thickness: 1, color: Colors.grey);
                    },
                  );
                }
                return Center(
                  child: spinKit(),
                );
              }),
        ));
  }

  Column textFields(BuildContext context) {
    return Column(
      children: [
        CustomTextField(readOnly: readOnlyStates[0], labelName: 'productName', maxline: 3, controller: textControllers[0], focusNode: focusNodes[0], requestfocusNode: focusNodes[1], unFocus: true),
        CustomTextField(
            onTap: () {
              focusNodes[1].unfocus();
              changeTextFieldWithData('categories', 1, 'category');
            },
            readOnly: readOnlyStates[1],
            labelName: 'category',
            controller: textControllers[1],
            focusNode: focusNodes[1],
            requestfocusNode: focusNodes[2],
            unFocus: true),
        CustomTextField(
            onTap: () {
              focusNodes[2].unfocus();
              changeTextFieldWithData('brands', 2, 'brand');
            },
            readOnly: readOnlyStates[2],
            labelName: 'brand',
            controller: textControllers[2],
            focusNode: focusNodes[2],
            requestfocusNode: focusNodes[3],
            unFocus: true),
        CustomTextField(readOnly: readOnlyStates[3], labelName: 'gramm', controller: textControllers[3], focusNode: focusNodes[3], requestfocusNode: focusNodes[4], unFocus: true),
        CustomTextField(
            onTap: () {
              focusNodes[4].unfocus();
              changeTextFieldWithData('materials', 4, 'material');
            },
            readOnly: readOnlyStates[4],
            labelName: 'material',
            controller: textControllers[4],
            focusNode: focusNodes[4],
            requestfocusNode: focusNodes[5],
            unFocus: true),
        CustomTextField(readOnly: readOnlyStates[5], labelName: 'price', controller: textControllers[5], focusNode: focusNodes[5], requestfocusNode: focusNodes[6], unFocus: true),
        CustomTextField(
            onTap: () {
              focusNodes[6].unfocus();
              changeTextFieldWithData('locations', 6, 'location');
            },
            readOnly: readOnlyStates[6],
            labelName: 'location',
            controller: textControllers[6],
            focusNode: focusNodes[6],
            requestfocusNode: focusNodes[7],
            unFocus: true),
        CustomTextField(readOnly: readOnlyStates[7], labelName: 'quantity', controller: textControllers[7], focusNode: focusNodes[7], requestfocusNode: focusNodes[8], unFocus: true),
        CustomTextField(readOnly: readOnlyStates[8], maxline: 3, labelName: 'note', controller: textControllers[8], focusNode: focusNodes[8], requestfocusNode: focusNodes[1], unFocus: true),
        imageURL.isEmpty || imageURL == ''
            ? AgreeButton(
                onTap: () {
                  _showPicker(context);
                },
                text: "uploadImage",
              )
            : const SizedBox.shrink(),
        AgreeButton(
          onTap: () async {
            int i = 0;
            bool changeValue = false;
            List names = ['name', 'category', 'brand', 'gramm', 'material', 'sell_price', 'location', 'quantity', 'note'];
            _homeController.agreeButton.value = !_homeController.agreeButton.value;

            for (var element in readOnlyStates) {
              if (element == true && textControllers[i].text.isNotEmpty) {
                changeValue = true;
                await FirebaseFirestore.instance.collection('products').doc(widget.product.documentID).update({
                  '${names[i]}': names[i] == 'gramm'
                      ? int.parse(textControllers[i].text.toString())
                      : names[i] == 'quantity'
                          ? int.parse(textControllers[i].text.toString())
                          : textControllers[i].text
                });
              }
              i++;
            }
            if (changeValue == false) {
              showSnackBar('errorTitle', "errorDontChangeData", Colors.red);
            } else {
              showSnackBar("copySucces", "changesUpdated", Colors.green);
            }
            _homeController.agreeButton.value = !_homeController.agreeButton.value;
          },
          text: "agree",
        ),
        SizedBox(
          height: 30.h,
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(backArrow: true, centerTitle: true, actionIcon: false, name: widget.product.name!),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('products').doc(widget.product.documentID!).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return spinKit();
            } else if (snapshot.hasError) {
              return errorData();
            } else if (snapshot.hasData) {
              final product = ProductModel.fromDocument(snapshot.data!);
              changeData(product);
              return ListView(
                padding: context.padding.horizontalNormal,
                children: [
                  GestureDetector(
                    onTap: () {
                      _showPicker(context);
                    },
                    child: Container(
                      width: Get.size.width,
                      height: Get.size.height / 2,
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
                              fit: BoxFit.fill,
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
                  ),
                  textFields(context)
                ],
              );
            }
            return const Text("No data");
          }),
    );
  }
}
