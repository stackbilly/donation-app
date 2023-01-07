class Donation {
  String name;
  String phoneNo;
  int amount;
  String category;
  String date;

  Donation(this.name, this.phoneNo, this.amount, this.category, this.date);

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phoneNo': phoneNo,
      'amount': amount,
      'category': category,
      'date': date
    };
  }
}
