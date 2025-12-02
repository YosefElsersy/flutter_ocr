import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:translator/translator.dart';

class TtsScreen extends StatefulWidget {
  final File image;
  const TtsScreen({super.key, required this.image});

  @override
  State<TtsScreen> createState() => _TtsScreenState();
}

class _TtsScreenState extends State<TtsScreen> {
  late FlutterTts flutterTts;
  String recognizedText = "";
  bool isLoading = true;
  bool isSpeaking = false;

  String translatedText = "";
  bool isTranslating = false;

  // Translate options
  String selectedTranslateLang = "ar";
  final translationLanguages = {
    "Arabic": "ar",
    "English": "en",
    "French": "fr",
    "Spanish": "es",
    "German": "de",
  };

  // TTS options
  String selectedTtsLanguage = "en-US";
  final ttsLanguages = {
    "English": "en-US",
    "Arabic": "ar-SA",
    "French": "fr-FR",
    "Spanish": "es-ES",
    "German": "de-DE",
  };

  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts();
    _extractText();
  }

  Future<void> _extractText() async {
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final input = InputImage.fromFile(widget.image);
    final result = await recognizer.processImage(input);
    await recognizer.close();

    setState(() {
      recognizedText = result.text;
      isLoading = false;
    });
  }

  Future<void> _translateText() async {
    if (recognizedText.trim().isEmpty) return;

    setState(() => isTranslating = true);

    final translator = GoogleTranslator();
    final translation = await translator.translate(
      recognizedText,
      to: selectedTranslateLang,
    );

    translatedText = translation.text;
    isTranslating = false;
    setState(() {});
  }

  Future<void> _speak() async {
    final textToRead =
        translatedText.isNotEmpty ? translatedText : recognizedText;

    if (textToRead.trim().isEmpty) return;

    await flutterTts.setLanguage(selectedTtsLanguage);
    await flutterTts.setSpeechRate(0.4);
    await flutterTts.setPitch(1.0);

    setState(() => isSpeaking = true);
    await flutterTts.speak(textToRead);

    flutterTts.setCompletionHandler(() {
      setState(() => isSpeaking = false);
    });
  }

  Future<void> _stop() async {
    await flutterTts.stop();
    setState(() => isSpeaking = false);
  }

  @override
  Widget build(BuildContext context) {
    final textToDisplay =
        translatedText.isNotEmpty ? translatedText : recognizedText;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Text to Speech"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            recognizedText.isEmpty
                                ? "No text recognized."
                                : recognizedText,
                            style: const TextStyle(fontSize: 16),
                          ),

                          const SizedBox(height: 20),

                          if (isTranslating)
                            const Center(child: CircularProgressIndicator()),

                          if (translatedText.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Text(
                                translatedText,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blueAccent,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Translation language selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Translate to:  "),
                      DropdownButton<String>(
                        value: selectedTranslateLang,
                        items: translationLanguages.entries
                            .map(
                              (e) => DropdownMenuItem(
                                value: e.value,
                                child: Text(e.key),
                              ),
                            )
                            .toList(),
                        onChanged: (value) =>
                            setState(() => selectedTranslateLang = value!),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  // TTS Language selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Speak in:  "),
                      DropdownButton<String>(
                        value: selectedTtsLanguage,
                        items: ttsLanguages.entries
                            .map(
                              (e) => DropdownMenuItem(
                                value: e.value,
                                child: Text(e.key),
                              ),
                            )
                            .toList(),
                        onChanged: (value) =>
                            setState(() => selectedTtsLanguage = value!),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  Wrap(
                    spacing: 12,
                    children: [
                      ElevatedButton.icon(
                        onPressed: isTranslating ? null : _translateText,
                        icon: const Icon(Icons.translate),
                        label: const Text("Translate"),
                      ),
                      ElevatedButton.icon(
                        onPressed: isSpeaking
                            ? _stop
                            : (textToDisplay.trim().isEmpty ? null : _speak),
                        icon: Icon(
                          isSpeaking ? Icons.stop : Icons.play_arrow,
                        ),
                        label: Text(isSpeaking ? "Stop" : "Play"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
