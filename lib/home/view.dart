import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:translate/home/controller.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeView extends GetResponsiveView<HomeController> {
  HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Obx(() => Center(
            child: Column(
              children: <Widget>[
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      !controller.isListening.value &&
                              controller.text.value != ""
                          ? Text(
                              controller.text.value,
                              style: const TextStyle(color: Colors.white),
                            )
                          : InkWell(
                              onTap: () {
                                if (!controller.isListening.value) {
                                  controller.listen();
                                }
                              },
                              child: SvgPicture.asset(
                                controller.isListening.value
                                    ? "asset/recordMic.svg"
                                    : "asset/mic.svg",
                                height: 400,
                                width: 100,
                              )),
                      const SizedBox(
                        height: 50,
                      ),
                    ],
                  ),
                ),
                controller.text.value == "" || !controller.isRecorded.value
                    ? Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                                onPressed: () {
                                  controller.uploadFile();
                                },
                                icon: const Icon(
                                  Icons.file_upload,
                                  size: 50,
                                  color: Colors.white,
                                )),
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromARGB(255, 227, 96, 45),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 80, vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                onPressed: controller.isListening.value
                                    ? () {
                                        controller.stopRecord();
                                      }
                                    : () {
                                        controller.listen();
                                      },
                                child: Text(
                                  controller.isListening.value
                                      ? "Stop Record"
                                      : "Start Record",
                                  style: const TextStyle(color: Colors.white),
                                )),
                            Container()
                          ],
                        ),
                      )
                    : Container(),
                controller.isRecorded.value
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 227, 96, 45),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 80, vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              onPressed: () async {
                                controller.translateString.value =
                                    await controller
                                        .translateText(controller.text.value);
                              },
                              child: const Text(
                                "Start Speak",
                                style: TextStyle(color: Colors.white),
                              )),
                          IconButton(
                              onPressed: () {
                                controller.onRestart();
                              },
                              icon: const Icon(
                                Icons.restart_alt,
                                size: 50,
                              ))
                        ],
                      )
                    : Container(),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          )),
    );
  }
}
