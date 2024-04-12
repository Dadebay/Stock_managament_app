import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:stock_managament_app/app/data/models/product_model.dart';
import 'package:stock_managament_app/constants/buttons/agree_button_view.dart';
import 'package:stock_managament_app/constants/constants.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
  TextEditingController textEditingController = TextEditingController();

  TextEditingController textEditingController1 = TextEditingController();

  TextEditingController textEditingController2 = TextEditingController();

  TextEditingController textEditingController3 = TextEditingController();

  TextEditingController textEditingController4 = TextEditingController();

  TextEditingController textEditingController5 = TextEditingController();

  TextEditingController textEditingController6 = TextEditingController();

  TextEditingController textEditingController7 = TextEditingController();

  TextEditingController textEditingController8 = TextEditingController();

  FocusNode focusNode = FocusNode();

  FocusNode focusNode1 = FocusNode();

  FocusNode focusNode2 = FocusNode();

  FocusNode focusNode3 = FocusNode();

  FocusNode focusNode4 = FocusNode();

  FocusNode focusNode5 = FocusNode();

  FocusNode focusNode6 = FocusNode();

  FocusNode focusNode7 = FocusNode();

  FocusNode focusNode8 = FocusNode();
  String imageURL = "";
  bool readOnly = false;
  bool readOnly1 = false;
  bool readOnly2 = false;
  bool readOnly3 = false;
  bool readOnly4 = false;
  bool readOnly5 = false;
  bool readOnly6 = false;
  bool readOnly7 = false;
  bool readOnly8 = false;
  void changeData() {
    imageURL = widget.product.image!;
    // if (widget.name.isEmpty || widget.name == "") {
    //   readOnly = true;
    // } else {
    //   textEditingController.text = widget.name.toString();
    // }
    // if (widget.category.isEmpty || widget.category == "") {
    //   readOnly1 = true;
    // } else {
    //   textEditingController1.text = widget.category.toString();
    // }
    // if (widget.brandName.isEmpty || widget.brandName == "") {
    //   readOnly2 = true;
    // } else {
    //   textEditingController2.text = widget.brandName.toString();
    // }
    // if (widget.gramm == 0) {
    //   readOnly3 = true;
    // } else {
    //   textEditingController3.text = widget.gramm.toString();
    // }
    // if (widget.material.isEmpty || widget.material == "") {
    //   readOnly4 = true;
    // } else {
    //   textEditingController4.text = widget.material.toString();
    // }
    // if (widget.cost == 0) {
    //   readOnly5 = true;
    // } else {
    //   textEditingController5.text = widget.cost.toString();
    // }
    // if (widget.sellPrice.isEmpty || widget.sellPrice == "") {
    //   readOnly6 = true;
    // } else {
    //   textEditingController6.text = widget.sellPrice.toString();
    // }
    // if (widget.location.isEmpty || widget.location == "") {
    //   readOnly7 = true;
    // } else {
    //   textEditingController7.text = widget.location.toString();
    // }
    // if (widget.quantity == 0) {
    //   readOnly8 = true;
    // } else {
    //   textEditingController8.text = widget.quantity.toString();
    // }
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
      } else {
        print('No image selected.');
      }
    });
  }

  Future imgFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _photo = File(pickedFile.path);
        showImageUploadDialog();
      } else {
        print('No image selected.');
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
        Get.back();

        showSnackBar("Uploaded", "Image succefully uploaded", Colors.green);
        var dowurl = await storageRef.getDownloadURL();
        String url = dowurl.toString();
        FirebaseFirestore.instance.collection('products').doc(widget.product.documentID).update({'image': url});
        imageURL = url;
        setState(() {});
      });
    } catch (e) {
      Get.back();

      showSnackBar("Error", e.toString(), Colors.red);

      print('error occured');
    }
  }

  showImageUploadDialog() {
    Get.dialog(Column(
      children: [
        _photo != null
            ? Image.file(
                _photo!,
                width: 100,
                height: 100,
                fit: BoxFit.fitHeight,
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
          text: "Upload Image",
        ),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.product.name!,
          style: TextStyle(color: Colors.black, fontFamily: gilroyBold, fontSize: 18.sp),
        ),
        centerTitle: true,
        leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: const Icon(
              IconlyLight.arrowLeftCircle,
              color: Colors.black,
            )),
      ),
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
                  errorWidget: (context, url, error) => const Center(
                    child: Text('No Image'),
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
            readOnly: readOnly,
            labelName: 'Product Name',
            maxline: 3,
            borderRadius: true,
            controller: textEditingController,
            focusNode: focusNode,
            requestfocusNode: focusNode8,
            isNumber: false,
            unFocus: true),
        CustomTextField(
            readOnly: readOnly1, labelName: 'Category', borderRadius: true, controller: textEditingController1, focusNode: focusNode1, requestfocusNode: focusNode2, isNumber: false, unFocus: true),
        CustomTextField(
            readOnly: readOnly2, labelName: 'Brand', borderRadius: true, controller: textEditingController2, focusNode: focusNode2, requestfocusNode: focusNode3, isNumber: false, unFocus: true),
        CustomTextField(
            readOnly: readOnly3, labelName: 'Gramm', borderRadius: true, controller: textEditingController3, focusNode: focusNode3, requestfocusNode: focusNode4, isNumber: false, unFocus: true),
        CustomTextField(
            readOnly: readOnly4, labelName: 'Material', borderRadius: true, controller: textEditingController4, focusNode: focusNode4, requestfocusNode: focusNode6, isNumber: false, unFocus: true),
        CustomTextField(
            readOnly: readOnly6, labelName: 'Sell Price', borderRadius: true, controller: textEditingController6, focusNode: focusNode6, requestfocusNode: focusNode7, isNumber: false, unFocus: true),
        CustomTextField(
            readOnly: readOnly7, labelName: 'Location', borderRadius: true, controller: textEditingController7, focusNode: focusNode7, requestfocusNode: focusNode8, isNumber: false, unFocus: true),
        CustomTextField(
            readOnly: readOnly8, labelName: 'Quantity', borderRadius: true, controller: textEditingController8, focusNode: focusNode8, requestfocusNode: focusNode, isNumber: false, unFocus: true),
        AgreeButton(
          onTap: () {
            _showPicker(context);
          },
          text: "Upload Image",
        ),
        AgreeButton(
          onTap: () {
            FirebaseFirestore.instance.collection('products').doc(widget.product.documentID).update({
              "name": textEditingController.text,
              "category": textEditingController1.text,
              "brand": textEditingController2.text,
              "gramm": int.parse(textEditingController3.text.toString()),
              "material": textEditingController4.text,
              "sell_price": textEditingController6.text,
              "location": textEditingController7.text,
              "quantity": int.parse(textEditingController8.text.toString()),
            });
            showSnackBar("Done", "All missing fields changed", Colors.green);
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
