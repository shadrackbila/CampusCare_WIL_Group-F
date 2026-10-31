import 'package:flutter/material.dart';

/// Returns the static rich content for a resource, matched by title.
Widget? resourceContentFor(String? title) {
  if (title == null) return null;
  final t = title.trim().toLowerCase();

  // "exam stress" must be checked before generic "stress".
  if (t.contains('exam stress')) return const ManagingExamStressContent();
  if (t.contains('crisis')) return const CrisisSupportContent();
  if (t.contains('healthy living')) return const HealthyLivingContent();
  if (t.contains('self-care') || t.contains('self care')) {
    return const SelfCareContent();
  }
  if (t.contains('academic')) return const AcademicSupportContent();
  if (t.contains('stress management') ||
      (t.contains('stress') && !t.contains('exam'))) {
    return const StressManagementContent();
  }
  if (t.contains('mental health')) return const MentalHealthContent();
  return null;
}

/// Returns the static rich content for a category, matched by name.
Widget? categoryContentFor(String? name) {
  if (name == null) return null;
  final t = name.trim().toLowerCase();

  if (t.contains('crisis')) return const CrisisSupportContent();
  if (t.contains('healthy')) return const HealthyLivingContent();
  if (t.contains('self')) return const SelfCareContent();
  if (t.contains('academic')) return const AcademicSupportContent();
  if (t.contains('stress')) return const StressManagementContent();
  if (t.contains('mental health')) return const MentalHealthContent();
  return null;
}

// ---------------------------------------------------------------------------
// Reusable little widgets (kept private to this file)
// ---------------------------------------------------------------------------

class _H extends StatelessWidget {
  const _H(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 18, bottom: 6),
    child: Text(
      text,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
    ),
  );
}

class _P extends StatelessWidget {
  const _P(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: SelectableText(text, style: const TextStyle(height: 1.45)),
  );
}

class _Bullets extends StatelessWidget {
  const _Bullets(this.items);
  final List<String> items;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      for (final item in items)
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('•  '),
              Expanded(
                child: SelectableText(
                  item,
                  style: const TextStyle(height: 1.45),
                ),
              ),
            ],
          ),
        ),
    ],
  );
}

class _Steps extends StatelessWidget {
  const _Steps(this.items);
  final List<String> items;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      for (var i = 0; i < items.length; i++)
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${i + 1}.  ',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              Expanded(
                child: SelectableText(
                  items[i],
                  style: const TextStyle(height: 1.45),
                ),
              ),
            ],
          ),
        ),
    ],
  );
}

class _ContactRow extends StatelessWidget {
  const _ContactRow(this.name, this.number);
  final String name;
  final String number;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.w700, height: 1.4),
          ),
        ),
        const SizedBox(width: 8),
        SelectableText(
          number,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ],
    ),
  );
}

// ---------------------------------------------------------------------------
// Content widgets
// ---------------------------------------------------------------------------

class ManagingExamStressContent extends StatelessWidget {
  const ManagingExamStressContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _P(
          'Stress is a normal part of student life. A moderate amount can '
          'improve concentration, motivation and performance. However, too '
          'much stress can affect your ability to study and function '
          'effectively.',
        ),
        _P(
          'The key is to balance studying, resting and taking care of yourself.',
        ),
        _H('Managing Your Time'),
        _P('Good time management helps prevent last-minute stress.'),
        _Bullets([
          'Create a weekly timetable that includes studying, lectures, meals, sleep and relaxation.',
          'Be realistic about how much time you can spend studying.',
          'Prioritise difficult and important topics.',
          'Set clear goals for each study session.',
          'Stick to deadlines.',
          'Make time for relaxation.',
        ]),
        _P(
          'Remember: Divide your week into 21 units (3 per day). Spend a '
          'maximum of 15 units on revision and keep 6 units for other activities.',
        ),
        _H('Improving Your Sleep'),
        _P('Good sleep improves concentration and memory.'),
        _Bullets([
          'Avoid studying in bed.',
          'Stop studying at least an hour before bedtime.',
          'Maintain a regular sleeping schedule.',
          'Aim for 6–8 hours of sleep per night.',
        ]),
        _H('Developing Healthy Study Patterns'),
        _Bullets([
          'Take regular breaks.',
          'Stop and rest when you lose concentration.',
          'Avoid forcing yourself to study when tired or distracted.',
        ]),
        _P(
          'Remember: 15 minutes of focused studying is better than 3 hours of '
          'ineffective studying.',
        ),
        _H('Basic Revision Method'),
        _P('Follow these five steps when revising:'),
        _Steps([
          'Read: Go through your notes and identify important questions.',
          'Close: Put your notes away.',
          'Recall: Answer questions from memory and write down what you remember.',
          'Check: Compare your answers with your original notes.',
          'Repeat: Revisit information you struggled to remember.',
        ]),
        _H('On the Day of the Exam'),
        _P('Before the exam:'),
        _Bullets([
          'Avoid learning new topics.',
          'Review short notes or revision cards.',
          'Stop studying during the last hour.',
          'Arrive on time to avoid unnecessary anxiety.',
        ]),
        _P('During the exam:'),
        _Bullets([
          'Take time to settle down.',
          'Read questions carefully.',
          'Use breathing exercises to stay calm.',
          'Manage your exam time effectively.',
        ]),
        _H('Relaxation Techniques'),
        _P('Simple activities can help reduce stress:'),
        _Bullets([
          'Deep breathing: Breathe slowly and focus on your breathing.',
          'Muscle relaxation: Relax tense muscles and stretch.',
          'Self-rewards: Give yourself a small treat each day.',
          'Relaxation activities: Try yoga, meditation or massage.',
        ]),
      ],
    );
  }
}

class CrisisSupportContent extends StatelessWidget {
  const CrisisSupportContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _P('You are not alone. Help is available.'),
        _P(
          'A crisis can happen when emotional or personal difficulties become '
          'too overwhelming to manage alone. SADAG encourages people '
          'experiencing mental-health difficulties to reach out for support.',
        ),
        _H('What to do'),
        _Bullets([
          'Talk to someone you trust.',
          'Contact a mental-health professional or counsellor.',
          "Don't ignore thoughts of self-harm or suicide.",
          'If someone is at risk, stay with them and seek urgent help.',
        ]),
        _H('Important support contacts'),
        _ContactRow('CUT Wellness Centre', '051 507 3154'),
        _ContactRow('SADAG Suicide Crisis Line (24-hour)', '0800 567 567'),
        _ContactRow(
          'Higher Health Student Helpline (24-hour)',
          '0800 36 36 36',
        ),
        _ContactRow('SADAG Office', '011 234 4837'),
        _P(
          'CUT (Lapeng Building) — SADAG also provides free support groups '
          'and counselling resources.',
        ),
      ],
    );
  }
}

class HealthyLivingContent extends StatelessWidget {
  const HealthyLivingContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _P('Small healthy habits can make a difference.'),
        _P(
          'Looking after your physical health can support your emotional '
          'wellbeing, energy and daily functioning.',
        ),
        _H('Healthy habits to practise'),
        _Bullets([
          'Maintain a regular sleeping routine.',
          'Eat balanced meals.',
          'Include walking or light exercise in your routine.',
          'Spend time outdoors.',
          'Reduce alcohol and substance use.',
          'Stay connected with friends and family.',
        ]),
        _P(
          'Try this: Set one small, achievable wellbeing goal each day, such '
          'as taking a walk or going to bed at a consistent time.',
        ),
      ],
    );
  }
}

class SelfCareContent extends StatelessWidget {
  const SelfCareContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _P('Taking care of yourself is not selfish.'),
        _P(
          'Self-care involves making time for activities that support your '
          'emotional, physical and mental wellbeing.',
        ),
        _H('Ways to practise self-care'),
        _Bullets([
          'Make time for activities you enjoy.',
          'Keep a journal of your thoughts and feelings.',
          'Set healthy boundaries and learn to say no.',
          'Spend time with supportive people.',
          'Celebrate small achievements.',
          'Allow yourself time to rest.',
        ]),
        _P(
          'Try this: Write down three things that make you feel relaxed or '
          'happy and make time for one of them today.',
        ),
      ],
    );
  }
}

class AcademicSupportContent extends StatelessWidget {
  const AcademicSupportContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _P('You can ask for help with your studies.'),
        _P(
          'Academic pressure, exam stress and balancing studies with '
          'personal responsibilities can affect student wellbeing. Time '
          'management, exam stress and social life are important student '
          'support topics.',
        ),
        _H('Study tips'),
        _Bullets([
          'Create a realistic weekly timetable.',
          'Break large assignments into smaller tasks.',
          'Prioritise difficult subjects.',
          'Set achievable study goals.',
          'Take regular breaks.',
          'Ask lecturers or tutors for academic assistance.',
        ]),
        _H('Additional support'),
        _P(
          'CUT has student peer educators to connect with other students '
          'experiencing similar challenges.',
        ),
      ],
    );
  }
}

class StressManagementContent extends StatelessWidget {
  const StressManagementContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _P('Learn to manage stress before it becomes overwhelming.'),
        _P(
          'SADAG explains that some stress can improve concentration and '
          'motivation, but excessive stress can interfere with studying and '
          'everyday life.',
        ),
        _H('Ways to manage stress'),
        _Steps([
          'Organise your time using a weekly timetable.',
          'Focus on one task at a time.',
          'Take regular study breaks.',
          'Prioritise important tasks.',
          'Make time for relaxation.',
          'Maintain healthy sleeping habits.',
        ]),
        _H('4-4-4 breathing exercise'),
        _Steps([
          'Breathe in for 4 seconds.',
          'Hold for 4 seconds.',
          'Breathe out for 4 seconds.',
          'Repeat until you feel calmer.',
        ]),
        _P(
          'Remember: Rest and relaxation are part of effective studying, '
          'not a waste of time.',
        ),
      ],
    );
  }
}

class MentalHealthContent extends StatelessWidget {
  const MentalHealthContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _P('Your mental health matters just as much as your physical health.'),
        _P(
          'Mental-health difficulties can affect your mood, thoughts, '
          'behaviour, relationships and ability to concentrate.',
        ),
        _P(
          'SADAG provides information about depression, anxiety, panic '
          'attacks and other mental-health challenges.',
        ),
        _H('Signs that you may need support'),
        _Bullets([
          'Feeling sad, hopeless or overwhelmed.',
          'Constant worrying or excessive fear.',
          'Losing interest in activities you enjoy.',
          'Difficulty sleeping or concentrating.',
          'Feeling tired or lacking motivation.',
          'Withdrawing from friends and family.',
        ]),
        _H('Ways to look after your mental health'),
        _Bullets([
          'Talk about your feelings.',
          'Maintain supportive relationships.',
          'Create healthy daily routines.',
          'Seek professional help when needed.',
          'Avoid isolating yourself when struggling.',
        ]),
        _P(
          'Important: If these difficulties persist or affect your daily '
          'life, consider speaking to a healthcare professional. You do not '
          'need to wait until things become unbearable before asking for help.',
        ),
      ],
    );
  }
}
