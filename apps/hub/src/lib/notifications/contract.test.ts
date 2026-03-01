import { dispatchNotification, assertNotificationsProviderIsStub } from './index';

assertNotificationsProviderIsStub('stub');

void dispatchNotification({
  tenantId: 't_demo',
  channel: 'email',
  recipient: { userId: 'u_demo', email: 'x@example.com' },
  template: 'welcome',
  data: { name: 'Demo' },
});
