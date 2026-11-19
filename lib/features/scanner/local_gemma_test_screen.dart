import 'package:flutter/material.dart';
import 'package:flutter_gemma/flutter_gemma.dart';

class LocalGemmaTestScreen extends StatefulWidget {
  const LocalGemmaTestScreen({super.key});

  @override
  State<LocalGemmaTestScreen> createState() => _LocalGemmaTestScreenState();
}

class _LocalGemmaTestScreenState extends State<LocalGemmaTestScreen> {
  bool _loading = false;
  bool _initialized = false;
  String _result = '';

  Future<void> _testGemma() async {
    if (_loading) return;

    setState(() {
      _loading = true;
      _result = '';
    });

    try {
      // Initialize only once while this screen is open.
      if (!_initialized) {
        await FlutterGemmaPlugin.instance.init(
          maxTokens: 512,
        );
        _initialized = true;
      }

      final response = await FlutterGemmaPlugin.instance.getResponse(
        prompt: 'Say hello in one sentence.',
      );

      if (!mounted) return;

      setState(() {
        _result = response ?? 'The model returned an empty response.';      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _result = 'Gemma test failed: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Local Gemma Test'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _loading ? null : _testGemma,
              child: Text(_loading ? 'Running...' : 'Test Gemma'),
            ),
            const SizedBox(height: 20),
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else
              SelectableText(_result),
          ],
        ),
      ),
    );
  }
}