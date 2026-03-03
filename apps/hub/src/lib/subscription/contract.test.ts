import { getOrInitSubscription, setSubscription, evaluateAccess } from './index';

const sub = getOrInitSubscription('t_demo');
const d1 = evaluateAccess(sub);
if (!d1.ok) throw new Error('SUB_CONTRACT_EXPECT_TRIAL_OK');

setSubscription('t_demo', 'free', 'canceled');
const d2 = evaluateAccess(getOrInitSubscription('t_demo'));
if (d2.ok) throw new Error('SUB_CONTRACT_EXPECT_CANCELED_DENY');
