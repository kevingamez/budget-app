import Foundation

/// Centralized translation service for runtime language switching.
/// Usage: `let S = AppStrings.shared; Text(S.tr("key"))`
@Observable
final class AppStrings {
    static let shared = AppStrings()

    var language: String {
        didSet {
            UserDefaults.standard.set(language, forKey: "preferredLanguage")
        }
    }

    private init() {
        self.language = UserDefaults.standard.string(forKey: "preferredLanguage") ?? "en"
    }

    func tr(_ key: String) -> String {
        Self.translations[key]?[language]
            ?? Self.translations[key]?["en"]
            ?? key
    }

    /// Interpolated translation: replaces `%@` placeholders in order.
    func tr(_ key: String, _ args: String...) -> String {
        var result = tr(key)
        for arg in args {
            if let range = result.range(of: "%@") {
                result.replaceSubrange(range, with: arg)
            }
        }
        return result
    }

    // MARK: - Translation Dictionary

    static let translations: [String: [String: String]] = [

        // =====================================================================
        // MARK: - Tab Titles
        // =====================================================================

        "tab.dashboard": [
            "en": "Dashboard",
            "es": "Panel",
            "fr": "Tableau de bord",
            "pt": "Painel",
            "ja": "\u{30C0}\u{30C3}\u{30B7}\u{30E5}\u{30DC}\u{30FC}\u{30C9}",
            "ko": "\u{B300}\u{C2DC}\u{BCF4}\u{B4DC}",
        ],
        "tab.debts": [
            "en": "Debts",
            "es": "Deudas",
            "fr": "Dettes",
            "pt": "D\u{00ED}vidas",
            "ja": "\u{50B5}\u{52D9}",
            "ko": "\u{BE5A}",
        ],
        "tab.activity": [
            "en": "Activity",
            "es": "Actividad",
            "fr": "Activit\u{00E9}",
            "pt": "Atividade",
            "ja": "\u{30A2}\u{30AF}\u{30C6}\u{30A3}\u{30D3}\u{30C6}\u{30A3}",
            "ko": "\u{D65C}\u{B3D9}",
        ],
        "tab.settings": [
            "en": "Settings",
            "es": "Ajustes",
            "fr": "R\u{00E9}glages",
            "pt": "Configura\u{00E7}\u{00F5}es",
            "ja": "\u{8A2D}\u{5B9A}",
            "ko": "\u{C124}\u{C815}",
        ],

        // =====================================================================
        // MARK: - Greetings
        // =====================================================================

        "greeting.morning": [
            "en": "Good Morning",
            "es": "Buenos D\u{00ED}as",
            "fr": "Bonjour",
            "pt": "Bom Dia",
            "ja": "\u{304A}\u{306F}\u{3088}\u{3046}\u{3054}\u{3056}\u{3044}\u{307E}\u{3059}",
            "ko": "\u{C88B}\u{C740} \u{C544}\u{CE68}",
        ],
        "greeting.afternoon": [
            "en": "Good Afternoon",
            "es": "Buenas Tardes",
            "fr": "Bon Apr\u{00E8}s-midi",
            "pt": "Boa Tarde",
            "ja": "\u{3053}\u{3093}\u{306B}\u{3061}\u{306F}",
            "ko": "\u{C88B}\u{C740} \u{C624}\u{D6C4}",
        ],
        "greeting.evening": [
            "en": "Good Evening",
            "es": "Buenas Noches",
            "fr": "Bonsoir",
            "pt": "Boa Noite",
            "ja": "\u{3053}\u{3093}\u{3070}\u{3093}\u{306F}",
            "ko": "\u{C88B}\u{C740} \u{C800}\u{B141}",
        ],
        "greeting.subtitle": [
            "en": "Here's your debt overview",
            "es": "Resumen de tus deudas",
            "fr": "Voici votre aper\u{00E7}u des dettes",
            "pt": "Resumo das suas d\u{00ED}vidas",
            "ja": "\u{50B5}\u{52D9}\u{306E}\u{6982}\u{8981}\u{3067}\u{3059}",
            "ko": "\u{BE5A} \u{C694}\u{C57D}\u{C785}\u{B2C8}\u{B2E4}",
        ],

        // =====================================================================
        // MARK: - Balance Overview
        // =====================================================================

        "balance.netBalance": [
            "en": "Net Balance",
            "es": "Balance Neto",
            "fr": "Solde Net",
            "pt": "Saldo L\u{00ED}quido",
            "ja": "\u{7D14}\u{6B8B}\u{9AD8}",
            "ko": "\u{C21C} \u{C794}\u{C561}",
        ],
        "balance.owedToMe": [
            "en": "Owed to Me",
            "es": "Me Deben",
            "fr": "On Me Doit",
            "pt": "Me Devem",
            "ja": "\u{8CB8}\u{3057}\u{305F}\u{304A}\u{91D1}",
            "ko": "\u{BC1B}\u{C744} \u{B3C8}",
        ],
        "balance.iOwe": [
            "en": "I Owe",
            "es": "Yo Debo",
            "fr": "Je Dois",
            "pt": "Eu Devo",
            "ja": "\u{501F}\u{308A}\u{305F}\u{304A}\u{91D1}",
            "ko": "\u{AC1A}\u{C740} \u{B3C8}",
        ],

        // =====================================================================
        // MARK: - Dashboard
        // =====================================================================

        "dashboard.activeDebts": [
            "en": "Active Debts",
            "es": "Deudas Activas",
            "fr": "Dettes Actives",
            "pt": "D\u{00ED}vidas Ativas",
            "ja": "\u{6D3B}\u{52D5}\u{4E2D}\u{306E}\u{50B5}\u{52D9}",
            "ko": "\u{D65C}\u{C131} \u{BE5A}",
        ],
        "dashboard.overdue": [
            "en": "Overdue",
            "es": "Vencidas",
            "fr": "En Retard",
            "pt": "Atrasadas",
            "ja": "\u{671F}\u{9650}\u{5207}\u{308C}",
            "ko": "\u{C5F0}\u{CCB4}",
        ],
        "dashboard.lifetimeStats": [
            "en": "LIFETIME STATS",
            "es": "ESTAD\u{00CD}STICAS TOTALES",
            "fr": "STATISTIQUES GLOBALES",
            "pt": "ESTAT\u{00CD}STICAS GERAIS",
            "ja": "\u{7D71}\u{8A08}",
            "ko": "\u{C804}\u{CCB4} \u{D1B5}\u{ACC4}",
        ],

        // =====================================================================
        // MARK: - Debt Progress
        // =====================================================================

        "progress.almostPaidOff": [
            "en": "Almost Paid Off",
            "es": "Casi Pagadas",
            "fr": "Presque Rembours\u{00E9}",
            "pt": "Quase Pagas",
            "ja": "\u{3082}\u{3046}\u{3059}\u{3050}\u{5B8C}\u{6E08}",
            "ko": "\u{AC70}\u{C758} \u{C644}\u{B0A9}",
        ],
        "progress.empty": [
            "en": "No debts with partial payments yet.",
            "es": "A\u{00FA}n no hay deudas con pagos parciales.",
            "fr": "Aucune dette avec paiements partiels.",
            "pt": "Nenhuma d\u{00ED}vida com pagamentos parciais.",
            "ja": "\u{90E8}\u{5206}\u{652F}\u{6255}\u{3044}\u{306E}\u{3042}\u{308B}\u{50B5}\u{52D9}\u{306F}\u{3042}\u{308A}\u{307E}\u{305B}\u{3093}\u{3002}",
            "ko": "\u{BD80}\u{BD84} \u{C0C1}\u{D658}\u{B41C} \u{BE5A}\u{C774} \u{C5C6}\u{C2B5}\u{B2C8}\u{B2E4}.",
        ],

        // =====================================================================
        // MARK: - Recent Activity
        // =====================================================================

        "recent.title": [
            "en": "Recent Payments",
            "es": "Pagos Recientes",
            "fr": "Paiements R\u{00E9}cents",
            "pt": "Pagamentos Recentes",
            "ja": "\u{6700}\u{8FD1}\u{306E}\u{652F}\u{6255}\u{3044}",
            "ko": "\u{CD5C}\u{ADF8} \u{ACB0}\u{C81C}",
        ],
        "recent.empty": [
            "en": "No payments recorded yet.",
            "es": "A\u{00FA}n no hay pagos registrados.",
            "fr": "Aucun paiement enregistr\u{00E9}.",
            "pt": "Nenhum pagamento registrado.",
            "ja": "\u{652F}\u{6255}\u{3044}\u{8A18}\u{9332}\u{306F}\u{3042}\u{308A}\u{307E}\u{305B}\u{3093}\u{3002}",
            "ko": "\u{ACB0}\u{C81C} \u{AE30}\u{B85D}\u{C774} \u{C5C6}\u{C2B5}\u{B2C8}\u{B2E4}.",
        ],

        // =====================================================================
        // MARK: - Debts List
        // =====================================================================

        "debts.empty.title": [
            "en": "No Debts Yet",
            "es": "Sin Deudas A\u{00FA}n",
            "fr": "Aucune Dette",
            "pt": "Sem D\u{00ED}vidas",
            "ja": "\u{50B5}\u{52D9}\u{306F}\u{3042}\u{308A}\u{307E}\u{305B}\u{3093}",
            "ko": "\u{BE5A}\u{C774} \u{C5C6}\u{C2B5}\u{B2C8}\u{B2E4}",
        ],
        "debts.empty.subtitle": [
            "en": "Start tracking your debts by tapping the + button below.",
            "es": "Empieza a rastrear tus deudas tocando el bot\u{00F3}n + abajo.",
            "fr": "Commencez \u{00E0} suivre vos dettes en appuyant sur le bouton +.",
            "pt": "Comece a rastrear suas d\u{00ED}vidas tocando no bot\u{00E3}o + abaixo.",
            "ja": "\u{4E0B}\u{306E}+\u{30DC}\u{30BF}\u{30F3}\u{3092}\u{30BF}\u{30C3}\u{30D7}\u{3057}\u{3066}\u{50B5}\u{52D9}\u{306E}\u{8FFD}\u{8DE1}\u{3092}\u{958B}\u{59CB}\u{3057}\u{307E}\u{3057}\u{3087}\u{3046}\u{3002}",
            "ko": "\u{C544}\u{B798} + \u{BC84}\u{D2BC}\u{C744} \u{D0ED}\u{D558}\u{C5EC} \u{BE5A} \u{CD94}\u{C801}\u{C744} \u{C2DC}\u{C791}\u{D558}\u{C138}\u{C694}.",
        ],
        "debts.noResults.title": [
            "en": "No Results",
            "es": "Sin Resultados",
            "fr": "Aucun R\u{00E9}sultat",
            "pt": "Sem Resultados",
            "ja": "\u{7D50}\u{679C}\u{306A}\u{3057}",
            "ko": "\u{ACB0}\u{ACFC} \u{C5C6}\u{C74C}",
        ],
        "debts.noResults.subtitle": [
            "en": "Try adjusting your filters or search.",
            "es": "Intenta ajustar tus filtros o b\u{00FA}squeda.",
            "fr": "Essayez d'ajuster vos filtres ou recherche.",
            "pt": "Tente ajustar seus filtros ou busca.",
            "ja": "\u{30D5}\u{30A3}\u{30EB}\u{30BF}\u{30FC}\u{3084}\u{691C}\u{7D22}\u{3092}\u{8ABF}\u{6574}\u{3057}\u{3066}\u{304F}\u{3060}\u{3055}\u{3044}\u{3002}",
            "ko": "\u{D544}\u{D130}\u{B098} \u{AC80}\u{C0C9}\u{C744} \u{C870}\u{C815}\u{D574} \u{BCF4}\u{C138}\u{C694}.",
        ],
        "debts.searchPrompt": [
            "en": "Search debts...",
            "es": "Buscar deudas...",
            "fr": "Rechercher des dettes...",
            "pt": "Buscar d\u{00ED}vidas...",
            "ja": "\u{50B5}\u{52D9}\u{3092}\u{691C}\u{7D22}...",
            "ko": "\u{BE5A} \u{AC80}\u{C0C9}...",
        ],

        // =====================================================================
        // MARK: - Filters
        // =====================================================================

        "filter.all": [
            "en": "All",
            "es": "Todos",
            "fr": "Tout",
            "pt": "Todos",
            "ja": "\u{3059}\u{3079}\u{3066}",
            "ko": "\u{C804}\u{CCB4}",
        ],
        "filter.owedToMe": [
            "en": "Owed to Me",
            "es": "Me Deben",
            "fr": "On Me Doit",
            "pt": "Me Devem",
            "ja": "\u{8CB8}\u{3057}\u{305F}\u{304A}\u{91D1}",
            "ko": "\u{BC1B}\u{C744} \u{B3C8}",
        ],
        "filter.iOwe": [
            "en": "I Owe",
            "es": "Yo Debo",
            "fr": "Je Dois",
            "pt": "Eu Devo",
            "ja": "\u{501F}\u{308A}\u{305F}\u{304A}\u{91D1}",
            "ko": "\u{AC1A}\u{C740} \u{B3C8}",
        ],
        "filter.incoming": [
            "en": "Incoming",
            "es": "Entrante",
            "fr": "Entrant",
            "pt": "Entrada",
            "ja": "\u{5165}\u{91D1}",
            "ko": "\u{C218}\u{C785}",
        ],
        "filter.outgoing": [
            "en": "Outgoing",
            "es": "Saliente",
            "fr": "Sortant",
            "pt": "Sa\u{00ED}da",
            "ja": "\u{51FA}\u{91D1}",
            "ko": "\u{C9C0}\u{CD9C}",
        ],

        // =====================================================================
        // MARK: - Sort Options
        // =====================================================================

        "sort.dateCreated": [
            "en": "Date Created",
            "es": "Fecha de Creaci\u{00F3}n",
            "fr": "Date de Cr\u{00E9}ation",
            "pt": "Data de Cria\u{00E7}\u{00E3}o",
            "ja": "\u{4F5C}\u{6210}\u{65E5}",
            "ko": "\u{C0DD}\u{C131}\u{C77C}",
        ],
        "sort.dueDate": [
            "en": "Due Date",
            "es": "Fecha de Vencimiento",
            "fr": "Date d'\u{00E9}ch\u{00E9}ance",
            "pt": "Data de Vencimento",
            "ja": "\u{671F}\u{9650}\u{65E5}",
            "ko": "\u{B9CC}\u{AE30}\u{C77C}",
        ],
        "sort.amount": [
            "en": "Amount",
            "es": "Monto",
            "fr": "Montant",
            "pt": "Valor",
            "ja": "\u{91D1}\u{984D}",
            "ko": "\u{AE08}\u{C561}",
        ],
        "sort.person": [
            "en": "Person",
            "es": "Persona",
            "fr": "Personne",
            "pt": "Pessoa",
            "ja": "\u{4EBA}\u{7269}",
            "ko": "\u{C0AC}\u{B78C}",
        ],

        // =====================================================================
        // MARK: - Status Labels
        // =====================================================================

        "status.active": [
            "en": "Active",
            "es": "Activa",
            "fr": "Active",
            "pt": "Ativa",
            "ja": "\u{30A2}\u{30AF}\u{30C6}\u{30A3}\u{30D6}",
            "ko": "\u{D65C}\u{C131}",
        ],
        "status.partiallyPaid": [
            "en": "Partially Paid",
            "es": "Parcialmente Pagada",
            "fr": "Partiellement Pay\u{00E9}",
            "pt": "Parcialmente Paga",
            "ja": "\u{90E8}\u{5206}\u{652F}\u{6255}\u{3044}\u{6E08}",
            "ko": "\u{BD80}\u{BD84} \u{C0C1}\u{D658}",
        ],
        "status.paidOff": [
            "en": "Paid Off",
            "es": "Pagada",
            "fr": "Rembours\u{00E9}",
            "pt": "Paga",
            "ja": "\u{5B8C}\u{6E08}",
            "ko": "\u{C644}\u{B0A9}",
        ],
        "status.overdue": [
            "en": "Overdue",
            "es": "Vencida",
            "fr": "En Retard",
            "pt": "Atrasada",
            "ja": "\u{671F}\u{9650}\u{5207}\u{308C}",
            "ko": "\u{C5F0}\u{CCB4}",
        ],
        "status.forgiven": [
            "en": "Forgiven",
            "es": "Perdonada",
            "fr": "Pardonn\u{00E9}",
            "pt": "Perdoada",
            "ja": "\u{514D}\u{9664}",
            "ko": "\u{D0D5}\u{AC10}",
        ],
        "status.overdueBadge": [
            "en": "OVERDUE",
            "es": "VENCIDA",
            "fr": "EN RETARD",
            "pt": "ATRASADA",
            "ja": "\u{671F}\u{9650}\u{5207}\u{308C}",
            "ko": "\u{C5F0}\u{CCB4}",
        ],
        "status.paid": [
            "en": "Paid",
            "es": "Pagada",
            "fr": "Pay\u{00E9}",
            "pt": "Paga",
            "ja": "\u{652F}\u{6255}\u{6E08}",
            "ko": "\u{C644}\u{B0A9}",
        ],

        // =====================================================================
        // MARK: - Direction Labels
        // =====================================================================

        "direction.owedToMe": [
            "en": "Owed to Me",
            "es": "Me Deben",
            "fr": "On Me Doit",
            "pt": "Me Devem",
            "ja": "\u{8CB8}\u{3057}\u{305F}\u{304A}\u{91D1}",
            "ko": "\u{BC1B}\u{C744} \u{B3C8}",
        ],
        "direction.iOwe": [
            "en": "I Owe",
            "es": "Yo Debo",
            "fr": "Je Dois",
            "pt": "Eu Devo",
            "ja": "\u{501F}\u{308A}\u{305F}\u{304A}\u{91D1}",
            "ko": "\u{AC1A}\u{C740} \u{B3C8}",
        ],
        "direction.incoming": [
            "en": "Incoming",
            "es": "Entrante",
            "fr": "Entrant",
            "pt": "Entrada",
            "ja": "\u{5165}\u{91D1}",
            "ko": "\u{C218}\u{C785}",
        ],
        "direction.outgoing": [
            "en": "Outgoing",
            "es": "Saliente",
            "fr": "Sortant",
            "pt": "Sa\u{00ED}da",
            "ja": "\u{51FA}\u{91D1}",
            "ko": "\u{C9C0}\u{CD9C}",
        ],
        "direction.someoneOwesMe": [
            "en": "Someone owes me",
            "es": "Alguien me debe",
            "fr": "Quelqu'un me doit",
            "pt": "Algu\u{00E9}m me deve",
            "ja": "\u{8AB0}\u{304B}\u{304C}\u{79C1}\u{306B}\u{501F}\u{308A}\u{3066}\u{3044}\u{308B}",
            "ko": "\u{B204}\u{AD70}\u{AC00} \u{B098}\u{C5D0}\u{AC8C} \u{BE5A}\u{C84C}\u{B2E4}",
        ],
        "direction.iOweSomeone": [
            "en": "I owe someone",
            "es": "Yo le debo a alguien",
            "fr": "Je dois \u{00E0} quelqu'un",
            "pt": "Eu devo a algu\u{00E9}m",
            "ja": "\u{79C1}\u{304C}\u{8AB0}\u{304B}\u{306B}\u{501F}\u{308A}\u{3066}\u{3044}\u{308B}",
            "ko": "\u{B0B4}\u{AC00} \u{B204}\u{AD70}\u{AC00}\u{C5D0}\u{AC8C} \u{BE5A}\u{C84C}\u{B2E4}",
        ],

        // =====================================================================
        // MARK: - Category Labels
        // =====================================================================

        "category.personal": [
            "en": "Personal",
            "es": "Personal",
            "fr": "Personnel",
            "pt": "Pessoal",
            "ja": "\u{500B}\u{4EBA}",
            "ko": "\u{AC1C}\u{C778}",
        ],
        "category.business": [
            "en": "Business",
            "es": "Negocio",
            "fr": "Affaires",
            "pt": "Neg\u{00F3}cio",
            "ja": "\u{30D3}\u{30B8}\u{30CD}\u{30B9}",
            "ko": "\u{C0AC}\u{C5C5}",
        ],
        "category.family": [
            "en": "Family",
            "es": "Familia",
            "fr": "Famille",
            "pt": "Fam\u{00ED}lia",
            "ja": "\u{5BB6}\u{65CF}",
            "ko": "\u{AC00}\u{C871}",
        ],
        "category.rent": [
            "en": "Rent",
            "es": "Alquiler",
            "fr": "Loyer",
            "pt": "Aluguel",
            "ja": "\u{5BB6}\u{8CC3}",
            "ko": "\u{C784}\u{B300}\u{B8CC}",
        ],
        "category.food": [
            "en": "Food",
            "es": "Comida",
            "fr": "Nourriture",
            "pt": "Comida",
            "ja": "\u{98DF}\u{4E8B}",
            "ko": "\u{C74C}\u{C2DD}",
        ],
        "category.travel": [
            "en": "Travel",
            "es": "Viaje",
            "fr": "Voyage",
            "pt": "Viagem",
            "ja": "\u{65C5}\u{884C}",
            "ko": "\u{C5EC}\u{D589}",
        ],
        "category.medical": [
            "en": "Medical",
            "es": "M\u{00E9}dico",
            "fr": "M\u{00E9}dical",
            "pt": "M\u{00E9}dico",
            "ja": "\u{533B}\u{7642}",
            "ko": "\u{C758}\u{B8CC}",
        ],
        "category.education": [
            "en": "Education",
            "es": "Educaci\u{00F3}n",
            "fr": "\u{00C9}ducation",
            "pt": "Educa\u{00E7}\u{00E3}o",
            "ja": "\u{6559}\u{80B2}",
            "ko": "\u{AD50}\u{C721}",
        ],
        "category.other": [
            "en": "Other",
            "es": "Otro",
            "fr": "Autre",
            "pt": "Outro",
            "ja": "\u{305D}\u{306E}\u{4ED6}",
            "ko": "\u{AE30}\u{D0C0}",
        ],

        // =====================================================================
        // MARK: - Debt Detail
        // =====================================================================

        "detail.recordPayment": [
            "en": "Record Payment",
            "es": "Registrar Pago",
            "fr": "Enregistrer Paiement",
            "pt": "Registrar Pagamento",
            "ja": "\u{652F}\u{6255}\u{3044}\u{3092}\u{8A18}\u{9332}",
            "ko": "\u{ACB0}\u{C81C} \u{AE30}\u{B85D}",
        ],
        "detail.paymentHistory": [
            "en": "Payment History",
            "es": "Historial de Pagos",
            "fr": "Historique des Paiements",
            "pt": "Hist\u{00F3}rico de Pagamentos",
            "ja": "\u{652F}\u{6255}\u{3044}\u{5C65}\u{6B74}",
            "ko": "\u{ACB0}\u{C81C} \u{B0B4}\u{C5ED}",
        ],
        "detail.noPayments": [
            "en": "No payments recorded yet.",
            "es": "A\u{00FA}n no hay pagos registrados.",
            "fr": "Aucun paiement enregistr\u{00E9}.",
            "pt": "Nenhum pagamento registrado.",
            "ja": "\u{652F}\u{6255}\u{3044}\u{8A18}\u{9332}\u{306F}\u{3042}\u{308A}\u{307E}\u{305B}\u{3093}\u{3002}",
            "ko": "\u{ACB0}\u{C81C} \u{AE30}\u{B85D}\u{C774} \u{C5C6}\u{C2B5}\u{B2C8}\u{B2E4}.",
        ],
        "detail.forgiveDebt": [
            "en": "Forgive Debt",
            "es": "Perdonar Deuda",
            "fr": "Pardonner la Dette",
            "pt": "Perdoar D\u{00ED}vida",
            "ja": "\u{50B5}\u{52D9}\u{3092}\u{514D}\u{9664}",
            "ko": "\u{BE5A} \u{D0D5}\u{AC10}",
        ],
        "detail.deleteDebt": [
            "en": "Delete Debt",
            "es": "Eliminar Deuda",
            "fr": "Supprimer la Dette",
            "pt": "Excluir D\u{00ED}vida",
            "ja": "\u{50B5}\u{52D9}\u{3092}\u{524A}\u{9664}",
            "ko": "\u{BE5A} \u{C0AD}\u{C81C}",
        ],
        "detail.paid": [
            "en": "Paid: %@",
            "es": "Pagado: %@",
            "fr": "Pay\u{00E9}: %@",
            "pt": "Pago: %@",
            "ja": "\u{652F}\u{6255}\u{6E08}: %@",
            "ko": "\u{C0C1}\u{D658}\u{C561}: %@",
        ],
        "detail.remaining": [
            "en": "Remaining: %@",
            "es": "Restante: %@",
            "fr": "Restant: %@",
            "pt": "Restante: %@",
            "ja": "\u{6B8B}\u{308A}: %@",
            "ko": "\u{B0A8}\u{C740} \u{AE08}\u{C561}: %@",
        ],
        "detail.created": [
            "en": "Created",
            "es": "Creada",
            "fr": "Cr\u{00E9}\u{00E9}",
            "pt": "Criada",
            "ja": "\u{4F5C}\u{6210}\u{65E5}",
            "ko": "\u{C0DD}\u{C131}\u{C77C}",
        ],
        "detail.dueDate": [
            "en": "Due Date",
            "es": "Fecha de Vencimiento",
            "fr": "Date d'\u{00E9}ch\u{00E9}ance",
            "pt": "Data de Vencimento",
            "ja": "\u{671F}\u{9650}\u{65E5}",
            "ko": "\u{B9CC}\u{AE30}\u{C77C}",
        ],
        "detail.category": [
            "en": "Category",
            "es": "Categor\u{00ED}a",
            "fr": "Cat\u{00E9}gorie",
            "pt": "Categoria",
            "ja": "\u{30AB}\u{30C6}\u{30B4}\u{30EA}",
            "ko": "\u{CE74}\u{D14C}\u{ACE0}\u{B9AC}",
        ],
        "detail.notes": [
            "en": "Notes",
            "es": "Notas",
            "fr": "Notes",
            "pt": "Notas",
            "ja": "\u{30E1}\u{30E2}",
            "ko": "\u{BA54}\u{BAA8}",
        ],

        // =====================================================================
        // MARK: - Add / Edit Debt
        // =====================================================================

        "addDebt.title": [
            "en": "New Debt",
            "es": "Nueva Deuda",
            "fr": "Nouvelle Dette",
            "pt": "Nova D\u{00ED}vida",
            "ja": "\u{65B0}\u{3057}\u{3044}\u{50B5}\u{52D9}",
            "ko": "\u{C0C8} \u{BE5A}",
        ],
        "addDebt.description": [
            "en": "Description",
            "es": "Descripci\u{00F3}n",
            "fr": "Description",
            "pt": "Descri\u{00E7}\u{00E3}o",
            "ja": "\u{8AAC}\u{660E}",
            "ko": "\u{C124}\u{BA85}",
        ],
        "addDebt.placeholder": [
            "en": "What's this for?",
            "es": "\u{00BF}Para qu\u{00E9} es?",
            "fr": "C'est pour quoi?",
            "pt": "Para que \u{00E9}?",
            "ja": "\u{4F55}\u{306E}\u{305F}\u{3081}\u{3067}\u{3059}\u{304B}\u{FF1F}",
            "ko": "\u{BB34}\u{C5C7} \u{C704}\u{D55C} \u{AC83}\u{C778}\u{AC00}\u{C694}?",
        ],
        "addDebt.person": [
            "en": "Person",
            "es": "Persona",
            "fr": "Personne",
            "pt": "Pessoa",
            "ja": "\u{4EBA}\u{7269}",
            "ko": "\u{C0AC}\u{B78C}",
        ],
        "addDebt.namePlaceholder": [
            "en": "Name",
            "es": "Nombre",
            "fr": "Nom",
            "pt": "Nome",
            "ja": "\u{540D}\u{524D}",
            "ko": "\u{C774}\u{B984}",
        ],
        "addDebt.category": [
            "en": "Category",
            "es": "Categor\u{00ED}a",
            "fr": "Cat\u{00E9}gorie",
            "pt": "Categoria",
            "ja": "\u{30AB}\u{30C6}\u{30B4}\u{30EA}",
            "ko": "\u{CE74}\u{D14C}\u{ACE0}\u{B9AC}",
        ],
        "addDebt.dueDate": [
            "en": "Due Date",
            "es": "Fecha de Vencimiento",
            "fr": "Date d'\u{00E9}ch\u{00E9}ance",
            "pt": "Data de Vencimento",
            "ja": "\u{671F}\u{9650}\u{65E5}",
            "ko": "\u{B9CC}\u{AE30}\u{C77C}",
        ],
        "addDebt.notes": [
            "en": "Notes",
            "es": "Notas",
            "fr": "Notes",
            "pt": "Notas",
            "ja": "\u{30E1}\u{30E2}",
            "ko": "\u{BA54}\u{BAA8}",
        ],
        "addDebt.notesPlaceholder": [
            "en": "Optional notes...",
            "es": "Notas opcionales...",
            "fr": "Notes optionnelles...",
            "pt": "Notas opcionais...",
            "ja": "\u{30E1}\u{30E2}\u{FF08}\u{4EFB}\u{610F}\u{FF09}...",
            "ko": "\u{BA54}\u{BAA8}(\u{C120}\u{D0DD})...",
        ],
        "addDebt.setReminder": [
            "en": "Set Reminder",
            "es": "Establecer Recordatorio",
            "fr": "D\u{00E9}finir un Rappel",
            "pt": "Definir Lembrete",
            "ja": "\u{30EA}\u{30DE}\u{30A4}\u{30F3}\u{30C0}\u{30FC}\u{3092}\u{8A2D}\u{5B9A}",
            "ko": "\u{C54C}\u{B9BC} \u{C124}\u{C815}",
        ],
        "addDebt.addDebt": [
            "en": "Add Debt",
            "es": "Agregar Deuda",
            "fr": "Ajouter une Dette",
            "pt": "Adicionar D\u{00ED}vida",
            "ja": "\u{50B5}\u{52D9}\u{3092}\u{8FFD}\u{52A0}",
            "ko": "\u{BE5A} \u{CD94}\u{AC00}",
        ],
        "editDebt.title": [
            "en": "Edit Debt",
            "es": "Editar Deuda",
            "fr": "Modifier la Dette",
            "pt": "Editar D\u{00ED}vida",
            "ja": "\u{50B5}\u{52D9}\u{3092}\u{7DE8}\u{96C6}",
            "ko": "\u{BE5A} \u{D3B8}\u{C9D1}",
        ],

        // =====================================================================
        // MARK: - Payment
        // =====================================================================

        "payment.title": [
            "en": "Record Payment",
            "es": "Registrar Pago",
            "fr": "Enregistrer Paiement",
            "pt": "Registrar Pagamento",
            "ja": "\u{652F}\u{6255}\u{3044}\u{3092}\u{8A18}\u{9332}",
            "ko": "\u{ACB0}\u{C81C} \u{AE30}\u{B85D}",
        ],
        "payment.remaining": [
            "en": "Remaining: %@",
            "es": "Restante: %@",
            "fr": "Restant: %@",
            "pt": "Restante: %@",
            "ja": "\u{6B8B}\u{308A}: %@",
            "ko": "\u{B0A8}\u{C740} \u{AE08}\u{C561}: %@",
        ],
        "payment.payFullAmount": [
            "en": "Pay Full Amount",
            "es": "Pagar Monto Total",
            "fr": "Payer la Totalit\u{00E9}",
            "pt": "Pagar Valor Total",
            "ja": "\u{5168}\u{984D}\u{652F}\u{6255}\u{3044}",
            "ko": "\u{C804}\u{C561} \u{ACB0}\u{C81C}",
        ],
        "payment.paymentDate": [
            "en": "Payment Date",
            "es": "Fecha de Pago",
            "fr": "Date de Paiement",
            "pt": "Data do Pagamento",
            "ja": "\u{652F}\u{6255}\u{65E5}",
            "ko": "\u{ACB0}\u{C81C}\u{C77C}",
        ],
        "payment.notesPlaceholder": [
            "en": "Notes (optional)",
            "es": "Notas (opcional)",
            "fr": "Notes (optionnel)",
            "pt": "Notas (opcional)",
            "ja": "\u{30E1}\u{30E2}\u{FF08}\u{4EFB}\u{610F}\u{FF09}",
            "ko": "\u{BA54}\u{BAA8}(\u{C120}\u{D0DD})",
        ],
        "payment.paidInFull": [
            "en": "Paid in full",
            "es": "Pagado en su totalidad",
            "fr": "Pay\u{00E9} en totalit\u{00E9}",
            "pt": "Pago integralmente",
            "ja": "\u{5168}\u{984D}\u{652F}\u{6255}\u{3044}\u{6E08}\u{307F}",
            "ko": "\u{C804}\u{C561} \u{C0C1}\u{D658} \u{C644}\u{B8CC}",
        ],

        // =====================================================================
        // MARK: - Activity
        // =====================================================================

        "activity.empty.title": [
            "en": "No Activity Yet",
            "es": "Sin Actividad A\u{00FA}n",
            "fr": "Aucune Activit\u{00E9}",
            "pt": "Sem Atividade",
            "ja": "\u{30A2}\u{30AF}\u{30C6}\u{30A3}\u{30D3}\u{30C6}\u{30A3}\u{306A}\u{3057}",
            "ko": "\u{D65C}\u{B3D9} \u{C5C6}\u{C74C}",
        ],
        "activity.empty.subtitle": [
            "en": "Payment activity will appear here as you record payments on your debts.",
            "es": "La actividad de pagos aparecer\u{00E1} aqu\u{00ED} al registrar pagos.",
            "fr": "L'activit\u{00E9} de paiement appara\u{00EE}tra ici lorsque vous enregistrez des paiements.",
            "pt": "A atividade de pagamentos aparecer\u{00E1} aqui ao registrar pagamentos.",
            "ja": "\u{652F}\u{6255}\u{3044}\u{3092}\u{8A18}\u{9332}\u{3059}\u{308B}\u{3068}\u{3001}\u{3053}\u{3053}\u{306B}\u{30A2}\u{30AF}\u{30C6}\u{30A3}\u{30D3}\u{30C6}\u{30A3}\u{304C}\u{8868}\u{793A}\u{3055}\u{308C}\u{307E}\u{3059}\u{3002}",
            "ko": "\u{BE5A}\u{C5D0} \u{B300}\u{D55C} \u{ACB0}\u{C81C}\u{B97C} \u{AE30}\u{B85D}\u{D558}\u{BA74} \u{C5EC}\u{AE30}\u{C5D0} \u{D65C}\u{B3D9}\u{C774} \u{D45C}\u{C2DC}\u{B429}\u{B2C8}\u{B2E4}.",
        ],
        "activity.today": [
            "en": "Today",
            "es": "Hoy",
            "fr": "Aujourd'hui",
            "pt": "Hoje",
            "ja": "\u{4ECA}\u{65E5}",
            "ko": "\u{C624}\u{B298}",
        ],
        "activity.yesterday": [
            "en": "Yesterday",
            "es": "Ayer",
            "fr": "Hier",
            "pt": "Ontem",
            "ja": "\u{6628}\u{65E5}",
            "ko": "\u{C5B4}\u{C81C}",
        ],
        "activity.thisWeek": [
            "en": "This Week",
            "es": "Esta Semana",
            "fr": "Cette Semaine",
            "pt": "Esta Semana",
            "ja": "\u{4ECA}\u{9031}",
            "ko": "\u{C774}\u{BC88} \u{C8FC}",
        ],
        "activity.thisMonth": [
            "en": "This Month",
            "es": "Este Mes",
            "fr": "Ce Mois",
            "pt": "Este M\u{00EA}s",
            "ja": "\u{4ECA}\u{6708}",
            "ko": "\u{C774}\u{BC88} \u{B2EC}",
        ],
        "activity.earlier": [
            "en": "Earlier",
            "es": "Anteriores",
            "fr": "Plus T\u{00F4}t",
            "pt": "Anteriores",
            "ja": "\u{305D}\u{308C}\u{4EE5}\u{524D}",
            "ko": "\u{C774}\u{C804}",
        ],

        // =====================================================================
        // MARK: - Settings
        // =====================================================================

        "settings.title": [
            "en": "Settings",
            "es": "Ajustes",
            "fr": "R\u{00E9}glages",
            "pt": "Configura\u{00E7}\u{00F5}es",
            "ja": "\u{8A2D}\u{5B9A}",
            "ko": "\u{C124}\u{C815}",
        ],
        "settings.setupProfile": [
            "en": "Set Up Profile",
            "es": "Configurar Perfil",
            "fr": "Configurer le Profil",
            "pt": "Configurar Perfil",
            "ja": "\u{30D7}\u{30ED}\u{30D5}\u{30A3}\u{30FC}\u{30EB}\u{3092}\u{8A2D}\u{5B9A}",
            "ko": "\u{D504}\u{B85C}\u{D544} \u{C124}\u{C815}",
        ],
        "settings.tapToAddName": [
            "en": "Tap to add your name and photo",
            "es": "Toca para agregar tu nombre y foto",
            "fr": "Appuyez pour ajouter votre nom et photo",
            "pt": "Toque para adicionar seu nome e foto",
            "ja": "\u{30BF}\u{30C3}\u{30D7}\u{3057}\u{3066}\u{540D}\u{524D}\u{3068}\u{5199}\u{771F}\u{3092}\u{8FFD}\u{52A0}",
            "ko": "\u{D0ED}\u{D558}\u{C5EC} \u{C774}\u{B984}\u{ACFC} \u{C0AC}\u{C9C4}\u{C744} \u{CD94}\u{AC00}\u{D558}\u{C138}\u{C694}",
        ],
        "settings.tapToEditProfile": [
            "en": "Tap to edit profile",
            "es": "Toca para editar perfil",
            "fr": "Appuyez pour modifier le profil",
            "pt": "Toque para editar perfil",
            "ja": "\u{30BF}\u{30C3}\u{30D7}\u{3057}\u{3066}\u{30D7}\u{30ED}\u{30D5}\u{30A3}\u{30FC}\u{30EB}\u{3092}\u{7DE8}\u{96C6}",
            "ko": "\u{D0ED}\u{D558}\u{C5EC} \u{D504}\u{B85C}\u{D544}\u{C744} \u{D3B8}\u{C9D1}\u{D558}\u{C138}\u{C694}",
        ],
        "settings.preferences": [
            "en": "Preferences",
            "es": "Preferencias",
            "fr": "Pr\u{00E9}f\u{00E9}rences",
            "pt": "Prefer\u{00EA}ncias",
            "ja": "\u{74B0}\u{5883}\u{8A2D}\u{5B9A}",
            "ko": "\u{D658}\u{ACBD}\u{C124}\u{C815}",
        ],
        "settings.notifications": [
            "en": "Notifications",
            "es": "Notificaciones",
            "fr": "Notifications",
            "pt": "Notifica\u{00E7}\u{00F5}es",
            "ja": "\u{901A}\u{77E5}",
            "ko": "\u{C54C}\u{B9BC}",
        ],
        "settings.appearance": [
            "en": "Appearance",
            "es": "Apariencia",
            "fr": "Apparence",
            "pt": "Apar\u{00EA}ncia",
            "ja": "\u{5916}\u{89B3}",
            "ko": "\u{C678}\u{AD00}",
        ],
        "settings.security": [
            "en": "Security",
            "es": "Seguridad",
            "fr": "S\u{00E9}curit\u{00E9}",
            "pt": "Seguran\u{00E7}a",
            "ja": "\u{30BB}\u{30AD}\u{30E5}\u{30EA}\u{30C6}\u{30A3}",
            "ko": "\u{BCF4}\u{C548}",
        ],
        "settings.requireBiometric": [
            "en": "Require %@",
            "es": "Requerir %@",
            "fr": "Exiger %@",
            "pt": "Exigir %@",
            "ja": "%@\u{3092}\u{8981}\u{6C42}",
            "ko": "%@ \u{D544}\u{C694}",
        ],
        "settings.lockOnLaunch": [
            "en": "Lock app on launch",
            "es": "Bloquear app al iniciar",
            "fr": "Verrouiller l'app au lancement",
            "pt": "Bloquear app ao iniciar",
            "ja": "\u{8D77}\u{52D5}\u{6642}\u{306B}\u{30ED}\u{30C3}\u{30AF}",
            "ko": "\u{C2E4}\u{D589} \u{C2DC} \u{C7A0}\u{AE08}",
        ],
        "settings.biometricsUnavailable": [
            "en": "Biometrics not available on this device",
            "es": "Biometr\u{00ED}a no disponible en este dispositivo",
            "fr": "Biom\u{00E9}trie non disponible sur cet appareil",
            "pt": "Biometria n\u{00E3}o dispon\u{00ED}vel neste dispositivo",
            "ja": "\u{3053}\u{306E}\u{30C7}\u{30D0}\u{30A4}\u{30B9}\u{3067}\u{306F}\u{751F}\u{4F53}\u{8A8D}\u{8A3C}\u{3092}\u{5229}\u{7528}\u{3067}\u{304D}\u{307E}\u{305B}\u{3093}",
            "ko": "\u{C774} \u{AE30}\u{AE30}\u{C5D0}\u{C11C}\u{B294} \u{C0DD}\u{CCB4} \u{C778}\u{C99D}\u{C744} \u{C0AC}\u{C6A9}\u{D560} \u{C218} \u{C5C6}\u{C2B5}\u{B2C8}\u{B2E4}",
        ],
        "settings.data": [
            "en": "Data",
            "es": "Datos",
            "fr": "Donn\u{00E9}es",
            "pt": "Dados",
            "ja": "\u{30C7}\u{30FC}\u{30BF}",
            "ko": "\u{B370}\u{C774}\u{D130}",
        ],
        "settings.exportSummary": [
            "en": "Export Summary to Clipboard",
            "es": "Exportar Resumen al Portapapeles",
            "fr": "Exporter le R\u{00E9}sum\u{00E9} dans le Presse-papiers",
            "pt": "Exportar Resumo para \u{00C1}rea de Transfer\u{00EA}ncia",
            "ja": "\u{6982}\u{8981}\u{3092}\u{30AF}\u{30EA}\u{30C3}\u{30D7}\u{30DC}\u{30FC}\u{30C9}\u{306B}\u{30A8}\u{30AF}\u{30B9}\u{30DD}\u{30FC}\u{30C8}",
            "ko": "\u{C694}\u{C57D}\u{C744} \u{D074}\u{B9BD}\u{BCF4}\u{B4DC}\u{C5D0} \u{B0B4}\u{BCF4}\u{B0B4}\u{AE30}",
        ],
        "settings.loadSample": [
            "en": "Load Sample Data",
            "es": "Cargar Datos de Ejemplo",
            "fr": "Charger des Donn\u{00E9}es d'Exemple",
            "pt": "Carregar Dados de Exemplo",
            "ja": "\u{30B5}\u{30F3}\u{30D7}\u{30EB}\u{30C7}\u{30FC}\u{30BF}\u{3092}\u{8AAD}\u{307F}\u{8FBC}\u{3080}",
            "ko": "\u{C0D8}\u{D50C} \u{B370}\u{C774}\u{D130} \u{B85C}\u{B4DC}",
        ],
        "settings.clearAll": [
            "en": "Clear All Data",
            "es": "Borrar Todos los Datos",
            "fr": "Effacer Toutes les Donn\u{00E9}es",
            "pt": "Limpar Todos os Dados",
            "ja": "\u{3059}\u{3079}\u{3066}\u{306E}\u{30C7}\u{30FC}\u{30BF}\u{3092}\u{6D88}\u{53BB}",
            "ko": "\u{BAA8}\u{B4E0} \u{B370}\u{C774}\u{D130} \u{C0AD}\u{C81C}",
        ],
        "settings.about": [
            "en": "About",
            "es": "Acerca de",
            "fr": "\u{00C0} Propos",
            "pt": "Sobre",
            "ja": "\u{3053}\u{306E}\u{30A2}\u{30D7}\u{30EA}\u{306B}\u{3064}\u{3044}\u{3066}",
            "ko": "\u{C815}\u{BCF4}",
        ],
        "settings.version": [
            "en": "Version",
            "es": "Versi\u{00F3}n",
            "fr": "Version",
            "pt": "Vers\u{00E3}o",
            "ja": "\u{30D0}\u{30FC}\u{30B8}\u{30E7}\u{30F3}",
            "ko": "\u{BC84}\u{C804}",
        ],
        "settings.build": [
            "en": "Build",
            "es": "Compilaci\u{00F3}n",
            "fr": "Build",
            "pt": "Build",
            "ja": "\u{30D3}\u{30EB}\u{30C9}",
            "ko": "\u{BE4C}\u{B4DC}",
        ],
        "settings.developer": [
            "en": "Developer",
            "es": "Desarrollador",
            "fr": "D\u{00E9}veloppeur",
            "pt": "Desenvolvedor",
            "ja": "\u{958B}\u{767A}\u{8005}",
            "ko": "\u{AC1C}\u{BC1C}\u{C790}",
        ],
        "settings.privacyNote": [
            "en": "All data is stored locally on your device and synced via iCloud. No third-party services.",
            "es": "Todos los datos se almacenan localmente y se sincronizan v\u{00ED}a iCloud. Sin servicios de terceros.",
            "fr": "Toutes les donn\u{00E9}es sont stock\u{00E9}es localement et synchronis\u{00E9}es via iCloud. Aucun service tiers.",
            "pt": "Todos os dados s\u{00E3}o armazenados localmente e sincronizados via iCloud. Sem servi\u{00E7}os de terceiros.",
            "ja": "\u{3059}\u{3079}\u{3066}\u{306E}\u{30C7}\u{30FC}\u{30BF}\u{306F}\u{30C7}\u{30D0}\u{30A4}\u{30B9}\u{306B}\u{30ED}\u{30FC}\u{30AB}\u{30EB}\u{4FDD}\u{5B58}\u{3055}\u{308C}\u{3001}iCloud\u{7D4C}\u{7531}\u{3067}\u{540C}\u{671F}\u{3055}\u{308C}\u{307E}\u{3059}\u{3002}\u{30B5}\u{30FC}\u{30C9}\u{30D1}\u{30FC}\u{30C6}\u{30A3}\u{306E}\u{30B5}\u{30FC}\u{30D3}\u{30B9}\u{306F}\u{3042}\u{308A}\u{307E}\u{305B}\u{3093}\u{3002}",
            "ko": "\u{BAA8}\u{B4E0} \u{B370}\u{C774}\u{D130}\u{B294} \u{AE30}\u{AE30}\u{C5D0} \u{B85C}\u{CEEC}\u{B85C} \u{C800}\u{C7A5}\u{B418}\u{BA70} iCloud\u{B97C} \u{D1B5}\u{D574} \u{B3D9}\u{AE30}\u{D654}\u{B429}\u{B2C8}\u{B2E4}. \u{C81C}3\u{C790} \u{C11C}\u{BE44}\u{C2A4}\u{B294} \u{C5C6}\u{C2B5}\u{B2C8}\u{B2E4}.",
        ],

        // =====================================================================
        // MARK: - Alerts
        // =====================================================================

        "alert.loadSample.title": [
            "en": "Load Sample Data",
            "es": "Cargar Datos de Ejemplo",
            "fr": "Charger des Donn\u{00E9}es d'Exemple",
            "pt": "Carregar Dados de Exemplo",
            "ja": "\u{30B5}\u{30F3}\u{30D7}\u{30EB}\u{30C7}\u{30FC}\u{30BF}\u{3092}\u{8AAD}\u{307F}\u{8FBC}\u{3080}",
            "ko": "\u{C0D8}\u{D50C} \u{B370}\u{C774}\u{D130} \u{B85C}\u{B4DC}",
        ],
        "alert.loadSample.message": [
            "en": "This will add sample debts, payments, and contacts for testing.",
            "es": "Esto agregar\u{00E1} deudas, pagos y contactos de ejemplo para pruebas.",
            "fr": "Cela ajoutera des dettes, paiements et contacts d'exemple pour tester.",
            "pt": "Isso adicionar\u{00E1} d\u{00ED}vidas, pagamentos e contatos de exemplo para testes.",
            "ja": "\u{30C6}\u{30B9}\u{30C8}\u{7528}\u{306E}\u{30B5}\u{30F3}\u{30D7}\u{30EB}\u{50B5}\u{52D9}\u{3001}\u{652F}\u{6255}\u{3044}\u{3001}\u{9023}\u{7D61}\u{5148}\u{3092}\u{8FFD}\u{52A0}\u{3057}\u{307E}\u{3059}\u{3002}",
            "ko": "\u{D14C}\u{C2A4}\u{D2B8}\u{C6A9} \u{C0D8}\u{D50C} \u{BE5A}, \u{ACB0}\u{C81C}, \u{C5F0}\u{B77D}\u{CC98}\u{B97C} \u{CD94}\u{AC00}\u{D569}\u{B2C8}\u{B2E4}.",
        ],
        "alert.loadSample.action": [
            "en": "Load",
            "es": "Cargar",
            "fr": "Charger",
            "pt": "Carregar",
            "ja": "\u{8AAD}\u{307F}\u{8FBC}\u{3080}",
            "ko": "\u{B85C}\u{B4DC}",
        ],
        "alert.clearAll.title": [
            "en": "Clear All Data",
            "es": "Borrar Todos los Datos",
            "fr": "Effacer Toutes les Donn\u{00E9}es",
            "pt": "Limpar Todos os Dados",
            "ja": "\u{3059}\u{3079}\u{3066}\u{306E}\u{30C7}\u{30FC}\u{30BF}\u{3092}\u{6D88}\u{53BB}",
            "ko": "\u{BAA8}\u{B4E0} \u{B370}\u{C774}\u{D130} \u{C0AD}\u{C81C}",
        ],
        "alert.clearAll.message": [
            "en": "This will permanently delete everything. This cannot be undone.",
            "es": "Esto eliminar\u{00E1} todo permanentemente. No se puede deshacer.",
            "fr": "Cela supprimera tout d\u{00E9}finitivement. Cette action est irr\u{00E9}versible.",
            "pt": "Isso excluir\u{00E1} tudo permanentemente. N\u{00E3}o pode ser desfeito.",
            "ja": "\u{3059}\u{3079}\u{3066}\u{304C}\u{5B8C}\u{5168}\u{306B}\u{524A}\u{9664}\u{3055}\u{308C}\u{307E}\u{3059}\u{3002}\u{5143}\u{306B}\u{623B}\u{305B}\u{307E}\u{305B}\u{3093}\u{3002}",
            "ko": "\u{BAA8}\u{B4E0} \u{B370}\u{C774}\u{D130}\u{AC00} \u{C601}\u{AD6C}\u{C801}\u{C73C}\u{B85C} \u{C0AD}\u{C81C}\u{B429}\u{B2C8}\u{B2E4}. \u{B418}\u{B3CC}\u{B9B4} \u{C218} \u{C5C6}\u{C2B5}\u{B2C8}\u{B2E4}.",
        ],
        "alert.clearAll.action": [
            "en": "Clear",
            "es": "Borrar",
            "fr": "Effacer",
            "pt": "Limpar",
            "ja": "\u{6D88}\u{53BB}",
            "ko": "\u{C0AD}\u{C81C}",
        ],
        "alert.deleteDebt.title": [
            "en": "Delete Debt",
            "es": "Eliminar Deuda",
            "fr": "Supprimer la Dette",
            "pt": "Excluir D\u{00ED}vida",
            "ja": "\u{50B5}\u{52D9}\u{3092}\u{524A}\u{9664}",
            "ko": "\u{BE5A} \u{C0AD}\u{C81C}",
        ],
        "alert.deleteDebt.message": [
            "en": "This will permanently delete this debt and all its payments.",
            "es": "Esto eliminar\u{00E1} permanentemente esta deuda y todos sus pagos.",
            "fr": "Cela supprimera d\u{00E9}finitivement cette dette et tous ses paiements.",
            "pt": "Isso excluir\u{00E1} permanentemente esta d\u{00ED}vida e todos os pagamentos.",
            "ja": "\u{3053}\u{306E}\u{50B5}\u{52D9}\u{3068}\u{3059}\u{3079}\u{3066}\u{306E}\u{652F}\u{6255}\u{3044}\u{304C}\u{5B8C}\u{5168}\u{306B}\u{524A}\u{9664}\u{3055}\u{308C}\u{307E}\u{3059}\u{3002}",
            "ko": "\u{C774} \u{BE5A}\u{ACFC} \u{BAA8}\u{B4E0} \u{ACB0}\u{C81C} \u{AE30}\u{B85D}\u{C774} \u{C601}\u{AD6C}\u{C801}\u{C73C}\u{B85C} \u{C0AD}\u{C81C}\u{B429}\u{B2C8}\u{B2E4}.",
        ],
        "alert.copied.title": [
            "en": "Copied!",
            "es": "\u{00A1}Copiado!",
            "fr": "Copi\u{00E9}!",
            "pt": "Copiado!",
            "ja": "\u{30B3}\u{30D4}\u{30FC}\u{3057}\u{307E}\u{3057}\u{305F}\u{FF01}",
            "ko": "\u{BCF5}\u{C0AC}\u{B428}!",
        ],
        "alert.copied.message": [
            "en": "Your debt summary has been copied to the clipboard.",
            "es": "El resumen de deudas se ha copiado al portapapeles.",
            "fr": "Votre r\u{00E9}sum\u{00E9} de dettes a \u{00E9}t\u{00E9} copi\u{00E9} dans le presse-papiers.",
            "pt": "O resumo das d\u{00ED}vidas foi copiado para a \u{00E1}rea de transfer\u{00EA}ncia.",
            "ja": "\u{50B5}\u{52D9}\u{306E}\u{6982}\u{8981}\u{304C}\u{30AF}\u{30EA}\u{30C3}\u{30D7}\u{30DC}\u{30FC}\u{30C9}\u{306B}\u{30B3}\u{30D4}\u{30FC}\u{3055}\u{308C}\u{307E}\u{3057}\u{305F}\u{3002}",
            "ko": "\u{BE5A} \u{C694}\u{C57D}\u{C774} \u{D074}\u{B9BD}\u{BCF4}\u{B4DC}\u{C5D0} \u{BCF5}\u{C0AC}\u{B418}\u{C5C8}\u{C2B5}\u{B2C8}\u{B2E4}.",
        ],

        // =====================================================================
        // MARK: - Common
        // =====================================================================

        "common.cancel": [
            "en": "Cancel",
            "es": "Cancelar",
            "fr": "Annuler",
            "pt": "Cancelar",
            "ja": "\u{30AD}\u{30E3}\u{30F3}\u{30BB}\u{30EB}",
            "ko": "\u{CE58}\u{C18C}",
        ],
        "common.delete": [
            "en": "Delete",
            "es": "Eliminar",
            "fr": "Supprimer",
            "pt": "Excluir",
            "ja": "\u{524A}\u{9664}",
            "ko": "\u{C0AD}\u{C81C}",
        ],
        "common.done": [
            "en": "Done",
            "es": "Listo",
            "fr": "Termin\u{00E9}",
            "pt": "Conclu\u{00ED}do",
            "ja": "\u{5B8C}\u{4E86}",
            "ko": "\u{C644}\u{B8CC}",
        ],
        "common.ok": [
            "en": "OK",
            "es": "OK",
            "fr": "OK",
            "pt": "OK",
            "ja": "OK",
            "ko": "\u{D655}\u{C778}",
        ],
        "common.unknown": [
            "en": "Unknown",
            "es": "Desconocido",
            "fr": "Inconnu",
            "pt": "Desconhecido",
            "ja": "\u{4E0D}\u{660E}",
            "ko": "\u{C54C} \u{C218} \u{C5C6}\u{C74C}",
        ],
        "common.back": [
            "en": "Back",
            "es": "Atr\u{00E1}s",
            "fr": "Retour",
            "pt": "Voltar",
            "ja": "\u{623B}\u{308B}",
            "ko": "\u{B4A4}\u{B85C}",
        ],
        "common.next": [
            "en": "Next",
            "es": "Siguiente",
            "fr": "Suivant",
            "pt": "Pr\u{00F3}ximo",
            "ja": "\u{6B21}\u{3078}",
            "ko": "\u{B2E4}\u{C74C}",
        ],
        "common.getStarted": [
            "en": "Get Started",
            "es": "Comenzar",
            "fr": "Commencer",
            "pt": "Come\u{00E7}ar",
            "ja": "\u{59CB}\u{3081}\u{308B}",
            "ko": "\u{C2DC}\u{C791}\u{D558}\u{AE30}",
        ],
        "common.markAsPaid": [
            "en": "Mark as Paid",
            "es": "Marcar como Pagada",
            "fr": "Marquer comme Pay\u{00E9}",
            "pt": "Marcar como Paga",
            "ja": "\u{652F}\u{6255}\u{6E08}\u{307F}\u{306B}\u{3059}\u{308B}",
            "ko": "\u{C0C1}\u{D658} \u{C644}\u{B8CC}\u{B85C} \u{D45C}\u{C2DC}",
        ],

        // =====================================================================
        // MARK: - Profile
        // =====================================================================

        "profile.title": [
            "en": "Profile",
            "es": "Perfil",
            "fr": "Profil",
            "pt": "Perfil",
            "ja": "\u{30D7}\u{30ED}\u{30D5}\u{30A3}\u{30FC}\u{30EB}",
            "ko": "\u{D504}\u{B85C}\u{D544}",
        ],
        "profile.name": [
            "en": "Name",
            "es": "Nombre",
            "fr": "Nom",
            "pt": "Nome",
            "ja": "\u{540D}\u{524D}",
            "ko": "\u{C774}\u{B984}",
        ],
        "profile.namePlaceholder": [
            "en": "Your name",
            "es": "Tu nombre",
            "fr": "Votre nom",
            "pt": "Seu nome",
            "ja": "\u{3042}\u{306A}\u{305F}\u{306E}\u{540D}\u{524D}",
            "ko": "\u{C774}\u{B984}\u{C744} \u{C785}\u{B825}\u{D558}\u{C138}\u{C694}",
        ],
        "profile.language": [
            "en": "Language",
            "es": "Idioma",
            "fr": "Langue",
            "pt": "Idioma",
            "ja": "\u{8A00}\u{8A9E}",
            "ko": "\u{C5B8}\u{C5B4}",
        ],
        "profile.currency": [
            "en": "Currency",
            "es": "Moneda",
            "fr": "Devise",
            "pt": "Moeda",
            "ja": "\u{901A}\u{8CA8}",
            "ko": "\u{D1B5}\u{D654}",
        ],
        "profile.removePhoto": [
            "en": "Remove Photo",
            "es": "Eliminar Foto",
            "fr": "Supprimer la Photo",
            "pt": "Remover Foto",
            "ja": "\u{5199}\u{771F}\u{3092}\u{524A}\u{9664}",
            "ko": "\u{C0AC}\u{C9C4} \u{C0AD}\u{C81C}",
        ],

        // =====================================================================
        // MARK: - Notification Settings
        // =====================================================================

        "notifications.title": [
            "en": "Notifications",
            "es": "Notificaciones",
            "fr": "Notifications",
            "pt": "Notifica\u{00E7}\u{00F5}es",
            "ja": "\u{901A}\u{77E5}",
            "ko": "\u{C54C}\u{B9BC}",
        ],
        "notifications.enable": [
            "en": "Enable Notifications",
            "es": "Activar Notificaciones",
            "fr": "Activer les Notifications",
            "pt": "Ativar Notifica\u{00E7}\u{00F5}es",
            "ja": "\u{901A}\u{77E5}\u{3092}\u{6709}\u{52B9}\u{306B}\u{3059}\u{308B}",
            "ko": "\u{C54C}\u{B9BC} \u{D65C}\u{C131}\u{D654}",
        ],
        "notifications.description": [
            "en": "Receive reminders for upcoming debt due dates.",
            "es": "Recibe recordatorios para las fechas de vencimiento.",
            "fr": "Recevez des rappels pour les \u{00E9}ch\u{00E9}ances de dettes.",
            "pt": "Receba lembretes para as datas de vencimento.",
            "ja": "\u{50B5}\u{52D9}\u{306E}\u{671F}\u{9650}\u{306E}\u{30EA}\u{30DE}\u{30A4}\u{30F3}\u{30C0}\u{30FC}\u{3092}\u{53D7}\u{3051}\u{53D6}\u{308A}\u{307E}\u{3059}\u{3002}",
            "ko": "\u{BE5A} \u{B9CC}\u{AE30}\u{C77C} \u{C54C}\u{B9BC}\u{C744} \u{BC1B}\u{C2B5}\u{B2C8}\u{B2E4}.",
        ],
        "notifications.sectionHeader": [
            "en": "Notifications",
            "es": "Notificaciones",
            "fr": "Notifications",
            "pt": "Notifica\u{00E7}\u{00F5}es",
            "ja": "\u{901A}\u{77E5}",
            "ko": "\u{C54C}\u{B9BC}",
        ],
        "notifications.howItWorks": [
            "en": "How it works",
            "es": "C\u{00F3}mo funciona",
            "fr": "Comment \u{00E7}a marche",
            "pt": "Como funciona",
            "ja": "\u{4ED5}\u{7D44}\u{307F}",
            "ko": "\u{C791}\u{B3D9} \u{BC29}\u{C2DD}",
        ],
        "notifications.howItWorksDescription": [
            "en": "When you enable reminders on a debt, you'll receive a local notification at your chosen time. No data is sent to any server \u{2014} all notifications are processed on-device.",
            "es": "Cuando activas recordatorios en una deuda, recibir\u{00E1}s una notificaci\u{00F3}n local a la hora elegida. No se env\u{00ED}an datos a ning\u{00FA}n servidor.",
            "fr": "Lorsque vous activez les rappels sur une dette, vous recevrez une notification locale \u{00E0} l'heure choisie. Aucune donn\u{00E9}e n'est envoy\u{00E9}e \u{00E0} un serveur.",
            "pt": "Quando voc\u{00EA} ativa lembretes em uma d\u{00ED}vida, receber\u{00E1} uma notifica\u{00E7}\u{00E3}o local no hor\u{00E1}rio escolhido. Nenhum dado \u{00E9} enviado a servidores.",
            "ja": "\u{50B5}\u{52D9}\u{306E}\u{30EA}\u{30DE}\u{30A4}\u{30F3}\u{30C0}\u{30FC}\u{3092}\u{6709}\u{52B9}\u{306B}\u{3059}\u{308B}\u{3068}\u{3001}\u{6307}\u{5B9A}\u{3057}\u{305F}\u{6642}\u{523B}\u{306B}\u{30ED}\u{30FC}\u{30AB}\u{30EB}\u{901A}\u{77E5}\u{304C}\u{5C4A}\u{304D}\u{307E}\u{3059}\u{3002}\u{30C7}\u{30FC}\u{30BF}\u{306F}\u{30B5}\u{30FC}\u{30D0}\u{30FC}\u{306B}\u{9001}\u{4FE1}\u{3055}\u{308C}\u{307E}\u{305B}\u{3093}\u{3002}",
            "ko": "\u{BE5A}\u{C5D0} \u{C54C}\u{B9BC}\u{C744} \u{D65C}\u{C131}\u{D654}\u{D558}\u{BA74} \u{C120}\u{D0DD}\u{D55C} \u{C2DC}\u{AC04}\u{C5D0} \u{B85C}\u{CEEC} \u{C54C}\u{B9BC}\u{C744} \u{BC1B}\u{C2B5}\u{B2C8}\u{B2E4}. \u{C11C}\u{BC84}\u{B85C} \u{B370}\u{C774}\u{D130}\u{AC00} \u{C804}\u{C1A1}\u{B418}\u{C9C0} \u{C54A}\u{C2B5}\u{B2C8}\u{B2E4}.",
        ],
        "notifications.infoHeader": [
            "en": "Info",
            "es": "Informaci\u{00F3}n",
            "fr": "Info",
            "pt": "Informa\u{00E7}\u{00E3}o",
            "ja": "\u{60C5}\u{5831}",
            "ko": "\u{C815}\u{BCF4}",
        ],

        // =====================================================================
        // MARK: - Appearance
        // =====================================================================

        "appearance.title": [
            "en": "Appearance",
            "es": "Apariencia",
            "fr": "Apparence",
            "pt": "Apar\u{00EA}ncia",
            "ja": "\u{5916}\u{89B3}",
            "ko": "\u{C678}\u{AD00}",
        ],
        "appearance.currency": [
            "en": "Currency",
            "es": "Moneda",
            "fr": "Devise",
            "pt": "Moeda",
            "ja": "\u{901A}\u{8CA8}",
            "ko": "\u{D1B5}\u{D654}",
        ],
        "appearance.currencyConverter": [
            "en": "Currency Converter",
            "es": "Convertidor de Moneda",
            "fr": "Convertisseur de Devises",
            "pt": "Conversor de Moeda",
            "ja": "\u{901A}\u{8CA8}\u{30B3}\u{30F3}\u{30D0}\u{30FC}\u{30BF}\u{30FC}",
            "ko": "\u{D1B5}\u{D654} \u{BCC0}\u{D658}\u{AE30}",
        ],
        "appearance.amountPlaceholder": [
            "en": "Amount",
            "es": "Monto",
            "fr": "Montant",
            "pt": "Valor",
            "ja": "\u{91D1}\u{984D}",
            "ko": "\u{AE08}\u{C561}",
        ],
        "appearance.ratesError": [
            "en": "Could not load rates",
            "es": "No se pudieron cargar las tasas",
            "fr": "Impossible de charger les taux",
            "pt": "N\u{00E3}o foi poss\u{00ED}vel carregar as taxas",
            "ja": "\u{30EC}\u{30FC}\u{30C8}\u{3092}\u{8AAD}\u{307F}\u{8FBC}\u{3081}\u{307E}\u{305B}\u{3093}\u{3067}\u{3057}\u{305F}",
            "ko": "\u{D658}\u{C728}\u{C744} \u{B85C}\u{B4DC}\u{D560} \u{C218} \u{C5C6}\u{C2B5}\u{B2C8}\u{B2E4}",
        ],
        "appearance.defaultDirection": [
            "en": "Default Direction for New Debts",
            "es": "Direcci\u{00F3}n Predeterminada para Nuevas Deudas",
            "fr": "Direction par D\u{00E9}faut pour les Nouvelles Dettes",
            "pt": "Dire\u{00E7}\u{00E3}o Padr\u{00E3}o para Novas D\u{00ED}vidas",
            "ja": "\u{65B0}\u{3057}\u{3044}\u{50B5}\u{52D9}\u{306E}\u{30C7}\u{30D5}\u{30A9}\u{30EB}\u{30C8}\u{65B9}\u{5411}",
            "ko": "\u{C0C8} \u{BE5A}\u{C758} \u{AE30}\u{BCF8} \u{BC29}\u{D5A5}",
        ],

        // =====================================================================
        // MARK: - Stats
        // =====================================================================

        "stats.totalDebts": [
            "en": "Total Debts",
            "es": "Total Deudas",
            "fr": "Total Dettes",
            "pt": "Total D\u{00ED}vidas",
            "ja": "\u{50B5}\u{52D9}\u{5408}\u{8A08}",
            "ko": "\u{CD1D} \u{BE5A}",
        ],
        "stats.amountTracked": [
            "en": "Amount Tracked",
            "es": "Monto Rastreado",
            "fr": "Montant Suivi",
            "pt": "Valor Rastreado",
            "ja": "\u{8FFD}\u{8DE1}\u{91D1}\u{984D}",
            "ko": "\u{CD94}\u{C801} \u{AE08}\u{C561}",
        ],
        "stats.paidOff": [
            "en": "Paid Off",
            "es": "Pagadas",
            "fr": "Rembours\u{00E9}",
            "pt": "Pagas",
            "ja": "\u{5B8C}\u{6E08}",
            "ko": "\u{C644}\u{B0A9}",
        ],
        "stats.avgDebt": [
            "en": "Avg. Debt",
            "es": "Deuda Prom.",
            "fr": "Moy. Dette",
            "pt": "M\u{00E9}d. D\u{00ED}vida",
            "ja": "\u{5E73}\u{5747}\u{50B5}\u{52D9}",
            "ko": "\u{D3C9}\u{ADE0} \u{BE5A}",
        ],
        "stats.people": [
            "en": "People",
            "es": "Personas",
            "fr": "Personnes",
            "pt": "Pessoas",
            "ja": "\u{4EBA}\u{6570}",
            "ko": "\u{C0AC}\u{B78C}",
        ],
        "stats.payments": [
            "en": "Payments",
            "es": "Pagos",
            "fr": "Paiements",
            "pt": "Pagamentos",
            "ja": "\u{652F}\u{6255}\u{3044}",
            "ko": "\u{ACB0}\u{C81C}",
        ],

        // =====================================================================
        // MARK: - Amount TextField
        // =====================================================================

        "amount.tapToEnter": [
            "en": "Tap to enter amount",
            "es": "Toca para ingresar monto",
            "fr": "Appuyez pour entrer le montant",
            "pt": "Toque para inserir valor",
            "ja": "\u{30BF}\u{30C3}\u{30D7}\u{3057}\u{3066}\u{91D1}\u{984D}\u{3092}\u{5165}\u{529B}",
            "ko": "\u{D0ED}\u{D558}\u{C5EC} \u{AE08}\u{C561}\u{C744} \u{C785}\u{B825}\u{D558}\u{C138}\u{C694}",
        ],

        // =====================================================================
        // MARK: - Onboarding - Welcome
        // =====================================================================

        "welcome.welcomeTo": [
            "en": "Welcome to",
            "es": "Bienvenido a",
            "fr": "Bienvenue sur",
            "pt": "Bem-vindo ao",
            "ja": "\u{3088}\u{3046}\u{3053}\u{305D}",
            "ko": "\u{D658}\u{C601}\u{D569}\u{B2C8}\u{B2E4}",
        ],
        "welcome.appName": [
            "en": "Debt Tracker",
            "es": "Debt Tracker",
            "fr": "Debt Tracker",
            "pt": "Debt Tracker",
            "ja": "Debt Tracker",
            "ko": "Debt Tracker",
        ],
        "welcome.subtitle": [
            "en": "Track, manage, and settle your debts with ease. Let's set up a few things to get started.",
            "es": "Rastrea, administra y liquida tus deudas f\u{00E1}cilmente. Configuremos algunas cosas para empezar.",
            "fr": "Suivez, g\u{00E9}rez et r\u{00E9}glez vos dettes facilement. Configurons quelques \u{00E9}l\u{00E9}ments pour commencer.",
            "pt": "Rastreie, gerencie e quite suas d\u{00ED}vidas com facilidade. Vamos configurar algumas coisas para come\u{00E7}ar.",
            "ja": "\u{50B5}\u{52D9}\u{3092}\u{7C21}\u{5358}\u{306B}\u{8FFD}\u{8DE1}\u{30FB}\u{7BA1}\u{7406}\u{30FB}\u{6E05}\u{7B97}\u{3002}\u{307E}\u{305A}\u{3044}\u{304F}\u{3064}\u{304B}\u{8A2D}\u{5B9A}\u{3057}\u{307E}\u{3057}\u{3087}\u{3046}\u{3002}",
            "ko": "\u{BE5A}\u{C744} \u{C27D}\u{AC8C} \u{CD94}\u{C801}, \u{AD00}\u{B9AC}, \u{C815}\u{C0B0}\u{D558}\u{C138}\u{C694}. \u{C2DC}\u{C791}\u{D558}\u{AE30} \u{C804} \u{BA87} \u{AC00}\u{C9C0}\u{B97C} \u{C124}\u{C815}\u{D569}\u{B2C8}\u{B2E4}.",
        ],
        "welcome.dashboardAnalytics": [
            "en": "Dashboard & analytics",
            "es": "Panel y an\u{00E1}lisis",
            "fr": "Tableau de bord et analyses",
            "pt": "Painel e an\u{00E1}lises",
            "ja": "\u{30C0}\u{30C3}\u{30B7}\u{30E5}\u{30DC}\u{30FC}\u{30C9}\u{3068}\u{5206}\u{6790}",
            "ko": "\u{B300}\u{C2DC}\u{BCF4}\u{B4DC} \u{BC0F} \u{BD84}\u{C11D}",
        ],
        "welcome.smartReminders": [
            "en": "Smart reminders",
            "es": "Recordatorios inteligentes",
            "fr": "Rappels intelligents",
            "pt": "Lembretes inteligentes",
            "ja": "\u{30B9}\u{30DE}\u{30FC}\u{30C8}\u{30EA}\u{30DE}\u{30A4}\u{30F3}\u{30C0}\u{30FC}",
            "ko": "\u{C2A4}\u{B9C8}\u{D2B8} \u{C54C}\u{B9BC}",
        ],
        "welcome.icloudSync": [
            "en": "iCloud sync",
            "es": "Sincronizaci\u{00F3}n con iCloud",
            "fr": "Synchronisation iCloud",
            "pt": "Sincroniza\u{00E7}\u{00E3}o iCloud",
            "ja": "iCloud\u{540C}\u{671F}",
            "ko": "iCloud \u{B3D9}\u{AE30}\u{D654}",
        ],

        // =====================================================================
        // MARK: - Language Selection
        // =====================================================================

        "language.chooseLanguage": [
            "en": "Choose Your Language",
            "es": "Elige tu Idioma",
            "fr": "Choisissez Votre Langue",
            "pt": "Escolha Seu Idioma",
            "ja": "\u{8A00}\u{8A9E}\u{3092}\u{9078}\u{629E}",
            "ko": "\u{C5B8}\u{C5B4}\u{B97C} \u{C120}\u{D0DD}\u{D558}\u{C138}\u{C694}",
        ],
        "language.subtitle": [
            "en": "Select your preferred language",
            "es": "Selecciona tu idioma preferido",
            "fr": "S\u{00E9}lectionnez votre langue pr\u{00E9}f\u{00E9}r\u{00E9}e",
            "pt": "Selecione seu idioma preferido",
            "ja": "\u{5E0C}\u{671B}\u{306E}\u{8A00}\u{8A9E}\u{3092}\u{9078}\u{629E}\u{3057}\u{3066}\u{304F}\u{3060}\u{3055}\u{3044}",
            "ko": "\u{C120}\u{D638}\u{D558}\u{B294} \u{C5B8}\u{C5B4}\u{B97C} \u{C120}\u{D0DD}\u{D558}\u{C138}\u{C694}",
        ],

        // =====================================================================
        // MARK: - Currency Selection
        // =====================================================================

        "currency.chooseCurrency": [
            "en": "Choose Your Currency",
            "es": "Elige tu Moneda",
            "fr": "Choisissez Votre Devise",
            "pt": "Escolha Sua Moeda",
            "ja": "\u{901A}\u{8CA8}\u{3092}\u{9078}\u{629E}",
            "ko": "\u{D1B5}\u{D654}\u{B97C} \u{C120}\u{D0DD}\u{D558}\u{C138}\u{C694}",
        ],
        "currency.subtitle": [
            "en": "You can change this later in Settings",
            "es": "Puedes cambiarlo despu\u{00E9}s en Ajustes",
            "fr": "Vous pouvez modifier cela plus tard dans les R\u{00E9}glages",
            "pt": "Voc\u{00EA} pode alterar isso depois em Configura\u{00E7}\u{00F5}es",
            "ja": "\u{5F8C}\u{3067}\u{8A2D}\u{5B9A}\u{3067}\u{5909}\u{66F4}\u{3067}\u{304D}\u{307E}\u{3059}",
            "ko": "\u{B098}\u{C911}\u{C5D0} \u{C124}\u{C815}\u{C5D0}\u{C11C} \u{BCC0}\u{ACBD}\u{D560} \u{C218} \u{C788}\u{C2B5}\u{B2C8}\u{B2E4}",
        ],

        // =====================================================================
        // MARK: - Biometric Labels
        // =====================================================================

        "biometric.faceId": [
            "en": "Face ID",
            "es": "Face ID",
            "fr": "Face ID",
            "pt": "Face ID",
            "ja": "Face ID",
            "ko": "Face ID",
        ],
        "biometric.touchId": [
            "en": "Touch ID",
            "es": "Touch ID",
            "fr": "Touch ID",
            "pt": "Touch ID",
            "ja": "Touch ID",
            "ko": "Touch ID",
        ],
        "biometric.opticId": [
            "en": "Optic ID",
            "es": "Optic ID",
            "fr": "Optic ID",
            "pt": "Optic ID",
            "ja": "Optic ID",
            "ko": "Optic ID",
        ],
        "biometric.biometrics": [
            "en": "Biometrics",
            "es": "Biometr\u{00ED}a",
            "fr": "Biom\u{00E9}trie",
            "pt": "Biometria",
            "ja": "\u{751F}\u{4F53}\u{8A8D}\u{8A3C}",
            "ko": "\u{C0DD}\u{CCB4} \u{C778}\u{C99D}",
        ],

        // =====================================================================
        // MARK: - Export
        // =====================================================================

        "export.title": [
            "en": "DEBT TRACKER \u{2014} Summary Export",
            "es": "DEBT TRACKER \u{2014} Resumen Exportado",
            "fr": "DEBT TRACKER \u{2014} R\u{00E9}sum\u{00E9} Export\u{00E9}",
            "pt": "DEBT TRACKER \u{2014} Resumo Exportado",
            "ja": "DEBT TRACKER \u{2014} \u{6982}\u{8981}\u{30A8}\u{30AF}\u{30B9}\u{30DD}\u{30FC}\u{30C8}",
            "ko": "DEBT TRACKER \u{2014} \u{C694}\u{C57D} \u{B0B4}\u{BCF4}\u{B0B4}\u{AE30}",
        ],
        "export.generated": [
            "en": "Generated: %@",
            "es": "Generado: %@",
            "fr": "G\u{00E9}n\u{00E9}r\u{00E9}: %@",
            "pt": "Gerado: %@",
            "ja": "\u{751F}\u{6210}\u{65E5}: %@",
            "ko": "\u{C0DD}\u{C131}\u{C77C}: %@",
        ],
        "export.overview": [
            "en": "OVERVIEW",
            "es": "RESUMEN",
            "fr": "APERCU",
            "pt": "RESUMO",
            "ja": "\u{6982}\u{8981}",
            "ko": "\u{C694}\u{C57D}",
        ],
        "export.totalActive": [
            "en": "Total active debts: %@",
            "es": "Total deudas activas: %@",
            "fr": "Total dettes actives: %@",
            "pt": "Total d\u{00ED}vidas ativas: %@",
            "ja": "\u{30A2}\u{30AF}\u{30C6}\u{30A3}\u{30D6}\u{306A}\u{50B5}\u{52D9}: %@",
            "ko": "\u{D65C}\u{C131} \u{BE5A} \u{D569}\u{ACC4}: %@",
        ],
        "export.owedToMe": [
            "en": "Owed to me: %@",
            "es": "Me deben: %@",
            "fr": "On me doit: %@",
            "pt": "Me devem: %@",
            "ja": "\u{8CB8}\u{3057}\u{305F}\u{304A}\u{91D1}: %@",
            "ko": "\u{BC1B}\u{C744} \u{B3C8}: %@",
        ],
        "export.iOwe": [
            "en": "I owe: %@",
            "es": "Yo debo: %@",
            "fr": "Je dois: %@",
            "pt": "Eu devo: %@",
            "ja": "\u{501F}\u{308A}\u{305F}\u{304A}\u{91D1}: %@",
            "ko": "\u{AC1A}\u{C740} \u{B3C8}: %@",
        ],
        "export.netBalance": [
            "en": "Net balance: %@",
            "es": "Balance neto: %@",
            "fr": "Solde net: %@",
            "pt": "Saldo l\u{00ED}quido: %@",
            "ja": "\u{7D14}\u{6B8B}\u{9AD8}: %@",
            "ko": "\u{C21C} \u{C794}\u{C561}: %@",
        ],
        "export.owedToMeSection": [
            "en": "OWED TO ME",
            "es": "ME DEBEN",
            "fr": "ON ME DOIT",
            "pt": "ME DEVEM",
            "ja": "\u{8CB8}\u{3057}\u{305F}\u{304A}\u{91D1}",
            "ko": "\u{BC1B}\u{C744} \u{B3C8}",
        ],
        "export.iOweSection": [
            "en": "I OWE",
            "es": "YO DEBO",
            "fr": "JE DOIS",
            "pt": "EU DEVO",
            "ja": "\u{501F}\u{308A}\u{305F}\u{304A}\u{91D1}",
            "ko": "\u{AC1A}\u{C740} \u{B3C8}",
        ],
        "export.completed": [
            "en": "COMPLETED (%@)",
            "es": "COMPLETADAS (%@)",
            "fr": "TERMIN\u{00C9}ES (%@)",
            "pt": "CONCLU\u{00CD}DAS (%@)",
            "ja": "\u{5B8C}\u{4E86} (%@)",
            "ko": "\u{C644}\u{B8CC} (%@)",
        ],
    ]
}
