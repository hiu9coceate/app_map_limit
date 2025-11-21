class MotionDetectorService {
  bool _isMoving = true;

  bool get isMoving => _isMoving;

  void startListening() {}

  void dispose() {}

  void reset() {
    _isMoving = true;
  }
}
