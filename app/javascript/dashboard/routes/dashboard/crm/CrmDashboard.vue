<template>
  <div class="flex flex-col bg-slate-25 dark:bg-slate-900" style="height: 100%; overflow: hidden;">
    <!-- Header -->
    <div class="flex items-center justify-between p-6 bg-white dark:bg-slate-800 border-b border-slate-75 dark:border-slate-700">
      <div>
        <h1 class="text-2xl font-semibold text-slate-900 dark:text-slate-25">
          CRM - Pipeline de Vendas
        </h1>
        <p class="text-sm text-slate-600 dark:text-slate-400 mt-1">
          Gerencie seus leads e oportunidades
        </p>
      </div>
      
      <div class="flex items-center gap-3">
        <!-- Stats -->
        <div class="flex items-center gap-6 px-4 py-2 bg-slate-50 dark:bg-slate-700 rounded-lg">
          <div class="text-center">
            <p class="text-xs text-slate-600 dark:text-slate-400">Leads Ativos</p>
            <p class="text-lg font-bold text-slate-900 dark:text-slate-25">
              {{ activeLeadsCount }}
            </p>
          </div>
          <div class="text-center">
            <p class="text-xs text-slate-600 dark:text-slate-400">Valor Total</p>
            <p class="text-lg font-bold text-[#00D1FF]">
              {{ formatCurrency(totalValue) }}
            </p>
          </div>
        </div>

        <!-- Create Lead Button -->
        <button
          @click="showCreateModal = true"
          class="px-4 py-2 bg-[#00D1FF] hover:bg-[#0080FF] text-white rounded-lg font-medium transition-colors flex items-center gap-2"
        >
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
          </svg>
          Novo Lead
        </button>
      </div>
    </div>

    <!-- Kanban Board -->
    <div style="flex: 1; min-height: 0; overflow-x: auto; overflow-y: hidden; padding: 24px;">
      <div v-if="uiFlags.isFetching" class="flex items-center justify-center h-full">
        <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-[#00D1FF]"></div>
      </div>

      <div v-else style="display: flex; gap: 16px; height: 100%; min-width: max-content; padding-bottom: 16px;">
        <!-- Stage Columns -->
        <div
          v-for="stage in stages"
          :key="stage.value"
          class="flex flex-col w-80 bg-white dark:bg-slate-800 rounded-lg shadow-sm"
        >
          <!-- Column Header -->
          <div class="p-4 border-b border-slate-75 dark:border-slate-700">
            <div class="flex items-center justify-between">
              <div class="flex items-center gap-2">
                <div
                  class="w-3 h-3 rounded-full"
                  :style="{ backgroundColor: stage.color }"
                ></div>
                <h3 class="font-semibold text-slate-900 dark:text-slate-25">
                  {{ stage.label }}
                </h3>
              </div>
              <span class="text-sm text-slate-600 dark:text-slate-400">
                {{ getLeadsByStage(stage.value).length }}
              </span>
            </div>
          </div>

          <!-- Cards Container -->
          <div
            class="flex-1 overflow-y-auto p-3 space-y-3"
            @drop="onDrop($event, stage.value)"
            @dragover.prevent
            @dragenter.prevent
          >
            <div
              v-for="lead in getLeadsByStage(stage.value)"
              :key="lead.id"
              draggable="true"
              @dragstart="onDragStart($event, lead)"
              class="bg-slate-25 dark:bg-slate-700 rounded-lg p-4 cursor-move hover:shadow-md transition-shadow border border-slate-100 dark:border-slate-600"
              @click="openLeadModal(lead)"
            >
              <!-- Lead Card -->
              <div class="space-y-2">
                <h4 class="font-medium text-slate-900 dark:text-slate-25 line-clamp-2">
                  {{ lead.title }}
                </h4>
                
                <div class="flex items-center gap-2 text-sm text-slate-600 dark:text-slate-400">
                  <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                  </svg>
                  <span class="truncate">{{ lead.contact?.name || 'Sem contato' }}</span>
                </div>

                <div class="flex items-center justify-between">
                  <span class="text-lg font-bold text-[#00D1FF]">
                    {{ formatCurrency(lead.value) }}
                  </span>
                  
                  <span
                    class="px-2 py-1 text-xs rounded-full"
                    :class="getPriorityClass(lead.priority)"
                  >
                    {{ getPriorityLabel(lead.priority) }}
                  </span>
                </div>
              </div>
            </div>

            <!-- Empty State -->
            <div
              v-if="getLeadsByStage(stage.value).length === 0"
              class="flex items-center justify-center h-32 text-slate-400 dark:text-slate-500 text-sm"
            >
              Nenhum lead neste estágio
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Lead Modal -->
    <lead-modal
      :show="showCreateModal || !!selectedLead"
      :lead="selectedLead"
      @close="closeModal"
      @success="onLeadSaved"
    />
  </div>
</template>

<script>
import { mapGetters } from 'vuex';
import LeadModal from './components/LeadModal.vue';

export default {
  name: 'CrmDashboard',
  
  components: {
    LeadModal,
  },
  
  data() {
    return {
      showCreateModal: false,
      selectedLead: null,
      stages: [
        { value: 'lead', label: 'Lead', color: '#F5C542' },
        { value: 'aguardando_fatura', label: 'Aguardando Fatura', color: '#3B82F6' },
        { value: 'negociacao', label: 'Negociação', color: '#F97316' },
        { value: 'troca_titularidade', label: 'Troca de Titularidade', color: '#EF4444' },
        { value: 'enviar_contrato', label: 'Enviar Contrato', color: '#22C55E' },
        { value: 'contratos_assinados_cmf', label: 'Contratos Assinados CMF', color: '#16A34A' },
        { value: 'contrato_enviado', label: 'Contrato Enviado', color: '#4ADE80' },
        { value: 'declinados', label: 'Declinados', color: '#DC2626' },
        { value: 'negocio_fechado', label: 'Negócio Fechado', color: '#1E293B' },
      ],
    };
  },

  computed: {
    ...mapGetters({
      leads: 'leads/getLeads',
      uiFlags: 'leads/getUIFlags',
      totalValue: 'leads/getTotalValue',
      activeLeads: 'leads/getActiveLeads',
    }),

    activeLeadsCount() {
      return this.activeLeads.length;
    },
  },

  mounted() {
    this.fetchLeads();
  },

  methods: {
    async fetchLeads() {
      try {
        await this.$store.dispatch('leads/get');
      } catch (error) {
        console.error('Error fetching leads:', error);
      }
    },

    getLeadsByStage(stage) {
      return this.$store.getters['leads/getLeadsByStage'](stage);
    },

    onDragStart(event, lead) {
      event.dataTransfer.effectAllowed = 'move';
      event.dataTransfer.setData('leadId', lead.id);
    },

    async onDrop(event, newStage) {
      const leadId = parseInt(event.dataTransfer.getData('leadId'));
      
      try {
        await this.$store.dispatch('leads/moveStage', {
          id: leadId,
          newStage,
        });
      } catch (error) {
        console.error('Error moving lead:', error);
      }
    },

    openLeadModal(lead) {
      this.selectedLead = lead;
    },

    closeModal() {
      this.showCreateModal = false;
      this.selectedLead = null;
    },

    async onLeadSaved() {
      await this.fetchLeads();
    },

    formatCurrency(value) {
      return new Intl.NumberFormat('pt-BR', {
        style: 'currency',
        currency: 'BRL',
      }).format(value || 0);
    },

    getPriorityClass(priority) {
      const classes = {
        low: 'bg-slate-100 text-slate-700 dark:bg-slate-600 dark:text-slate-200',
        medium: 'bg-yellow-100 text-yellow-700 dark:bg-yellow-900 dark:text-yellow-200',
        high: 'bg-red-100 text-red-700 dark:bg-red-900 dark:text-red-200',
      };
      return classes[priority] || classes.medium;
    },

    getPriorityLabel(priority) {
      const labels = {
        low: 'Baixa',
        medium: 'Média',
        high: 'Alta',
      };
      return labels[priority] || 'Média';
    },
  },
};
</script>
