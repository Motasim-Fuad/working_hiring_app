part of 'fade_slide_in.dart';

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  static const int _maxStaggeredItems = 8;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );
  late final Animation<double> _curve = CurvedAnimation(
    parent: _controller,
    curve: AppCurves.standard,
  );
  late final Animation<Offset> _offset = Tween(
    begin: widget.beginOffset,
    end: Offset.zero,
  ).animate(_curve);

  @override
  void initState() {
    super.initState();
    final steps = math.min(widget.index, _maxStaggeredItems);
    if (steps == 0) {
      _controller.forward();
    } else {
      Future.delayed(AppDurations.staggerStep * steps, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _curve,
      child: SlideTransition(position: _offset, child: widget.child),
    );
  }
}
