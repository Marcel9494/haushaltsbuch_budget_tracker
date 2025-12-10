class Account {
  final String? id;
  final String? uid;
  final String name;
  final String accountType;
  final double balance;

  Account({
    this.id,
    this.uid,
    required this.name,
    required this.accountType,
    required this.balance,
  });

  factory Account.fromMap(Map<String, dynamic> map) {
    return Account(
      id: map['id'],
      uid: map['uid'],
      name: map['name'],
      accountType: map['account_type'],
      balance: map['balance'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'account_type': accountType,
      'balance': balance,
    };
  }
}
