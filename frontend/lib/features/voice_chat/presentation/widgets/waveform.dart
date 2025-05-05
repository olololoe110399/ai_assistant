import 'dart:async';
import 'package:flutter/material.dart';

class Amplitude {
  final double current;

  const Amplitude({required this.current});
}

class WaveFormBar extends StatelessWidget {
  final Amplitude amplitude;
  final Animation<double>? animation;
  final double maxHeight;
  final Color color;

  const WaveFormBar({
    super.key,
    required this.amplitude,
    this.animation,
    this.maxHeight = 50,
    this.color = Colors.cyan,
  });

  double _computeBarHeight() {
    final normalized = amplitude.current.clamp(0, 1); // 0.0 to 1.0
    return normalized * maxHeight;
  }

  Widget _buildBar() {
    return Container(
      width: 4,
      height: _computeBarHeight(),
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (animation != null) {
      return SizeTransition(sizeFactor: animation!, child: _buildBar());
    } else {
      return _buildBar();
    }
  }
}

typedef RemovedItemBuilder<T> =
    Widget Function(T item, BuildContext context, Animation<double> animation);

class ListModel<E> {
  final GlobalKey<AnimatedListState> listKey;
  final RemovedItemBuilder<E> removedItemBuilder;
  final List<E> _items;

  ListModel({
    required this.listKey,
    required this.removedItemBuilder,
    Iterable<E>? initialItems,
  }) : _items = List<E>.from(initialItems ?? []);

  AnimatedListState? get _animatedList => listKey.currentState;

  void insert(int index, E item) {
    _items.insert(index, item);
    _animatedList?.insertItem(index);
  }

  E removeAt(int index) {
    final E removedItem = _items.removeAt(index);
    _animatedList?.removeItem(index, (context, animation) {
      return removedItemBuilder(removedItem, context, animation);
    });
    return removedItem;
  }

  int get length => _items.length;

  E operator [](int index) => _items[index];
}

class AnimatedWaveList extends StatefulWidget {
  final Stream<Amplitude> stream;
  final Widget Function(Animation<double> animation, Amplitude amplitude)?
  barBuilder;

  const AnimatedWaveList({super.key, required this.stream, this.barBuilder});

  @override
  State<AnimatedWaveList> createState() => _AnimatedWaveListState();
}

class _AnimatedWaveListState extends State<AnimatedWaveList> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  late ListModel<Amplitude> _list;

  Widget _defaultBarBuilder(Animation<double> animation, Amplitude amp) =>
      WaveFormBar(animation: animation, amplitude: amp);

  @override
  void initState() {
    super.initState();
    _list = ListModel<Amplitude>(
      listKey: _listKey,
      initialItems: [],
      removedItemBuilder:
          (item, context, animation) => _barBuilder(animation, item),
    );

    widget.stream.listen((amp) {
      if (mounted) {
        _list.insert(0, amp);

        if (_list.length > 40) {
          _list.removeAt(_list.length - 1);
        }
      }
    });
  }

  Widget _barBuilder(Animation<double> animation, Amplitude amp) {
    return widget.barBuilder?.call(animation, amp) ??
        _defaultBarBuilder(animation, amp);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedList(
      key: _listKey,
      scrollDirection: Axis.horizontal,
      reverse: true,
      initialItemCount: _list.length,
      itemBuilder:
          (context, index, animation) => _barBuilder(animation, _list[index]),
    );
  }
}

class WaveForm extends StatelessWidget {
  final Stream<Amplitude> amplitudeStream;

  const WaveForm({super.key, required this.amplitudeStream});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      width: 150,
      child: AnimatedWaveList(
        stream: amplitudeStream,
        barBuilder:
            (animation, amplitude) => WaveFormBar(
              animation: animation,
              amplitude: amplitude,
              color: Colors.red,
            ),
      ),
    );
  }
}
