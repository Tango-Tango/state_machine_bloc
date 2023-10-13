import 'package:state_machine_bloc/src/state_machine.dart';
import 'package:test/test.dart';

import 'utils.dart';

sealed class Event {}

class EventA extends Event {}

class EventB extends Event {}

class EventC extends Event {}

sealed class State {
  @override
  bool operator ==(Object value) => false;

  @override
  int get hashCode => 0;
}

class StateA extends State {}

class StateB extends State {}

class StateC extends State {}

class StateAHandler extends StateHandler<Event, State, StateA> {
  @override
  registerEventHandlers() {
    on<EventA>(_onA);
    on<EventA>(_onA);
  }

  StateB _onA(EventA event, StateA state) {
    _onEvent(event);
    return StateB();
  }

  @override
  Future<void> onEnter(state) async {
    print('in onEnter');
  }

  @override
  Future<void> onExit(state) async {
    print('in onExit');
  }

  @override
  Future<void> onChange(previous, next) async {
    print('in onChange: $previous $next');
  }
}

void _onEvent(dynamic e) => eventsReceived.add(e.runtimeType.toString());
List<String> eventsReceived = [];

class StateBHandler extends StateHandler<Event, State, StateB> {
  @override
  registerEventHandlers() {
    on<EventB>(_onB);
  }

  StateA _onB(EventB event, StateB state) {
    _onEvent(event);
    return StateA();
  }

  @override
  Future<void> onEnter(state) async {
    print('in onEnter');
  }

  @override
  Future<void> onExit(state) async {
    print('in onExit');
  }

  @override
  Future<void> onChange(previous, next) async {
    print('in onChange: $previous $next');
  }
}

class StateCHandler extends StateHandler<Event, State, StateC> {
  @override
  registerEventHandlers() {
    on<EventC>(_onCNull);
    on<EventC>(_onC);
  }

  State? _onCNull(EventC event, StateC state) {
    _onEvent(event);
    return null;
  }

  StateA _onC(EventC event, StateC state) {
    _onEvent(event);
    return StateA();
  }

  @override
  Future<void> onEnter(state) async {
    print('in onEnter');
  }

  @override
  Future<void> onExit(state) async {
    print('in onExit');
  }

  @override
  Future<void> onChange(previous, next) async {
    print('in onChange: $previous $next');
  }
}

class DummyStateMachine extends StateMachine<Event, State> {
  DummyStateMachine([State? initial]) : super(initial ?? StateA()) {
    defineHandler<StateA>(StateAHandler());
    defineHandler<StateB>(StateBHandler());
    defineHandler<StateC>(StateCHandler());
  }
}

void main() {
  group("StateHandler", () {
    tearDown(() => eventsReceived.clear());
    test("event handler that return null does not trigger a transition",
        () async {
      final sm = DummyStateMachine(StateC());
      sm.add(EventC());

      await wait();

      expect(eventsReceived, ["EventC", "EventC"]);
    });

    test("events are received and evaluated sequentially", () async {
      final sm = DummyStateMachine();
      sm.add(EventB());
      sm.add(EventB());
      sm.add(EventA());
      sm.add(EventA());
      sm.add(EventA());
      sm.add(EventB());

      await wait();

      expect(eventsReceived, ["EventA", "EventB"]);
    });

    test("events are evaluated sequentially until a transition happen",
        () async {
      final sm = DummyStateMachine();
      sm.add(EventA());
      sm.add(EventA());

      await wait();

      expect(eventsReceived, ["EventA"]);
    });
    test(
        "if no event handler corresponding to the received event is registered for the current state, event is ignored",
        () async {
      final sm = DummyStateMachine();
      sm.add(EventB());

      await wait();

      expect(eventsReceived, []);
    });
  });
}
