class FetchNotificationModel {
  var notifications; // List of NotificationItemModel
  var total;
  var unread;
  var page;
  var limit;

  FetchNotificationModel({
    this.notifications,
    this.total,
    this.unread,
    this.page,
    this.limit,
  });

  factory FetchNotificationModel.fromJson(Map<String, dynamic> json) {
    return FetchNotificationModel(
      notifications: json['notifications'] != null
          ? (json['notifications'] as List)
          .map((i) => NotificationItemModel.fromJson(i))
          .toList()
          : [],
      total: json['total'],
      unread: json['unread'],
      page: json['page'],
      limit: json['limit'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notifications': notifications?.map((v) => v.toJson()).toList(),
      'total': total,
      'unread': unread,
      'page': page,
      'limit': limit,
    };
  }
}

class NotificationItemModel {
  var id;
  var row_id;
  var user_id;
  var title;
  var message;
  var is_read;
  var cr_on;
  var up_on;
  var type;
  var reference_id;
  var reference_type;
  var priority;
  var is_deleted;

  NotificationItemModel({
    this.id,
    this.row_id,
    this.user_id,
    this.title,
    this.message,
    this.is_read,
    this.cr_on,
    this.up_on,
    this.type,
    this.reference_id,
    this.reference_type,
    this.priority,
    this.is_deleted,
  });

  factory NotificationItemModel.fromJson(Map<String, dynamic> json) {
    return NotificationItemModel(
      id: json['id'],
      row_id: json['row_id'],
      user_id: json['user_id'],
      title: json['title'],
      message: json['message'],
      is_read: json['is_read'],
      cr_on: json['cr_on'],
      up_on: json['up_on'],
      type: json['type'],
      reference_id: json['reference_id'],
      reference_type: json['reference_type'],
      priority: json['priority'],
      is_deleted: json['is_deleted'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'row_id': row_id,
      'user_id': user_id,
      'title': title,
      'message': message,
      'is_read': is_read,
      'cr_on': cr_on,
      'up_on': up_on,
      'type': type,
      'reference_id': reference_id,
      'reference_type': reference_type,
      'priority': priority,
      'is_deleted': is_deleted,
    };
  }
}