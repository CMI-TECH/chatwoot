/* global axios */
import ApiClient from './ApiClient';

class LeadStagesAPI extends ApiClient {
    constructor() {
        super('lead_stages', { accountScoped: true });
    }

    get() {
        return axios.get(this.url);
    }

    show(id) {
        return axios.get(`${this.url}/${id}`);
    }

    create(stageData) {
        return axios.post(this.url, stageData);
    }

    update(id, stageData) {
        return axios.patch(`${this.url}/${id}`, stageData);
    }

    delete(id) {
        return axios.delete(`${this.url}/${id}`);
    }
}

export default new LeadStagesAPI();
