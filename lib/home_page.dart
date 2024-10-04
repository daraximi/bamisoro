import 'package:animate_do/animate_do.dart';
import 'package:bamisoro/feature_box.dart';
import 'package:bamisoro/openai_service.dart';
import 'package:bamisoro/pallete.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController textEditingController = TextEditingController();
  final speechToText = SpeechToText();
  final flutterTts = FlutterTts();
  String lastWords = "";
  final OpenAIService openAIService = OpenAIService();
  String? generatedText;
  String? generatedImageUrl;
  int start = 200;
  int delay = 200;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initSpeechToText();
    initTTs();
  }

  void sendText() {
    final text = textEditingController.text.trim();
    textEditingController.clear();
    openAIService.chatGPTAPI(text);
  }

  Future<void> initSpeechToText() async {
    await speechToText.initialize();
    setState(() {});
  }

  Future<void> initTTs() async {
    await flutterTts.setSharedInstance(true);
    setState(() {});
  }

  /// Each time to start a speech recognition session
  Future<void> startListening() async {
    await speechToText.listen(onResult: onSpeechResult);
    setState(() {});
  }

  /// Manually stop the active speech recognition session
  /// Note that there are also timeouts that each platform enforces
  /// and the SpeechToText plugin supports setting timeouts on the
  /// listen method.
  Future<void> stopListening() async {
    await speechToText.stop();
    setState(() {});
  }

  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
  void onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      lastWords = result.recognizedWords;
      debugPrint(lastWords);
    });
  }

  Future<void> systemSpeak(String content) async {
    await flutterTts.speak(content);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    speechToText.stop();
    flutterTts.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: BounceInDown(child: const Text("bamisoro")),
        leading: const Icon(Icons.menu),
      ),
      body: Stack(children: [
        Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            child: Column(
              children: [
                //VA picture
                ZoomIn(
                  child: Stack(
                    children: [
                      Center(
                        child: Container(
                            height: 120,
                            width: 120,
                            margin: const EdgeInsets.only(top: 4),
                            decoration: const BoxDecoration(
                                color: Pallete.assistantCircleColor,
                                shape: BoxShape.circle)),
                      ),
                      Container(
                        height: 124,
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                                image: AssetImage(
                                    "assets/images/virtualAssistant.png"))),
                      )
                    ],
                  ),
                ),
                //Chat Bubble
                FadeInRight(
                  child: Visibility(
                    visible: generatedImageUrl == null,
                    child: Container(
                      margin:
                          const EdgeInsets.only(top: 30, left: 20, right: 20),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                          border: Border.all(color: Pallete.borderColor),
                          borderRadius: BorderRadius.circular(20)
                              .copyWith(topLeft: Radius.zero)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Text(
                          generatedText == null
                              ? "Good Morning, what can I help you with today?"
                              : generatedText!,
                          style: TextStyle(
                              fontFamily: "Cera Pro",
                              color: Pallete.mainFontColor,
                              fontSize: generatedText == null ? 25 : 18),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 50,
          child: Container(
            height: 65,
            width: 290,
            margin: const EdgeInsets.only(top: 10, left: 10, right: 2),
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            decoration: BoxDecoration(
                border: Border.all(color: Pallete.borderColor),
                borderRadius:
                    BorderRadius.circular(20).copyWith(topLeft: Radius.zero)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: SizedBox(
                    height: 65,
                    width: 200,
                    child: TextFormField(
                      controller: textEditingController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                          hintText: "Type your message here",
                          hintStyle: TextStyle(
                              fontFamily: "Cera Pro",
                              color: Pallete.mainFontColor,
                              fontSize: 16),
                          border: InputBorder.none),
                    ),
                  ),
                ),
                IconButton(
                    onPressed: () => sendText(),
                    icon: const Icon(
                      Icons.send,
                      color: Pallete.mainFontColor,
                    ))
              ],
            ),
          ),
        )
      ]),
      floatingActionButton: ZoomIn(
        delay: Duration(milliseconds: start + delay * 3),
        child: FloatingActionButton(
          backgroundColor: Pallete.firstSuggestionBoxColor,
          onPressed: () async {
            await flutterTts.stop();
            if (await speechToText.hasPermission && !speechToText.isListening) {
              await startListening();
            } else if (speechToText.isListening) {
              await stopListening();
              final speech = await openAIService.chatGPTAPI(lastWords);
              if (speech.contains('https')) {
                generatedImageUrl = speech;
                generatedText = null;
                setState(() {});
              } else {
                generatedText = speech;
                generatedImageUrl = null;
                setState(() {});
                await systemSpeak(speech);
              }

              debugPrint(speech);
            } else {
              await initSpeechToText();
            }
          },
          child: Icon(speechToText.isListening ? Icons.stop : Icons.mic),
        ),
      ),
    );
  }
}
