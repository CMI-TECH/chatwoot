import * as MutationHelpers from 'shared/helpers/vuex/mutationHelpers';
import types from '../mutation-types';
import LeadsAPI from '../../api/leads';

export const state = {
    records: [],
    uiFlags: {
        isFetching: false,
        isFetchingItem: false,
        isCreating: false,
        isUpdating: false,
        isDeleting: false,
    },
    meta: {
        count: 0,
        currentPage: 1,
    },
};

export const getters = {
    getLeads(_state) {
        return _state.records;
    },
    getLeadsByStage: _state => stage => {
        return _state.records.filter(lead => lead.stage === stage);
    },
    getLead: _state => id => {
        return _state.records.find(lead => lead.id === id);
    },
    getUIFlags(_state) {
        return _state.uiFlags;
    },
    getMeta(_state) {
        return _state.meta;
    },
    getTotalValue(_state) {
        return _state.records.reduce((sum, lead) => {
            return sum + (parseFloat(lead.value) || 0);
        }, 0);
    },
    getActiveLeads(_state) {
        return _state.records.filter(lead =>
            lead.stage !== 'negocio_fechado' && lead.stage !== 'declinados'
        );
    },
};

export const actions = {
    get: async ({ commit }, params = {}) => {
        commit(types.SET_LEADS_UI_FLAG, { isFetching: true });
        try {
            const response = await LeadsAPI.get(params);
            commit(types.SET_LEADS, response.data);
            commit(types.SET_LEADS_META, {
                count: response.data.meta?.count || response.data.length,
                currentPage: params.page || 1,
            });
        } catch (error) {
            // Handle error
            throw error;
        } finally {
            commit(types.SET_LEADS_UI_FLAG, { isFetching: false });
        }
    },

    show: async ({ commit }, id) => {
        commit(types.SET_LEADS_UI_FLAG, { isFetchingItem: true });
        try {
            const response = await LeadsAPI.show(id);
            commit(types.ADD_LEAD, response.data);
            return response.data;
        } catch (error) {
            throw error;
        } finally {
            commit(types.SET_LEADS_UI_FLAG, { isFetchingItem: false });
        }
    },

    create: async ({ commit }, leadData) => {
        commit(types.SET_LEADS_UI_FLAG, { isCreating: true });
        try {
            const response = await LeadsAPI.create(leadData);
            commit(types.ADD_LEAD, response.data);
            return response.data;
        } catch (error) {
            throw error;
        } finally {
            commit(types.SET_LEADS_UI_FLAG, { isCreating: false });
        }
    },

    update: async ({ commit }, { id, ...leadData }) => {
        commit(types.SET_LEADS_UI_FLAG, { isUpdating: true });
        try {
            const response = await LeadsAPI.update(id, leadData);
            commit(types.EDIT_LEAD, response.data);
            return response.data;
        } catch (error) {
            throw error;
        } finally {
            commit(types.SET_LEADS_UI_FLAG, { isUpdating: false });
        }
    },

    delete: async ({ commit }, id) => {
        commit(types.SET_LEADS_UI_FLAG, { isDeleting: true });
        try {
            await LeadsAPI.delete(id);
            commit(types.DELETE_LEAD, id);
        } catch (error) {
            throw error;
        } finally {
            commit(types.SET_LEADS_UI_FLAG, { isDeleting: false });
        }
    },

    moveStage: async ({ commit }, { id, newStage }) => {
        commit(types.SET_LEADS_UI_FLAG, { isUpdating: true });
        try {
            const response = await LeadsAPI.moveStage(id, newStage);
            commit(types.EDIT_LEAD, response.data);
            return response.data;
        } catch (error) {
            throw error;
        } finally {
            commit(types.SET_LEADS_UI_FLAG, { isUpdating: false });
        }
    },
};

export const mutations = {
    [types.SET_LEADS_UI_FLAG](_state, data) {
        _state.uiFlags = {
            ..._state.uiFlags,
            ...data,
        };
    },

    [types.SET_LEADS]: MutationHelpers.set,
    [types.SET_LEADS_META](_state, data) {
        _state.meta = data;
    },
    [types.ADD_LEAD]: MutationHelpers.create,
    [types.EDIT_LEAD]: MutationHelpers.update,
    [types.DELETE_LEAD]: MutationHelpers.destroy,
};

export default {
    namespaced: true,
    state,
    getters,
    actions,
    mutations,
};
