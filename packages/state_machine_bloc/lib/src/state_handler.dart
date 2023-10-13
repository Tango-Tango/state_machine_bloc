part of 'state_machine.dart';

abstract class StateHandler<Event, State, DefinedState extends State> {
  final StateDefinitionBuilder<Event, State, DefinedState> _builder =
      StateDefinitionBuilder<Event, State, DefinedState>();
  void Function(Event event)? _addFn;

  set add(Function(Event event) fn) => _addFn = fn;
  void Function(Event event) get add {
    assert(() {
      if (_addFn == null) {
        throw 'Add function has not be applied to the handler. '
            'Please use `add` setter to apply it.';
      }
      return true;
    }());

    return _addFn!;
  }

  void registerEventHandlers();

  Future<void> onEnter(DefinedState state) async {}
  Future<void> onExit(DefinedState state) async {}
  Future<void> onChange(
      DefinedState currentState, DefinedState nextState) async {}

  void on<DefinedEvent extends Event>(
    EventTransition<DefinedEvent, State, DefinedState> transition,
  ) =>
      _builder.on<DefinedEvent>(transition);

  _StateDefinition<Event, State, DefinedState> _build() => _builder._build();
}
