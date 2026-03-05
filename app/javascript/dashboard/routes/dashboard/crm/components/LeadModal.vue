<template>
  <div
    v-if="show"
    class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4"
    @click.self="closeModal"
  >
    <div class="bg-white dark:bg-slate-800 rounded-lg w-full max-w-2xl max-h-[90vh] overflow-hidden flex flex-col">
      <!-- Header -->
      <div class="flex items-center justify-between p-6 border-b border-slate-200 dark:border-slate-700">
        <h2 class="text-xl font-semibold text-slate-900 dark:text-slate-25">
          {{ isEditing ? 'Editar Lead' : 'Novo Lead' }}
        </h2>
        <button
          @click="closeModal"
          class="text-slate-400 hover:text-slate-600 dark:hover:text-slate-200 transition-colors"
        >
          <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
          </svg>
        </button>
      </div>

      <!-- Body -->
      <div class="flex-1 overflow-y-auto p-6">
        <form @submit.prevent="handleSubmit" class="space-y-4">
          <!-- Title -->
          <div>
            <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">
              Título *
            </label>
            <input
              v-model="formData.title"
              type="text"
              required
              class="w-full px-3 py-2 border border-slate-300 dark:border-slate-600 rounded-lg bg-white dark:bg-slate-700 text-slate-900 dark:text-slate-25 focus:ring-2 focus:ring-[#00D1FF] focus:border-transparent"
              placeholder="Ex: Proposta para Sistema de Gestão"
            />
          </div>

          <!-- Contact -->
          <div>
            <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">
              Contato *
            </label>
            <select
              v-model="formData.contact_id"
              required
              class="w-full px-3 py-2 border border-slate-300 dark:border-slate-600 rounded-lg bg-white dark:bg-slate-700 text-slate-900 dark:text-slate-25 focus:ring-2 focus:ring-[#00D1FF] focus:border-transparent"
            >
              <option value="">Selecione um contato</option>
              <option v-for="contact in contacts" :key="contact.id" :value="contact.id">
                {{ contact.name }}
              </option>
            </select>
          </div>

          <!-- Value -->
          <div>
            <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">
              Valor (R$)
            </label>
            <input
              v-model.number="formData.value"
              type="number"
              step="0.01"
              min="0"
              class="w-full px-3 py-2 border border-slate-300 dark:border-slate-600 rounded-lg bg-white dark:bg-slate-700 text-slate-900 dark:text-slate-25 focus:ring-2 focus:ring-[#00D1FF] focus:border-transparent"
              placeholder="0.00"
            />
          </div>

          <!-- Stage -->
          <div>
            <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">
              Estágio
            </label>
            <select
              v-model="formData.stage"
              class="w-full px-3 py-2 border border-slate-300 dark:border-slate-600 rounded-lg bg-white dark:bg-slate-700 text-slate-900 dark:text-slate-25 focus:ring-2 focus:ring-[#00D1FF] focus:border-transparent"
            >
              <option value="lead">Lead</option>
              <option value="aguardando_fatura">Aguardando Fatura</option>
              <option value="negociacao">Negociação</option>
              <option value="troca_titularidade">Troca de Titularidade</option>
              <option value="enviar_contrato">Enviar Contrato</option>
              <option value="contratos_assinados_cmf">Contratos Assinados CMF</option>
              <option value="contrato_enviado">Contrato Enviado</option>
              <option value="declinados">Declinados</option>
              <option value="negocio_fechado">Negócio Fechado</option>
            </select>
          </div>

          <!-- Priority -->
          <div>
            <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">
              Prioridade
            </label>
            <div class="flex gap-3">
              <label
                v-for="priority in priorities"
                :key="priority.value"
                class="flex-1 cursor-pointer"
              >
                <input
                  v-model="formData.priority"
                  type="radio"
                  :value="priority.value"
                  class="sr-only"
                />
                <div
                  class="px-4 py-2 rounded-lg text-center font-medium transition-all"
                  :class="formData.priority === priority.value ? priority.activeClass : priority.inactiveClass"
                >
                  {{ priority.label }}
                </div>
              </label>
            </div>
          </div>

          <!-- Assigned User -->
          <div>
            <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">
              Responsável
            </label>
            <select
              v-model="formData.assigned_user_id"
              class="w-full px-3 py-2 border border-slate-300 dark:border-slate-600 rounded-lg bg-white dark:bg-slate-700 text-slate-900 dark:text-slate-25 focus:ring-2 focus:ring-[#00D1FF] focus:border-transparent"
            >
              <option value="">Nenhum</option>
              <option v-for="agent in agents" :key="agent.id" :value="agent.id">
                {{ agent.name }}
              </option>
            </select>
          </div>

          <!-- Description -->
          <div>
            <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">
              Descrição
            </label>
            <textarea
              v-model="formData.description"
              rows="4"
              class="w-full px-3 py-2 border border-slate-300 dark:border-slate-600 rounded-lg bg-white dark:bg-slate-700 text-slate-900 dark:text-slate-25 focus:ring-2 focus:ring-[#00D1FF] focus:border-transparent resize-none"
              placeholder="Detalhes sobre o lead..."
            ></textarea>
          </div>
        </form>
      </div>

      <!-- Footer -->
      <div class="flex items-center justify-end gap-3 p-6 border-t border-slate-200 dark:border-slate-700">
        <button
          @click="closeModal"
          type="button"
          class="px-4 py-2 text-slate-700 dark:text-slate-300 hover:bg-slate-100 dark:hover:bg-slate-700 rounded-lg font-medium transition-colors"
        >
          Cancelar
        </button>
        <button
          @click="handleSubmit"
          :disabled="isSubmitting"
          class="px-6 py-2 bg-[#00D1FF] hover:bg-[#0080FF] text-white rounded-lg font-medium transition-colors disabled:opacity-50 disabled:cursor-not-allowed flex items-center gap-2"
        >
          <span v-if="isSubmitting" class="animate-spin rounded-full h-4 w-4 border-b-2 border-white"></span>
          {{ isSubmitting ? 'Salvando...' : (isEditing ? 'Salvar' : 'Criar Lead') }}
        </button>
      </div>
    </div>
  </div>
</template>

<script>
import { mapGetters } from 'vuex';
import { useAlert } from 'dashboard/composables';

export default {
  name: 'LeadModal',
  
  props: {
    show: {
      type: Boolean,
      default: false,
    },
    lead: {
      type: Object,
      default: null,
    },
  },

  data() {
    return {
      isSubmitting: false,
      formData: {
        title: '',
        contact_id: '',
        value: 0,
        stage: 'lead',
        priority: 'medium',
        assigned_user_id: '',
        description: '',
      },
      priorities: [
        {
          value: 'low',
          label: 'Baixa',
          activeClass: 'bg-slate-200 text-slate-900 dark:bg-slate-600 dark:text-slate-25',
          inactiveClass: 'bg-slate-50 text-slate-600 dark:bg-slate-700 dark:text-slate-400',
        },
        {
          value: 'medium',
          label: 'Média',
          activeClass: 'bg-yellow-200 text-yellow-900 dark:bg-yellow-700 dark:text-yellow-100',
          inactiveClass: 'bg-slate-50 text-slate-600 dark:bg-slate-700 dark:text-slate-400',
        },
        {
          value: 'high',
          label: 'Alta',
          activeClass: 'bg-red-200 text-red-900 dark:bg-red-700 dark:text-red-100',
          inactiveClass: 'bg-slate-50 text-slate-600 dark:bg-slate-700 dark:text-slate-400',
        },
      ],
    };
  },

  computed: {
    ...mapGetters({
      contacts: 'contacts/getContacts',
      agents: 'agents/getVerifiedAgents',
    }),

    isEditing() {
      return !!this.lead;
    },
  },

  watch: {
    show(newVal) {
      if (newVal) {
        this.initForm();
      }
    },
  },

  methods: {
    initForm() {
      if (this.lead) {
        this.formData = {
          title: this.lead.title || '',
          contact_id: this.lead.contact_id || '',
          value: this.lead.value || 0,
          stage: this.lead.stage || 'lead',
          priority: this.lead.priority || 'medium',
          assigned_user_id: this.lead.assigned_user_id || '',
          description: this.lead.description || '',
        };
      } else {
        this.formData = {
          title: '',
          contact_id: '',
          value: 0,
          stage: 'lead',
          priority: 'medium',
          assigned_user_id: '',
          description: '',
        };
      }
    },

    async handleSubmit() {
      this.isSubmitting = true;

      try {
        const payload = {
          lead: this.formData,
        };

        if (this.isEditing) {
          await this.$store.dispatch('leads/update', {
            id: this.lead.id,
            ...payload,
          });
        } else {
          await this.$store.dispatch('leads/create', payload);
        }

        this.$emit('success');
        this.closeModal();
      } catch (error) {
        console.error('Error saving lead:', error);
        useAlert('Ocorreu um erro ao salvar o lead. Por favor, tente novamente.');
      } finally {
        this.isSubmitting = false;
      }
    },

    closeModal() {
      this.$emit('close');
    },
  },
};
</script>
