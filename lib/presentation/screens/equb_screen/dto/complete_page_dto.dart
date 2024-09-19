class CompletePageDto {
  final String title;
  final String description;
  final Function() onComplete;

  CompletePageDto({
    required this.title,
    required this.description,
    required this.onComplete,
  });
}
