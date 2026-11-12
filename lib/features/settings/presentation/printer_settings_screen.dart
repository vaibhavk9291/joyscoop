import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_snack_bar.dart';
import '../../../core/widgets/background_gradient_scaffold.dart';
import '../../../core/widgets/circular_icon_button.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/secondary_button.dart';
import '../../../services/printing/models/printer_config.dart';
import '../../../services/printing/printer_service.dart';

class PrinterSettingsScreen extends ConsumerStatefulWidget {
  const PrinterSettingsScreen({super.key});

  @override
  ConsumerState<PrinterSettingsScreen> createState() =>
      _PrinterSettingsScreenState();
}

class _PrinterSettingsScreenState extends ConsumerState<PrinterSettingsScreen> {
  late TextEditingController _shopNameController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  late TextEditingController _gstinController;
  late TextEditingController _footerController;
  late TextEditingController _upiIdController;

  @override
  void initState() {
    super.initState();
    final config = ref.read(printerServiceProvider).config;
    _shopNameController = TextEditingController(text: config.shopName);
    _addressController = TextEditingController(text: config.address);
    _phoneController = TextEditingController(text: config.phone);
    _gstinController = TextEditingController(text: config.gstin);
    _footerController = TextEditingController(text: config.footerMessage);
    _upiIdController = TextEditingController(text: config.upiId);
  }

  @override
  void dispose() {
    _shopNameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _gstinController.dispose();
    _footerController.dispose();
    _upiIdController.dispose();
    super.dispose();
  }

  void _saveSettings() {
    final current = ref.read(printerServiceProvider).config;
    final updated = current.copyWith(
      shopName: _shopNameController.text.trim(),
      address: _addressController.text.trim(),
      phone: _phoneController.text.trim(),
      gstin: _gstinController.text.trim(),
      footerMessage: _footerController.text.trim(),
      upiId: _upiIdController.text.trim(),
    );
    ref.read(printerServiceProvider.notifier).updateConfig(updated);
    AppSnackBar.show(context, message: 'Printer settings saved');
  }

  @override
  Widget build(BuildContext context) {
    final printerState = ref.watch(printerServiceProvider);
    final printerNotifier = ref.read(printerServiceProvider.notifier);
    final config = printerState.config;
    final isIOS = defaultTargetPlatform == TargetPlatform.iOS;

    ref.listen<PrinterState>(printerServiceProvider, (previous, next) {
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        AppSnackBar.show(context, message: next.errorMessage!, isError: true);
      }
      if (next.successMessage != null &&
          next.successMessage != previous?.successMessage) {
        AppSnackBar.show(context, message: next.successMessage!);
      }
    });

    return BackgroundGradientScaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.screenPadding,
                vertical: AppDimensions.space12,
              ),
              child: Row(
                children: [
                  CircularIconButton(
                    icon: Icons.arrow_back_rounded,
                    tooltip: 'Back',
                    onTap: () {
                      _saveSettings();
                      Navigator.of(context).pop();
                    },
                  ),
                  const SizedBox(width: AppDimensions.space16),
                  Expanded(
                    child: Text(
                      'Thermal Printer',
                      style: AppTextStyles.title.copyWith(fontSize: 22),
                    ),
                  ),
                  if (printerState.isConnected)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.space12,
                        vertical: AppDimensions.space4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.liveGreen.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusChip),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.liveGreen,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Connected',
                            style: AppTextStyles.captionBold.copyWith(
                              color: AppColors.liveGreen,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.space12,
                        vertical: AppDimensions.space4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.textSecondary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusChip),
                      ),
                      child: Text(
                        'Offline',
                        style: AppTextStyles.captionBold.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.screenPadding,
                  vertical: AppDimensions.space8,
                ),
                children: [
                  // Section 1: Connection Type (USB / Bluetooth)
                  _buildCard(
                    title: 'Connection Type',
                    icon: Icons.cable_rounded,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // Bluetooth Option
                            Expanded(
                              child: _buildSelectableChip(
                                label: 'Bluetooth',
                                icon: Icons.bluetooth_rounded,
                                isSelected: config.connectionType ==
                                    PrinterConnectionType.bluetooth,
                                onTap: () {
                                  printerNotifier.updateConfig(
                                    config.copyWith(
                                      connectionType:
                                          PrinterConnectionType.bluetooth,
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: AppDimensions.space12),

                            // USB Option (hidden on iOS per requirements)
                            if (!isIOS)
                              Expanded(
                                child: _buildSelectableChip(
                                  label: 'USB OTG',
                                  icon: Icons.usb_rounded,
                                  isSelected: config.connectionType ==
                                      PrinterConnectionType.usb,
                                  onTap: () {
                                    printerNotifier.updateConfig(
                                      config.copyWith(
                                        connectionType:
                                            PrinterConnectionType.usb,
                                      ),
                                    );
                                  },
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: AppDimensions.space16),

                        // Scan Button & Discovery
                        Row(
                          children: [
                            Expanded(
                              child: PrimaryButton(
                                text: printerState.status == PrinterStatus.scanning
                                    ? 'Scanning...'
                                    : 'Scan for Printers',
                                icon: Icons.search_rounded,
                                isLoading:
                                    printerState.status == PrinterStatus.scanning,
                                onPressed: () {
                                  printerNotifier.scan();
                                },
                              ),
                            ),
                            if (printerState.isConnected) ...[
                              const SizedBox(width: AppDimensions.space12),
                              SecondaryButton(
                                text: 'Disconnect',
                                icon: Icons.link_off_rounded,
                                onPressed: () {
                                  printerNotifier.disconnect();
                                },
                              ),
                            ],
                          ],
                        ),

                        // Discovered Device List
                        if (printerState.discoveredPrinters.isNotEmpty) ...[
                          const SizedBox(height: AppDimensions.space16),
                          Text(
                            'Available Devices',
                            style: AppTextStyles.cardTitle.copyWith(fontSize: 14),
                          ),
                          const SizedBox(height: AppDimensions.space8),
                          ...printerState.discoveredPrinters.map((printer) {
                            final isCurrent = config.selectedPrinterAddress ==
                                printer.address;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: isCurrent
                                    ? AppColors.primaryTint
                                    : AppColors.surfaceMuted,
                                borderRadius: BorderRadius.circular(12),
                                border: isCurrent
                                    ? Border.all(
                                        color: AppColors.primary.withValues(alpha: 0.5),
                                      )
                                    : null,
                              ),
                              child: ListTile(
                                leading: Icon(
                                  printer.type == PrinterConnectionType.bluetooth
                                      ? Icons.bluetooth_audio_rounded
                                      : Icons.usb_rounded,
                                  color: isCurrent
                                      ? AppColors.primary
                                      : AppColors.textPrimary,
                                ),
                                title: Text(
                                  printer.name,
                                  style: AppTextStyles.cardTitle.copyWith(
                                    fontSize: 14,
                                    fontWeight: isCurrent
                                        ? FontWeight.w700
                                        : FontWeight.w600,
                                  ),
                                ),
                                subtitle: Text(
                                  printer.address,
                                  style: AppTextStyles.caption.copyWith(fontSize: 11),
                                ),
                                trailing: isCurrent && printerState.isConnected
                                    ? const Icon(
                                        Icons.check_circle_rounded,
                                        color: AppColors.primary,
                                      )
                                    : (printerState.status ==
                                                PrinterStatus.connecting &&
                                            config.selectedPrinterAddress ==
                                                printer.address
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: AppColors.primary,
                                            ),
                                          )
                                        : TextButton(
                                            onPressed: () =>
                                                printerNotifier.connect(printer),
                                            child: const Text('Connect'),
                                          )),
                                onTap: () => printerNotifier.connect(printer),
                              ),
                            );
                          }),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: AppDimensions.space16),

                  // Section 2: Paper Size & Options
                  _buildCard(
                    title: 'Paper & Layout',
                    icon: Icons.print_outlined,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Paper Width',
                          style: AppTextStyles.captionBold,
                        ),
                        const SizedBox(height: AppDimensions.space8),
                        Row(
                          children: [
                            Expanded(
                              child: _buildSelectableChip(
                                label: '58 mm (Standard)',
                                isSelected:
                                    config.paperSize == ReceiptPaperSize.mm58,
                                onTap: () {
                                  printerNotifier.updateConfig(
                                    config.copyWith(
                                      paperSize: ReceiptPaperSize.mm58,
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: AppDimensions.space12),
                            Expanded(
                              child: _buildSelectableChip(
                                label: '80 mm (Wide)',
                                isSelected:
                                    config.paperSize == ReceiptPaperSize.mm80,
                                onTap: () {
                                  printerNotifier.updateConfig(
                                    config.copyWith(
                                      paperSize: ReceiptPaperSize.mm80,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppDimensions.space16),

                        // Auto-print toggle
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          activeTrackColor: AppColors.primary,
                          title: Text(
                            'Auto-Print on Bill Save',
                            style: AppTextStyles.body.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            'Automatically trigger print when sale is recorded',
                            style: AppTextStyles.caption,
                          ),
                          value: config.autoPrint,
                          onChanged: (val) {
                            printerNotifier.updateConfig(
                              config.copyWith(autoPrint: val),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppDimensions.space16),

                  // Section 3: Receipt Header & Details
                  _buildCard(
                    title: 'Receipt Details',
                    icon: Icons.receipt_long_rounded,
                    child: Column(
                      children: [
                        _buildTextField(
                          controller: _shopNameController,
                          label: 'Shop Name',
                          hint: 'Joyscoop',
                          icon: Icons.store_rounded,
                          onChanged: (v) => _saveSettings(),
                        ),
                        const SizedBox(height: AppDimensions.space12),
                        _buildTextField(
                          controller: _addressController,
                          label: 'Address / Tagline',
                          hint: 'Ice Cream & Cold Coffee Bar',
                          icon: Icons.location_on_outlined,
                          onChanged: (v) => _saveSettings(),
                        ),
                        const SizedBox(height: AppDimensions.space12),
                        _buildTextField(
                          controller: _phoneController,
                          label: 'Phone Number',
                          hint: '+91 98765 43210',
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          onChanged: (v) => _saveSettings(),
                        ),
                        const SizedBox(height: AppDimensions.space12),
                        _buildTextField(
                          controller: _gstinController,
                          label: 'GSTIN (Optional)',
                          hint: '27AAAAA0000A1Z5',
                          icon: Icons.badge_outlined,
                          onChanged: (v) => _saveSettings(),
                        ),
                        const SizedBox(height: AppDimensions.space12),
                        _buildTextField(
                          controller: _upiIdController,
                          label: 'UPI ID for Payment QR (Optional)',
                          hint: 'joyscoop@upi',
                          icon: Icons.qr_code_2_rounded,
                          onChanged: (v) => _saveSettings(),
                        ),
                        const SizedBox(height: AppDimensions.space12),
                        _buildTextField(
                          controller: _footerController,
                          label: 'Footer Message',
                          hint: 'Thank you! Visit again 🍦',
                          icon: Icons.favorite_border_rounded,
                          onChanged: (v) => _saveSettings(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppDimensions.space24),

                  // Print Test Page Button
                  PrimaryButton(
                    text: 'Print Test Page',
                    icon: Icons.receipt_rounded,
                    isLoading: printerState.status == PrinterStatus.printing,
                    onPressed: () async {
                      _saveSettings();
                      await printerNotifier.printTestPage();
                    },
                  ),

                  const SizedBox(height: AppDimensions.space32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.space20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppDimensions.borderCard,
        boxShadow: AppShadows.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: AppDimensions.space8),
              Text(title, style: AppTextStyles.cardTitle),
            ],
          ),
          const SizedBox(height: AppDimensions.space16),
          child,
        ],
      ),
    );
  }

  Widget _buildSelectableChip({
    required String label,
    IconData? icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppDimensions.space12,
          horizontal: AppDimensions.space12,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(AppDimensions.radiusChip),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.dividerHairline,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: AppTextStyles.captionBold.copyWith(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: AppTextStyles.body,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: AppTextStyles.caption,
        prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20),
        filled: true,
        fillColor: AppColors.surfaceMuted,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.space16,
          vertical: AppDimensions.space12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusChip),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusChip),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}

