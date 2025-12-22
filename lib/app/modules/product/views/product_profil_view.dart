import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kartal/kartal.dart';
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
  final SearchViewController controller = Get.find<SearchViewController>();

  late SearchModel currentProduct;
  late List<String?> selectedIds;
  final int fieldCount = 11;
  late List<FocusNode> focusNodes;
  late List<TextEditingController> textControllers;
  File? _photo;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    currentProduct = widget.product;
    focusNodes = List.generate(fieldCount, (_) => FocusNode());
    textControllers = List.generate(fieldCount, (_) => TextEditingController());
    selectedIds = List<String?>.filled(fieldCount, null);
    _populateTextFields();
    findAdmin();
  }

  @override
  void dispose() {
    for (var controller in textControllers) {
      controller.dispose();
    }
    for (var node in focusNodes) {
      node.dispose();
    }
    controller.clearSelectedImage();
    super.dispose();
  }

  void _populateTextFields() {
    textControllers[0].text = currentProduct.name;
    textControllers[1].text = currentProduct.price;
    textControllers[2].text =
        currentProduct.createdAT.length > 15 ? currentProduct.createdAT.toString().replaceAll("T", " ").substring(0, 16) : currentProduct.createdAT.toString().replaceAll("T", " ");
    textControllers[3].text = currentProduct.category?.name ?? '';
    textControllers[4].text = currentProduct.brend?.name ?? '';
    textControllers[5].text = currentProduct.location?.name ?? '';
    textControllers[6].text = currentProduct.material?.name ?? '';
    textControllers[7].text = currentProduct.gramm;
    textControllers[8].text = currentProduct.count.toString();
    textControllers[9].text = currentProduct.description;
    textControllers[10].text = currentProduct.gaplama;

    selectedIds[3] = currentProduct.category?.id.toString();
    selectedIds[4] = currentProduct.brend?.id.toString();
    selectedIds[5] = currentProduct.location?.id.toString();
    selectedIds[6] = currentProduct.material?.id.toString();
  }

  void _showPicker(BuildContext context) {
    void pickImage(ImageSource source) async {
      final pickedFile = await _picker.pickImage(source: source, imageQuality: 50);
      if (pickedFile != null) {
        Get.back();
        _photo = File(pickedFile.path);
        controller.selectedImageBytes.value = await _photo!.readAsBytes();
        controller.selectedImageFileName.value = _photo!.path.split('/').last;
        setState(() {});
        await _handleUpdate();
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

  late final bool isAdmin;

  final storage = GetStorage();

  findAdmin() async {
    isAdmin = storage.read('isAdmin') ?? false;
    setState(() {});
  }

  Widget _buildTextFields(BuildContext context) {
    print("---------------------------------------------=======================================");
    print(isAdmin);

    List editFields = isAdmin ? [true, true, true, true, true, true, true, true, true, true, true] : [true, false, false, true, true, true, true, true, false, true, true];
    return Column(
      children: List.generate(fieldCount, (index) {
        final label = ListConstants.fieldLabels[index];
        final isSelectableField = index == 3 || index == 4 || index == 5 || index == 6;

        return CustomTextField(
          onTap: () {
            if (isSelectableField) {
              final fieldName = ListConstants.apiFieldNames[index];
              final url = ListConstants.four_in_one_names.firstWhere((element) => element['countName'] == fieldName)['url'].toString();
              DialogUtils().showSelectableDialog(
                context: context,
                title: label,
                url: url,
                targetController: textControllers[index],
                onIdSelected: (id) {
                  selectedIds[index] = id;
                },
              );
            }
          },
          labelName: label,
          readOnly: editFields[index],
          controller: textControllers[index],
          focusNode: focusNodes[index],
          requestfocusNode: (index < fieldCount - 1) ? focusNodes[index + 1] : focusNodes[0],
          maxline: (ListConstants.apiFieldNames[index] == 'description') ? 3 : 1,
          unFocus: false,
        );
      }),
    );
  }

  Future<void> _handleUpdate() async {
    Map<String, String> productData = {};
    for (int i = 0; i < fieldCount; i++) {
      final key = ListConstants.apiFieldNames[i];
      if ([3, 4, 5, 6].contains(i)) {
        productData[key] = selectedIds[i].toString() == '0' ? '' : selectedIds[i] ?? '';
      } else {
        productData[key] = textControllers[i].text;
      }
    }

    String? finalImageFileName;
    if (controller.selectedImageBytes.value != null) {
      finalImageFileName = controller.selectedImageFileName.value ?? "${currentProduct.name}_updated.png";
    }
    print("barik geldi0000---------------------------------");
    try {
      final updatedProduct = await SearchService().updateProductWithImage(
        id: currentProduct.id,
        fields: productData,
        imageBytes: controller.selectedImageBytes.value,
        imageFileName: finalImageFileName,
      );

      setState(() {
        currentProduct = updatedProduct;
        controller.updateProductLocally(currentProduct);
        _populateTextFields();
        _photo = null;
      });
      Get.back();
      showSnackBar("Success", "Product updated successfully", Colors.green);
    } catch (error) {
      showSnackBar("Error", "Failed to update product: $error", Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        backArrow: true,
        centerTitle: true,
        actionIcon: false,
        name: currentProduct.name,
      ),
      body: ListView(
        padding: context.padding.horizontalNormal,
        children: [
          GestureDetector(
            onTap: () => _showPicker(context),
            child: Container(
              width: Get.size.width,
              height: Get.size.height / 2.5,
              margin: const EdgeInsets.only(top: 10),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                boxShadow: const [BoxShadow(color: Colors.grey, blurRadius: 5.0)],
                borderRadius: borderRadius25,
              ),
              child: _photo != null
                  ? ClipRRect(
                      borderRadius: borderRadius25,
                      child: Image.file(_photo!, fit: BoxFit.cover),
                    )
                  : CachedNetworkImage(
                      imageUrl: currentProduct.img!,
                      imageBuilder: (context, imageProvider) => Container(
                        decoration: BoxDecoration(
                          borderRadius: borderRadius25,
                          image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                        ),
                      ),
                      placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) => Center(child: Text('noImage'.tr)),
                    ),
            ),
          ),
          _buildTextFields(context),
          AgreeButton(
            onTap: _handleUpdate,
            text: "Update Product",
          ),
          SizedBox(height: 30.h),
        ],
      ),
    );
  }
}
