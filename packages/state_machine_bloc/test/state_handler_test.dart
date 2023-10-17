import 'dart:async';

import 'package:state_machine_bloc/src/state_machine.dart';
import 'package:test/test.dart';

import 'utils.dart';

List<String> eventsReceived = [];
List<String> lifecycleEventsReceived = [];

void _onEvent(dynamic e) => eventsReceived.add(e.runtimeType.toString());
void _onLifecycleEvent(String e) => lifecycleEventsReceived.add(e);

sealed class Event {}

class EventA extends Event {}

class EventB extends Event {}

class EventC extends Event {}

class EventLifecycle extends Event {}

sealed class State {
  @override
  bool operator ==(Object value) => false;

  @override
  int get hashCode => 0;
}

class StateA extends State {}

class StateB extends State {}

class StateC extends State {}

class StateLifecycle extends State {}

class StateAHandler extends StateHandler<Event, State, StateA> {
  @override
  registerEventHandlers() {
    on<EventA>(_onA);
    on<EventA>(_onA);
    on<EventLifecycle>(_onLifecycle);
  }

  StateB _onA(EventA event, StateA state) {
    _onEvent(event);
    return StateB();
  }

  StateLifecycle _onLifecycle(EventLifecycle event, StateA state) {
    _onEvent(event);
    return StateLifecycle();
  }

  @override
  FutureOr<Event?> onEnter(state) {
    _onLifecycleEvent('onEnterA');
    return null;
  }

  @override
  FutureOr<Event?> onExit(state) async {
    _onLifecycleEvent('onExitA');
    return null;
  }

  @override
  FutureOr<Event?> onChange(previous, next) async {
    _onLifecycleEvent('onChangeA');
    return null;
  }
}

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
  FutureOr<Event?> onExit(state) async {
    _onLifecycleEvent('onExitB');
    return null;
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
  FutureOr<Event?> onEnter(state) async {
    _onLifecycleEvent('onEnterC');
    return null;
  }
}

class LifecycleHandler extends StateHandler<Event, State, StateLifecycle> {
  @override
  registerEventHandlers() {
    on<EventA>((event, state) => StateLifecycle());
    on<EventB>((event, state) => StateA());
  }

  @override
  FutureOr<Event?> onEnter(state) async {
    _onLifecycleEvent('onEnterLifecycle');
    return EventA();
  }

  @override
  FutureOr<Event?> onExit(state) async {
    _onLifecycleEvent('onExitLifecycle');
    return EventC();
  }

  @override
  FutureOr<Event?> onChange(previous, next) async {
    _onLifecycleEvent('onChangeLifecycle');
    return EventB();
  }
}

class DummyStateMachine extends StateMachine<Event, State> {
  DummyStateMachine([State? initial]) : super(initial ?? StateA()) {
    defineHandler<StateA>(StateAHandler());
    defineHandler<StateB>(StateBHandler());
    defineHandler<StateC>(StateCHandler());
    defineHandler<StateLifecycle>(LifecycleHandler());
  }
}

void main() {
  group("StateHandler", () {
    tearDown(() {
      eventsReceived.clear();
      lifecycleEventsReceived.clear();
    });

    test("event handler that return null does not trigger a transition",
        () async {
      final sm = DummyStateMachine(StateC());
      sm.add(EventC());

      await wait();

      expect(eventsReceived, ["EventC", "EventC"]);
      expect(lifecycleEventsReceived, ["onEnterC", "onEnterA"]);
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
      expect(lifecycleEventsReceived,
          ['onEnterA', 'onExitA', 'onExitB', 'onEnterA']);
    });

    test("events are evaluated sequentially until a transition happen",
        () async {
      final sm = DummyStateMachine();
      sm.add(EventA());
      sm.add(EventA());

      await wait();

      expect(eventsReceived, ["EventA"]);
      expect(lifecycleEventsReceived, ['onEnterA', 'onExitA']);
    });
    test(
        "if no event handler corresponding to the received event is registered for the current state, event is ignored",
        () async {
      final sm = DummyStateMachine();
      sm.add(EventB());

      await wait();

      expect(eventsReceived, []);
      expect(lifecycleEventsReceived, ['onEnterA']);
    });

    test("handles returning events from async and non-async lifecycle handlers",
        () async {
      final sm = DummyStateMachine();
      sm.add(EventLifecycle());

      await wait();

      expect(eventsReceived, ['EventLifecycle']);
      expect(lifecycleEventsReceived, [
        'onEnterA',
        'onExitA',
        'onEnterLifecycle',
        'onChangeLifecycle',
        'onExitLifecycle',
        'onEnterA'
      ]);
    });
  });
}
