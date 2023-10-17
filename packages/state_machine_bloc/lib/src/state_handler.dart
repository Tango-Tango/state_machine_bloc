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

  /// Register event handlers for the [DefinedState].
  void registerEventHandlers();

  /// Register [onEnterCallback] function as onExit side effect for [DefinedState]
  ///
  /// Returns a [FutureOr<Event?>], and any event returned will be added to
  /// the [StateMachine] where this [StateHandler] is registered.
  ///
  /// See also:
  ///
  /// * [StateDefinitionBuilder.onExit] for more information
  FutureOr<Event?> onEnter(DefinedState state) => null;

  /// Register [onExitCallback] function as onExit side effect for [DefinedState]
  ///
  /// Returns a [FutureOr<Event?>], and any event returned will be added to
  /// the [StateMachine] where this [StateHandler] is registered.
  ///
  /// See also:
  ///
  /// * [StateDefinitionBuilder.onExit] for more information
  FutureOr<Event?> onExit(DefinedState state) => null;

  /// Register [onChangeCallback] function as onExit side effect for [DefinedState]
  ///
  /// Returns a [FutureOr<Event?>], and any event returned will be added to
  /// the [StateMachine] where this [StateHandler] is registered.
  ///
  /// See also:
  ///
  /// * [StateDefinitionBuilder.onExit] for more information
  FutureOr<Event?> onChange(
          DefinedState currentState, DefinedState nextState) =>
      null;

  /// Register [transition] function as one of [DefinedState]'s event handler
  /// for [DefinedEvent]
  void on<DefinedEvent extends Event>(
    EventTransition<DefinedEvent, State, DefinedState> transition,
  ) =>
      _builder.on<DefinedEvent>(transition);

  // Build the internal [StateDefinitionBuilder] to generate a [StateDefinition]
  _StateDefinition<Event, State, DefinedState> _build() => _builder._build();
}
