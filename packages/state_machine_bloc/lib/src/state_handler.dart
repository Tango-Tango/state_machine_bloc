part of 'state_machine.dart';

/// {@template state_handler}
/// A class that provides encapsulation for event handling, improving readability
/// and testability for a given state.
///
/// ```dart
/// class InitialStateHandler extends StateHandler<Event, State, InitialState> {
///   @override
///   registerEventHandlers() {
///     on<SomeEvent>((SomeEvent event, InitialState state) => OtherState());
///   }
///
///   @override
///   Future<void> onEnter(state) async {
///     print('in onEnter');
///   }
///
///   @override
///   Future<void> onExit(state) async {
///     print('in onExit');
///   }
///
///   @override
///   Future<void> onChange(previous, next) async {
///     print('in onChange: $previous $next');
///   }
/// }
///
/// class MyStateMachine extends StateMachine<Event, State> {
/// MyStateMachine() : super(InitialState()) {
///    defineHandler<InitialState>(InitialStateHandler())
///    define<OtherState>();
///   }
/// }
/// ```
abstract class StateHandler<Event, State, DefinedState extends State> {
  final StateDefinitionBuilder<Event, State, DefinedState> _builder =
      StateDefinitionBuilder<Event, State, DefinedState>();
  void Function(Event event)? _addFn;

  set add(Function(Event event) fn) {
    assert(() {
      if (_addFn != null) {
        throw 'Tried to add an `add` handler twice. This setter should only be '
            'called once.';
      }
      return true;
    }());
    _addFn = fn;
  }

  /// Add an event to the enclosing [StateMachine] where this [StateHandler]
  /// is registered.
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

  /// Register event handlers for the [DefinedState].
  void registerEventHandlers();

  /// Register [onEnterCallback] function as onExit side effect for [DefinedState]
  /// See also:
  ///
  /// * [StateDefinitionBuilder.onExit] for more information
  FutureOr<void> onEnter(DefinedState state) {}

  /// Register [onExitCallback] function as onExit side effect for [DefinedState]
  /// See also:
  ///
  /// * [StateDefinitionBuilder.onExit] for more information
  FutureOr<void> onExit(DefinedState state) {}

  /// Register [onChangeCallback] function as onExit side effect for [DefinedState]
  /// See also:
  ///
  /// * [StateDefinitionBuilder.onExit] for more information
  FutureOr<void> onChange(DefinedState currentState, DefinedState nextState) {}

  /// Register [transition] function as one of [DefinedState]'s event handler
  /// for [DefinedEvent]
  void on<DefinedEvent extends Event>(
    EventTransition<DefinedEvent, State, DefinedState> transition,
  ) =>
      _builder.on<DefinedEvent>(transition);

  // Build the internal [StateDefinitionBuilder] to generate a [StateDefinition]
  _StateDefinition<Event, State, DefinedState> _build() => _builder._build();
}
