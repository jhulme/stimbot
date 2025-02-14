# Description:
#   Tools for interacting with the NetrunnerDB API.
#
# Commands:
#   [[card name]] - search for a card with that name in the NetrunnerDB API
#   {{card name}} - fetch the card image for a card
#   !jank (corp|runner) - Choose an identity and three random cards. Break the meta!
#   !find (e|t|s|f|x|p|o|n|d|c|a|i|u|y|g|v)(:|=|>|<|!)<query> - find cards searching by attributes

Fuse = require 'fuse.js'

FACTION_ICONS = {
    'adam': 'https://emoji.slack-edge.com/T0AV68M8C/adam/c9fc2127ea57ab41.png',
    'anarch': 'https://emoji.slack-edge.com/T0AV68M8C/anarch/76e0d2bd50175857.png',
    'apex': 'https://emoji.slack-edge.com/T0AV68M8C/apex/17fdf10b8326daf3.png',
    'criminal': 'https://emoji.slack-edge.com/T0AV68M8C/criminal/9ebb239ab7c5de1c.png',
    'haas-bioroid': 'https://emoji.slack-edge.com/T0AV68M8C/hb/929240a94b055ac4.png',
    'jinteki': 'https://emoji.slack-edge.com/T0AV68M8C/jinteki/5ee8a93180cae42a.png',
    'nbn': 'https://emoji.slack-edge.com/T0AV68M8C/nbn/941383205f0a93b1.png',
    'shaper': 'https://emoji.slack-edge.com/T0AV68M8C/shaper/41994ae80b49af30.png',
    'sunny-lebeau': 'https://emoji.slack-edge.com/T0AV68M8C/sunnylebeau/831b222f07a01e6a.png',
    'weyland-consortium': 'https://emoji.slack-edge.com/T0AV68M8C/weyland/4b6d1be376b3cd52.png'
}

LOCALIZATION = {
    'en': {
        'influence': 'influence',
        'infinite': 'Infinite',
        'decksize': 'min deck size',
        'strength': 'strength',
        'cycle': 'Cycle',
        'trace': 'trace'
    },
    'kr': {
        'influence': '영향력',
        'infinite': '무한한',
        'decksize': '최소 덱 크기',
        'strength': '힘',
        'cycle': '사이클',
        'trace': '추적'
    }
}

# FACTIONS = {
# 	'adam': { "name": 'Adam', "color": '#b9b23a', "icon": "Adam" },
# 	'anarch': { "name": 'Anarch', "color": '#ff4500', "icon": "Anarch" },
# 	'apex': { "name": 'Apex', "color": '#9e564e', "icon": "Apex" },
# 	'criminal': { "name": 'Criminal', "color": '#4169e1', "icon": "Criminal" },
# 	'shaper': { "name": 'Shaper', "color": '#32cd32', "icon": "Shaper" },
# 	'sunny-lebeau': { "name": 'Sunny Lebeau', "color": '#715778', "icon": "Sunny LeBeau" },
# 	'neutral': { "name": 'Neutral (runner)', "color": '#808080', "icon": "Neutral" },
# 	'haas-bioroid': { "name": 'Haas-Bioroid', "color": '#8a2be2', "icon": "Haas-Bioroid" },
# 	'jinteki': { "name": 'Jinteki', "color": '#dc143c', "icon": "Jinteki" },
# 	'nbn': { "name": 'NBN', "color": '#ff8c00', "icon": "NBN" },
# 	'weyland-consortium': { "name": 'Weyland Consortium', "color": '#326b5b', "icon": "Weyland" },
# 	'neutral': { "name": 'Neutral (corp)', "color": '#808080', "icon": "Neutral" }
# }

ABBREVIATIONS = {
    'en': {
        'proco': 'Professional Contacts',
        'procon': 'Professional Contacts',
        'jhow': 'Jackson Howard',
        'smc': 'Self-Modifying Code',
        'kit': 'Rielle "Kit" Peddler',
        'abt': 'Accelerated Beta Test',
        'mopus': 'Magnum Opus',
        'mo': 'Magnum Opus',
        'charizard': 'Scheherazade',
        ':charizard:': 'Scheherazade',
        'siphon': 'Account Siphon',
        'deja': 'Déjà Vu',
        'deja vu': 'Déjà Vu',
        'gov takeover': 'Government Takeover',
        'gt': 'Government Takeover',
        'baby': 'Symmetrical Visage',
        'pancakes': 'Adjusted Chronotype',
        'dlr': 'Data Leak Reversal',
        'bn': 'Breaking News',
        'rp': 'Replicating Perftion',
        'neh': 'Near-Earth Hub',
        'pe': 'Perfecting Evolution',
        'white tree': 'Replicating Perfection',
        'black tree': 'Perfecting Evolution',
        'ci': 'Cerebral Imaging',
        'ppvp': 'Prepaid VoicePAD',
        'pvpp': 'Prepaid VoicePAD',
        'sfss': 'Shipment from SanSan',
        'rdi': 'R&D Interface',
        'hqi': 'HQ Interface',
        'gfi': 'Global Food Initiative',
        'dbs': 'Daily Business Show',
        'nre': 'Net-Ready Eyes',
        'elp': 'Enhanced Login Protocol',
        'levy': 'Levy AR Lab Access',
        'oai': 'Oversight AI',
        'fao': 'Forged Activation Orders',
        'psf': 'Private Security Force',
        'david': 'd4v1d',
        'ihw': 'I\'ve Had Worse',
        'qt': 'Quality Time',
        'nisei': 'Nisei Mk II',
        'dhpp': 'Director Haas\' Pet Project',
        'tfin': 'The Future Is Now',
        'ash': 'Ash 2X3ZB9CY',
        'cvs': 'Cyberdex Virus Suite',
        'otg': 'Off the Grid',
        'ts': 'Team Sponsorship',
        'glc': 'Green Level Clearance',
        'blc': 'Blue Level Clearance',
        'pp': 'Product Placement',
        'asi': 'All-Seeing I',
        'nas': 'New Angeles Sol',
        'bbg': 'Breaker Bay Grid',
        'drt': 'Dedicated Response Team',
        'sot': 'Same Old Thing',
        'stamherk': 'Stimhack',
        'stam herk': 'Stimhack',
        'tempo': 'Professional Contacts',
        'ff': 'Feedback Filter',
        'fis': 'Fisk Investment Seminar',
        'fisk': 'Laramy Fisk',
        'lf': 'Lucky Find',
        'prof': 'The Professor',
        'tol': 'Trick of Light',
        'manup': 'Mandatory Upgrades',
        'ij': 'Inside Job',
        'toilet': 'Inside Job',
        ':toilet:': 'Inside Job',
        'loo': 'Inside Job',
        'potty': 'Inside Job',
        'restroom': 'Inside Job',
        'bathroom': 'Inside Job',
        'washroom': 'Inside Job',
        'commode': 'Inside Job',
        'wc': 'Inside Job',
        'w.c.': 'Inside Job',
        'andy': 'Andromeda',
        'qpm': 'Quantum Predictive Model',
        'smashy dino': 'Shattered Remains',
        'smashy dinosaur': 'Shattered Remains',
        'mhc': 'Mental Health Clinic',
        'etf': 'Engineering the Future',
        'st': 'Stronger Together',
        'babw': 'Building a Better World',
        'bwbi': 'Because We Built It',
        'mn': 'Making News',
        'ct': 'Chaos Theory',
        'oycr': 'An Offer You Can\'t Refuse',
        'aoycr': 'An Offer You Can\'t Refuse',
        'hok': 'House of Knives',
        'cc': 'Clone Chip',
        'ta': 'Traffic Accident',
        'jesus': 'Jackson Howard',
        'baby bucks': 'Symmetrical Visage',
        'babybucks': 'Symmetrical Visage',
        'mediohxcore': 'Deuces Wild',
        'calimsha': 'Kate "Mac" McCaffrey',
        'spags': 'Troll',
        'bs': 'Blue Sun',
        'larla': 'Levy AR Lab Access',
        'ig': 'Industrial Genomics',
        'clone': 'Clone Chip',
        'josh01': 'Professional Contacts',
        'hiro': 'Chairman Hiro',
        'director': 'Director Haas',
        'haas': 'Director Haas',
        'zeromus': 'Mushin no Shin',
        'tldr': 'TL;DR',
        'sportsball': 'Team Sponsorship',
        'sports ball': 'Team Sponsorship',
        'sports': 'Team Sponsorship',
        'crfluency': 'Blue Sun',
        'dodgepong': 'Broadcast Square',
        'cheese potato': 'Data Leak Reversal',
        'cheese potatos': 'Data Leak Reversal',
        'cheese potatoes': 'Data Leak Reversal',
        'cycy': 'Cyber-Cipher',
        'cy cy': 'Cyber-Cipher',
        'cy-cy': 'Cyber-Cipher',
        'expose': 'Exposé',
        'sneakysly': 'Stimhack',
        'eap': 'Explode-a-palooza',
        'wnp': 'Wireless Net Pavilion',
        'mcg': 'Mumbad City Grid',
        'sscg': 'SanSan City Grid',
        'jes': 'Jesminder Sareen',
        'jess': 'Jesminder Sareen',
        'jessie': 'Jesminder Sareen',
        'palana': 'Pālanā Foods',
        'palana foods': 'Pālanā Foods',
        'plop': 'Political Operative',
        'polop': 'Political Operative',
        'pol op': 'Political Operative',
        'poop': 'Political Operative',
        'mcc': 'Mumbad Construction Co.',
        'coco': 'Mumbad Construction Co.',
        'moh': 'Museum of History',
        'cst': 'Corporate Sales Team',
        'panera': 'Panchatantra',
        'pancetta': 'Panchatantra',
        'hhn': 'Hard-Hitting News',
        'adap': 'Another Day, Another Paycheck',
        'maus': 'Mausolus',
        'eoi': 'Exchange of Information',
        'oota': 'Out of the Ashes',
        'tw': 'The Turning Wheel',
        'dnn': 'Dedicated Neural Net',
        'ftm': 'Fear The Masses',
        'ttw': 'The Turning Wheel',
        'tw': 'The Turning Wheel',
        'tbf': 'The Black File',
        'bf': 'The Black File',
        'ips': 'Improved Protien Source',
        'nmcg': 'Navi Mumbai City Grid',
        'tpof': 'The Price of Freedom',
        'pgo': 'Power Grid Overload',
        'am': 'Archived Memories',
        'ro': 'Reclamation Order',
        'mch': 'Mumbad City Hall',
        'nach': 'New Angeles City Hall',
        'dl': 'Dirty Laundry',
        'tr': 'Test Run',
        'itd': 'IT Department',
        'it': 'IT Department',
        'vi': 'Voter Intimidation',
        'fte': 'Freedom Through Equality',
        'vbg': 'Virus Breeding Ground',
        'exploda': 'Explode-a-palooza',
        'ctm': 'NBN: Controlling the Message',
        'hrf': 'Hyouba Research Facility',
        'abr': 'Always Be Running',
        'dan': 'Deuces Wild',
        ':dan:': 'Deuces Wild',
        ':themtg:': 'Deuces Wild',
        'pornstache': 'Hernando Cortez',
        'porn stache': 'Hernando Cortez',
        'porn-stache': 'Hernando Cortez',
        'vape': 'Deuces Wild',
        'fair1': 'Fairchild 1.0',
        'fc1': 'Fairchild 1.0',
        'fc 1': 'Fairchild 1.0',
        'fair2': 'Fairchild 2.0',
        'fc2': 'Fairchild 2.0',
        'fc 2': 'Fairchild 2.0',
        'fair3': 'Fairchild 3.0',
        'fc3': 'Fairchild 3.0',
        'fc 3': 'Fairchild 3.0',
        'fc4': 'Fairchild',
        'fc 4': 'Fairchild',
        'fcp': 'Fairchild',
        'fcprime': 'Fairchild',
        "fc'": 'Fairchild',
        'psk': 'Rumor Mill',
        'khantract': 'Temüjin Contract',
        'tc': 'Temüjin Contract',
        'clippy': 'Paperclip',
        'clippit': 'Paperclip',
        'crouton': 'Curtain Wall',
        'bon': 'Weyland: Builder of Nations',
        'aot': 'Archtects of Tomorrow',
        'pu': 'Jinteki: Potential Unleashed',
        'smoke': 'Ele "Smoke" Scovak',
        'bl': 'Biotic Labor',
        'ad': 'Accelerated Diagnostics',
        'sfm': 'Shipment from Mirrormorph',
        'sfmm': 'Shipment from Mirrormorph',
        'sfk': 'Shipment from Kaguya',
        'psyfield': 'Psychic Field',
        'psy field': 'Psychic Field',
        'psifield': 'Psychic Field',
        'psi field': 'Psychic Field',
        'mvt': 'Mumbad Virtual Tour',
        'eff comm': 'Efficiency Committee',
        'eff com': 'Efficiency Committee',
        'effcomm': 'Efficiency Committee',
        'effcom': 'Efficiency Committee',
        'ec': 'Efficiency Committee',
        'd1en': 'Memstrips',
        'dien': 'Memstrips',
        'ber': 'Bioroid Efficiency Research',
        'ci fund': 'C.I. Fund',
        'vlc': 'Violet Level Clearance',
        'pv': 'Project Vitruvius',
        'sac con': 'Sacrificial Construct',
        'saccon': 'Sacrificial Construct',
        'sc': 'Sacrificial Construct',
        'willow': "Will-o'-the-Wisp",
        'will o': "Will-o'-the-Wisp",
        'willo': "Will-o'-the-Wisp",
        'will-o': "Will-o'-the-Wisp",
        'wotw': "Will-o'-the-Wisp",
        'fihp': 'Friends in High Places',
        'otl': 'On the Lam',
        'sifr': 'Ṣifr',
        'piot': 'Peace in Our Time',
        'sna': 'Sensor Net Activation',
        'sunya', 'Sūnya',
        'barney': 'Bryan Stinson',
        'hat': 'Hellion Alpha Test',
        'hbt': 'Hellion Beta Test',
        'csm': 'Clone Suffrage Movement',
        'mogo': 'Mother Goddess',
        'uwc': 'Underworld Contacts',
        ':dien:': 'Memstrips',
        'o2': 'O₂ Shortage',
        ':damon:': 'O₂ Shortage',
        ':lukas:': 'Astroscript Pilot Program',
        ':mtgdan:': 'Deuces Wild',
        ':spags:': 'Troll',
        'deuces mild': 'Build Script',
        'sau': 'Sensie Actors Union',
        'sft': 'Shipment from Tennin',
        'moon': 'Estelle Moon',
        'uvc': 'Ultraviolet Clearance',
        'sva': 'Salvaged Vanadis Armory',
        'bob': 'Bug Out Bag',
        'turtle': 'Aumakua',
        'tla': 'Threat Level Alpha',
        'mca': 'MCA Austerity Policy',
        'map': 'MCA Austerity Policy',
        'nanotech': "Na'Not'K",
        'nanotek': "Na'Not'K",
        'bitey boi': 'Gbahali',
        'bitey boy': 'Gbahali',
        'one bitey boi': 'Gbahali',
        'one bitey boy': 'Gbahali',
        'crocodile': 'Gbahali',
        'alligator': 'Gbahali',
        'gator': 'Gbahali',
        ':crocodile:': 'Gbahali',
        ':bitey:': 'Gbahali',
        ':biteyboi:': 'Gbahali',
        'estrike': 'Employee strike',
        'strike': 'Employee Strike',
        'e-strike': 'Employee Strike',
        'doof': 'Diversion of Funds',
        'dof': 'Diversion of Funds',
        'divvy': 'Diversion of Funds',
        'gabe': 'Gabriel Santiago',
        'daddy gabe': 'Gabriel Santiago',
        'ucf': 'Universal Connectivity Fee',
        'mache': 'Mâché',
        'aal': 'Advanced Assembly Lines',
        'lat': 'Lat: Ethical Freelancer'
    },
    'kr': {
        '미드시즌': '중간 개편',
        '하드히팅': '신랄한 특종'
        '팔라나': '팔라나 식품: 지속가능한 성장',
        '팔라냐': '팔라나 식품: 지속가능한 성장',
        '푸드': '전지구 식량 계획',
        '블랙메일': '협박',
        '보안 방': '보안 결',
        '팬사이트': '팬 사이트',
        '민지': '잭슨 하워드'
    }
}

DISPLAY_CYCLES = [ 2, 4, 6, 8, 10, 11, 12, 21, 26 ]

preloadData = (robot) ->
    locales = [ "en", "kr" ]
    for locale in locales
        do (locale) ->
            robot.http("https://netrunnerdb.com/api/2.0/public/cards?_locale=" + locale)
                .get() (err, res, body) ->
                    cardData = JSON.parse body
                    cards = cardData.data.sort(compareCards)
                    robot.logger.info "Loaded " + cardData.data.length + " NRDB cards"
                    robot.brain.set 'cards-' + locale, cards
                    robot.brain.set 'imageUrlTemplate-' + locale, cardData.imageUrlTemplate

                    robot.http("https://netrunnerdb.com/api/2.0/public/mwl?_locale=" + locale)
                        .get() (err, res, body) ->
                            mwlData = JSON.parse body
                            currentMwl = {}
                            for mwl in mwlData.data
                                if mwl.active
                                    currentMwl = mwl
                                    break
                            robot.brain.set 'mwl-' + locale, currentMwl
                            restrictedCards = []
                            bannedCards = []
                            mwlCards = cards.filter((card) ->
                                return card.code of currentMwl.cards
                            )
                            for card in mwlCards
                                if currentMwl.cards[card.code].is_restricted == 1
                                    restrictedCards.push(card.title)
                                if currentMwl.cards[card.code].deck_limit == 0
                                    bannedCards.push(card.title)
                            robot.logger.info "Loaded " + mwlCards.length + " NRDB MWL cards"
                            robot.brain.set 'restrictedCards-' + locale, restrictedCards
                            robot.brain.set 'bannedCards-' + locale, bannedCards

            robot.http("https://netrunnerdb.com/api/2.0/public/packs?_locale=" + locale)
                .get() (err, res, body) ->
                    packData = JSON.parse body
                    mappedPackData = {}
                    for pack in packData.data
                        mappedPackData[pack.code] = pack
                    robot.logger.info "Loaded " + packData.data.length + " NRDB packs"
                    robot.brain.set 'packs-' + locale, mappedPackData

            robot.http("https://netrunnerdb.com/api/2.0/public/cycles?_locale=" + locale)
                .get() (err, res, body) ->
                    cycleData = JSON.parse body
                    mappedCycleData = {}
                    for cycle in cycleData.data
                        mappedCycleData[cycle.code] = cycle
                    robot.logger.info "Loaded " + cycleData.data.length + " NRDB cycles"
                    robot.brain.set 'cycles-' + locale, mappedCycleData

            robot.http("https://netrunnerdb.com/api/2.0/public/types?_locale=" + locale)
                .get() (err, res, body) ->
                    typeData = JSON.parse body
                    mappedTypeData = {}
                    for type in typeData.data
                        mappedTypeData[type.code] = type
                    robot.logger.info "Loaded " + typeData.data.length + " NRDB types"
                    robot.brain.set 'types-' + locale, mappedTypeData

            robot.http("https://netrunnerdb.com/api/2.0/public/factions?_locale=" + locale)
                .get() (err, res, body) ->
                    factionData = JSON.parse body
                    mappedFactionData = {}
                    for faction in factionData.data
                        mappedFactionData[faction.code] = faction
                    robot.logger.info "Loaded " + factionData.data.length + " NRDB factions"
                    robot.brain.set 'factions-' + locale, mappedFactionData



formatCard = (card, packs, cycles, types, factions, mwl, imageUrlTemplate, locale) ->
    title = card.title
    if locale != 'en' and card._locale
        title = card._locale[locale].title
    if card.uniqueness
        title = "◆ " + title


    card_image_url = card.image_url
    if not card_image_url
        card_image_url = imageUrlTemplate.replace /\{code\}/, card.code
    else
        card_image_url = card_image_url.replace('https', 'http')

    attachment = {
        'fallback': title,
        'title': title,
        'title_link': 'https://netrunnerdb.com/' + locale + '/card/' + card.code,
        'mrkdwn_in': [ 'text', 'author_name' ],
        'thumb_url': card_image_url
    }

    attachment['text'] = ''

    if locale != 'en' and card._locale
        typeline = "*#{types[card.type_code]._locale[locale].name}*"
        if card._locale[locale].keywords? and card._locale[locale].keywords != ''
            typeline += ": #{card._locale[locale].keywords}"
        else if card.keywords? and card.keywords != ''
            typeline += ": #{card.keywords}"
    else
        typeline = "*#{types[card.type_code].name}*"
        if card.keywords? and card.keywords != ''
            typeline += ": #{card.keywords}"

    cardCost = card.cost
    if card.cost == null
        cardCost = 'X'

    switch card.type_code
        when 'agenda'
            typeline += " _(#{card.advancement_cost}:rez:, #{card.agenda_points}:agenda:)_"
        when 'asset', 'upgrade'
            typeline += " _(#{cardCost}:credit:, #{card.trash_cost}:trash:)_"
        when 'event', 'operation', 'hardware', 'resource'
            typeline += " _(#{cardCost}:credit:"
            if card.trash_cost?
                typeline += ", #{card.trash_cost}:trash:"
            typeline += ")_"
        when 'ice'
            cardStrength = card.strength
            if card.strength == null
                cardStrength = 'X'
            typeline += " _(#{cardCost}:credit:, #{cardStrength} #{LOCALIZATION[locale]['strength']}"
            if card.trash_cost?
                typeline += ", #{card.trash_cost}:trash:"
            typeline += ")_"
        when 'identity'
            if card.side_code == 'runner'
                typeline += " _(#{card.base_link}:baselink:, #{card.minimum_deck_size} #{LOCALIZATION[locale]['decksize']}, #{card.influence_limit || LOCALIZATION[locale]['infinite']} #{LOCALIZATION[locale]['influence']})_"
            else if card.side_code == 'corp'
                typeline += " _(#{card.minimum_deck_size} #{LOCALIZATION[locale]['decksize']}, #{card.influence_limit || LOCALIZATION[locale]['infinite']} #{LOCALIZATION[locale]['influence']})_"
        when 'program'
            if /Icebreaker/.test(card.keywords)
                cardStrength = card.strength
                if card.strength == null
                    cardStrength = 'X'
                typeline += " _(#{cardCost}:credit:, #{card.memory_cost}:mu:, #{cardStrength} #{LOCALIZATION[locale]['strength']})_"
            else
                typeline += " _(#{cardCost}:credit:, #{card.memory_cost}:mu:)_"

    attachment['text'] += typeline + "\n\n"
    if locale != 'en' && card._locale && card._locale[locale].text
        attachment['text'] += emojifyNRDBText(card._locale[locale].text)
    else if card.text
        attachment['text'] += emojifyNRDBText(card.text)
    else
        attachment['text'] += ''

    faction = factions[card.faction_code]

    if faction?
        authorname = "#{packs[card.pack_code].name}"
        if locale != 'en' and packs[card.pack_code]._locale
            authorname = "#{packs[card.pack_code]._locale[locale].name}"
        if cycles[packs[card.pack_code].cycle_code].position in DISPLAY_CYCLES
            if locale != 'en' and cycles[packs[card.pack_code].cycle_code]._locale
                authorname = authorname + " / #{cycles[packs[card.pack_code].cycle_code]._locale[locale].name} #{LOCALIZATION[locale]['cycle']}"
            else
                authorname = authorname + " / #{cycles[packs[card.pack_code].cycle_code].name} #{LOCALIZATION[locale]['cycle']}"

        if locale != 'en' and faction._locale
            authorname = authorname + " ##{card.position} / #{faction._locale[locale].name}"
        else
            authorname = authorname + " ##{card.position} / #{faction.name}"
        influencepips = ""
        if card.faction_cost?
            i = card.faction_cost
            while i--
                influencepips += '●'
        if influencepips != ""
            authorname = authorname + " #{influencepips}"

        attachment['author_name'] = authorname
        attachment['color'] = '#' + faction.color
        if faction.code of FACTION_ICONS
            attachment['author_icon'] = FACTION_ICONS[faction.code]

    if card.code of mwl.cards
        attachment['footer'] = mwl.name
        if mwl.cards[card.code].is_restricted == 1
            attachment['footer'] += ' Restricted'
        if mwl.cards[card.code].deck_limit == 0
            attachment['footer'] += ' Banned'

    return attachment

superscriptify = (num) ->
    superscripts = {
        '0': '⁰',
        '1': '¹',
        '2': '²',
        '3': '³',
        '4': '⁴',
        '5': '⁵',
        '6': '⁶',
        '7': '⁷',
        '8': '⁸',
        '9': '⁹',
        'X': 'ˣ',
        'x': 'ˣ'
    }

    sup = ''
    for digit in [0..(num.length-1)]
        sup = sup + superscripts[num[digit]]
    return sup

emojifyNRDBText = (text) ->
    text = text.replace /\[Credits?\]/ig, ":credit:"
    text = text.replace /\[Click\]/ig, ":click:"
    text = text.replace /\[Trash\]/ig, ":trash:"
    text = text.replace /\[Recurring( |-)Credits?\]/ig, ":recurring:"
    text = text.replace /\[Subroutine\]/gi, ":subroutine:"
    text = text.replace /\[(Memory Unit|mu)\]/ig, " :mu:"
    text = text.replace /\[Link\]/ig, ":baselink:"
    text = text.replace /<sup>/ig, " "
    text = text.replace /<\/sup>/ig, ""
    text = text.replace /&ndash/ig, "–"
    text = text.replace /<strong>/ig, "*"
    text = text.replace /<\/strong>/ig, "*"
    text = text.replace /\[jinteki\]/ig, ":jinteki:"
    text = text.replace /\[weyland-consortium\]/ig, ":weyland:"
    text = text.replace /\[nbn\]/ig, ":nbn:"
    text = text.replace /\[haas-bioroid\]/ig, ":hb:"
    text = text.replace /\[shaper\]/ig, ":shaper:"
    text = text.replace /\[criminal\]/ig, ":criminal:"
    text = text.replace /\[anarch\]/ig, ":anarch:"
    text = text.replace /\[adam\]/ig, ":adam:"
    text = text.replace /\[sunny\]/ig, ":sunnylebeau:"
    text = text.replace /\[apex\]/ig, ":apex:"
    text = text.replace /\<ul>/ig, "\n"
    text = text.replace /\<\/ul>/ig, ""
    text = text.replace /\<li>/ig, "• "
    text = text.replace /\<\/li>/ig, "\n"
    text = text.replace /\<errata>/ig, "_"
    text = text.replace /\<\/errata>/ig, "_"
    text = text.replace /\<i>/ig, "_"
    text = text.replace /\<\/i>/ig, "_"
    trace_words = Object.keys(LOCALIZATION).map((language) -> LOCALIZATION[language]['trace']).join('|')
    trace_regex = new RegExp("<trace>(" + trace_words + ") (\\d+|X)<\/trace>", "ig")
    text = text.replace trace_regex, (match, traceText, strength, offset, string) ->
        traceStrength = superscriptify strength
        return "*" + traceText + traceStrength + "*—"

    return text

compareCards = (card1, card2) ->
    if card1.title < card2.title
        return -1
    else if card1.title > card2.title
        return 1
    else
        return 0

cardMatches = (card, cond, packs, cycles) ->
    conditionValue = cond.value.replace(/\"/g, "")

    return false if cond.key == 'p' && typeof(card.strength) == 'undefined'
    return false if cond.key == 'o' && typeof(card.cost) == 'undefined'
    return false if cond.key == 'n' && typeof(card.faction_cost) == 'undefined'
    return false if cond.key == 'y' && typeof(card.quantity) == 'undefined'
    return false if cond.key == 'g' && typeof(card.advancement_cost) == 'undefined'
    return false if cond.key == 'v' && typeof(card.agenda_points) == 'undefined'

    switch cond.op
        when ":", "="
            switch cond.key
                when "e" then return card.pack_code == conditionValue
                when "t" then return card.type_code == conditionValue
                when "s" then return card.keywords && conditionValue in card.keywords.toLowerCase().split(" - ")
                when "f" then return card.faction_code.substr(0, conditionValue.length) == conditionValue
                when "x" then return card.text && ~(card.text.toLowerCase().indexOf(conditionValue))
                when "d" then return conditionValue == card.side_code.substr(0, conditionValue.length)
                when "a" then return card.flavor && ~(card.flavor.toLowerCase().indexOf(conditionValue))
                when "i" then return card.illustrator && ~(card.illustrator.toLowerCase().indexOf(conditionValue))
                when "u" then return !card.uniqueness == !parseInt(conditionValue)
                when "p" then return card.strength == parseInt(conditionValue)
                when "o" then return card.cost == parseInt(conditionValue)
                when "n" then return card.faction_cost == parseInt(conditionValue)
                when "y" then return card.quantity == parseInt(conditionValue)
                when "g" then return card.advancement_cost == parseInt(conditionValue)
                when "v" then return card.agenda_points == parseInt(conditionValue)
                when "c" then return cycles[packs[card.pack_code].cycle_code].position == parseInt(conditionValue)
        when "<"
            switch cond.key
                when "p" then return card.strength < parseInt(conditionValue)
                when "o" then return card.cost < parseInt(conditionValue)
                when "n" then return card.faction_cost < parseInt(conditionValue)
                when "y" then return card.quantity < parseInt(conditionValue)
                when "g" then return card.advancement_cost < parseInt(conditionValue)
                when "v" then return card.agenda_points < parseInt(conditionValue)
                when "c" then return cycles[packs[card.pack_code].cycle_code].position < parseInt(conditionValue)
        when ">" then return !cardMatches(card, { key: cond.key, op: "<", value: parseInt(conditionValue) + 1 }, packs, cycles)
        when "!" then	return !cardMatches(card, { key: cond.key, op: ":", value: conditionValue }, packs, cycles)
    true

lookupCard = (query, cards, locale) ->
    query = query.toLowerCase()

    if query of ABBREVIATIONS[locale]
        query = ABBREVIATIONS[locale][query]

    if locale in ["kr"]
        # fuzzy search won't work, do naive string-matching
        results_exact = cards.filter((card) -> card._locale && card._locale[locale].title == query)
        results_includes = cards.filter((card) -> card._locale && card._locale[locale].title.includes(query))

        if results_exact.length > 0
            return results_exact[0]

        if results_includes.length > 0
            sortedResults = results_includes.sort((c1, c2) -> c1._locale[locale].title.length - c2._locale[locale].title.length)
            return sortedResults[0]
        return false
    else
        keys = ['title']
        if locale != 'en'
            keys.push('_locale["' + locale + '"].title')

        fuseOptions =
            caseSensitive: false
            include: ['score']
            shouldSort: true
            threshold: 0.6
            location: 0
            distance: 100
            maxPatternLength: 32
            keys: keys

        fuse = new Fuse cards, fuseOptions
        results = fuse.search(query)

        if results? and results.length > 0
            filteredResults = results.filter((c) -> c.score == results[0].score)
            sortedResults = []
            if locale is 'en'
                sortedResults = filteredResults.sort((c1, c2) -> c1.item.title.length - c2.item.title.length)
            else
                # favor localized results over non-localized results when showing matches
                sortedResults = filteredResults.sort((c1, c2) ->
                    if c1.item._locale and c2.item._locale
                        return c1.item._locale[locale].title.length - c2.item._locale[locale].title.length
                    if c1.item._locale and not c2.item._locale
                        return -1
                    if c2.item._locale and not c1.item._locale
                        return 1
                    return c1.item.title.length - c2.item.title.length
                )
            return sortedResults[0].item
        else
            return false

createNRDBSearchLink = (conditions) ->
    start = "https://netrunnerdb.com/find/?q="
    cond_array = []
    for cond in conditions
        cond.op = ":" if cond.op == "="
        cond_array.push encodeURIComponent(cond.key + cond.op + cond.value)
    return start + cond_array.join "+"


module.exports = (robot) ->
    # delay preload to give the app time to connect to redis
    setTimeout ( ->
        preloadData(robot)
    ), 1000

    robot.hear /\[\[([^\]\|]+)\]\]/, (res) ->
        # ignore card searches in #keyforge
        if res.message.room == 'CC0S7SXGQ'
            return

        query = res.match[1].replace /^\s+|\s+$/g, ""

        locale = "en"
        hangul = new RegExp("[\u1100-\u11FF|\u3130-\u318F|\uA960-\uA97F|\uAC00-\uD7AF|\uD7B0-\uD7FF]");
        if hangul.test(query)
            locale = "kr"

        card = lookupCard(query, robot.brain.get('cards-' + locale), locale)
        robot.logger.info "Searching NRDB for card #{query} (from #{res.message.user.name} in #{res.message.room})"
        robot.logger.info "Locale: " + locale

        if card
            formattedCard = formatCard(card, robot.brain.get('packs-' + locale), robot.brain.get('cycles-' + locale), robot.brain.get('types-' + locale), robot.brain.get('factions-' + locale), robot.brain.get('mwl-' + locale), robot.brain.get('imageUrlTemplate-' + locale), locale)
            # robot.logger.info formattedCard
            res.send
                as_user: true
                attachments: [formattedCard]
                username: res.robot.name
        else
            res.send "No Netrunner card result found for \"" + res.match[1] + "\"."

    robot.hear /{{([^}\|]+)}}/, (res) ->
        # ignore card searches in #keyforge
        if res.message.room == 'CC0S7SXGQ'
            return
        query = res.match[1].replace /^\s+|\s+$/g, ""

        locale = "en"
        hangul = new RegExp("[\u1100-\u11FF|\u3130-\u318F|\uA960-\uA97F|\uAC00-\uD7AF|\uD7B0-\uD7FF]");
        if hangul.test(query)
            locale = "kr"

        card = lookupCard(query, robot.brain.get('cards-' + locale), locale)
        robot.logger.info "Searching NRDB for card image #{query} (from #{res.message.user.name} in #{res.message.room})"
        robot.logger.info "Locale: " + locale

        if card
            if card.image_url
                res.send card.image_url.replace('https', 'http')
            else
                res.send robot.brain.get('imageUrlTemplate-' + locale).replace /\{code\}/, card.code
        else
            res.send "No Netrunner card result found for \"" + res.match[1] + "\"."

    robot.hear /^!jank\s?(runner|corp)?$/i, (res) ->
        side = res.match[1]
        cards = robot.brain.get('cards-en')
        packs = robot.brain.get('packs-en')
        cycles = robot.brain.get('cycles-en')
        bannedCards = robot.brain.get('bannedCards-en')

        if !side?
            randomside = Math.floor(Math.random() * 2)
            if randomside is 0
                side = "runner"
            else
                side = "corp"
        else
            side = side.toLowerCase()

        sidecards = cards.filter((card) ->
            return card.side_code == side && cycles[packs[card.pack_code].cycle_code].position != 0 && !cycles[packs[card.pack_code].cycle_code].rotated && card.title not in bannedCards && packs[card.pack_code].date_release != null
        )
        identities = sidecards.filter((card) ->
            return card.type_code == "identity"
        )
        sideNonIDCards = sidecards.filter((card) ->
            return card.type_code != "identity"
        )

        randomIdentity = Math.floor(Math.random() * identities.length)
        identityCard = identities[randomIdentity]

        numberOfCards = 3
        cardString = identityCard.title

        for num in [1..numberOfCards]
            do (num) ->
                randomCard = {}
                while true
                    randomCard = sideNonIDCards[Math.floor(Math.random() * sideNonIDCards.length)]
                    break if (randomCard.type_code != "agenda" || (randomCard.type_code == "agenda" && (randomCard.faction_code == identityCard.faction_code || randomCard.faction_code == "neutral"))) && (identityCard.code != "03002" || (identityCard.code == "03002" && randomCard.faction_code != "jinteki"))
                cardString += " + " + randomCard.title

        res.send cardString

    robot.hear /^!rngkey (\d+)$/i, (res) ->
      # get the guess
      guess = parseInt(res.match[1])

      # get legal accesses from a corp
      packs = robot.brain.get('packs-en')
      cycles = robot.brain.get('cycles-en')
      bannedCards = robot.brain.get('bannedCards-en')
      cards = robot.brain.get('cards-en').filter((card) ->
        return card.side_code == "corp" && cycles[packs[card.pack_code].cycle_code].position != 0 && !cycles[packs[card.pack_code].cycle_code].rotated && card.title not in bannedCards && packs[card.pack_code].date_release != null && card.type_code != "identity"
      )

      # pick the random access
      access = cards[Math.floor(Math.random() * cards.length)]

      #determine the result
      if access.type_code == "agenda"
        cost = access.advancement_cost
        emoji = ":rez:"
      else if access.type_code in ["asset", "operation", "ice", "upgrade"]
        cost = access.cost
        emoji = ":credit:"

      if cost == guess
        result = "you win!"
      else
        result = "you lose!"

      res.send "You guessed: " + guess + ". You accessed " + access.title + "! That's " + cost + emoji + ", " + result

    # robot.hear /^!mwl$/i, (res) ->
    #     mwl = robot.brain.get('mwl-en')
    #     restrictedCards = robot.brain.get('restrictedCards-en')
    #     bannedCards = robot.brain.get('bannedCards-en')

    #     message = "Current MWL: " + mwl.name + "\n"
    #     message += "Restricted Cards:\n"
    #     for card in restrictedCards
    #         message += "● " + card + "\n"
    #     message += "Banned Cards:\n"
    #     for card in bannedCards
    #         message += "● " + card + "\n"
    #     res.send message

    robot.hear /^!find (.*)/, (res) ->
        conditions = []
        for part in res.match[1].toLowerCase().match(/(([etsfxpondaiuygvc])([:=<>!])([-\w]+|\".+?\"))+/g)
            if out = part.match(/([etsfxpondaiuygvc])([:=<>!])(.+)/)
                if out[2] in ":=!".split("") || out[1] in "ponygvc".split("")
                    conditions.push({ key: out[1], op: out[2], value: out[3] })

        return res.send("Sorry, I didn't understand :(") if !conditions || conditions.length < 1

        results = []
        packs = robot.brain.get('packs-en')
        cycles = robot.brain.get('cycles-en')
        for card in robot.brain.get('cards-en')
            valid = true
            for cond in conditions
                valid = valid && cardMatches(card, cond, packs, cycles)
            results.push(card.title) if valid

        total = results.length
        if total > 10
            res.send("Found #{results[0..9].join(", ")} and <" + createNRDBSearchLink(conditions) + "|#{total - 10} more>")
        else if total < 1
            res.send("Couldn't find anything :|")
        else
            res.send("Found #{results.join(", ")}")
