class Campaign {
  String title;
  String description;
  int targetAmount;
  int days;
  String imageUrl;
  int total;

  Campaign(this.title, this.description, this.targetAmount, this.days,
      this.imageUrl, this.total);

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'targetAmount': targetAmount,
      'days': days,
      'imageUrl': imageUrl,
      'total': total,
    };
  }
}
