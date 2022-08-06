class PushNotification::Visibility < ActiveHash::Base
  include ActiveHash::Enum
  enum_accessor :id

  self.data = [
    {
      id: 'unspecified',
      enum: 'VISIBILITY_UNSPECIFIED',
      description: 'If unspecified, default to Visibility.PRIVATE.',
    },
    {
      id: 'private',
      enum: 'PRIVATE',
      description: 'Show this notification on all lockscreens, but conceal sensitive or private information on secure lockscreens.',
    },
    {
      id: 'public',
      enum: 'PUBLIC',
      description: 'Show this notification in its entirety on all lockscreens.',
    },
    {
      id: 'secret',
      enum: 'SECRET',
      description: 'Do not reveal any part of this notification on a secure lockscreen.',
    }
  ]
end
