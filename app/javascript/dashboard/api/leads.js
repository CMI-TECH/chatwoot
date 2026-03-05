/* global axios */
import ApiClient from './ApiClient';

class LeadsAPI extends ApiClient {
    constructor() {
        super('leads', { accountScoped: true });
    }

    get({ page = 1, stage, priority, assigned_user_id, sort_by, sort_order } = {}) {
        const params = {
            page,
            ...(stage && { stage }),
            ...(priority && { priority }),
            ...(assigned_user_id && { assigned_user_id }),
            ...(sort_by && { sort_by }),
            ...(sort_order && { sort_order }),
        };

        return axios.get(this.url, { params });
    }

    show(id) {
        return axios.get(`${this.url}/${id}`);
    }

    create(leadData) {
        return axios.post(this.url, leadData);
    }

    update(id, leadData) {
        return axios.patch(`${this.url}/${id}`, leadData);
    }

    delete(id) {
        return axios.delete(`${this.url}/${id}`);
    }

    moveStage(id, newStage) {
        return axios.patch(`${this.url}/${id}`, {
            lead: { stage: newStage }
        });
    }
}

export default new LeadsAPI();
