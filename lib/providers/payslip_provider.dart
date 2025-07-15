import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../models/payslip_model.dart';
import '../services/payslip_parser.dart';

class PayslipProvider extends ChangeNotifier {
  PayslipData _payslipData = PayslipData.empty();
  bool _isLoading = false;
  String? _error;
  File? _selectedImage;

  PayslipData get payslipData => _payslipData;
  bool get isLoading => _isLoading;
  String? get error => _error;
  File? get selectedImage => _selectedImage;

  final ImagePicker _picker = ImagePicker();
  final TextRecognizer _textRecognizer = TextRecognizer();

  Future<void> pickImageFromGallery() async {
    try {
      _setLoading(true);
      _clearError();
      
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 100,
      );

      if (image != null) {
        _selectedImage = File(image.path);
        await _processImage(_selectedImage!);
      }
    } catch (e) {
      _setError('Failed to pick image: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> takePhotoFromCamera() async {
    try {
      _setLoading(true);
      _clearError();
      
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );

      if (image != null) {
        _selectedImage = File(image.path);
        await _processImage(_selectedImage!);
      }
    } catch (e) {
      _setError('Failed to take photo: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _processImage(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
      final extractedText = recognizedText.text;
      if (extractedText.isNotEmpty) {
        _payslipData = PayslipParser.parsePayslip(extractedText);

        if (_payslipData.isEmpty) {
          _setError('Could not extract payslip information from the image. Please ensure the image is clear and contains a valid payslip.');
        }
      } else {
        _setError('No text found in the image. Please try again with a clearer image.');
      }
    } catch (e) {
      _setError('OCR processing failed: $e');
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void clearPayslipData() {
    _payslipData = PayslipData.empty();
    _selectedImage = null;
    _clearError();
    notifyListeners();
  }

  @override
  void dispose() {
    _textRecognizer.close();
    super.dispose();
  }
} 