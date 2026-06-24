part of 'mind_garden_bloc.dart';

abstract class MindGardenEvent extends Equatable {
  const MindGardenEvent();

  @override
  List<Object?> get props => [];
}

class LoadGardenRequested extends MindGardenEvent {
  final String uid;
  final DateTime month;

  const LoadGardenRequested({required this.uid, required this.month});

  @override
  List<Object?> get props => [uid, month];
}
