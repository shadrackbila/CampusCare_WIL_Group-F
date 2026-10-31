import 'package:flutter/material.dart';
import '../../../../core/constants/options.dart';
import '../../../../shared/widgets/app_dropdown.dart';

class AcademicDropdowns extends StatefulWidget {
  const AcademicDropdowns({
    super.key,
    required this.initialFaculty,
    required this.initialDepartment,
    required this.initialProgramme,
    required this.onChanged,
    this.enabled = true,
  });

  final String? initialFaculty;
  final String? initialDepartment;
  final String? initialProgramme;
  final void Function(String? faculty, String? department, String? programme)
  onChanged;
  final bool enabled;

  @override
  State<AcademicDropdowns> createState() => _AcademicDropdownsState();
}

class _AcademicDropdownsState extends State<AcademicDropdowns> {
  String? _faculty;
  String? _department;
  String? _programme;

  @override
  void initState() {
    super.initState();
    _faculty = widget.initialFaculty;
    _department = widget.initialDepartment;
    _programme = widget.initialProgramme;
  }

  List<String> get _facultyNames =>
      Options.cutFaculties.map((f) => f.name).toList();

  List<String> get _departmentNames {
    final fac = Options.cutFaculties
        .where((f) => f.name == _faculty)
        .firstOrNull;
    return fac?.departments.map((d) => d.name).toList() ?? [];
  }

  List<String> get _programmeNames {
    final fac = Options.cutFaculties
        .where((f) => f.name == _faculty)
        .firstOrNull;
    final dept = fac?.departments
        .where((d) => d.name == _department)
        .firstOrNull;
    return dept?.programmes.map((p) => p.name).toList() ?? [];
  }

  void _emit() => widget.onChanged(_faculty, _department, _programme);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppDropdown<String>(
          label: 'Faculty',
          items: AppDropdown.stringItems(_facultyNames),
          value: _faculty,
          enabled: widget.enabled,
          validator: (v) => v == null ? 'Please choose a faculty' : null,
          onChanged: (v) {
            setState(() {
              _faculty = v;
              _department = null;
              _programme = null;
            });
            _emit();
          },
        ),
        const SizedBox(height: 12),
        AppDropdown<String>(
          label: 'Department',
          items: AppDropdown.stringItems(_departmentNames),
          value: _department,
          enabled: widget.enabled && _faculty != null,
          validator: (v) => v == null ? 'Please choose a department' : null,
          onChanged: (v) {
            setState(() {
              _department = v;
              _programme = null;
            });
            _emit();
          },
        ),
        const SizedBox(height: 12),
        AppDropdown<String>(
          label: 'Qualification / Programme',
          items: AppDropdown.stringItems(_programmeNames),
          value: _programme,
          enabled: widget.enabled && _department != null,
          validator: (v) => v == null ? 'Please choose a programme' : null,
          onChanged: (v) {
            setState(() => _programme = v);
            _emit();
          },
        ),
      ],
    );
  }
}
