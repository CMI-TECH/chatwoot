import { frontendURL } from '../../../helper/URLHelper';

export const routes = [
    {
        path: frontendURL('accounts/:accountId/crm'),
        name: 'crm_dashboard',
        component: () => import('./CrmDashboard.vue'),
        meta: {
            permissions: ['administrator', 'agent'],
        },
    },
];
