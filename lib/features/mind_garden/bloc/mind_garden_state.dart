part of 'mind_garden_bloc.dart';

abstract class MindGardenState extends Equatable {
  const MindGardenState();

  @override
  List<Object?> get props => [];
}

class MindGardenInitial extends MindGardenState {}

class MindGardenLoading extends MindGardenState {}

class MindGardenSuccess extends MindGardenState {
  final List<AnchorModel> anchors;
  final DateTime displayMonth;

  const MindGardenSuccess({required this.anchors, required this.displayMonth});

  @override
  List<Object?> get props => [anchors, displayMonth];
}

class MindGardenFailure extends MindGardenState {
  final String errorMessage;

  const MindGardenFailure({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}
