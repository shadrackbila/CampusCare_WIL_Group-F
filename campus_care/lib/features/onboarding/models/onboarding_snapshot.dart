import 'academic_info.dart';
import 'next_of_kin.dart';
import 'personal_info.dart';
import 'referral_source.dart';
import 'residence_info.dart';

enum OnboardingStep {
  consent,
  personal,
  nextOfKin,
  academic,
  residence,
  concerns,
  referral,
}

/// Everything already saved for this student. Used to resume onboarding where it stopped.
class OnboardingSnapshot {
  const OnboardingSnapshot({
    required this.personal,
    this.nextOfKin,
    this.academic,
    this.residence,
    this.concernCodes = const {},
    this.referral,
    this.hasActiveConsent = false,
  });

  final PersonalInfo personal;
  final NextOfKin? nextOfKin;
  final AcademicInfo? academic;
  final ResidenceInfo? residence;
  final Set<String> concernCodes;
  final ReferralSource? referral;
  final bool hasActiveConsent;

  OnboardingSnapshot copyWith({
    PersonalInfo? personal,
    NextOfKin? nextOfKin,
    AcademicInfo? academic,
    ResidenceInfo? residence,
    Set<String>? concernCodes,
    ReferralSource? referral,
    bool? hasActiveConsent,
  }) =>
      OnboardingSnapshot(
        personal: personal ?? this.personal,
        nextOfKin: nextOfKin ?? this.nextOfKin,
        academic: academic ?? this.academic,
        residence: residence ?? this.residence,
        concernCodes: concernCodes ?? this.concernCodes,
        referral: referral ?? this.referral,
        hasActiveConsent: hasActiveConsent ?? this.hasActiveConsent,
      );

  /// Where to resume. Concerns have no "done" marker of their own, so they are
  /// shown until a referral source has been saved.
  OnboardingStep get firstIncompleteStep {
    if (!hasActiveConsent) return OnboardingStep.consent;
    if (!personal.isComplete) return OnboardingStep.personal;
    if (nextOfKin == null || !nextOfKin!.isComplete) return OnboardingStep.nextOfKin;
    if (academic == null || !academic!.isComplete) return OnboardingStep.academic;
    if (residence == null || !residence!.isComplete) return OnboardingStep.residence;
    if (referral == null) return OnboardingStep.concerns;
    return OnboardingStep.referral; // everything saved; just needs "Complete"
  }
}
