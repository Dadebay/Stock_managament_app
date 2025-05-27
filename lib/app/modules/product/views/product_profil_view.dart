import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kartal/kartal.dart';
import 'package:stock_managament_app/api_constants.dart';
import 'package:stock_managament_app/app/modules/home/controllers/home_controller.dart';
import 'package:stock_managament_app/app/modules/home/controllers/search_model.dart';
import 'package:stock_managament_app/app/modules/home/controllers/search_service.dart';
import 'package:stock_managament_app/app/product/constants/list_constants.dart';
import 'package:stock_managament_app/app/product/utils/dialog_utils.dart';
import 'package:stock_managament_app/constants/buttons/agree_button_view.dart';
import 'package:stock_managament_app/constants/customWidget/constants.dart';
import 'package:stock_managament_app/constants/customWidget/custom_app_bar.dart';
import 'package:stock_managament_app/constants/customWidget/custom_text_field.dart';
import 'package:stock_managament_app/constants/customWidget/widgets.dart';

class ProductProfilView extends StatefulWidget {
  const ProductProfilView({super.key, required this.product});

  final SearchModel product;

  @override
  State<ProductProfilView> createState() => _ProductProfilViewState();
}

class _ProductProfilViewState extends State<ProductProfilView> {
  List<FocusNode> focusNodes = List.generate(10, (_) => FocusNode());
  String imageURL = "";
  List<TextEditingController> textControllers = List.generate(10, (_) => TextEditingController());

  final HomeController _homeController = Get.find<HomeController>();
  File? _photo;
  final ImagePicker _picker = ImagePicker();
  @override
  void initState() {
    super.initState();
    changeData();
  }

  final int fieldCount = 9;
  final SearchViewController controller = Get.find<SearchViewController>();

  void changeData() {
    selectedIds = List<String?>.filled(fieldCount, null);
    imageURL = widget.product.img!;
    textControllers[0].text = widget.product.name;
    textControllers[1].text = widget.product.price.toString();
    textControllers[2].text = widget.product.count.toString();

    textControllers[3].text = widget.product.category!.name;
    textControllers[4].text = widget.product.brend!.name;
    textControllers[5].text = widget.product.material!.name.toString();
    textControllers[6].text = widget.product.location!.name.toString();
    textControllers[7].text = widget.product.gramm.toString();

    textControllers[8].text = widget.product.description.toString();
    selectedIds[3] = widget.product.category?.id.toString(); // category
    selectedIds[4] = widget.product.brend?.id.toString(); // brend
    selectedIds[5] = widget.product.location?.id.toString(); // location
    selectedIds[6] = widget.product.material?.id.toString();
  }

  late List<String?> selectedIds;

  void _showPicker(BuildContext context) {
    void pickImage(ImageSource source) async {
      final pickedFile = await _picker.pickImage(source: source, imageQuality: 50);
      if (pickedFile != null) {
        Get.back();
        _photo = File(pickedFile.path);
        controller.selectedImageBytes.value = await _photo!.readAsBytes();
        controller.selectedImageFileName.value = _photo!.path.split('/').last;
        setState(() {});
      }
    }

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

  Column textFields(BuildContext context) {
    return Column(
      children: [
        CustomTextField(readOnly: true, labelName: 'productName', maxline: 3, controller: textControllers[0], focusNode: focusNodes[0], requestfocusNode: focusNodes[1], unFocus: false),
        CustomTextField(readOnly: false, labelName: 'price', controller: textControllers[1], focusNode: focusNodes[5], requestfocusNode: focusNodes[6], unFocus: false),
        CustomTextField(readOnly: false, labelName: 'quantity', controller: textControllers[2], focusNode: focusNodes[7], requestfocusNode: focusNodes[8], unFocus: false),
        CustomTextField(
            onTap: () {
              focusNodes[1].unfocus();
              DialogUtils().showSelectableDialog(
                context: context,
                title: 'Category',
                url: ApiConstants.categories,
                targetController: textControllers[3],
                onIdSelected: (id) {
                  selectedIds[3] = id;
                },
              );
            },
            readOnly: true,
            labelName: 'category',
            controller: textControllers[3],
            focusNode: focusNodes[1],
            requestfocusNode: focusNodes[2],
            unFocus: true),
        CustomTextField(
            onTap: () {
              focusNodes[2].unfocus();
              DialogUtils().showSelectableDialog(
                context: context,
                title: 'Brands',
                url: ApiConstants.brends,
                targetController: textControllers[4],
                onIdSelected: (id) {
                  selectedIds[4] = id;
                },
              );
            },
            readOnly: true,
            labelName: 'brand',
            controller: textControllers[4],
            focusNode: focusNodes[2],
            requestfocusNode: focusNodes[3],
            unFocus: true),
        CustomTextField(
            onTap: () {
              focusNodes[4].unfocus();
              DialogUtils().showSelectableDialog(
                context: context,
                title: 'Materials',
                url: ApiConstants.materials,
                targetController: textControllers[5],
                onIdSelected: (id) {
                  selectedIds[5] = id;
                },
              );
            },
            readOnly: true,
            labelName: 'material',
            controller: textControllers[5],
            focusNode: focusNodes[4],
            requestfocusNode: focusNodes[5],
            unFocus: true),
        CustomTextField(
            onTap: () {
              focusNodes[6].unfocus();
              DialogUtils().showSelectableDialog(
                context: context,
                title: 'Locations',
                url: ApiConstants.locations,
                targetController: textControllers[6],
                onIdSelected: (id) {
                  selectedIds[6] = id;
                },
              );
            },
            readOnly: true,
            labelName: 'location',
            controller: textControllers[6],
            focusNode: focusNodes[6],
            requestfocusNode: focusNodes[7],
            unFocus: true),
        CustomTextField(readOnly: true, labelName: 'gramm', controller: textControllers[7], focusNode: focusNodes[3], requestfocusNode: focusNodes[4], unFocus: true),
        CustomTextField(readOnly: true, maxline: 3, labelName: 'note', controller: textControllers[8], focusNode: focusNodes[8], requestfocusNode: focusNodes[1], unFocus: true),
        AgreeButton(
          onTap: () async {
            _handleUpdate();
          },
          text: "agree",
        ),
        SizedBox(
          height: 30.h,
        )
      ],
    );
  }

  Future<void> _handleUpdate() async {
    Map<String, String> productData = {};
    for (int i = 0; i < fieldCount; i++) {
      final key = ListConstants.apiFieldNames[i];

      if (ListConstants.apiFieldNames[i] == 'category' || ListConstants.apiFieldNames[i] == 'brends' || ListConstants.apiFieldNames[i] == 'materials' || ListConstants.apiFieldNames[i] == 'location') {
        final selectedId = selectedIds[i];
        if (selectedId == null || selectedId.isEmpty) {
          productData[key] = '';
          continue;
        }
        productData[key] = selectedId == 0 ? '' : selectedId.toString();
        if (productData[key] == '0') {
          productData[key] = '';
        }
      } else {
        if (textControllers[i].text == '' || textControllers[i].text.isEmpty) {
          productData[key] = '';
          continue;
        }
        productData[key] = textControllers[i].text;
      }
    }
    String? finalImageFileName;
    if (controller.selectedImageBytes.value != null) {
      finalImageFileName = controller.selectedImageFileName.value; // Resim seçildiyse dosya adını al
      if (finalImageFileName == null || finalImageFileName.isEmpty) {
        finalImageFileName = "${widget.product.name}_updated.png";
      }
    }

    await SearchService().updateProductWithImage(id: widget.product.id, fields: productData, imageBytes: controller.selectedImageBytes.value, imageFileName: finalImageFileName).then((_) {
      Get.back();
      showSnackBar("Success", "Product updated successfully", Colors.green);
    }).catchError((error) {
      showSnackBar("Error", "Failed to update product: $error", Colors.red);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: CustomAppBar(backArrow: true, centerTitle: true, actionIcon: false, name: widget.product.name),
        body: ListView(
          padding: context.padding.horizontalNormal,
          children: [
            GestureDetector(
              onTap: () {
                _showPicker(context);
              },
              child: Container(
                width: Get.size.width,
                height: Get.size.height / 2.5,
                margin: const EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.grey,
                        blurRadius: 5.0,
                      ),
                    ],
                    borderRadius: borderRadius25),
                child: _photo != null
                    ? ClipRRect(
                        borderRadius: borderRadius25,
                        child: Image.file(
                          _photo!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : CachedNetworkImage(
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
            ),
            textFields(context)
          ],
        ));
  }
}
