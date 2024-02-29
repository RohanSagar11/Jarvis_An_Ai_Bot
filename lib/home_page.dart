import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:jarvis/featuresbox.dart';
import 'package:jarvis/openapiservice.dart';
import 'package:jarvis/pallete.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String lastWords = '';
  final SpeechToText speechToText = SpeechToText();
  final OpenAiService openAiService = OpenAiService();
  final flutterTts = FlutterTts();
  String? imageUrl;
  String? genContent;
  int start = 200;
  int delay = -200;
  String? imageEncoded;
  @override
  void initState() {
    super.initState();
    initSpeechToText();
    // initTexttoSpeech();
  }

  // Future<void> initTexttoSpeech() async {
  //   // await flutterTts.setSharedInstance(true);
  //   setState(() {});
  // }

  Future<void> initSpeechToText() async {
    await speechToText.initialize();
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
    });
  }

  Future<void> systemSpeak(String speech) async {
    await flutterTts.speak(speech);
  }

  @override
  void dispose() {
    super.dispose();
    speechToText.stop();
    flutterTts.stop();
  }

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null) {
      imageEncoded = Uri.encodeFull(imageUrl!);
    }
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Bounce(child: const Text('Jarvis')),
        leading: Spin(child: const Icon(Icons.menu)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: Stack(
                children: [
                  // Container(
                  //   margin: const EdgeInsets.only(top: 4),
                  //   height: 120,
                  //   width: 120,
                  //   decoration: const BoxDecoration(
                  //       color: Pallete.assistantCircleColor,
                  //       shape: BoxShape.circle),
                  // ),
                  ZoomIn(
                    child: Image.asset(
                      'assets/images/virtualAssistant.png',
                      width: 120,
                      height: 120,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              margin:
                  const EdgeInsets.symmetric(horizontal: 40).copyWith(top: 30),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20).copyWith(
                    topLeft: Radius.zero,
                  ),
                  border: Border.all(
                    color: Pallete.borderColor,
                  )),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: FadeInLeft(
                  child: Text(
                    genContent == null
                        ? 'Good Morning, What task can i do for you ?'
                        : genContent!,
                    style: TextStyle(
                        color: Pallete.mainFontColor,
                        fontSize: genContent == null ? 20 : 18,
                        fontFamily: 'Cera Pro'),
                  ),
                ),
              ),
            ),
            if (imageUrl != null)
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(imageEncoded!),
                ),
              ),
            //suggestion lis
            Visibility(
              visible: genContent == null && imageUrl == null,
              child: Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.only(top: 10, left: 22),
                alignment: Alignment.centerLeft,
                child: const Text(
                  'Here are the few features',
                  style: TextStyle(
                      fontFamily: 'Cera Pro',
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: Pallete.mainFontColor),
                ),
              ),
            ),
            FadeInLeft(
              delay: Duration(milliseconds: start),
              child: const FeatureBox(
                  color: Pallete.firstSuggestionBoxColor,
                  headerText: "ChatGPT",
                  descriptionText:
                      "A Smarter way to stay organized and informed with ChatGPT"),
            ),
            FadeInRight(
              delay: Duration(milliseconds: start - delay),
              child: const FeatureBox(
                  color: Pallete.secondSuggestionBoxColor,
                  headerText: "Dall-E",
                  descriptionText:
                      "Get inspired and stay creative with your personal assistant powered by Dall-E"),
            ),
            FadeInLeft(
              delay: Duration(milliseconds: start + delay),
              child: const FeatureBox(
                  color: Pallete.thirdSuggestionBoxColor,
                  headerText: "Smart Voice Assistant",
                  descriptionText:
                      "Get the best of both worlds with a voice assistant powered by Dall-E and ChatGPT"),
            ),
          ],
        ),
      ),
      floatingActionButton: ElasticIn(
        child: FloatingActionButton(
          backgroundColor: Pallete.firstSuggestionBoxColor,
          shape: const CircleBorder(),
          onPressed: () async {
            // await startListening();
            // print(lastWords);
            if (await speechToText.hasPermission &&
                speechToText.isNotListening) {
              await startListening();
            }
            if (speechToText.isListening) {
              final speech = await openAiService.isArtPromtAPI(lastWords);
              if (speech.contains("https:")) {
                imageUrl = speech;
                genContent = null;
                // setState(() {
                //   imageUrl = speech;
                // });
              } else {
                imageUrl = null;
                genContent = speech;
                await systemSpeak(speech);
                setState(() {});
              }
              await stopListening();
            } else {
              initSpeechToText();
            }
          },
          child: const Icon(Icons.mic),
        ),
      ),
    );
  }
}
