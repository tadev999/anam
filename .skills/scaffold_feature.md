# Skill: Flutter Feature Scaffolder (Feature-First & BLoC)

This skill provides a highly optimized, precise procedural checklist and boilerplate templates to scaffold a new feature folder in the **Anam** project. By following this guide, the agent ensures 100% architectural alignment with `.cursorrules` and aesthetic conformity with `lib/core/DESIGN.md` in a single pass, saving significant token overhead.

---

## 🛠️ Step-by-Step Procedure

When the user asks to **"create a new feature [feature_name]"**, perform the following actions:

### Step 1: Directory Scaffolding
Create the following directory structure inside `lib/features/<feature_name>/`:
* `lib/features/<feature_name>/data/models/`
* `lib/features/<feature_name>/data/repositories/`
* `lib/features/<feature_name>/bloc/`
* `lib/features/<feature_name>/presentation/screens/`
* `lib/features/<feature_name>/presentation/widgets/`

### Step 2: Create Data Model
Create `lib/features/<feature_name>/data/models/<feature_name>_model.dart`.
* Must be immutable (`@immutable` or const constructor).
* Must extend `Equatable` and implement `props`.
* Must include a `copyWith` method.
* Include `fromJson` / `toJson` if remote persistence is required.

### Step 3: Create BLoC State
Create `lib/features/<feature_name>/bloc/<feature_name>_state.dart`.
* Must extend `Equatable`.
* Standard states required:
  * `<FeatureName>Initial`
  * `<FeatureName>Loading`
  * `<FeatureName>Success` (holding loaded data/models)
  * `<FeatureName>Failure` (holding error message string or custom Error object)

### Step 4: Create BLoC Event
Create `lib/features/<feature_name>/bloc/<feature_name>_event.dart`.
* Must extend `Equatable`.
* Use the naming convention: `PresentTense + Verb + Noun` (e.g., `FetchData`, `SubmitInput`, `ResetState`).

### Step 5: Create BLoC Coordinator
Create `lib/features/<feature_name>/bloc/<feature_name>_bloc.dart`.
* Extends `Bloc<<FeatureName>Event, <FeatureName>State>`.
* Implements sequential or concurrent event handling using `on<EventName>`.
* Emits state changes using immutable state transitions.

### Step 6: Create Presentation Screens & Widgets
Create `lib/features/<feature_name>/presentation/screens/<feature_name>_screen.dart`.
* Integrate `BlocProvider` or `BlocBuilder` correctly.
* Use `BlocListener` or `BlocConsumer` for side-effects (snackbars, navigation).
* Must incorporate the Zen/Indochine styling guidelines from `lib/core/DESIGN.md` (e.g., `GlassContainer` for panels, `ZenButton` for actions, Outfit/Lora Google Fonts, soft gradients).

### Step 7: Create BLoC Unit Test
Create `test/features/<feature_name>/<feature_name>_bloc_test.dart`.
* Use `bloc_test` package.
* Provide at least two core tests: one for success transition, one for failure transition.

---

## 📄 Boilerplate Code Templates

Substitute `<feature_name>` (snake_case) and `<FeatureName>` (PascalCase) accordingly.

### 1. Model Template
```dart
import 'package:equatable/equatable.dart';

class <FeatureName>Model extends Equatable {
  final String id;
  final String title;

  const <FeatureName>Model({
    required this.id,
    required this.title,
  });

  <FeatureName>Model copyWith({
    String? id,
    String? title,
  }) {
    return <FeatureName>Model(
      id: id ?? this.id,
      title: title ?? this.title,
    );
  }

  @override
  List<Object?> get props => [id, title];
}
```

### 2. State Template
```dart
part of '<feature_name>_bloc.dart';

abstract class <FeatureName>State extends Equatable {
  const <FeatureName>State();
  
  @override
  List<Object?> get props => [];
}

class <FeatureName>Initial extends <FeatureName>State {}

class <FeatureName>Loading extends <FeatureName>State {}

class <FeatureName>Success extends <FeatureName>State {
  final List<<FeatureName>Model> items;

  const <FeatureName>Success({required this.items});

  @override
  List<Object?> get props => [items];
}

class <FeatureName>Failure extends <FeatureName>State {
  final String errorMessage;

  const <FeatureName>Failure({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}
```

### 3. Event Template
```dart
part of '<feature_name>_bloc.dart';

abstract class <FeatureName>Event extends Equatable {
  const <FeatureName>Event();

  @override
  List<Object?> get props => [];
}

class Load<FeatureName>Data extends <FeatureName>Event {}
```

### 4. BLoC Template
```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../data/models/<feature_name>_model.dart';

part '<feature_name>_event.dart';
part '<feature_name>_state.dart';

class <FeatureName>Bloc extends Bloc<<FeatureName>Event, <FeatureName>State> {
  <FeatureName>Bloc() : super(<FeatureName>Initial()) {
    on<Load<FeatureName>Data>(_onLoadData);
  }

  Future<void> _onLoadData(
    Load<FeatureName>Data event,
    Emitter<<FeatureName>State> emit,
  ) async {
    emit(<FeatureName>Loading());
    try {
      // Simulate fetch or call Repository
      await Future.delayed(const Duration(milliseconds: 800));
      final items = [
        <FeatureName>Model(id: '1', title: 'Danh mục mẫu 1'),
      ];
      emit(<FeatureName>Success(items: items));
    } catch (e) {
      emit(<FeatureName>Failure(errorMessage: e.toString()));
    }
  }
}
```

### 5. UI Presentation Template (Zen Style)
```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/zen_button.dart';
import '../../bloc/<feature_name>_bloc.dart';

class <FeatureName>Screen extends StatelessWidget {
  const <FeatureName>Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => <FeatureName>Bloc()..add(Load<FeatureName>Data()),
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF1C1D1A), // Deep Moss Green / Charcoal
                Color(0xFF121311),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '<FeatureName>',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontFamily: 'Outfit',
                          color: const Color(0xFFF7F8F6),
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Không gian tỉnh lặng tâm trí',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontFamily: 'Lora',
                          color: const Color(0xFFC4C7C0),
                          fontStyle: FontStyle.italic,
                        ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: BlocBuilder<<FeatureName>Bloc, <FeatureName>State>(
                      builder: (context, state) {
                        if (state is <FeatureName>Loading) {
                          return const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFA3B19B)),
                            ),
                          );
                        } else if (state is <FeatureName>Success) {
                          return ListView.builder(
                            itemCount: state.items.length,
                            itemBuilder: (context, index) {
                              final item = state.items[index];
                              return GlassContainer(
                                margin: const EdgeInsets.only(bottom: 16),
                                child: ListTile(
                                  title: Text(
                                    item.title,
                                    style: const TextStyle(
                                      color: Color(0xFFF7F8F6),
                                      fontFamily: 'Lora',
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        } else if (state is <FeatureName>Failure) {
                          return Center(
                            child: Text(
                              'Đã xảy ra lỗi: ${state.errorMessage}',
                              style: const TextStyle(color: Colors.redAccent),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  ZenButton(
                    text: 'Trở về',
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```
