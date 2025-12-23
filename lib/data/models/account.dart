class Account {
  final String? id;
  final String? userId;
  final String name;
  final String accountType;
  final double balance;

  Account({
    this.id,
    this.userId,
    required this.name,
    required this.accountType,
    required this.balance,
  });

  factory Account.fromMap(Map<String, dynamic> map) {
    return Account(
      id: map['id'],
      userId: map['user_id'],
      name: map['name'],
      accountType: map['account_type'],
      balance: map['balance'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'name': name,
      'account_type': accountType,
      'balance': balance,
    };
  }
}
