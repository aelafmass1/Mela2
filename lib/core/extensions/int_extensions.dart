extension IntExtension on int {
  bool isPrime() {
    if (this < 2) return false; // Prime numbers are greater than 1
    for (int i = 2; i <= this ~/ 2; i++) {
      if (this % i == 0) return false; // If divisible by any number, it's not prime
    }
    return true;
  }
}
