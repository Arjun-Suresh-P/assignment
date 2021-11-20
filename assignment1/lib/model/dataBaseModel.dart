class DataBaseModel{
  String? id;
  String? title;
  String? image;
  String? rate;

  DataBaseModel({
    this.id,
    this.title,
    this.image,
    this.rate,
  });
  Map<String, dynamic> toMap() {
    return {
      "id": this.id,
      "title": this.title,
      "image": this.image,
      "rate": this.rate,
    };
  }
  factory DataBaseModel.fromMap(Map<String, dynamic> json) => new DataBaseModel(
    id: json["id"],
    title: json["title"],
    image: json["image"],
    rate: json["rate"],
  );
}
