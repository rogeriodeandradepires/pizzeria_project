class Category {
  String name;
  String description;
  String icon;
  String id;
  String image;
  String title;

  Category({
    this.name,
    this.description,
    this.icon,
    this.id,
    this.image,
    this.title,
  });

  _parseResult(List<dynamic> data) {
    List<Category> results = new List<Category>();
    data.forEach((item) {
      results.add(Category.fromJson(item));
    });
    return results;
  }

  _parseString(List<dynamic> data) {
    List<String> results = new List<String>();
    data.forEach((item) {
      results.add(item);
    });
    return results;
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      name: json['name'],
      description: json['description'],
      icon: json['icon'],
      id: json['id'],
      image: json['image'],
      title: json['title'],
    );
  }
}