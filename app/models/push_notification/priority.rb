class PushNotification::Priority < ActiveHash::Base
  include ActiveHash::Enum
  enum_accessor :id

  self.data = [
    {
      id: 'unspecified',
      android: 'PRIORITY_UNSPECIFIED',
      apns: 5,
      description: 'If priority is unspecified, notification priority is set to PRIORITY_DEFAULT.',
    },
    {
      id: 'min',
      android: 'PRIORITY_MIN',
      apns: 1,
      description: 'Lowest notification priority. Notifications with this PRIORITY_MIN might not be shown to the user except under special circumstances, such as detailed notification logs.',
    },
    {
      id: 'low',
      android: 'PRIORITY_LOW',
      apns: 3,
      description: 'Lower notification priority. The UI may choose to show the notifications smaller, or at a different position in the list, compared with notifications with PRIORITY_DEFAULT.',
    },
    {
      id: 'default',
      android: 'PRIORITY_DEFAULT',
      apns: 5,
      description: 'Default notification priority. If the application does not prioritize its own notifications, use this value for all notifications.',
    },
    {
      id: 'high',
      android: 'PRIORITY_HIGH',
      apns: 8,
      description: '	Higher notification priority. Use this for more important notifications or alerts. The UI may choose to show these notifications larger, or at a different position in the notification lists, compared with notifications with PRIORITY_DEFAULT.',
    },
    {
      id: 'max',
      android: 'PRIORITY_MAX',
      apns: 10,
      description: 'Highest notification priority. Use this for the application\'s most important items that require the user\'s prompt attention or input.',
    },
  ]
end
