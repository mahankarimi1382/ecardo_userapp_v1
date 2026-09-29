import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import '../models/visa_models.dart';
import '../services/visa_service.dart';

class VisaController extends GetxController {
  late final VisaService _service;

  // State
  final RxList<VisaCatalogItem> catalogList = <VisaCatalogItem>[].obs;
  final Rxn<VisaCatalogItem> selectedCatalog = Rxn<VisaCatalogItem>();
  final RxList<VisaRequestModel> myRequests = <VisaRequestModel>[].obs;
  final Rxn<VisaRequestModel> currentRequest = Rxn<VisaRequestModel>();

  // Filter state for my requests
  final RxString selectedFilterStatus = 'ALL'.obs;
  final RxString selectedFilterCountry = 'ALL'.obs;

  // Loading states
  final RxBool isLoadingCatalog = false.obs;
  final RxBool isLoadingRequests = false.obs;
  final RxBool isLoadingDetail = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxBool isPaying = false.obs;

  // Document upload tracking
  final RxMap<String, File> pickedFiles = <String, File>{}.obs;
  final RxMap<String, bool> uploadProgress = <String, bool>{}.obs;

  // Form controllers
  final fullNameController = TextEditingController();
  final passportNumberController = TextEditingController();
  final nationalityController = TextEditingController(text: 'IR');
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final Rxn<DateTime> travelDate = Rxn<DateTime>();
  final Rxn<DateTime> returnDate = Rxn<DateTime>();

  @override
  void onInit() {
    super.onInit();
    _service = Get.isRegistered<VisaService>()
        ? Get.find<VisaService>()
        : Get.put(VisaService());
    loadCatalog();
  }

  @override
  void onClose() {
    fullNameController.dispose();
    passportNumberController.dispose();
    nationalityController.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.onClose();
  }

  void resetForm() {
    fullNameController.clear();
    passportNumberController.clear();
    phoneController.clear();
    emailController.clear();
    travelDate.value = null;
    returnDate.value = null;
    pickedFiles.clear();
    uploadProgress.clear();
  }

  /// Load catalog list from API
  Future<void> loadCatalog() async {
    isLoadingCatalog.value = true;
    try {
      final items = await _service.getCatalog();
      catalogList.assignAll(items);
    } catch (e) {
      ToastHelper().showErrorToast('Failed to load visa catalog: $e');
    } finally {
      isLoadingCatalog.value = false;
    }
  }

  /// Select catalog item
  void selectCatalog(VisaCatalogItem item) {
    selectedCatalog.value = item;
    resetForm();
  }

  /// Load user requests
  Future<void> loadUserRequests() async {
    isLoadingRequests.value = true;
    try {
      final list = await _service.getUserRequests();
      myRequests.assignAll(list);
    } catch (e) {
      ToastHelper().showErrorToast('Failed to load your visa requests: $e');
    } finally {
      isLoadingRequests.value = false;
    }
  }

  /// Filtered requests list
  List<VisaRequestModel> get filteredRequests {
    return myRequests.where((req) {
      final matchStatus = selectedFilterStatus.value == 'ALL' ||
          req.status.toUpperCase() == selectedFilterStatus.value.toUpperCase();
      final matchCountry = selectedFilterCountry.value == 'ALL' ||
          req.countryName.contains(selectedFilterCountry.value);
      return matchStatus && matchCountry;
    }).toList();
  }

  /// Load single request detail
  Future<void> loadRequestDetail(String caseNo) async {
    isLoadingDetail.value = true;
    try {
      final detail = await _service.getRequestDetail(caseNo);
      currentRequest.value = detail;
    } catch (e) {
      ToastHelper().showErrorToast('Failed to load request details: $e');
    } finally {
      isLoadingDetail.value = false;
    }
  }

  /// Pick local file for a document requirement
  void pickDocumentFile(String docKey, File file) {
    pickedFiles[docKey] = file;
  }

  /// Create visa application and navigate to payment
  Future<VisaRequestModel?> submitApplication() async {
    final catalog = selectedCatalog.value;
    if (catalog == null) return null;

    if (fullNameController.text.trim().isEmpty ||
        passportNumberController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty) {
      ToastHelper().showErrorToast('Please fill all required applicant fields');
      return null;
    }

    isSubmitting.value = true;
    try {
      final applicantInfo = {
        'full_name': fullNameController.text.trim(),
        'passport_number': passportNumberController.text.trim().toUpperCase(),
        'nationality': nationalityController.text.trim().toUpperCase(),
        'phone': phoneController.text.trim(),
        'email': emailController.text.trim(),
      };

      final String? travelDateStr = travelDate.value != null
          ? "${travelDate.value!.year}-${travelDate.value!.month.toString().padLeft(2, '0')}-${travelDate.value!.day.toString().padLeft(2, '0')}"
          : null;

      final String? returnDateStr = returnDate.value != null
          ? "${returnDate.value!.year}-${returnDate.value!.month.toString().padLeft(2, '0')}-${returnDate.value!.day.toString().padLeft(2, '0')}"
          : null;

      final created = await _service.createRequest(
        catalogId: catalog.id,
        applicantInfo: applicantInfo,
        travelDate: travelDateStr,
        returnDate: returnDateStr,
      );

      if (created != null) {
        currentRequest.value = created;

        // Upload any pre-picked documents
        for (final entry in pickedFiles.entries) {
          uploadProgress[entry.key] = true;
          await _service.uploadDocument(
            caseNo: created.caseNo,
            docKey: entry.key,
            file: entry.value,
          );
          uploadProgress[entry.key] = false;
        }

        // Refresh request detail
        await loadRequestDetail(created.caseNo);
        return currentRequest.value;
      }
    } catch (e) {
      ToastHelper().showErrorToast('Failed to create application: $e');
    } finally {
      isSubmitting.value = false;
    }
    return null;
  }

  /// Upload single document directly for current request
  Future<bool> uploadDocumentForCurrent(String docKey, File file) async {
    final req = currentRequest.value;
    if (req == null) return false;

    uploadProgress[docKey] = true;
    try {
      final success = await _service.uploadDocument(
        caseNo: req.caseNo,
        docKey: docKey,
        file: file,
      );
      if (success) {
        ToastHelper().showSuccessToast('Document uploaded successfully');
        await loadRequestDetail(req.caseNo);
        return true;
      }
    } catch (e) {
      ToastHelper().showErrorToast('Failed to upload document: $e');
    } finally {
      uploadProgress[docKey] = false;
    }
    return false;
  }

  /// Pay for visa request
  Future<bool> payForRequest(String caseNo) async {
    isPaying.value = true;
    try {
      final ok = await _service.payRequest(caseNo);
      if (ok) {
        // Also auto-submit to consultant queue
        await _service.submitRequest(caseNo);
        await loadRequestDetail(caseNo);
        ToastHelper().showSuccessToast('Payment completed and request submitted');
        return true;
      } else {
        ToastHelper().showErrorToast('Payment failed. Check your wallet balance.');
      }
    } catch (e) {
      ToastHelper().showErrorToast('Payment error: $e');
    } finally {
      isPaying.value = false;
    }
    return false;
  }

  /// Cancel request
  Future<bool> cancelRequest(String caseNo) async {
    try {
      final ok = await _service.cancelRequest(caseNo);
      if (ok) {
        ToastHelper().showSuccessToast('Request cancelled successfully');
        await loadRequestDetail(caseNo);
        await loadUserRequests();
        return true;
      }
    } catch (e) {
      ToastHelper().showErrorToast('Failed to cancel request: $e');
    }
    return false;
  }

  /// Confirm delivery of issued visa
  Future<bool> confirmDelivery(String caseNo) async {
    try {
      final ok = await _service.confirmDelivery(caseNo);
      if (ok) {
        ToastHelper().showSuccessToast('Delivery confirmed');
        await loadRequestDetail(caseNo);
        return true;
      }
    } catch (e) {
      ToastHelper().showErrorToast('Failed to confirm delivery: $e');
    }
    return false;
  }
}
