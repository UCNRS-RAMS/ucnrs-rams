class Waiver < Struct.new(:id, :name, :description, :pdf_link)
  def self.fake
    [
      Waiver.new(1, "Main Waiver", "If you plan to visit more than one reserve, you may use this Multi-Reserve waiver form.", "pdf_link01"),
      Waiver.new(2, "Main Waiver (Spanish)", "Renuncia de responsabilidad, asunción de riesgo y acuerdo de indemnización.", "pdf_link02"),
      Waiver.new(3, "Group Signature Form", "If you have a group of adults, you may attach this Group Signature Form to the Reserve Waiver.", "pdf_link03"),
      Waiver.new(4, "Multi-Reserve Waiver", "If you plan to visit more than one reserve, you may use this Multi-Reserve waiver form.", "pdf_link04"),
      Waiver.new(5, "Photo Consent Form", "Consent for the University to use all and any images or sounds of you appearing in photographs, videos, or audio tape recordings taken on the reserve.", "pdf_link05"),
    ]
  end
end
