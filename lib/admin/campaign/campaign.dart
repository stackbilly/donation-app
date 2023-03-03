enum CampaignState { active, closed, deleted }

class Campaign {
  String id;
  String title;
  String description;
  int targetAmount;
  int days;
  String imageUrl;
  int total;
  int totalSpent;

  Campaign(this.id, this.title, this.description, this.targetAmount, this.days,
      this.imageUrl, this.total, this.totalSpent);

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
