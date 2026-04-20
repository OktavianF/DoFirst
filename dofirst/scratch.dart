void main() {
  var dl = DateTime.tryParse("2026-04-19T13:00:00.000Z");
  var now = DateTime.now(); // local time
  print("DL: $dl");
  print("Now: $now");
  print("Diff: ${dl!.difference(now)}");
}
