class NotificationBody {
  final String title;
  final String body;

  NotificationBody(this.title, this.body);

  NotificationBody.fromJson(Map<String, dynamic> json)
      : title = json['data']['displayedTitle'],
        body = json['data']['displayedBody'];

  Map<String, dynamic> toJson() => {
        'title': title,
        'body': body,
      };
}
