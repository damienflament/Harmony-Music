import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harmonymusic/helper.dart';
import 'package:harmonymusic/services/piped_service.dart';
import 'package:harmonymusic/ui/screens/settings_screen_controller.dart';

import 'snackbar.dart';

class LinkPiped extends StatelessWidget {
  const LinkPiped({super.key});

  @override
  Widget build(BuildContext context) {
    final pipedLinkedController = Get.put(PipedLinkedController());
    return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 30),
          height: 380,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Piped",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20.0, bottom: 10),
                child: Obx(() => DropdownButton(
                    value: pipedLinkedController.selectedInst.value,
                    items: pipedLinkedController.pipedInstList
                        .map(
                          (element) => DropdownMenuItem(
                              value: element.apiUrl, child: Text(element.name)),
                        )
                        .toList(),
                    onChanged: (val) {
                      pipedLinkedController.selectedInst.value = val as String;
                    })),
              ),
              TextField(
                  controller: pipedLinkedController.usernameInputController,
                  decoration: const InputDecoration(hintText: "Username")),
              const SizedBox(
                height: 15,
              ),
              Obx(() => TextField(
                    controller: pipedLinkedController.passwordInputController,
                    decoration: InputDecoration(
                      hintText: "Password",
                      suffixIcon: IconButton(
                        icon: pipedLinkedController.passwordVisible.value
                            ? const Icon(Icons.visibility_off)
                            : const Icon(Icons.visibility),
                        onPressed: () =>
                            pipedLinkedController.passwordVisible.value =
                                !pipedLinkedController.passwordVisible.value,
                      ),
                    ),
                    obscureText: !pipedLinkedController.passwordVisible.value,
                  )),
              Expanded(
                  child: Obx(() => Center(
                      child: Text(pipedLinkedController.errorText.value,textAlign: TextAlign.center,)))),
              FilledButton(
                  onPressed: pipedLinkedController.link,
                  child: const Text("Link"))
            ],
          ),
        ));
  }
}

class PipedLinkedController extends GetxController {
  final usernameInputController = TextEditingController();
  final passwordInputController = TextEditingController();
  final pipedInstList = <PipedInstance>[
    PipedInstance(name: "Select Auth Instance        ", apiUrl: "")
  ].obs;
  final selectedInst = "".obs;
  final _pipedServices = Get.find<PipedServices>();
  final passwordVisible = false.obs;
  final errorText = "".obs;

  @override
  void onInit() {
    getAllInstList();
    super.onInit();
  }

  Future<void> getAllInstList() async {
    _pipedServices.getAllInstanceList().then((res) {
      if (res.code == 1) {
        pipedInstList.addAll(List<PipedInstance>.from(res.response));
      }
    });
  }

  void link() {
    errorText.value = "";
    final userName = usernameInputController.text;
    final password = passwordInputController.text;
    if (selectedInst.isEmpty) {
      errorText.value = "Please select Authentication instance!";
      return;
    }
    if (userName.isEmpty || password.isEmpty) {
      errorText.value = "All fields required";
      return;
    }
    _pipedServices
        .login(selectedInst.toString(), userName, password)
        .then((res) {
      if (res.code == 1) {
        printINFO("Login Successfull");
        Get.find<SettingsScreenController>().isLinkedWithPiped.value = true;
        Navigator.of(Get.context!).pop();
        ScaffoldMessenger.of(Get.context!).showSnackBar(snackbar(
            Get.context!, "Linked successfully!",
            size: SanckBarSize.MEDIUM));
      } else {
        errorText.value = res.errorMessage ?? "Error occurred!";
      }
    });
  }
}
