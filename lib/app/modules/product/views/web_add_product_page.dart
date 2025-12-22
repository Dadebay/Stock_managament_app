import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:kartal/kartal.dart';
import 'package:stock_managament_app/app/modules/home/controllers/four_in_one_model.dart';
import 'package:stock_managament_app/app/modules/home/controllers/four_in_one_page_service.dart';
import 'package:stock_managament_app/app/modules/home/controllers/home_controller.dart';
import 'package:stock_managament_app/app/modules/product/views/string_constants.dart';
import 'package:stock_managament_app/constants/buttons/agree_button_view.dart';
import 'package:stock_managament_app/constants/customWidget/custom_app_bar.dart';
import 'package:stock_managament_app/constants/customWidget/custom_text_field.dart';
import 'package:stock_managament_app/constants/customWidget/widgets.dart';

class WebAddProductPage extends StatefulWidget {
  const WebAddProductPage({super.key});

  @override
  State<WebAddProductPage> createState() => _WebAddProductPageState();
}

class _WebAddProductPageState extends State<WebAddProductPage> {
  final SearchViewController controller = Get.find<SearchViewController>();
  final int fieldCount = 12;
  late List<TextEditingController> textControllers;
  late List<FocusNode> focusNodes;
  late List<String?> selectedIds;

  @override
  void initState() {
    super.initState();
    controller.clearSelectedImage();
    textControllers = List.generate(fieldCount, (_) => TextEditingController());
    focusNodes = List.generate(fieldCount, (_) => FocusNode());
    selectedIds = List<String?>.filled(fieldCount, null);
  }

  @override
  void dispose() {
    for (var tc in textControllers) {
      tc.dispose();
    }
    for (var fn in focusNodes) {
      fn.dispose();
    }

    super.dispose();
  }

  Future<void> _handleAddProduct() async {
    if (textControllers[0].text.isEmpty) {
      showSnackBar("Hata", "Ürün adı boş bırakılamaz.", Colors.red);
      return;
    }
    if (controller.selectedImageBytes.value == null) {}

    Map<String, String> productData = {};
    for (int i = 0; i < fieldCount; i++) {
      final key = StringConstants.apiFieldNames[i];

      if (i == 3 || i == 4 || i == 5 || i == 6) {
        productData[key] = selectedIds[i] ?? '';
      } else {
        productData[key] = textControllers[i].text;
      }
    }
    controller.selectedImageFileName.value = "${textControllers[0].text.replaceAll(' ', '_')}_image.png";
    productData['gram'] = (productData['gram'] == '' ? '0' : productData['gram'])!;
    print(productData);
    print(controller.selectedImageBytes.value);
    print("${textControllers[0].text.replaceAll(' ', '_')}_image.png");

    await controller.addNewProduct(
        productData: productData, selectedImageBytes: controller.selectedImageBytes.value, selectedImageFileName: "${textControllers[0].text.replaceAll(' ', '_')}_image.png");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: const CustomAppBar(
          backArrow: true,
          actionIcon: false,
          centerTitle: true,
          name: "Add Product",
        ),
        body: Stack(
          children: [
            ListView(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20.h),
              children: [
                Center(
                  child: GestureDetector(
                    onTap: () {
                      _showImageSourceDialog();
                    },
                    child: Obx(() {
                      return Container(
                        width: Get.size.width > 600 ? 300 : Get.width * 0.6,
                        height: Get.size.width > 600 ? 300 : Get.width * 0.6,
                        margin: context.padding.medium,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: context.border.normalBorderRadius,
                          border: Border.all(color: Colors.grey.shade300, width: 1),
                        ),
                        child: ClipRRect(
                          borderRadius: context.border.normalBorderRadius,
                          child: controller.selectedImageBytes.value != null
                              ? Image.memory(controller.selectedImageBytes.value!, fit: BoxFit.cover)
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(IconlyLight.camera, size: 50, color: Colors.grey.shade700),
                                    SizedBox(height: 8.h),
                                    Text("Select Image", style: TextStyle(color: Colors.grey.shade700)),
                                  ],
                                ),
                        ),
                      );
                    }),
                  ),
                ),
                _buildTextFields(context),
                SizedBox(height: 20.h),
                Center(
                  child: AgreeButton(
                    onTap: _handleAddProduct,
                    text: "Add Product",
                  ),
                ),
                SizedBox(height: 30.h),
              ],
            ),
          ],
        ));
  }

  Widget _buildTextFields(BuildContext context) {
    return Column(
      children: List.generate(fieldCount, (index) {
        final label = StringConstants.fieldLabels[index];

        final isSelectableField = index == 3 || index == 4 || index == 5 || index == 6;

        return CustomTextField(
          onTap: () {
            if (label.toLowerCase() == "date") {
              DateTime? selectedDateTime;
              showDateTimePicker(BuildContext context) async {
                final result = await showDateTimePickerWidget(context: context);
                if (result != null) {
                  setState(() {
                    selectedDateTime = result;
                    textControllers[2].text = DateFormat('yyyy-MM-dd, HH:mm').format(selectedDateTime!);
                  });
                }
              }

              showDateTimePicker(context);
            } else {
              if (isSelectableField) {
                focusNodes[index].unfocus();
                final fieldApiName = StringConstants.apiFieldNames[index];
                Map<String, String>? selectableInfo;
                try {
                  selectableInfo = StringConstants.four_in_one_names.firstWhere((element) => element['countName'] == fieldApiName);
                } catch (e) {}
                if (selectableInfo != null && selectableInfo['url'] != null) {
                  showSelectableDialog(
                    context: context,
                    title: "Select $label",
                    url: selectableInfo['url']!,
                    targetController: textControllers[index],
                    onIdSelected: (id) {
                      selectedIds[index] = id;
                    },
                  );
                } else {
                  showSnackBar("Configuration Error", "Cannot find URL for $label", Colors.red);
                }
              }
            }
          },
          labelName: label,
          controller: textControllers[index],
          focusNode: focusNodes[index],
          requestfocusNode: (index < fieldCount - 1) ? focusNodes[index + 1] : focusNodes[0],
          unFocus: false,
          readOnly: true,
        );
      }),
    );
  }

  void showSelectableDialog({
    required BuildContext context,
    required String title,
    required String url,
    required TextEditingController targetController,
    required void Function(String id) onIdSelected,
  }) {
    Get.defaultDialog(
      title: title.tr,
      titleStyle: TextStyle(color: Colors.black, fontSize: 28.sp, fontWeight: FontWeight.bold),
      titlePadding: EdgeInsets.only(top: 20),
      content: Container(
        width: Get.size.width,
        height: Get.size.height / 2,
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
        child: FutureBuilder<List<FourInOneModel>>(
          future: FourInOnePageService().getData(url: url),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return spinKit();
            } else if (snapshot.hasError) {
              return errorData();
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return emptyData();
            }

            final items = snapshot.data!;
            return ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return ListTile(
                  minVerticalPadding: 10.h,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  title: Text(
                    item.name.tr,
                    style: TextStyle(color: const Color.fromARGB(255, 115, 109, 109), fontSize: 22.sp, fontWeight: FontWeight.w500),
                  ),
                  trailing: const Icon(IconlyLight.arrowRightCircle),
                  onTap: () {
                    targetController.text = item.name;
                    onIdSelected(item.id.toString());
                    Get.back();
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _showImageSourceDialog() {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
        ),
        child: Wrap(
          children: [
            ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              leading: Icon(IconlyLight.camera, color: Colors.black87, size: 28.sp),
              title: Text(
                'Camera',
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w500),
              ),
              onTap: () {
                Get.back();
                controller.pickImage(source: ImageSource.camera);
              },
            ),
            Divider(height: 1.h),
            ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              leading: Icon(IconlyLight.image, color: Colors.black87, size: 28.sp),
              title: Text(
                'Gallery',
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w500),
              ),
              onTap: () {
                Get.back();
                controller.pickImage(source: ImageSource.gallery);
              },
            ),
            SizedBox(height: 10.h),
          ],
        ),
      ),
    );
  }
}
