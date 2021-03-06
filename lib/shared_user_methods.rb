module SharedUserMethods
  def self.included(base)
    base.has_many :event_feeds, as: :user
    base.has_many :events, through: :event_feeds, select: 'events.*, event_feeds.read as read'
    base.has_many :watches, as: :user
  end

  def gravatar_url
    "//gravatar.com/avatar/#{Digest::MD5::hexdigest(email.downcase)}?size=45&d=identicon"
  end

  def display_name
    self.name || self.email
  end

  # @todo use update_all for performance?
  def read_notifications(targetable, *event_types)
    sql = targetable.events

    if event_types.any?
      sql = sql.where("event_type IN (?)", Event.event_types.only(*event_types).values)
    end

    event_feeds.where("event_id IN (?)", sql.pluck(:id)).each do |event_feed|
      event_feed.read!
    end
  end

  def unread_notification_count
    self.event_feeds.unread.count
  end

  def watches?(watchable_type, watchable_id)
    watches.where(watchable_type: watchable_type, watchable_id: watchable_id, disabled: false).first ? true : false
  end

  def watch!(watchable_type, watchable_id)
    watch = watches.where(watchable_type: watchable_type, watchable_id: watchable_id).first_or_create
    if watch.disabled then watch.update_attributes(disabled: false) end
  end

  def unwatch!(watchable_type, watchable_id)
    watches.where(watchable_type: watchable_type, watchable_id: watchable_id).first.update_attributes(disabled: true)
  end

  def send_email_notifications_for?(event_type_value)
    self.notification_preferences && self.notification_preferences.include?(event_type_value)
  end
end