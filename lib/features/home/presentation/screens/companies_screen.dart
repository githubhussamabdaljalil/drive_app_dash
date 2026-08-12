import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/dashboard/dashboard_layout.dart';
import '../../../../core/widgets/app_button.dart';

import 'package:driver_app_dash/features/companies/data/models/company_model.dart';
import 'package:driver_app_dash/features/companies/presentation/cubit/company_cubit.dart';

class CompaniesScreen extends StatelessWidget {
  const CompaniesScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return DashboardLayout(
      activeRoute: '/admin/companies',
      pageTitle: 'الشركات',
      body: const _CompaniesBody(),
    );
  }
}

// ============================================================================
// COMPANIES BODY
// ============================================================================

class _CompaniesBody extends StatefulWidget {
  const _CompaniesBody();

  @override
  State<_CompaniesBody> createState() =>
      _CompaniesBodyState();
}

class _CompaniesBodyState extends State<_CompaniesBody> {
  String _search = '';

  @override
  void initState() {
    super.initState();

    context.read<CompanyCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CompanyCubit, CompanyState>(
      listener: (ctx, state) {
        if (state is CompanyError) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.danger,
            ),
          );
        }
      },
      builder: (ctx, state) {
        final companies = switch (state) {
          CompanyLoaded() => state.companies,
          CompanySubmitting() => state.companies,
          CompanyError() => state.companies ?? [],
          _ => <CompanyModel>[],
        };

        final query = _search
            .trim()
            .toLowerCase();

        final filtered = query.isEmpty
            ? companies
            : companies.where((company) {
                return company.name
                        .toLowerCase()
                        .contains(query) ||
                    (company.commercialNo
                            ?.toLowerCase()
                            .contains(query) ??
                        false);
              }).toList();

        final isLoading =
            state is CompanyLoading;

        final isSubmitting =
            state is CompanySubmitting;

        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              // ============================================================
              // HEADER
              // ============================================================

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'إدارة الشركات',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight:
                                FontWeight.w700,
                            color:
                                AppColors.textPrimary,
                          ),
                        ),

                        const SizedBox(height: 3),

                        Text(
                          '${companies.length} شركة مسجلة',
                          style: const TextStyle(
                            fontSize: 13,
                            color:
                                AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  AppButton(
                    label: 'إضافة شركة',
                    icon: Icons.add,
                    width: 150,
                    height: 40,
                    onPressed: () {
                      _showForm(ctx);
                    },
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ============================================================
              // SEARCH
              // ============================================================

              SizedBox(
                height: 42,
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      _search = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText:
                        'بحث باسم الشركة أو الرقم التجاري...',

                    prefixIcon: const Icon(
                      Icons.search,
                      size: 18,
                      color: AppColors.textHint,
                    ),

                    contentPadding:
                        const EdgeInsets.symmetric(
                      horizontal: 14,
                    ),

                    filled: true,

                    fillColor:
                        AppColors.surface,

                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(8),
                      borderSide:
                          const BorderSide(
                        color:
                            AppColors.border,
                      ),
                    ),

                    enabledBorder:
                        OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(8),
                      borderSide:
                          const BorderSide(
                        color:
                            AppColors.border,
                      ),
                    ),

                    focusedBorder:
                        OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(8),
                      borderSide:
                          const BorderSide(
                        color:
                            AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ============================================================
              // TABLE
              // ============================================================

              Expanded(
                child: isLoading
                    ? const Center(
                        child:
                            CircularProgressIndicator(),
                      )
                    : filtered.isEmpty
                        ? _EmptyState(
                            onAdd: () {
                              _showForm(ctx);
                            },
                          )
                        : _CompanyTable(
                            companies: filtered,
                            isSubmitting:
                                isSubmitting,
                            onEdit: (company) {
                              _showForm(
                                ctx,
                                company: company,
                              );
                            },
                            onToggle: (company) {
                              ctx
                                  .read<CompanyCubit>()
                                  .toggleStatus(
                                    company,
                                  );
                            },
                            onDelete: (company) {
                              _confirmDelete(
                                ctx,
                                company,
                              );
                            },
                          ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ==========================================================================
  // SHOW FORM
  // ==========================================================================

  void _showForm(
    BuildContext context, {
    CompanyModel? company,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return BlocProvider.value(
          value: context.read<CompanyCubit>(),
          child: _CompanyFormDialog(
            company: company,
          ),
        );
      },
    );
  }

  // ==========================================================================
  // DELETE CONFIRMATION
  // ==========================================================================

  void _confirmDelete(
    BuildContext context,
    CompanyModel company,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(12),
          ),

          title: const Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: AppColors.danger,
                size: 22,
              ),

              SizedBox(width: 8),

              Text(
                'تأكيد الحذف',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight:
                      FontWeight.w700,
                  color:
                      AppColors.textPrimary,
                ),
              ),
            ],
          ),

          content: Text(
            'هل أنت متأكد من حذف شركة "${company.name}"؟\n'
            'لا يمكن التراجع عن هذا الإجراء.',
            style: const TextStyle(
              fontSize: 13,
              color:
                  AppColors.textSecondary,
              height: 1.6,
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                );
              },
              child: const Text(
                'إلغاء',
                style: TextStyle(
                  color:
                      AppColors.textSecondary,
                ),
              ),
            ),

            ElevatedButton(
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    AppColors.danger,
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                );

                context
                    .read<CompanyCubit>()
                    .delete(company.id);
              },
              child: const Text(
                'حذف',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ============================================================================
// COMPANY TABLE
// ============================================================================

class _CompanyTable extends StatelessWidget {
  final List<CompanyModel> companies;
  final bool isSubmitting;

  final void Function(CompanyModel) onEdit;
  final void Function(CompanyModel) onToggle;
  final void Function(CompanyModel) onDelete;

  const _CompanyTable({
    required this.companies,
    required this.isSubmitting,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius:
            BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(.04),
            blurRadius: 8,
            offset:
                const Offset(0, 2),
          ),
        ],
      ),

      child: Column(
        children: [
          // ================================================================
          // HEADER
          // ================================================================

          Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 12,
            ),

            decoration:
                const BoxDecoration(
              color: AppColors.background,

              borderRadius:
                  BorderRadius.vertical(
                top:
                    Radius.circular(12),
              ),

              border: Border(
                bottom: BorderSide(
                  color:
                      AppColors.border,
                ),
              ),
            ),

            child: const Row(
              children: [
                Expanded(
                  flex: 4,
                  child:
                      _HeaderCell(
                    'الشركة',
                  ),
                ),

                Expanded(
                  flex: 1,
                  child:
                      _HeaderCell(
                    'المديرون',
                    centered: true,
                  ),
                ),

                Expanded(
                  flex: 1,
                  child:
                      _HeaderCell(
                    'السائقون',
                    centered: true,
                  ),
                ),

                Expanded(
                  flex: 1,
                  child:
                      _HeaderCell(
                    'المركبات',
                    centered: true,
                  ),
                ),

                Expanded(
                  flex: 2,
                  child:
                      _HeaderCell(
                    'الانتهاء',
                    centered: true,
                  ),
                ),

                Expanded(
                  flex: 2,
                  child:
                      _HeaderCell(
                    'الحالة',
                    centered: true,
                  ),
                ),

                SizedBox(
                  width: 120,
                  child:
                      _HeaderCell(
                    'إجراءات',
                    centered: true,
                  ),
                ),
              ],
            ),
          ),

          // ================================================================
          // ROWS
          // ================================================================

          Expanded(
            child: Stack(
              children: [
                ListView.separated(
                  itemCount:
                      companies.length,

                  separatorBuilder:
                      (_, __) {
                    return const Divider(
                      height: 1,
                      color:
                          AppColors.divider,
                    );
                  },

                  itemBuilder:
                      (_, index) {
                    return _CompanyRow(
                      company:
                          companies[index],
                      onEdit:
                          onEdit,
                      onToggle:
                          onToggle,
                      onDelete:
                          onDelete,
                    );
                  },
                ),

                if (isSubmitting)
                  Container(
                    color:
                        Colors.white
                            .withOpacity(.6),

                    child:
                        const Center(
                      child:
                          CircularProgressIndicator(),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// HEADER CELL
// ============================================================================

class _HeaderCell extends StatelessWidget {
  final String text;
  final bool centered;

  const _HeaderCell(
    this.text, {
    this.centered = false,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: centered
          ? Alignment.center
          : Alignment.centerRight,

      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight:
              FontWeight.w700,
          color:
              AppColors.textSecondary,
          letterSpacing: .3,
        ),
      ),
    );
  }
}

// ============================================================================
// COMPANY ROW
// ============================================================================

class _CompanyRow
    extends StatefulWidget {
  final CompanyModel company;

  final void Function(CompanyModel)
      onEdit;

  final void Function(CompanyModel)
      onToggle;

  final void Function(CompanyModel)
      onDelete;

  const _CompanyRow({
    required this.company,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  State<_CompanyRow> createState() =>
      _CompanyRowState();
}

class _CompanyRowState
    extends State<_CompanyRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final c = widget.company;

    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _hovered = true;
        });
      },

      onExit: (_) {
        setState(() {
          _hovered = false;
        });
      },

      child: AnimatedContainer(
        duration:
            const Duration(
          milliseconds: 120,
        ),

        color: _hovered
            ? AppColors.primarySurface
                .withOpacity(.4)
            : Colors.transparent,

        padding:
            const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),

        child: Row(
          children: [
            // ================================================================
            // COMPANY
            // ================================================================

            Expanded(
              flex: 4,
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,

                    decoration:
                        BoxDecoration(
                      color: AppColors
                          .primary
                          .withOpacity(.1),

                      borderRadius:
                          BorderRadius
                              .circular(8),
                    ),

                    child: Center(
                      child: Text(
                        c.name.isNotEmpty
                            ? c.name[0]
                                .toUpperCase()
                            : '?',

                        style:
                            const TextStyle(
                          fontSize: 15,
                          fontWeight:
                              FontWeight.w700,
                          color:
                              AppColors
                                  .primary,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    width: 10,
                  ),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,

                      children: [
                        Text(
                          c.name,
                          style:
                              const TextStyle(
                            fontSize: 13,
                            fontWeight:
                                FontWeight
                                    .w600,
                            color:
                                AppColors
                                    .textPrimary,
                          ),
                          overflow:
                              TextOverflow
                                  .ellipsis,
                        ),

                        if (c.commercialNo !=
                                null &&
                            c.commercialNo!
                                .isNotEmpty)
                          Text(
                            c.commercialNo!,
                            style:
                                const TextStyle(
                              fontSize: 11,
                              color:
                                  AppColors
                                      .textHint,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ================================================================
            // MANAGERS
            // ================================================================

            Expanded(
              flex: 1,
              child: _CountCell(
                icon:
                    Icons.person_outline,
                value:
                    c.managersCount,
              ),
            ),

            // ================================================================
            // DRIVERS
            // ================================================================

            Expanded(
              flex: 1,
              child: _CountCell(
                icon:
                    Icons.drive_eta_outlined,
                value:
                    c.driversCount,
              ),
            ),

            // ================================================================
            // VEHICLES
            // ================================================================

            Expanded(
              flex: 1,
              child: _CountCell(
                icon:
                    Icons.local_shipping_outlined,
                value:
                    c.vehiclesCount,
              ),
            ),

            // ================================================================
            // EXPIRY
            // ================================================================

            Expanded(
              flex: 2,
              child: Center(
                child: Text(
                  c.expiryDate
                              ?.isNotEmpty ==
                          true
                      ? c.expiryDate!
                      : '—',

                  style:
                      const TextStyle(
                    fontSize: 12,
                    color:
                        AppColors
                            .textSecondary,
                  ),
                ),
              ),
            ),

            // ================================================================
            // STATUS
            // ================================================================

            Expanded(
              flex: 2,
              child: Center(
                child: _StatusBadge(
                  active:
                      c.isActive,
                ),
              ),
            ),

            // ================================================================
            // ACTIONS
            // ================================================================

            SizedBox(
              width: 120,

              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment
                        .center,

                children: [
                  _ActionBtn(
                    icon:
                        Icons.edit_outlined,
                    color:
                        AppColors.primary,
                    tooltip:
                        'تعديل',
                    onTap: () =>
                        widget.onEdit(
                      c,
                    ),
                  ),

                  const SizedBox(
                    width: 6,
                  ),

                  _ActionBtn(
                    icon: c.isActive
                        ? Icons
                            .pause_circle_outline
                        : Icons
                            .play_circle_outline,

                    color: c.isActive
                        ? AppColors
                            .warning
                        : AppColors
                            .success,

                    tooltip: c.isActive
                        ? 'تعطيل'
                        : 'تفعيل',

                    onTap: () =>
                        widget.onToggle(
                      c,
                    ),
                  ),

                  const SizedBox(
                    width: 6,
                  ),

                  _ActionBtn(
                    icon:
                        Icons.delete_outline,
                    color:
                        AppColors.danger,
                    tooltip:
                        'حذف',
                    onTap: () =>
                        widget.onDelete(
                      c,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// COUNT CELL
// ============================================================================

class _CountCell
    extends StatelessWidget {
  final IconData icon;
  final int value;

  const _CountCell({
    required this.icon,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisSize:
            MainAxisSize.min,

        children: [
          Icon(
            icon,
            size: 15,
            color:
                AppColors.textHint,
          ),

          const SizedBox(
            width: 5,
          ),

          Text(
            '$value',
            style:
                const TextStyle(
              fontSize: 13,
              fontWeight:
                  FontWeight.w600,
              color:
                  AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// STATUS BADGE
// ============================================================================

class _StatusBadge
    extends StatelessWidget {
  final bool active;

  const _StatusBadge({
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ),

      decoration:
          BoxDecoration(
        color: active
            ? AppColors
                .successSurface
            : AppColors
                .dangerSurface,

        borderRadius:
            BorderRadius.circular(
          20,
        ),
      ),

      child: Row(
        mainAxisSize:
            MainAxisSize.min,

        children: [
          Container(
            width: 6,
            height: 6,

            decoration:
                BoxDecoration(
              shape:
                  BoxShape.circle,

              color: active
                  ? AppColors
                      .success
                  : AppColors
                      .danger,
            ),
          ),

          const SizedBox(
            width: 5,
          ),

          Text(
            active
                ? 'نشطة'
                : 'معطلة',

            style: TextStyle(
              fontSize: 11,
              fontWeight:
                  FontWeight.w600,

              color: active
                  ? AppColors
                      .success
                  : AppColors
                      .danger,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// ACTION BUTTON
// ============================================================================

class _ActionBtn
    extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,

      child: InkWell(
        onTap: onTap,

        borderRadius:
            BorderRadius.circular(
          6,
        ),

        child: Container(
          padding:
              const EdgeInsets.all(
            6,
          ),

          decoration:
              BoxDecoration(
            color: color.withOpacity(
              .08,
            ),

            borderRadius:
                BorderRadius.circular(
              6,
            ),
          ),

          child: Icon(
            icon,
            size: 16,
            color: color,
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// EMPTY STATE
// ============================================================================

class _EmptyState
    extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyState({
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize:
            MainAxisSize.min,

        children: [
          Container(
            width: 72,
            height: 72,

            decoration:
                BoxDecoration(
              color:
                  AppColors
                      .primarySurface,

              borderRadius:
                  BorderRadius.circular(
                20,
              ),
            ),

            child: const Icon(
              Icons.business_outlined,
              size: 36,
              color:
                  AppColors.primary,
            ),
          ),

          const SizedBox(
            height: 16,
          ),

          const Text(
            'لا توجد شركات بعد',

            style:
                TextStyle(
              fontSize: 16,
              fontWeight:
                  FontWeight.w600,
              color:
                  AppColors
                      .textPrimary,
            ),
          ),

          const SizedBox(
            height: 6,
          ),

          const Text(
            'ابدأ بإضافة أول شركة في المنصة',

            style:
                TextStyle(
              fontSize: 13,
              color:
                  AppColors
                      .textSecondary,
            ),
          ),

          const SizedBox(
            height: 20,
          ),

          AppButton(
            label:
                'إضافة شركة',
            icon:
                Icons.add,
            width: 160,
            height: 40,
            onPressed:
                onAdd,
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// COMPANY FORM DIALOG
// ============================================================================

class _CompanyFormDialog
    extends StatefulWidget {
  final CompanyModel? company;

  const _CompanyFormDialog({
    this.company,
  });

  @override
  State<_CompanyFormDialog> createState() =>
      _CompanyFormDialogState();
}

class _CompanyFormDialogState
    extends State<_CompanyFormDialog> {
  final _formKey =
      GlobalKey<FormState>();

  late final TextEditingController
      _name;

  late final TextEditingController
      _commercialNo;

  late final TextEditingController
      _expiryDate;

  late final TextEditingController
      _managerName;

  late final TextEditingController
      _managerEmail;

  late final TextEditingController
      _managerPhone;

  bool _isSubmitting = false;

  bool get _isEdit =>
      widget.company != null;

  // ==========================================================================
  // INIT
  // ==========================================================================

  @override
  void initState() {
    super.initState();

    final c = widget.company;

    _name =
        TextEditingController(
      text: c?.name ?? '',
    );

    _commercialNo =
        TextEditingController(
      text: _removeCommercialPrefix(
        c?.commercialNo,
      ),
    );

    _expiryDate =
        TextEditingController(
      text: c?.expiryDate ?? '',
    );

    _managerName =
        TextEditingController();

    _managerEmail =
        TextEditingController();

    _managerPhone =
        TextEditingController();
  }

  // ==========================================================================
  // REMOVE CR-
  // ==========================================================================

  String _removeCommercialPrefix(
    String? value,
  ) {
    if (value == null ||
        value.trim().isEmpty) {
      return '';
    }

    final normalized =
        value.trim();

    if (normalized
        .toUpperCase()
        .startsWith('CR-')) {
      return normalized.substring(3);
    }

    return normalized;
  }

  // ==========================================================================
  // DISPOSE
  // ==========================================================================

  @override
  void dispose() {
    _name.dispose();
    _commercialNo.dispose();
    _expiryDate.dispose();

    _managerName.dispose();
    _managerEmail.dispose();
    _managerPhone.dispose();

    super.dispose();
  }

  // ==========================================================================
  // SUBMIT
  // ==========================================================================

  Future<void> _submit() async {
    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    if (_isSubmitting) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final commercialNumber =
        _commercialNo.text.trim();

    final body =
        <String, dynamic>{
      'name':
          _name.text.trim(),

      if (commercialNumber
          .isNotEmpty)
        'commercial_no':
            'CR-$commercialNumber',

      if (_expiryDate.text
          .trim()
          .isNotEmpty)
        'expiry_date':
            _expiryDate.text.trim(),
    };

    if (!_isEdit) {
      body['manager_name'] =
          _managerName.text.trim();

      body['manager_email'] =
          _managerEmail.text.trim();

      body['manager_phone'] =
          _managerPhone.text.trim();
    }

    final cubit =
        context.read<CompanyCubit>();

    bool success;

    if (_isEdit) {
      success = await cubit.update(
        widget.company!.id,
        body,
      );
    } else {
      success = await cubit.create(
        body,
      );
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _isSubmitting = false;
    });

    if (success) {
      Navigator.pop(context);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(
            _isEdit
                ? 'تم تعديل الشركة بنجاح'
                : 'تمت إضافة الشركة بنجاح',
          ),
          backgroundColor:
              AppColors.success,
        ),
      );
    }
  }

  // ==========================================================================
  // DATE PICKER
  // ==========================================================================

  Future<void> _pickExpiryDate() async {
    DateTime initialDate =
        DateTime.now();

    if (_expiryDate.text
        .trim()
        .isNotEmpty) {
      try {
        final parsed =
            DateTime.parse(
          _expiryDate.text.trim(),
        );

        // إذا كان التاريخ القديم
        // قبل اليوم، نستخدم اليوم
        // حتى لا يحدث خطأ في DatePicker.
        if (parsed.isBefore(
          DateTime.now(),
        )) {
          initialDate =
              DateTime.now();
        } else {
          initialDate = parsed;
        }
      } catch (_) {
        initialDate =
            DateTime.now();
      }
    }

    final picked =
        await showDatePicker(
      context: context,

      initialDate:
          initialDate,

      firstDate:
          DateTime.now(),

      lastDate:
          DateTime(2100),

      initialDatePickerMode:
          DatePickerMode.day,

      initialEntryMode:
          DatePickerEntryMode
              .calendar,

      helpText:
          'اختر تاريخ انتهاء الشركة',

      cancelText:
          'إلغاء',

      confirmText:
          'اختيار',
    );

    if (picked == null ||
        !mounted) {
      return;
    }

    final year =
        picked.year
            .toString()
            .padLeft(4, '0');

    final month =
        picked.month
            .toString()
            .padLeft(2, '0');

    final day =
        picked.day
            .toString()
            .padLeft(2, '0');

    setState(() {
      _expiryDate.text =
          '$year-$month-$day';
    });
  }

  // ==========================================================================
  // BUILD
  // ==========================================================================

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(
          16,
        ),
      ),

      child: Container(
        width: 500,

        padding:
            const EdgeInsets.all(
          28,
        ),

        child: Form(
          key: _formKey,

          child:
              SingleChildScrollView(
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,

              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,

              children: [
                // ============================================================
                // HEADER
                // ============================================================

                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,

                      decoration:
                          BoxDecoration(
                        color:
                            AppColors
                                .primarySurface,

                        borderRadius:
                            BorderRadius
                                .circular(
                          10,
                        ),
                      ),

                      child:
                          const Icon(
                        Icons
                            .business_outlined,
                        color:
                            AppColors
                                .primary,
                        size: 20,
                      ),
                    ),

                    const SizedBox(
                      width: 12,
                    ),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,

                        children: [
                          Text(
                            _isEdit
                                ? 'تعديل الشركة'
                                : 'إضافة شركة جديدة',

                            style:
                                const TextStyle(
                              fontSize: 16,
                              fontWeight:
                                  FontWeight
                                      .w700,
                              color:
                                  AppColors
                                      .textPrimary,
                            ),
                          ),

                          Text(
                            _isEdit
                                ? 'تعديل بيانات ${widget.company!.name}'
                                : 'أدخل بيانات الشركة',

                            style:
                                const TextStyle(
                              fontSize: 12,
                              color:
                                  AppColors
                                      .textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    IconButton(
                      onPressed:
                          _isSubmitting
                              ? null
                              : () {
                                  Navigator
                                      .pop(
                                    context,
                                  );
                                },

                      icon:
                          const Icon(
                        Icons.close,
                        size: 18,
                        color:
                            AppColors
                                .textHint,
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height: 20,
                ),

                const Divider(
                  color:
                      AppColors.border,
                  height: 1,
                ),

                const SizedBox(
                  height: 20,
                ),

                // ============================================================
                // COMPANY DATA
                // ============================================================

                const _SectionLabel(
                  'بيانات الشركة',
                ),

                const SizedBox(
                  height: 12,
                ),

                _FormField(
                  label:
                      'اسم الشركة *',

                  controller:
                      _name,

                  hint:
                      'مثال: شركة النقل الحديث',

                  validator:
                      (value) {
                    if (value
                            ?.trim()
                            .isEmpty ??
                        true) {
                      return 'الاسم مطلوب';
                    }

                    return null;
                  },
                ),

                const SizedBox(
                  height: 12,
                ),

                Row(
                  children: [
                    // ========================================================
                    // COMMERCIAL NUMBER
                    // ========================================================

                    Expanded(
                      child:
                          _CommercialNumberField(
                        controller:
                            _commercialNo,
                      ),
                    ),

                    const SizedBox(
                      width: 12,
                    ),

                    // ========================================================
                    // EXPIRY DATE
                    // ========================================================

                    Expanded(
                      child:
                          _ExpiryDateField(
                        controller:
                            _expiryDate,

                        onTap:
                            _pickExpiryDate,
                      ),
                    ),
                  ],
                ),

                // ============================================================
                // INITIAL MANAGER
                // ============================================================

                if (!_isEdit) ...[
                  const SizedBox(
                    height: 20,
                  ),

                  const Divider(
                    color:
                        AppColors.border,
                    height: 1,
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  const _SectionLabel(
                    'بيانات المدير الأولي',
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  _FormField(
                    label:
                        'اسم المدير *',

                    controller:
                        _managerName,

                    hint:
                        'الاسم الكامل',

                    validator:
                        (value) {
                      if (value
                              ?.trim()
                              .isEmpty ??
                          true) {
                        return 'الاسم مطلوب';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  Row(
                    children: [
                      Expanded(
                        child:
                            _FormField(
                          label:
                              'البريد الإلكتروني *',

                          controller:
                              _managerEmail,

                          hint:
                              'manager@company.com',

                          keyboardType:
                              TextInputType
                                  .emailAddress,

                          validator:
                              (value) {
                            if (value
                                    ?.trim()
                                    .isEmpty ??
                                true) {
                              return 'البريد مطلوب';
                            }

                            return null;
                          },
                        ),
                      ),

                      const SizedBox(
                        width: 12,
                      ),

                      Expanded(
                        child:
                            _FormField(
                          label:
                              'رقم الهاتف *',

                          controller:
                              _managerPhone,

                          hint:
                              '05xxxxxxxx',

                          keyboardType:
                              TextInputType
                                  .phone,

                          validator:
                              (value) {
                            if (value
                                    ?.trim()
                                    .isEmpty ??
                                true) {
                              return 'الهاتف مطلوب';
                            }

                            return null;
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  Container(
                    padding:
                        const EdgeInsets
                            .all(
                      10,
                    ),

                    decoration:
                        BoxDecoration(
                      color: AppColors
                          .primarySurface,

                      borderRadius:
                          BorderRadius
                              .circular(
                        8,
                      ),
                    ),

                    child:
                        const Row(
                      children: [
                        Icon(
                          Icons
                              .info_outline,
                          size: 14,
                          color:
                              AppColors
                                  .primary,
                        ),

                        SizedBox(
                          width: 8,
                        ),

                        Expanded(
                          child: Text(
                            'سيتم إنشاء حساب المدير تلقائياً وإرسال كلمة المرور المؤقتة.',

                            style:
                                TextStyle(
                              fontSize: 11,
                              color:
                                  AppColors
                                      .primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(
                  height: 24,
                ),

                // ============================================================
                // ACTIONS
                // ============================================================

                Row(
                  children: [
                    Expanded(
                      child:
                          OutlinedButton(
                        onPressed:
                            _isSubmitting
                                ? null
                                : () {
                                    Navigator
                                        .pop(
                                      context,
                                    );
                                  },

                        style:
                            OutlinedButton
                                .styleFrom(
                          side:
                              const BorderSide(
                            color:
                                AppColors
                                    .border,
                          ),

                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(
                              8,
                            ),
                          ),

                          padding:
                              const EdgeInsets
                                  .symmetric(
                            vertical: 12,
                          ),
                        ),

                        child:
                            const Text(
                          'إلغاء',

                          style:
                              TextStyle(
                            color:
                                AppColors
                                    .textSecondary,
                            fontWeight:
                                FontWeight
                                    .w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(
                      width: 12,
                    ),

                    Expanded(
                      child:
                          AppButton(
                        label:
                            _isSubmitting
                                ? 'جاري الحفظ...'
                                : _isEdit
                                    ? 'حفظ التعديلات'
                                    : 'إضافة الشركة',

                        icon:
                            _isSubmitting
                                ? Icons
                                    .hourglass_top
                                : _isEdit
                                    ? Icons
                                        .save_outlined
                                    : Icons
                                        .add,

                        height: 44,

                        onPressed:
                            _isSubmitting
                                ? null
                                : _submit,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// SECTION LABEL
// ============================================================================

class _SectionLabel
    extends StatelessWidget {
  final String text;

  const _SectionLabel(
    this.text,
  );

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 14,

          decoration:
              BoxDecoration(
            color:
                AppColors.primary,

            borderRadius:
                BorderRadius.circular(
              2,
            ),
          ),
        ),

        const SizedBox(
          width: 7,
        ),

        Text(
          text,

          style:
              const TextStyle(
            fontSize: 13,
            fontWeight:
                FontWeight.w700,
            color:
                AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// NORMAL FORM FIELD
// ============================================================================

class _FormField
    extends StatelessWidget {
  final String label;
  final TextEditingController
      controller;
  final String hint;
  final TextInputType? keyboardType;
  final String? Function(String?)?
      validator;

  const _FormField({
    required this.label,
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [
        Text(
          label,

          style:
              const TextStyle(
            fontSize: 12,
            fontWeight:
                FontWeight.w600,
            color:
                AppColors
                    .textSecondary,
          ),
        ),

        const SizedBox(
          height: 5,
        ),

        TextFormField(
          controller:
              controller,

          keyboardType:
              keyboardType,

          validator:
              validator,

          style:
              const TextStyle(
            fontSize: 13,
            color:
                AppColors
                    .textPrimary,
          ),

          decoration:
              InputDecoration(
            hintText:
                hint,

            contentPadding:
                const EdgeInsets
                    .symmetric(
              horizontal: 12,
              vertical: 10,
            ),

            filled: true,

            fillColor:
                AppColors
                    .surfaceInput,

            border:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius
                      .circular(
                8,
              ),

              borderSide:
                  const BorderSide(
                color:
                    AppColors.border,
              ),
            ),

            enabledBorder:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius
                      .circular(
                8,
              ),

              borderSide:
                  const BorderSide(
                color:
                    AppColors.border,
              ),
            ),

            focusedBorder:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius
                      .circular(
                8,
              ),

              borderSide:
                  const BorderSide(
                color:
                    AppColors.primary,
                width: 1.5,
              ),
            ),

            errorBorder:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius
                      .circular(
                8,
              ),

              borderSide:
                  const BorderSide(
                color:
                    AppColors.danger,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// COMMERCIAL NUMBER FIELD
// ============================================================================

class _CommercialNumberField
    extends StatelessWidget {
  final TextEditingController
      controller;

  const _CommercialNumberField({
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [
        const Text(
          'الرقم التجاري',

          style:
              TextStyle(
            fontSize: 12,
            fontWeight:
                FontWeight.w600,
            color:
                AppColors
                    .textSecondary,
          ),
        ),

        const SizedBox(
          height: 5,
        ),

        TextFormField(
          controller:
              controller,

          keyboardType:
              TextInputType.number,

          style:
              const TextStyle(
            fontSize: 13,
            color:
                AppColors
                    .textPrimary,
          ),

          decoration:
              InputDecoration(
            // CR- ثابتة
            prefixText:
                'CR-',

            prefixStyle:
                const TextStyle(
              fontSize: 13,
              fontWeight:
                  FontWeight.w600,
              color:
                  AppColors
                      .textSecondary,
            ),

            hintText:
                '1001',

            contentPadding:
                const EdgeInsets
                    .symmetric(
              horizontal: 12,
              vertical: 10,
            ),

            filled: true,

            fillColor:
                AppColors
                    .surfaceInput,

            border:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius
                      .circular(
                8,
              ),

              borderSide:
                  const BorderSide(
                color:
                    AppColors.border,
              ),
            ),

            enabledBorder:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius
                      .circular(
                8,
              ),

              borderSide:
                  const BorderSide(
                color:
                    AppColors.border,
              ),
            ),

            focusedBorder:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius
                      .circular(
                8,
              ),

              borderSide:
                  const BorderSide(
                color:
                    AppColors.primary,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// EXPIRY DATE FIELD
// ============================================================================

class _ExpiryDateField
    extends StatelessWidget {
  final TextEditingController
      controller;

  final VoidCallback onTap;

  const _ExpiryDateField({
    required this.controller,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [
        const Text(
          'تاريخ الانتهاء',

          style:
              TextStyle(
            fontSize: 12,
            fontWeight:
                FontWeight.w600,
            color:
                AppColors
                    .textSecondary,
          ),
        ),

        const SizedBox(
          height: 5,
        ),

        TextFormField(
          controller:
              controller,

          // يمنع الكتابة اليدوية
          readOnly: true,

          onTap:
              onTap,

          style:
              const TextStyle(
            fontSize: 13,
            color:
                AppColors
                    .textPrimary,
          ),

          decoration:
              InputDecoration(
            hintText:
                'اختر التاريخ',

            suffixIcon:
                const Icon(
              Icons
                  .calendar_month_outlined,
              size: 19,
              color:
                  AppColors
                      .textHint,
            ),

            contentPadding:
                const EdgeInsets
                    .symmetric(
              horizontal: 12,
              vertical: 10,
            ),

            filled: true,

            fillColor:
                AppColors
                    .surfaceInput,

            border:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius
                      .circular(
                8,
              ),

              borderSide:
                  const BorderSide(
                color:
                    AppColors.border,
              ),
            ),

            enabledBorder:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius
                      .circular(
                8,
              ),

              borderSide:
                  const BorderSide(
                color:
                    AppColors.border,
              ),
            ),

            focusedBorder:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius
                      .circular(
                8,
              ),

              borderSide:
                  const BorderSide(
                color:
                    AppColors.primary,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}