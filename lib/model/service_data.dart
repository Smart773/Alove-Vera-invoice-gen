class ServiceData {
  String _description;
  double _amount;
  int _qty;
  double total;

  get getTotal => total;

  set setTotal(total) => this.total = total;
  String get description => _description;

  set description(String value) => _description = value;

  get amount => _amount;

  set amount(value) => _amount = value;

  get qty => _qty;

  set qty(value) => _qty = value;

  ServiceData({required description, required amount, required qty})
      : _description = description,
        _amount = amount,
        _qty = qty,
        total = amount * qty;
}
