module Common

  def menu_style value
    {:class => @item[:menu] == value ? "current_page_item" : ""}
  end

end

