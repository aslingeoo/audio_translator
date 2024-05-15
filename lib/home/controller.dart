import 'dart:io';

import 'package:deepgram_speech_to_text/deepgram_speech_to_text.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:path_provider/path_provider.dart';
import 'package:translator/translator.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class HomeController extends GetxController {
  RxString localId = "en_IN".obs;
  late stt.SpeechToText _speech;
  RxBool isListening = false.obs;
  RxString text = ''.obs;
  RxList textList = [].obs;
  FlutterTts flutterTts = FlutterTts();
  RxString translateString = "".obs;
  RxBool isRecorded = false.obs;
  RxBool isLoading = false.obs;

  Deepgram deepgram =
      Deepgram("96801e983a97e9853eae3bfc849c4b91280a7f7e", baseQueryParams: {
    'model': 'nova-2-general',
    'detect_language': true,
    'filler_words': false,
    'punctuation': true,
    // more options here : https://developers.deepgram.com/reference/listen-file
  });
  @override
  void onInit() {
    super.onInit();
    _speech = stt.SpeechToText();
  }

  Future<void> listen() async {
    if (!isListening.value) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        isListening.value = true;
        isListening.refresh();
        await _speech.listen(
            localeId: localId.value,
            onResult: (val) {
              print(val.recognizedWords);
              text.value = val.recognizedWords;
              // textList.add(val.recognizedWords);
            });
      }
    }
  }

  stopRecord() {
    print(textList.value);
    // text.value = textList.value.join(' ');
    print(text.value);
    isListening.value = false;
    isRecorded.value = true;
    isListening.refresh();
    _speech.stop();
  }

  translateText(String textInput) async {
    if (text.value == "") {
      isListening.value = false;
      isRecorded.value = false;
      return;
    }
    isLoading.value = true;
    final translator = GoogleTranslator();
    Translation translation =
        await translator.translate(textInput, from: 'en', to: 'ta');
    await speakTranslatedText(translation.text);
  }

  Future<void> speakTranslatedText(String text) async {
    await flutterTts.setLanguage("ta-IN");
    isLoading.value = false;
    await flutterTts.setPitch(1);
    await flutterTts.speak(text);
  }

  onRestart() async {
    await flutterTts.stop();
    text.value = "";
    isListening.value = false;
    isRecorded.value = false;
  }

  uploadFile() async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.audio, allowMultiple: false);

    if (result != null) {
      isLoading.value = true;
      File file = File(result.files.single.path!);
      DeepgramSttResult res = await deepgram.transcribeFromFile(file);
      text.value = res.transcript;
      isListening.value = false;
      isRecorded.value = true;
      isLoading.value = false;
    } else {
      // User canceled the picker
    }
  }
}
