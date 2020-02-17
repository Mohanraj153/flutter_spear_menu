class CustomData{
  var _name;
  var _isShow;

  String get name => _name;

  bool get isShow => _isShow;

  set isShow(bool value) {
    _isShow = value;
  }

  set name(String value) {
    _name = value;
  }

  CustomData(this._name, this._isShow);

}