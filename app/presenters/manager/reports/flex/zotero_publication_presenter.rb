# frozen_string_literal: true

class Manager::Reports::Flex::ZoteroPublicationPresenter
  RESERVE_IDS = [323578, 323540, 323588, 323544, 323477, 323487, 323551, 323560,
    323558, 323548, 323478, 323541, 323573, 323582, 323481, 323489, 323539, 323566,
    323484, 323585, 323563, 2395930, 323577, 323596, 323559, 2395929, 323576, 323586,
    323549, 323554, 323488, 323583, 323556, 323565, 323592, 323581, 323562, 323552, 323593,
    323591, 323570].freeze

  def reserve_ids
    RESERVE_IDS
  end

  def item_type_options
    [
      ["book"], ["bookSection"], ["journalArticle"], ["magazineArticle"], ["newspaperArticle"],
      ["thesis"], ["manuscript"], ["patent"], ["webpage"], ["computerProgram"], ["filmRecording"],
      ["interview"], ["podcast"], ["letter"], ["email"], ["attachment"], ["note"]
    ]
  end
end
